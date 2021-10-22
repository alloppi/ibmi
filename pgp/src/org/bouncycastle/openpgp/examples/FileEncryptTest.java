/* Create key for encryption */
/* Refer: https://stackoverflow.com/questions/46089713/pgp-signencrypt-then-decryptverify/46101812 */

package org.bouncycastle.openpgp.examples;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.security.Security;
import java.util.Iterator;

import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.bcpg.BCPGOutputStream;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openpgp.PGPCompressedData;
import org.bouncycastle.openpgp.PGPCompressedDataGenerator;
import org.bouncycastle.openpgp.PGPEncryptedData;
import org.bouncycastle.openpgp.PGPEncryptedDataGenerator;
import org.bouncycastle.openpgp.PGPEncryptedDataList;
import org.bouncycastle.openpgp.PGPException;
import org.bouncycastle.openpgp.PGPLiteralData;
import org.bouncycastle.openpgp.PGPLiteralDataGenerator;
import org.bouncycastle.openpgp.PGPObjectFactory;
import org.bouncycastle.openpgp.PGPOnePassSignatureList;
import org.bouncycastle.openpgp.PGPPrivateKey;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPPublicKeyEncryptedData;
import org.bouncycastle.openpgp.PGPPublicKeyRing;
import org.bouncycastle.openpgp.PGPPublicKeyRingCollection;
import org.bouncycastle.openpgp.PGPSecretKey;
import org.bouncycastle.openpgp.PGPSecretKeyRing;
import org.bouncycastle.openpgp.PGPSecretKeyRingCollection;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureGenerator;
import org.bouncycastle.openpgp.PGPSignatureSubpacketGenerator;
import org.bouncycastle.openpgp.PGPUtil;
import org.bouncycastle.openpgp.operator.KeyFingerPrintCalculator;
import org.bouncycastle.openpgp.operator.PBESecretKeyDecryptor;
import org.bouncycastle.openpgp.operator.bc.BcKeyFingerprintCalculator;
import org.bouncycastle.openpgp.operator.bc.BcPublicKeyDataDecryptorFactory;
import org.bouncycastle.openpgp.operator.jcajce.JcaKeyFingerprintCalculator;
import org.bouncycastle.openpgp.operator.jcajce.JcaPGPContentSignerBuilder;
import org.bouncycastle.openpgp.operator.jcajce.JcePBESecretKeyDecryptorBuilder;
import org.bouncycastle.openpgp.operator.jcajce.JcePGPDataEncryptorBuilder;
import org.bouncycastle.openpgp.operator.jcajce.JcePublicKeyKeyEncryptionMethodGenerator;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

//
public class FileEncryptTest {
    private static File publicKeyFile = new File("public.asc");
    private static File privateKeyFile = new File("secret.asc");
    private static String privateKeyPassword = "Promise4";

    private static boolean isEncrypt = false;

