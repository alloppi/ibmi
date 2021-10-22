package be.codesandnotes;

import com.ibm.as400.access.*;

import org.bouncycastle.openpgp.PGPException;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.security.SignatureException;

import static org.assertj.core.api.Assertions.*;

public class OpenPGPCmd {

    // AS400 "warning" message
    static String cpfWarningMessageID = null;
    static String cpfWarningMessage = null;

    private static final Logger LOGGER = LoggerFactory.getLogger(OpenPGPTest.class);
    private static final SecureRandom SECURE_RANDOM;
    static {
        try {
            SECURE_RANDOM = SecureRandom.getInstanceStrong();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Could not initialize a strong secure random instance", e);
        }
    }

    private OpenPGP openPgp;

    @Before
    public void setUp() {
        openPgp = new OpenPGP(SECURE_RANDOM);
    }

    @Test
    public void generateJavaKeys() throws PGPException {

        OpenPGP.ArmoredKeyPair armoredKeyPair = openPgp
                .generateKeys(KEY_SIZE, JAVA_USER_ID_NAME, JAVA_USER_ID_EMAIL, JAVA_PASSPHRASE);

        assertThat(armoredKeyPair).hasNoNullFieldsOrProperties();

        LOGGER.info("java's private key ring:\n" + armoredKeyPair.privateKey());
        LOGGER.info("java's public key ring:\n" + armoredKeyPair.publicKey());
    }

    @Test
    public void generateAvajKeys() throws PGPException {

        OpenPGP.ArmoredKeyPair armoredKeyPair = openPgp
                .generateKeys(KEY_SIZE, AVAJ_USER_ID_NAME, AVAJ_USER_ID_EMAIL, AVAJ_PASSPHRASE);

        assertThat(armoredKeyPair).hasNoNullFieldsOrProperties();

        LOGGER.info("avaj's private key ring:\n" + armoredKeyPair.privateKey());
        LOGGER.info("avaj's public key ring:\n" + armoredKeyPair.publicKey());
    }

    @Test
    public void encryptSignedMessageAsJavaAndDecryptItAsAvaj() throws IOException, PGPException, NoSuchAlgorithmException, SignatureException, NoSuchProviderException {

        String unencryptedMessage = "Message from java to avaj: you're all backwards!";

        String encryptedMessage = openPgp.encryptAndSign(
                unencryptedMessage,
                JAVA_USER_ID_EMAIL,
                JAVA_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVA_PRIVATE_KEYS, JAVA_PUBLIC_KEYS),
                AVAJ_USER_ID_EMAIL,
                AVAJ_PUBLIC_KEYS);

        assertThat(encryptedMessage).isNotEmpty();

        LOGGER.info("java's encrypted message to avaj:\n" + encryptedMessage);

        String messageDecryptedByAvaj = openPgp.decryptAndVerify(
                encryptedMessage,
                AVAJ_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(AVAJ_PRIVATE_KEYS, AVAJ_PUBLIC_KEYS),
                JAVA_USER_ID_EMAIL,
                JAVA_PUBLIC_KEYS);

