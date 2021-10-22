package hk.com.promise.openpgp;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.security.SignatureException;
import java.util.Date;

import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openpgp.PGPEncryptedData;
import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPKeyPair;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPSecretKey;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.operator.PGPDigestCalculator;
import org.bouncycastle.openpgp.operator.jcajce.JcaPGPContentSignerBuilder;
import org.bouncycastle.openpgp.operator.jcajce.JcaPGPDigestCalculatorProviderBuilder;
import org.bouncycastle.openpgp.operator.jcajce.JcaPGPKeyPair;
import org.bouncycastle.openpgp.operator.jcajce.JcePBESecretKeyEncryptorBuilder;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400SecurityException;
import com.ibm.as400.access.CharacterDataArea;
import com.ibm.as400.access.ErrorCompletingRequestException;
import com.ibm.as400.access.ObjectDoesNotExistException;
import com.ibm.as400.access.QSYSObjectPathName;

/**
 * A simple utility class that generates a RSA PGPPublicKey/PGPSecretKey pair.
 * <p>
 * usage: RSAKeyPairGenerator AS400DataArea keySize [-a] secretKeyFile pubKeyFile identity passPhrase
 * <p>
 * Where identity is the name to be associated with the public key. The keys are placed
 * in the files pub.[asc|bpg] and secret.[asc|bpg].
 */
public class RSAKeyPairGenerator
{
    // AS400 warning message
    static String cpfWarningMessageID = null;
    static String cpfWarningMessage = null;

    private static void exportKeyPair(
        OutputStream    secretOut,
        OutputStream    publicOut,
        KeyPair         pair,
        String          identity,
        char[]          passPhrase,
        boolean         armor)
        throws IOException, InvalidKeyException, NoSuchProviderException, SignatureException, PGPException
    {
        if (armor)
        {
            secretOut = new ArmoredOutputStream(secretOut);
        }

        PGPDigestCalculator sha1Calc  = new JcaPGPDigestCalculatorProviderBuilder().build().get(HashAlgorithmTags.SHA1);
        PGPKeyPair          keyPair   = new JcaPGPKeyPair(PGPPublicKey.RSA_GENERAL, pair, new Date());
        PGPSecretKey        secretKey = new PGPSecretKey(PGPSignature.DEFAULT_CERTIFICATION, keyPair, identity, sha1Calc, null, null, new JcaPGPContentSignerBuilder(keyPair.getPublicKey().getAlgorithm(), HashAlgorithmTags.SHA256), new JcePBESecretKeyEncryptorBuilder(PGPEncryptedData.CAST5, sha1Calc).setProvider("BC").build(passPhrase));

        secretKey.encode(secretOut);

        secretOut.close();

        if (armor)
        {
            publicOut = new ArmoredOutputStream(publicOut);
        }

        PGPPublicKey key = secretKey.getPublicKey();

        key.encode(publicOut);

        publicOut.close();
    }

    public static void main(
        String[] args)
        throws Exception
    {
        // Assume an error condition. Only successful completion changes this.
        String cpfErrorMessageID = "PGP1001";
        String cpfErrorMessage = "Unknown error occurred.";

        // Connect to AS400 data area associated with invoking job
        // args[0]=Data area unique to invoking job.
        AS400 as400 = new AS400();
        as400.connectService(AS400.COMMAND);
        QSYSObjectPathName qpath = new QSYSObjectPathName("ALAN", args[0], "DTAARA");
        System.out.println(qpath.getPath());
        CharacterDataArea da = new CharacterDataArea(as400, qpath.getPath());

        Security.addProvider(new BouncyCastleProvider());

        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA", "BC");

        try
        {
            if (args.length < 6)
            {
                throw new Exception("PGP Key pair generation command parameters not enough.");
            }

            int keySize = Integer.parseInt(args[1]);

            kpg.initialize(keySize);
            KeyPair kp = kpg.generateKeyPair();

            if (args[2].equals("-a"))
            {
                if (args.length < 7)
                {
                    throw new Exception("PGP Key pair generation command parameters not enough.");
                }

                String out1Name = args[3].trim() + ".asc";
                String out2Name = args[4].trim() + ".asc";
                FileOutputStream out1 = new FileOutputStream(out1Name);
                FileOutputStream out2 = new FileOutputStream(out2Name);

                exportKeyPair(out1, out2, kp, args[5], args[6].toCharArray(), true);

                // Now it is safe to say that no errors occurred.
                cpfErrorMessageID = "       ";
                cpfErrorMessage = " ";

            }
            else
            {
                String out1Name = args[3].trim() + ".bpg";
                String out2Name = args[4].trim() + ".bpg";
                FileOutputStream out1 = new FileOutputStream(out1Name);
                FileOutputStream out2 = new FileOutputStream(out2Name);

                exportKeyPair(out1, out2, kp, args[4], args[5].toCharArray(), false);

                // Now it is safe to say that no errors occurred.
                cpfErrorMessageID = "";
                cpfErrorMessage = "";
            }
        }
        catch (NumberFormatException e)
        {
            cpfErrorMessageID = "PGP2003";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
            
        } catch (InvalidKeyException e) {
            cpfErrorMessageID = "PGP2004";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
            
        } catch (NoSuchProviderException e) {
            cpfErrorMessageID = "PGP2005";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
            
        } catch (SignatureException e) {
            cpfErrorMessageID = "PGP2006";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
            
        } catch (IOException e) {
            cpfErrorMessageID = "PGP2007";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
            
        } catch (PGPException e) {
            cpfErrorMessageID = "PGP2008";
            cpfErrorMessage = e.getMessage();
            System.err.println(e);
            if (e.getUnderlyingException() != null)
            {
                e.getUnderlyingException().printStackTrace();
            }
            
        } catch (Exception e) {
            System.err.println("usage: RSAKeyPairGenerator AS400DataArea keySize [-a] secretKeyFile pubKeyFile identity passPhrase");
            cpfErrorMessageID = "PGP2002";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
        }
        
        finally
        {
            try
            {
                System.out.println("debug: finally block: cpfErrorMessageID:" + cpfErrorMessageID + ", " + cpfErrorMessage);
                // Add Error message to AS400 Data Area
                if(!cpfErrorMessageID.isEmpty())
                {
                    System.out.println("debug: finally DA write: cpfErrorMessageID:" + cpfErrorMessageID + ", " + cpfErrorMessage);
                    da.write(cpfErrorMessageID, 0);
                    if(cpfErrorMessage.length() > 100)
                        cpfErrorMessage = cpfErrorMessage.substring(0, 100);
                    da.write(cpfErrorMessage, 7);
                }

                // Warning message
                if(cpfWarningMessageID != null)
                {
                    da.write(cpfWarningMessageID, 107);
                    if(cpfWarningMessage.length() > 100)
                        cpfWarningMessage = cpfWarningMessage.substring(0, 100);
                    da.write(cpfWarningMessage, 114);
                }
            }

            catch(AS400SecurityException | ErrorCompletingRequestException | InterruptedException | IOException | ObjectDoesNotExistException e)
            {
                cpfErrorMessageID = "PGP2009";
                cpfErrorMessage = e.getMessage();
                e.printStackTrace();
            }
        }
    }
}