    public static void main(String[] args) {
        Security.addProvider(new BouncyCastleProvider());

        if (args[0].equals("-e"))
        {
			isEncrypt = true;
		}
		else if (args[0].equals("-d"))
        {
			isEncrypt = false;
		} 
		else 
		{
			System.err.println("usage: FileEncryptTest -e|-d");
		}

        String outFileName = "Test.asc";
        String recoverFile = "Test.rec";
        OutputStream out = null;
        InputStream keyIn = null;
        InputStream outFileIn = null;
        String fileName = "Test";

        PGPPublicKey encKey = null;

        char[] passPhrase = privateKeyPassword.toCharArray();
        boolean armor = false;
        boolean withIntegrityCheck = true;

        if (isEncrypt) {
            try {
                keyIn = new BufferedInputStream(new FileInputStream(privateKeyFile));
                out = new BufferedOutputStream(new FileOutputStream(outFileName));
                encKey = readPublicKeyFromCol(new FileInputStream(publicKeyFile));
                //
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

                try {
                    signFile(fileName, keyIn, out, passPhrase, armor);

                    out = new BufferedOutputStream(new FileOutputStream(outFileName));

                } catch (GeneralSecurityException | IOException | PGPException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            encryptFile(outFileName, out, fileName, encKey, passPhrase, armor, withIntegrityCheck);
        } else {


            try {
                keyIn = new BufferedInputStream(new FileInputStream(privateKeyFile));
                outFileIn = new BufferedInputStream(new FileInputStream(outFileName));
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            decryptFile(outFileIn, keyIn, passPhrase, recoverFile);
        }
    }

    static final KeyFingerPrintCalculator FP_CALC = new BcKeyFingerprintCalculator();

    private static PGPPublicKey readPublicKeyFromCol(InputStream in) throws Exception {
        PGPPublicKeyRing pkRing = null;

        // PGPPublicKeyRingCollection pkCol = new PGPPublicKeyRingCollection(in,
        // FP_CALC);
        PGPPublicKeyRingCollection pkCol = new PGPPublicKeyRingCollection(PGPUtil.getDecoderStream(in), FP_CALC);
        System.out.println("key ring size=" + pkCol.size());
        Iterator it = pkCol.getKeyRings();
        while (it.hasNext()) {
            pkRing = (PGPPublicKeyRing) it.next();
            Iterator pkIt = pkRing.getPublicKeys();
            while (pkIt.hasNext()) {
                PGPPublicKey key = (PGPPublicKey) pkIt.next();
                System.out.println("Encryption key = " + key.isEncryptionKey() + ", Master key = " + key.isMasterKey());
                if (key.isEncryptionKey())
                    return key;
            }
        }
        return null;
    }

    public static void decryptFile(InputStream outFileIn, InputStream privKeyStream, char[] passPhrase, String outFileName) {
        // ----- Decrypt the file

        try {

            ByteBuffer buf = ByteBuffer.allocate(1024 * 10);
            byte[] read = new byte[1024];

            while (outFileIn.read(read, 0, 1024) != -1) {
                buf.put(read);
            }

            BASE64Encoder en = new BASE64Encoder();
            String temp = en.encode(buf.array());
            // System.out.println("Temp: " + temp);

            byte[] newB = null;
            BASE64Decoder en1 = new BASE64Decoder();
            try {
                newB = en1.decodeBuffer(temp);
            } catch (Exception e) {
                System.out.println("Exception: " + e);
            }
            ByteArrayInputStream bais = new ByteArrayInputStream(newB);
            decryptIt(bais, privKeyStream, passPhrase, outFileName);

        } catch (Exception e1) {

            e1.printStackTrace();
        }

    }


    private static PGPPrivateKey findSecretKey(InputStream keyIn, long keyID, char[] pass)
            throws IOException, PGPException, NoSuchProviderException {
        PGPSecretKeyRingCollection pgpSec = new PGPSecretKeyRingCollection(PGPUtil.getDecoderStream(keyIn), FP_CALC);
        PGPSecretKey pgpSecKey = pgpSec.getSecretKey(keyID);
        if (pgpSecKey == null) {
            return null;
        }
        PBESecretKeyDecryptor secretKeyDecryptor = new JcePBESecretKeyDecryptorBuilder()
                .setProvider(BouncyCastleProvider.PROVIDER_NAME).build(pass);

        return pgpSecKey.extractPrivateKey(secretKeyDecryptor);
    }

    private static void decryptIt(InputStream in, InputStream keyIn, char[] passwd, String filename) throws Exception {
        in = PGPUtil.getDecoderStream(in);
        try {
            PGPObjectFactory pgpF = new PGPObjectFactory(in, FP_CALC);
            PGPEncryptedDataList enc;
            Object o = pgpF.nextObject();
            //
            // the first object might be a PGP marker packet.
            //
            if (o instanceof PGPEncryptedDataList) {
                enc = (PGPEncryptedDataList) o;
            } else {
                enc = (PGPEncryptedDataList) pgpF.nextObject();
            }
            //
            // find the secret key
            //
            Iterator it = enc.getEncryptedDataObjects();
            PGPPrivateKey sKey = null;
            PGPPublicKeyEncryptedData pbe = null;
            while (sKey == null && it.hasNext()) {
                pbe = (PGPPublicKeyEncryptedData) it.next();
                System.out.println("pbe id=" + pbe.getKeyID());
                sKey = findSecretKey(keyIn, pbe.getKeyID(), passwd);
            }
            if (sKey == null) {
                throw new IllegalArgumentException("secret key for message not found.");
            }
            // InputStream clear = pbe.getDataStream(sKey, "BC");
            InputStream clear = pbe.getDataStream(new BcPublicKeyDataDecryptorFactory(sKey));
            PGPObjectFactory plainFact = new PGPObjectFactory(clear, FP_CALC);
            Object message = plainFact.nextObject();
            if (message instanceof PGPCompressedData) {
                PGPCompressedData cData = (PGPCompressedData) message;
                PGPObjectFactory pgpFact = new PGPObjectFactory(cData.getDataStream(), FP_CALC);
                message = pgpFact.nextObject();
            }
            // ByteArrayOutputStream baos = new ByteArrayOutputStream();
            BufferedOutputStream bout = new BufferedOutputStream(new FileOutputStream(filename));
            if (message instanceof PGPLiteralData) {
                PGPLiteralData ld = (PGPLiteralData) message;
                InputStream unc = ld.getInputStream();
                int ch;
                while ((ch = unc.read()) >= 0) {
                    bout.write(ch);
                }

            } else if (message instanceof PGPOnePassSignatureList) {
                throw new PGPException("encrypted message contains a signed message - not literal data.");
            } else {
                throw new PGPException("message is not a simple encrypted file - type unknown.");
            }

            bout.flush();
            bout.close();

            if (pbe.isIntegrityProtected()) {
                if (!pbe.verify()) {
                    System.err.println("message failed integrity check");
                } else {
                    System.err.println("message integrity check passed");
                }
            } else {
                System.err.println("no message integrity check");
            }
        } catch (PGPException e) {
            System.err.println(e);
            if (e.getUnderlyingException() != null) {
                e.getUnderlyingException().printStackTrace();
            }
        }
    }

    private static void encryptFile(String outFileName, OutputStream out, String fileName, PGPPublicKey encKey,
            char[] passPhrase, boolean armor, boolean withIntegrityCheck) {
        if (armor) {
            out = new ArmoredOutputStream(out);
        }

        ByteArrayOutputStream bOut = new ByteArrayOutputStream();
        System.out.println("creating comData...");
        // get the data from the original file
        PGPCompressedDataGenerator comData = new PGPCompressedDataGenerator(PGPCompressedDataGenerator.ZIP);
        try {
            PGPUtil.writeFileToLiteralData(comData.open(bOut), PGPLiteralData.BINARY, new File(fileName));
        } catch (IOException e) {

            e.printStackTrace();
        } finally {
            try {
                comData.close();
            } catch (IOException e) {

            }
        }

        PGPEncryptedDataGenerator encGen = new PGPEncryptedDataGenerator(
                new JcePGPDataEncryptorBuilder(PGPEncryptedData.CAST5).setWithIntegrityPacket(withIntegrityCheck)
                        .setSecureRandom(new SecureRandom()).setProvider("BC"));
        encGen.addMethod(new JcePublicKeyKeyEncryptionMethodGenerator(encKey).setProvider("BC"));

        byte[] bytes = bOut.toByteArray();
        OutputStream cOut;
        try {
            cOut = encGen.open(out, bytes.length);
            cOut.write(bytes);
        } catch (IOException | PGPException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            try {
                encGen.close();
                out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

        }

    }

    /**
     * A simple routine that opens a key ring file and loads the first available
     * key suitable for signature generation.
     *
     * @param input
     *            stream to read the secret key ring collection from.
     * @return a secret key.
     * @throws IOException
     *             on a problem with using the input stream.
     * @throws PGPException
     *             if there is an issue parsing the input stream.
     */
    static PGPSecretKey readSecretKey(InputStream input) throws IOException, PGPException {
        PGPSecretKeyRingCollection pgpSec = new PGPSecretKeyRingCollection(PGPUtil.getDecoderStream(input),
                new JcaKeyFingerprintCalculator());

        //
        // we just loop through the collection till we find a key suitable for
        // encryption, in the real
        // world you would probably want to be a bit smarter about this.
        //

        Iterator keyRingIter = pgpSec.getKeyRings();
        while (keyRingIter.hasNext()) {
            PGPSecretKeyRing keyRing = (PGPSecretKeyRing) keyRingIter.next();

            Iterator keyIter = keyRing.getSecretKeys();
            while (keyIter.hasNext()) {
                PGPSecretKey key = (PGPSecretKey) keyIter.next();

                if (key.isSigningKey()) {
                    return key;
                }
            }
        }

        throw new IllegalArgumentException("Can't find signing key in key ring.");
    }

    private static void signFile(String fileName, InputStream keyIn, OutputStream out, char[] pass, boolean armor)
            throws GeneralSecurityException, IOException, PGPException {
        if (armor) {
            out = new ArmoredOutputStream(out);
        }

        PGPSecretKey pgpSec = readSecretKey(keyIn);
        PGPPrivateKey pgpPrivKey = pgpSec
                .extractPrivateKey(new JcePBESecretKeyDecryptorBuilder().setProvider("BC").build(pass));
        PGPSignatureGenerator sGen = new PGPSignatureGenerator(
                new JcaPGPContentSignerBuilder(pgpSec.getPublicKey().getAlgorithm(), PGPUtil.SHA1).setProvider("BC"));

        sGen.init(PGPSignature.BINARY_DOCUMENT, pgpPrivKey);

        BCPGOutputStream bOut = new BCPGOutputStream(out);

        InputStream fIn = new BufferedInputStream(new FileInputStream(fileName));

        byte[] buf = new byte[1024];
        int len;
        while ((len = fIn.read(buf)) > 0) {
            sGen.update(buf, 0, len);
        }

        //int ch;
        //while ((ch = fIn.read()) >= 0) {
        //  sGen.update((byte) ch);
        //}

        fIn.close();

        sGen.generate().encode(bOut);

        if (armor) {
            out.close();
        }

        out.close();
        bOut.close();
    }
}