        assertThat(messageDecryptedByAvaj).isEqualTo(unencryptedMessage);
    }

    @Test
    public void encryptMessageAsJavascriptAndDecryptItAsJava() throws PGPException, SignatureException, NoSuchAlgorithmException, NoSuchProviderException, IOException {

        String unencryptedMessage = "Message from javascript to java: how's life in the back end?";

        String encryptedMessage = openPgp.encryptAndSign(
                unencryptedMessage,
                JAVASCRIPT_USER_ID_EMAIL,
                JAVASCRIPT_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVASCRIPT_PRIVATE_KEYS, JAVASCRIPT_PUBLIC_KEYS),
                JAVA_USER_ID_EMAIL,
                JAVA_PUBLIC_KEYS);

        assertThat(encryptedMessage).isNotEmpty();

        LOGGER.info("javascript's encrypted message to java:\n" + encryptedMessage);

        String messageDecryptedByJava = openPgp.decryptAndVerify(
                encryptedMessage,
                JAVA_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVA_PRIVATE_KEYS, JAVA_PUBLIC_KEYS),
                JAVASCRIPT_USER_ID_EMAIL,
                JAVASCRIPT_PUBLIC_KEYS);

        assertThat(messageDecryptedByJava).isEqualTo(unencryptedMessage);
    }

    @Test
    public void encryptMessageAsJavaAndDecryptItAsJavascript() throws PGPException, SignatureException, NoSuchAlgorithmException, NoSuchProviderException, IOException {

        String unencryptedMessage = "Message from java to javascript: how's life in the front end?";

        String encryptedMessage = openPgp.encryptAndSign(
                unencryptedMessage,
                JAVA_USER_ID_EMAIL,
                JAVA_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVA_PRIVATE_KEYS, JAVA_PUBLIC_KEYS),
                JAVASCRIPT_USER_ID_EMAIL,
                JAVASCRIPT_PUBLIC_KEYS);

        assertThat(encryptedMessage).isNotEmpty();

        LOGGER.info("java's encrypted message to javascript:\n" + encryptedMessage);

        String messageDecryptedByJavascript = openPgp.decryptAndVerify(
                encryptedMessage,
                JAVASCRIPT_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVASCRIPT_PRIVATE_KEYS, JAVASCRIPT_PUBLIC_KEYS),
                JAVA_USER_ID_EMAIL,
                JAVA_PUBLIC_KEYS);

        assertThat(messageDecryptedByJavascript).isEqualTo(unencryptedMessage);
    }

    @Test
    public void decryptJavascriptMessageToJava() throws IOException, PGPException, NoSuchProviderException {

        String decryptedMessage = openPgp.decryptAndVerify(
                JAVASCRIPT_ENCRYPTED_MESSAGE_TO_JAVA,
                JAVA_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVA_PRIVATE_KEYS, JAVA_PUBLIC_KEYS),
                JAVASCRIPT_USER_ID_EMAIL,
                JAVASCRIPT_PUBLIC_KEYS
        );

        assertThat(decryptedMessage).isEqualTo(JAVASCRIPT_UNENCRYPTED_MESSAGE_TO_JAVA);
    }

    @Test
    public void generateKeysAndEncryptAndDecryptMessage() throws PGPException, SignatureException, NoSuchAlgorithmException, NoSuchProviderException, IOException {

        OpenPGP.ArmoredKeyPair javaArmoredKeyPair = openPgp
                .generateKeys(KEY_SIZE, JAVA_USER_ID_NAME, JAVA_USER_ID_EMAIL, JAVA_PASSPHRASE);

        assertThat(javaArmoredKeyPair).hasNoNullFieldsOrProperties();

        OpenPGP.ArmoredKeyPair avajArmoredKeyPair = openPgp
                .generateKeys(KEY_SIZE, AVAJ_USER_ID_NAME, AVAJ_USER_ID_EMAIL, AVAJ_PASSPHRASE);

        assertThat(avajArmoredKeyPair).hasNoNullFieldsOrProperties();

        String unencryptedMessage = "Message from java to avaj: you're all backwards!";

        String encryptedMessage = openPgp.encryptAndSign(
                unencryptedMessage,
                JAVA_USER_ID_EMAIL,
                JAVA_PASSPHRASE,
                javaArmoredKeyPair,
                AVAJ_USER_ID_EMAIL,
                avajArmoredKeyPair.publicKey());

        assertThat(encryptedMessage).isNotEmpty();

        LOGGER.info("java's encrypted message to avaj:\n" + encryptedMessage);

        String messageDecryptedByAvaj = openPgp.decryptAndVerify(
                encryptedMessage,
                AVAJ_PASSPHRASE,
                avajArmoredKeyPair,
                JAVA_USER_ID_EMAIL,
                javaArmoredKeyPair.publicKey());

        assertThat(messageDecryptedByAvaj).isEqualTo(unencryptedMessage);
    }

    private static final String JAVASCRIPT_ENCRYPTED_MESSAGE_TO_JAVA = "-----BEGIN PGP MESSAGE-----\n" +
            "Version: OpenPGP.js v3.0.11\n" +
            "Comment: https://openpgpjs.org\n" +
            "\n" +
            "wcBMAw2t7NW0cb1oAQgAmSFw5kjMOoaWutOIDyE7i7T8NeZPV8Q3yAh+vqCP\n" +
            "FGSSLlEArsmAGacCdcYV1Cxanp7lgs775bjarEX8HIHrh8LuAM6cg9Tby4e7\n" +
            "NdCgJxTGQbdY9HErYYzCDJ0TOpVYAXn47SWTd2Dvdf3CdlOQkeJkgn61LekG\n" +
            "uI76y9LkrBDZhJYPL3HmG2+lK8+NKnQPt3Vg1dBks/j+9XrWXKuiYb4gWgP7\n" +
            "EtFwazpUJaRFqMFFUa9G1qPeZ6nlyMK19vL+sW5vaLRcl2iVv1WZdNU1aXBm\n" +
            "1E8pZ3b4C38QMbFq/iFrSsLxlSyBOXcmRiiddTgov1jwgq39tyGB6xbyXAE+\n" +
            "7dLA1gFr4PDnVn/Txhm11UfWy+bGWNsKBFCa5ifyBdgH7WdMVMQJuZ12HXNc\n" +
            "v14eUdc8cYSfRBUuRfnZjzkJZOBLuExbdJJIp2tGs0qTPzErGoVHi7u2hGNJ\n" +
            "NZpwD9EfguS8wzZ7xXmzD+LtoMjiRGB3EwJz46IZhXpUPOm+wydcht82p6aA\n" +
            "sBCqAK22YLltcTcOsXf9mND7GDe1tNd4N3oGV6kA1EyCJYg8T9eMOKtCg1Zp\n" +
            "joVnRq9tNV2HvhAzgDB90TJD8J97LmGZ425Ytn3QjvGS5dCUtFFjUC2KqcYv\n" +
            "+M5rxyD74V+9VbceFzVqaWIUywoRHqQfPFtgPAHfS7AqsiaabTq+KEocbwsK\n" +
            "EX5gFiPnnXBIU9xZe9AXHWty6z4srN/irAQMd+fLAXEis7ULidjnPE4u1A9L\n" +
            "jzK/q4MDXq3dbZ+KP3kbXGbfms8fErLT1UgcRvQv5tjvT25bSNlNVOSIV1LX\n" +
            "Tw5YIIyoYIo77XVqq+sORpEvy0ojcSu2HMt64403CLGVW2zEgcacITaiQu4u\n" +
            "GoCDncI=\n" +
            "=O0yP\n" +
            "-----END PGP MESSAGE-----\n";
    private static final String JAVASCRIPT_UNENCRYPTED_MESSAGE_TO_JAVA = "A message encrypted by javascript";

    public static void main(String[] args) throws Exception {

        // Assume an error condition. Only successful completion changes this.
        String cpfErrorMessageID = "PGP1001";
        String cpfErrorMessage = "Unknown error occurred.";

        // Connect to IBMi data area associated with invoking job
        AS400 as400 = new AS400();
        as400.connectService(AS400.COMMAND);
        CharacterDataArea da = new CharacterDataArea(as400, "/QSYS.LIB/QGPL.LIB/" + args[1].trim() + ".DTAARA");

        try {

            // args[0]='0'=Generate Key Pair, '1'=Encrypt, '2'=Decrypt
            if (args[0].equals("0")) {

                // args[1]=IBMi data area
                // args[2]=Key Size
                // args[3]=User Name
                // args[4]=User Email
                // args[5]=Passphrase

                int keySize = Integer.parseInt(args[2]);
                String javaUserIdName = args[3];
                String javaUserIdEmail = args[4];
                String javaPassphrase = args[5];

                OpenPGP.ArmoredKeyPair armoredKeyPair = openPgp
                    .generateKeys(keySize, javaUserIdName, javaUserIdEmail, javaPassphrase);

                assertThat(armoredKeyPair).hasNoNullFieldsOrProperties();

                LOGGER.info("java's private key ring:\n" + armoredKeyPair.privateKey());
                LOGGER.info("java's public key ring:\n" + armoredKeyPair.publicKey());
            }

            // Now it is safe to say that no errors occurred.
            cpfErrorMessageID = "       ";
            cpfErrorMessage = " ";
        }

            // args[0]='0'=Generate Key Pair, '1'=Encrypt, '2'=Decrypt
            if (args[0].equals("1")) {

                // args[1]=IBMi data area
                // args[2]=Unencrypted Message
                // args[3]=User Email
                // args[4]=Passphrase

        String unencryptedMessage = "Message from java to avaj: you're all backwards!";

        String encryptedMessage = openPgp.encryptAndSign(
                unencryptedMessage,
                JAVA_USER_ID_EMAIL,
                JAVA_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(JAVA_PRIVATE_KEYS, JAVA_PUBLIC_KEYS),
                AVAJ_USER_ID_EMAIL,
                AVAJ_PUBLIC_KEYS);

        assertThat(encryptedMessage).isNotEmpty();

        LOGGER.info("java's encrypted message to avaj:\n" + encryptedMessage);

        String messageDecryptedByAvaj = openPgp.decryptAndVerify(
                encryptedMessage,
                AVAJ_PASSPHRASE,
                OpenPGP.ArmoredKeyPair.of(AVAJ_PRIVATE_KEYS, AVAJ_PUBLIC_KEYS),
                JAVA_USER_ID_EMAIL,
                JAVA_PUBLIC_KEYS);

        assertThat(messageDecryptedByAvaj).isEqualTo(unencryptedMessage);

        // Now it is safe to say that no errors occurred.
        cpfErrorMessageID = "       ";
        cpfErrorMessage = " ";
      }

      // args[0]='1'=Encrypt, '2'=Decrypt
      if (args[0].equals("2")) {
        // args[1]=IBMi data area
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
        if (!f.exists()) {
          throw new FileNotFoundException("Cannot find file to decrypt.");
        }

        FileInputStream in = new FileInputStream(args[2]);
        FileInputStream secKeyIn = new FileInputStream(args[6]);

        FileInputStream sigKeyIn = null;
        if(!args[8].equals("*IGNORE")) {
          sigKeyIn = new FileInputStream(args[9]);
        }

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
      if (e.getUnderlyingException() != null) {
        e.getUnderlyingException().printStackTrace();
      }
    } catch (Exception e) {
      cpfErrorMessageID = "PGP1002";
      cpfErrorMessage = e.getMessage();
      e.printStackTrace();
    }

    finally {
      try {
        // Error message
        da.write(cpfErrorMessageID, 0);
        if (cpfErrorMessage.length() > 100) {
          cpfErrorMessage = cpfErrorMessage.substring(0, 100);
        }
        da.write(cpfErrorMessage, 7);

        // Warning message
        if (cpfWarningMessageID != null) {
          da.write(cpfWarningMessageID, 107);
          if (cpfWarningMessage.length() > 100) {
            cpfWarningMessage = cpfWarningMessage.substring(0, 100);
          }
          da.write(cpfWarningMessage, 114);
        }
      }
      catch(Exception e) {
        throw e;
      }
    }
  }
}
