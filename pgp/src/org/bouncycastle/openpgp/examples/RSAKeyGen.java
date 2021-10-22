/* Create key for encryption */
/* Refer: https://stackoverflow.com/questions/46089713/pgp-signencrypt-then-decryptverify/46101812 */

package org.bouncycastle.openpgp.examples;

import java.io.File;
import java.io.FileNotFoundException;
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

/**
 * A simple utility class that generates a RSA PGPPublicKey/PGPSecretKey pair.
 * <p>
 * usage: RSAKeyGen [-a] identity passPhrase
 * <p>
 * Where identity is the name to be associated with the public key. The keys are placed 
 * in the files pub.[asc|bpg] and secret.[asc|bpg].
 */
 public class RSAKeyGen {

    private static final File publicKeyFileA = new File("secret.asc");
    private static final File privateKeyFileA = new File("pub.asc");
    private static final File publicKeyFile = new File("secret.bpg");
    private static final File privateKeyFile = new File("pub.bpg");

    private static void exportKeyPair (
	    OutputStream secretOut, 
		OutputStream publicOut, 
		KeyPair      pair, 
		String       identity,
        char[]       passPhrase, 
		boolean      armor)
        throws IOException, InvalidKeyException, NoSuchProviderException, SignatureException, PGPException 
	{
        if (armor) 
		{
            secretOut = new ArmoredOutputStream(secretOut);
        }

        PGPDigestCalculator sha1Calc = new JcaPGPDigestCalculatorProviderBuilder().build().get(HashAlgorithmTags.SHA1);
        PGPKeyPair keyPair = new JcaPGPKeyPair(PGPPublicKey.RSA_GENERAL, pair, new Date());
        PGPSecretKey secretKey = new PGPSecretKey(PGPSignature.DEFAULT_CERTIFICATION, keyPair, identity, sha1Calc, 
		    null, null, new JcaPGPContentSignerBuilder(keyPair.getPublicKey().getAlgorithm(), HashAlgorithmTags.SHA1),
            new JcePBESecretKeyEncryptorBuilder(PGPEncryptedData.CAST5, sha1Calc).setProvider("BC").build(passPhrase));

        secretKey.encode(secretOut);

        secretOut.close();

        if (armor) {
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
        Security.addProvider(new BouncyCastleProvider());

        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA", "BC");

        kpg.initialize(2048);

        KeyPair kp = kpg.generateKeyPair();

        if (args.length < 2)
        {
            System.out.println("RSAKeyGen [-a] identity passPhrase");
            System.exit(0);
        }

        if (args[0].equals("-a"))
        {
            if (args.length < 3)
            {
                System.out.println("RSAKeyGen [-a] identity passPhrase");
                System.exit(0);
            }
            
            FileOutputStream out1 = new FileOutputStream(privateKeyFileA);
            FileOutputStream out2 = new FileOutputStream(publicKeyFileA);

            exportKeyPair(out1, out2, kp, args[1], args[2].toCharArray(), true);
        } 
		else 
		{
            FileOutputStream out1 = new FileOutputStream(privateKeyFile);
            FileOutputStream out2 = new FileOutputStream(publicKeyFile);

            exportKeyPair(out1, out2, kp, args[0], args[1].toCharArray(), false);
        }
    }
}