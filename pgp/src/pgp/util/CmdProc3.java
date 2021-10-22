package pgp.util;

import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openpgp.*;

import java.io.*;
import java.security.*;
import java.util.*;

import com.ibm.as400.access.*;

/*
    Copyright (c) 2000 - 2006 The Legion Of The Bouncy Castle (http://www.bouncycastle.org)
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute,
    sublicense, and/or sell copies of the Software, and to permit persons
    to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

public class CmdProc3
{
    // Optional "warning" message
    static String cpfWarningMessageID = null;
    static String cpfWarningMessage = null;
    
    
    private static void decryptFile(InputStream in, String destinationDir,
        InputStream secKeyFile, char[] passPhrase, String sigAction, InputStream sigKeyFile)
        throws IOException, NoSuchProviderException, PGPException
    {
        in = PGPUtil.getDecoderStream(in);
        PGPSecretKeyRingCollection pgpSec = new PGPSecretKeyRingCollection(PGPUtil.getDecoderStream(secKeyFile));

        PGPObjectFactory pgpF = new PGPObjectFactory(in);
        PGPEncryptedDataList enc;
        
        Object o = pgpF.nextObject();
        
        if (o instanceof PGPEncryptedDataList)
            enc = (PGPEncryptedDataList)o;
        else
            enc = (PGPEncryptedDataList)pgpF.nextObject();
            
        Iterator it = enc.getEncryptedDataObjects();
        PGPPrivateKey sKey = null;
        PGPPublicKeyEncryptedData pbe = null;
            
        while (sKey == null && it.hasNext())
        {
            pbe = (PGPPublicKeyEncryptedData)it.next();
            sKey = findSecretKey(pgpSec, pbe.getKeyID(), passPhrase);
        }
        
        if (sKey == null)
            throw new PGPException("Secret key for message not found.");
        
        InputStream clear = pbe.getDataStream(sKey, "BC");
        PGPObjectFactory plainFact = new PGPObjectFactory(clear);
        PGPCompressedData cData = (PGPCompressedData)plainFact.nextObject();
        
        InputStream compressedStream = new BufferedInputStream(cData.getDataStream());
        PGPObjectFactory pgpFact = new PGPObjectFactory(compressedStream);
        
        Object message = pgpFact.nextObject();
        
        PGPOnePassSignature ops = null;
        
        if (message instanceof PGPOnePassSignatureList)
        {
            if(!sigAction.equals("*IGNORE"))
            {
                try
                {
                    // Initialize for signature validation
                    ops = ((PGPOnePassSignatureList)message).get(0);
                    PGPPublicKeyRingCollection  pgpSigRing = new PGPPublicKeyRingCollection(PGPUtil.getDecoderStream(sigKeyFile));
                    PGPPublicKey key = pgpSigRing.getPublicKey(ops.getKeyID());
                    ops.initVerify(key, "BC");
                }
                 catch(Exception e)
                {
                    if(sigAction.equals("*WARN"))
                    {
                        ops = null;
                        cpfWarningMessageID = "PGP1007";
                        cpfWarningMessage = "Signature not validated. Output created but may be corrupt.";
                    }
                    else 
                    {
                        throw new PGPException("Signature not validated. Output not created.");
                    }
                }
            }
            
            try {
                message = pgpFact.nextObject();
            } catch(Exception e) {}
        }

        if (message instanceof PGPLiteralData)
        {
            PGPLiteralData ld = (PGPLiteralData)message;
            File outFile = new File(destinationDir + "/" + ld.getFileName());
            FileOutputStream fOut = new FileOutputStream(outFile);
            BufferedOutputStream bOut = new BufferedOutputStream(fOut);
            
            InputStream unc = ld.getInputStream();
            int ch;
            while ((ch = unc.read()) >= 0)
            {
                // Accumulate signature data
                if(ops != null)
                {
                    try
                    {
                        ops.update((byte)ch);
                    }
                    catch(Exception e)
                    {
                        if(sigAction.equals("*WARN"))
                        {
                            ops = null;
                            cpfWarningMessageID = "PGP1007";
                            cpfWarningMessage = "Signature not validated. Output file created but may be corrupt.";
                        }
                        else
                        {
                            throw new PGPException("Signature not validated. Output file in unknown state.");
                        }
                    }
                }
                
                bOut.write(ch);
            }
            bOut.close();

            // Signature validation
            if(ops != null)
            {
                try
                {
                    PGPSignatureList p3 = (PGPSignatureList)pgpFact.nextObject();
                    if (!ops.verify(p3.get(0)))
                    {
                        if(sigAction.equals("*WARN"))
                        {
                            cpfWarningMessageID = "PGP1007";
                            cpfWarningMessage = "Signature not validated. Output file created but may be corrupt.";
                        }
                        else
                        {
                            throw new PGPException("Signature not validated. Output file in unknown state.");
                        }
                    }
                
                }
                catch(Exception e)
                { 
                    if(sigAction.equals("*WARN"))
                    {
                        cpfWarningMessageID = "PGP1007";
                        cpfWarningMessage = "Signature not validated. Output file created but may be corrupt.";
                    }
                    else
                    {
                        throw new PGPException("Signature not validated. Output file in unknown state.");
                    }
                }
            }
        }
        else if (message instanceof PGPOnePassSignatureList)
        {
            throw new PGPException("Encrypted message contains a signed message - not literal data.");
        }
        else
        {
            throw new PGPException("Message is not a simple encrypted file - type unknown.");
        }
        
        if (pbe.isIntegrityProtected())
        {
            if (!pbe.verify())
                throw new PGPException("Message integrity check failed.");
        }
    }

    private static void encryptFile(OutputStream out, String fileName,
            PGPPublicKey encKey, boolean armor, boolean withIntegrityCheck)
            throws IOException, NoSuchProviderException, PGPException
    {
        if (armor)
            out = new ArmoredOutputStream(out);
        
        PGPEncryptedDataGenerator cPk = new PGPEncryptedDataGenerator(PGPEncryptedData.CAST5, withIntegrityCheck, new SecureRandom(), "BC");
        cPk.addMethod(encKey);
        OutputStream cOut = cPk.open(out, new byte[1 << 16]);
        
        PGPCompressedDataGenerator comData = new PGPCompressedDataGenerator(PGPCompressedData.ZIP);
        
        PGPUtil.writeFileToLiteralData(comData.open(cOut), PGPLiteralData.BINARY, new File(fileName), new byte[1 << 16]);
        
        comData.close();
        cOut.close();
        out.close();
    }
    
    private static void encryptAndSignFile(OutputStream out, String fileName,
            PGPPublicKey encKey, boolean armor, boolean withIntegrityCheck, PGPSecretKey sigKey, char[] sigPassPhrase  )
            throws IOException, NoSuchProviderException, PGPException, NoSuchAlgorithmException, SignatureException
    {
        int BUFFER_SIZE = 1 << 16;
        
        if (armor)
            out = new ArmoredOutputStream(out);
        
        PGPEncryptedDataGenerator cPk = new PGPEncryptedDataGenerator(PGPEncryptedData.CAST5, withIntegrityCheck, new SecureRandom(), "BC");
        cPk.addMethod(encKey);
        OutputStream cOut = cPk.open(out, new byte[BUFFER_SIZE]);
        
        PGPCompressedDataGenerator comData = new PGPCompressedDataGenerator(PGPCompressedData.ZIP);
        OutputStream compressedOut = comData.open(cOut);
        
        PGPPrivateKey pgpPrivKey = sigKey.extractPrivateKey(sigPassPhrase, "BC");
        PGPSignatureGenerator signatureGenerator = 
            new PGPSignatureGenerator(sigKey.getPublicKey().getAlgorithm(), HashAlgorithmTags.SHA1, "BC");
        signatureGenerator.initSign(PGPSignature.BINARY_DOCUMENT, pgpPrivKey);

        // Iterate to find first signature to use
        for (Iterator i = sigKey.getPublicKey().getUserIDs(); i.hasNext();) {
            String userId = (String) i.next();
            PGPSignatureSubpacketGenerator spGen = new PGPSignatureSubpacketGenerator();
            spGen.setSignerUserID(false, userId);
            signatureGenerator.setHashedSubpackets(spGen.generate());
            break;
        }
        
        signatureGenerator.generateOnePassVersion(false).encode(compressedOut);

        // Create the Literal Data generator output stream
        PGPLiteralDataGenerator literalDataGenerator = new PGPLiteralDataGenerator();
        
        // get file handle
        File actualFile = new File(fileName);
        InputStream contentStream = new FileInputStream(actualFile);
        
        // create output stream
        OutputStream literalOut = literalDataGenerator.open(compressedOut,
                PGPLiteralData.BINARY, actualFile.getName(),
        new Date(actualFile.lastModified()), new byte[BUFFER_SIZE]);
        
        // read input file and write to target file using a buffer
        byte[] buf = new byte[BUFFER_SIZE];
        int len;
        
        while ((len = contentStream.read(buf, 0, buf.length)) > 0) {
            literalOut.write(buf, 0, len);
            signatureGenerator.update(buf, 0, len);
        }

        literalOut.close();
        literalDataGenerator.close();
        
        signatureGenerator.generate().encode(compressedOut);
        compressedOut.close();
        comData.close();
        
        cOut.close();
        out.close();
        
        contentStream.close();
    }

    public static void main(String[] args) throws Exception
    {
        // Assume an error condition. Only successful completion changes this.
        String cpfErrorMessageID = "PGP1001";
        String cpfErrorMessage = "Unknown error occurred.";

        // Connect to iSeries data area associated with invoking job
        // args[1]=Data area unique to invoking job.
        AS400 as400 = new AS400();
        as400.connectService(AS400.COMMAND);
        CharacterDataArea da = new CharacterDataArea(as400, "/QSYS.LIB/QUSRTEMP.LIB/" + args[1].trim() +".DTAARA");
        
        try {
            Security.addProvider(new BouncyCastleProvider());
            
            // args[0]='1'=Encrypt, '2'=Decrypt
            if (args[0].equals("1"))
            {
                // args[2]=File to encrypt
                // args[3]=Target directory
                // args[4]=Armor *YES/*NO
                // args[5]=Integrity *YES/*NO
                // args[6]=Public Key file
                // args[7]=Key ID
                // args[8]=Signature action
                // args[9]=Signature key file
                // args[10]=Signature key ID
                // args[11]=Signature passphrase
                String ext = ".bpg";
                if(args[4].equals("*YES"))
                    ext = ".asc";
                    
                File f = new File(args[2]);
                
                if(!f.exists())
                    throw new FileNotFoundException("Cannot find file to encrypt.");
                    
                File outFile = new File(args[3]+ "/" + f.getName() + ext);
                
                FileInputStream keyIn = new FileInputStream(args[6]);
                FileOutputStream out = new FileOutputStream(outFile);
                FileInputStream sigKeyIn = null;
                if(args[8].equals("*SIGN")) {
                    sigKeyIn = new FileInputStream(args[9]);
                    encryptAndSignFile(out, args[2], readPublicKey(keyIn, args[7].toUpperCase()), (args[4].equals("*YES")), (args[5].equals("*YES")), readSigningKey(sigKeyIn, args[10].toUpperCase()), args[11].toCharArray());
                } else {
                    encryptFile(out, args[2], readPublicKey(keyIn, args[7].toUpperCase()), (args[4].equals("*YES")), (args[5].equals("*YES")));
                }
                
                // Now it is safe to say that no errors occurred.
                cpfErrorMessageID = "       ";
                cpfErrorMessage = " ";
            }
            
            if (args[0].equals("2"))
            {
                // args[2]=File to decrypt
                // args[3]=Target directory
                // args[4]=Not used
                // args[5]=Not used
                // args[6]=Secret Key file
                // args[7]=Passphrase
                // args[8]=Signature action
                // args[9]=Signature key file
                // args[10]=Not used
                // args[11]=Not used
                File f = new File(args[2]);
                if(!f.exists())
                    throw new FileNotFoundException("Cannot find file to decrypt.");
                
                FileInputStream in = new FileInputStream(args[2]);
                FileInputStream secKeyIn = new FileInputStream(args[6]);
                
                FileInputStream sigKeyIn = null;
                if(!args[8].equals("*IGNORE"))
                    sigKeyIn = new FileInputStream(args[9]);
                
                decryptFile(in, args[3], secKeyIn, args[7].toCharArray(), args[8], sigKeyIn);
                
                // Now it is safe to say that no errors occurred.
                cpfErrorMessageID = "    ";
                cpfErrorMessage = " ";
            }
        } catch (FileNotFoundException e) {
            cpfErrorMessageID = "PGP1003";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
        } catch (NoSuchProviderException e) {
            cpfErrorMessageID = "PGP1005";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
        } catch (IOException e) {
            cpfErrorMessageID = "PGP1004";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
        } catch (PGPException e) {
            cpfErrorMessageID = "PGP1006";
            cpfErrorMessage = e.getMessage();
            System.err.println(e);
            if (e.getUnderlyingException() != null)
            {
                e.getUnderlyingException().printStackTrace();
            }
        } catch (Exception e) {
            cpfErrorMessageID = "PGP1002";
            cpfErrorMessage = e.getMessage();
            e.printStackTrace();
        }
        finally
        {
            try
            {
                // Error message
                da.write(cpfErrorMessageID, 0);
                if(cpfErrorMessage.length() > 100)
                    cpfErrorMessage = cpfErrorMessage.substring(0,100);
                da.write(cpfErrorMessage, 7);
                
                // Warning message
                if(cpfWarningMessageID != null)
                {
                    da.write(cpfWarningMessageID, 107);
                    if(cpfWarningMessage.length() > 100)
                        cpfWarningMessage = cpfWarningMessage.substring(0,100);
                    da.write(cpfWarningMessage, 114);
                }
            }
            catch(Exception e)
            {
                throw e;
            }
        }
    }
    
    private static PGPPublicKey readPublicKey(InputStream in, String desiredKey) 
        throws IOException, PGPException
    {
        in = PGPUtil.getDecoderStream(in);
        
        if(desiredKey.indexOf("0X") != -1)
            desiredKey = desiredKey.substring(desiredKey.indexOf("0X")+2);
        
        PGPPublicKeyRingCollection pgpPub = new PGPPublicKeyRingCollection(in);
        PGPPublicKey key = null;
        
        Iterator rIt = pgpPub.getKeyRings();

        boolean keyIDMatch = false;
        
        while (!keyIDMatch && rIt.hasNext())
        {
            PGPPublicKeyRing kRing = (PGPPublicKeyRing)rIt.next();    
            
            Iterator kIt = kRing.getPublicKeys();

            while (kIt.hasNext())
            {
                PGPPublicKey k = (PGPPublicKey)kIt.next();
                
                if(Long.toHexString(k.getKeyID()).toUpperCase().indexOf(desiredKey) != -1)
                    keyIDMatch = true;
                    
                if (k.isEncryptionKey())
                    key = k;
            }
        }
        
        if (key == null ||!keyIDMatch)
            throw new PGPException("Cannot find encryption key in key ring.");
            
        return key;
    }
    
    private static PGPSecretKey readSigningKey(InputStream in, String desiredKey) 
            throws IOException, PGPException
        {
            in = PGPUtil.getDecoderStream(in);
            
            if(desiredKey.indexOf("0X") != -1)
                desiredKey = desiredKey.substring(desiredKey.indexOf("0X")+2);
                
            PGPSecretKeyRingCollection pgpSec = new PGPSecretKeyRingCollection(in);
            PGPSecretKey key = null;
            
            Iterator rIt = pgpSec.getKeyRings();
            
            boolean keyIDMatch = false;
            
            while (!keyIDMatch && rIt.hasNext())
            {
                PGPSecretKeyRing kRing = (PGPSecretKeyRing)rIt.next();    
                
                Iterator kIt = kRing.getSecretKeys();
                
                while (kIt.hasNext())
                {
                    PGPSecretKey k = (PGPSecretKey)kIt.next();
                    
                    if(Long.toHexString(k.getKeyID()).toUpperCase().indexOf(desiredKey) != -1)
                        keyIDMatch = true;
                        
                    if (k.isSigningKey())
                        key = k;
                }
            }
            
            if (key == null ||!keyIDMatch)
                throw new PGPException("Cannot find signing key in key ring.");
                    
            return key;
        }

    private static PGPPrivateKey findSecretKey(PGPSecretKeyRingCollection pgpSec, long keyID, char[]pass)
        throws IOException, PGPException, NoSuchProviderException
    {
        PGPSecretKey pgpSecKey = pgpSec.getSecretKey(keyID);
        
        if (pgpSecKey == null)
            return null;
            
        return pgpSecKey.extractPrivateKey(pass, "BC");
    }
}
