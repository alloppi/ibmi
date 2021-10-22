/* Create master signing key and sub-key for encryption */
/* Refer: https://bouncycastle-pgp-cookbook.blogspot.com/ */
/* Refer: https://www.codesandnotes.be/2018/07/17/openpgp-java-keys-generation/ */

package hk.com.promise.openpgp;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;

import java.math.BigInteger;

import java.security.SecureRandom;

import java.util.Date;

import org.bouncycastle.bcpg.ArmoredOutputStream;
import org.bouncycastle.bcpg.HashAlgorithmTags;
import org.bouncycastle.bcpg.SymmetricKeyAlgorithmTags;
import org.bouncycastle.bcpg.sig.Features;
import org.bouncycastle.bcpg.sig.KeyFlags;
import org.bouncycastle.crypto.generators.RSAKeyPairGenerator;
import org.bouncycastle.crypto.params.RSAKeyGenerationParameters;
import org.bouncycastle.openpgp.PGPEncryptedData;
import org.bouncycastle.openpgp.PGPKeyPair;
import org.bouncycastle.openpgp.PGPKeyRingGenerator;
import org.bouncycastle.openpgp.PGPPublicKey;
import org.bouncycastle.openpgp.PGPPublicKeyRing;
import org.bouncycastle.openpgp.PGPSecretKeyRing;
import org.bouncycastle.openpgp.PGPSignature;
import org.bouncycastle.openpgp.PGPSignatureSubpacketGenerator;
import org.bouncycastle.openpgp.operator.PBESecretKeyEncryptor;
import org.bouncycastle.openpgp.operator.PGPDigestCalculator;
import org.bouncycastle.openpgp.operator.bc.BcPBESecretKeyEncryptorBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPContentSignerBuilder;
import org.bouncycastle.openpgp.operator.bc.BcPGPDigestCalculatorProvider;
import org.bouncycastle.openpgp.operator.bc.BcPGPKeyPair;

/**
 * A simple utility class that generates a RSA PGP PublicKey/PGPSecretKey pair.
 * <p>
 * usage: RSASignKeyPairGen keySize secKeyFileName pubKeyFileName userIdName userIdEmail passPhrase
 * <p>
 * Where identity is the name to be associated with the public key. The keys are placed
 * in the files public.asc and secret.asc.
 */
 public class RSASignKeyPairGen
{
    private static final int CERTAINTY = 12;
    private static final BigInteger PUBLIC_EXPONENT = BigInteger.valueOf(0x10001);

    // Note: S2K_COUNT is a number between 0 and 0xff that controls the number of times to iterate
    // the password hash before use. More iterations are useful against off-line attacks,
    // as it takes more time to check each password. The actual number of iterations is rather
    // complex, and also depends on the hash function in use.
    // Refer to Section 3.7.1.3 in rfc4880.txt. Bigger numbers give you more iterations.
    // As a rough rule of thumb, when using SHA256 as the hashing function,
    // 0x10 gives you about 64 iterations, 0x20 about 128, 0x30 about 256 and so on till 0xf0,
    // or about 1 million iterations.
    // The maximum you can go to is 0xff, or about 2 million iterations.
    // Recommend using 0xc0 as a default -- about 130,000 iterations.
    private static final int S2K_COUNT = 0xc0;

    public static void main(String args[]) throws Exception {

        if (args.length < 6) {
            System.err.println("Usage: RSASignKeyPairGen keySize expiryMonths" +
                " secKeyFileName pubKeyFileName userIdName userIdEmail passPhrase");
            System.exit(0);
        }

        try {
            // args[0]=RSA Key Size
            // args[1]=Key Expiry Period in Months
            // args[2]=Private Key File Name
            // args[3]=Public Key File Name
            // args[4]=User name
            // args[5]=Email name
            // args[6]=Password for Private Key
            int keySize = Integer.parseInt(args[0]);
            int expiryMonths = Integer.parseInt(args[1]);
            String secKeyFileNameName = args[2] + ".asc";
            String pubKeyFileNameName = args[3] + ".asc";
            
            generateKeys(keySize, expiryMonths, secKeyFileNameName, pubKeyFileNameName, 
                args[4], args[5], args[6].toCharArray());
        } catch (NumberFormatException nfe) {
            System.err.println("keySize and expiryMonths must be numeric");
            System.exit(0);
        }
    }

    /**
     * generate both public and secret key pairs and write to its file
     *
     * @param keySize
     * @param expiryMonths
     * @param secKeyFileName
     * @param pubKeyFileName
     * @param userIdName
     * @param userIdEmail
     * @param pass
     * @throws Exception
     */
    private final static void generateKeys(int keySize, int expiryMonths, 
            String secKeyFileName, String pubKeyFileName,
            String userIdName, String userIdEmail, char[] pass) throws Exception {

        String identity = userIdName.trim() + " <" + userIdEmail.trim() + ">";
        PGPKeyRingGenerator keyRingGen = generateKeyRingGenerator(
            keySize, expiryMonths, identity, pass);

        // Generate public key ring, dump to file.
        PGPPublicKeyRing pubKeyRing = keyRingGen.generatePublicKeyRing();
        OutputStream pubOut = new BufferedOutputStream (new FileOutputStream(pubKeyFileName));
        pubOut = new ArmoredOutputStream(pubOut);
        pubKeyRing.encode(pubOut);
        pubOut.close();

        // Generate private key, dump to file.
        PGPSecretKeyRing secKeyRing = keyRingGen.generateSecretKeyRing();
        OutputStream secOut = new BufferedOutputStream (new FileOutputStream(secKeyFileName));
        secOut = new ArmoredOutputStream(secOut);
        secKeyRing.encode(secOut);
        secOut.close();
    }

    /**
     * generate both signing and encrypted key rings
     *
     * @param keySize
     * @param expiryMonths
     * @param identity
     * @param pass
     * @throws Exception
     */
    private final static PGPKeyRingGenerator generateKeyRingGenerator
            (int keySize, int expiryMonths, String identity, char[] pass) throws Exception {

        Date now = new Date();
        
        // Calculate expiry time to 2 years
        int expirySeconds = expiryMonths * 30 * 24 * 60 * 60;

        // This object generates individual key-pairs.
        RSAKeyPairGenerator keyPairGen = new RSAKeyPairGenerator();

        // Boilerplate RSA parameters, no need to change anything
        // except for the RSA key-size (2048). You can use whatever
        // key-size makes sense for you -- 4096, etc.
        keyPairGen.init(new RSAKeyGenerationParameters
            (PUBLIC_EXPONENT, new SecureRandom(), keySize, CERTAINTY));

        // First create the master signing key by the generator.
        PGPKeyPair signKeyPair = new BcPGPKeyPair(
            PGPPublicKey.RSA_SIGN, keyPairGen.generateKeyPair(), now);
            
        // Then an encryption sub-key.
        PGPKeyPair encyptKeyPair = new BcPGPKeyPair(
            PGPPublicKey.RSA_ENCRYPT, keyPairGen.generateKeyPair(), now);

        // 1) Create a self-signature on master signing key
        PGPSignatureSubpacketGenerator signKeyGen = new PGPSignatureSubpacketGenerator();

        // Add signed meta-data on the signature.
        // 1.1) Declare its purpose and set expiry time
        signKeyGen.setKeyFlags(false, KeyFlags.SIGN_DATA | KeyFlags.CERTIFY_OTHER);
        signKeyGen.setKeyExpirationTime(true, expirySeconds);
        // 1.2) Set preferences for secondary cryptography algorithms to use when sending messages
        //    to this key.
        signKeyGen.setPreferredSymmetricAlgorithms
            (false, new int[] {
                SymmetricKeyAlgorithmTags.AES_256,
                SymmetricKeyAlgorithmTags.AES_192,
                SymmetricKeyAlgorithmTags.AES_128
            });
        signKeyGen.setPreferredHashAlgorithms
            (false, new int[] {
                HashAlgorithmTags.SHA512,
                HashAlgorithmTags.SHA256,
                HashAlgorithmTags.SHA1,
                HashAlgorithmTags.SHA384,
                HashAlgorithmTags.SHA224
            });
        // 1.3) Request senders add additional checksums to the
        //      message (useful when verifying unsigned messages.)
        signKeyGen.setFeature(false, Features.FEATURE_MODIFICATION_DETECTION);

        // 2) Create a signature on the encryption sub-key
        PGPSignatureSubpacketGenerator encryptKeyGen = new PGPSignatureSubpacketGenerator();
        // Add signed meta-data on the signature
        // 2.1) Declare its purpose
        encryptKeyGen.setKeyFlags(false, KeyFlags.ENCRYPT_COMMS | KeyFlags.ENCRYPT_STORAGE);
        encryptKeyGen.setKeyExpirationTime(true, expirySeconds);

        // Objects used to encrypt the secret key.
        PGPDigestCalculator sha1Calc =
            new BcPGPDigestCalculatorProvider().get(HashAlgorithmTags.SHA1);
        PGPDigestCalculator sha256Calc =
            new BcPGPDigestCalculatorProvider().get(HashAlgorithmTags.SHA256);

        // 3) bcpg 1.48 exposes this API that includes S2K_COUNT. Earlier
        //    versions use a default of 0x60.
        PBESecretKeyEncryptor secKeyEncryptor =
            (new BcPBESecretKeyEncryptorBuilder
                (PGPEncryptedData.AES_256, sha256Calc, S2K_COUNT)).build(pass);

        // 4) Finally, create the keyring itself. The constructor takes parameters
        //    that allow it to generate the self signature.
        PGPKeyRingGenerator keyRingGen =
            new PGPKeyRingGenerator
                (PGPSignature.POSITIVE_CERTIFICATION, 
                 signKeyPair,
                 identity, 
                 sha1Calc, 
                 signKeyGen.generate(), 
                 null,
                 new BcPGPContentSignerBuilder
                    (signKeyPair.getPublicKey().getAlgorithm(), HashAlgorithmTags.SHA1),
                 secKeyEncryptor);

        // 5) Add encryption sub-key, together with its signature master key.
        keyRingGen.addSubKey(encyptKeyPair, encryptKeyGen.generate(), null);

        return keyRingGen;
    }
}