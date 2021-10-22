Encryption    Signing	     Decryption	    Verifying
==========    =======        ==========     =========
public        secret, pass   secret, pass   public
encrypt                                     master


javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/DSAElGamalKeyRingGenerator.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DSAElGamalKeyRingGenerator -a Alan2 Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DSAElGamalKeyRingGenerator Alan2 Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/RSAKeyPairGenerator.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.RSAKeyPairGenerator -a "Alan Chan <cya012@promise.com.hk>" Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/RSAGen.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.RSAGen

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/RSAGen2.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.RSAGen2

gpg --list-packet dummy.pkr
gpg --list-packet dummy.skr

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/FileEncryptTest.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.FileEncryptTest -e
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.FileEncryptTest -d

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/ByteArrayHandler.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.ByteArrayHandler

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/PGPExampleUtil.java

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/ClearSignedFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.ClearSignedFileProcessor -s Test secret.asc Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.ClearSignedFileProcessor -v Test.asc pub.asc

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/DetachedSignatureProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DetachedSignatureProcessor -s -a Test secret.asc Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DetachedSignatureProcessor -v Test Test.asc public.asc

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/DirectKeySignature.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DirectKeySignature secret.asc Promise4 pub.asc notationName notationValue
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.DirectKeySignature SignedKey.asc

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/KeyBasedFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.KeyBasedFileProcessor -e -ai Test pub.asc
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.KeyBasedFileProcessor -d Test.asc secret.asc Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/KeyBasedLargeFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.KeyBasedLargeFileProcessor -e -ai Test pub.asc
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.KeyBasedLargeFileProcessor -d Test.asc secret.asc Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/PBEFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.PBEFileProcessor -e -ai Test Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.PBEFileProcessor -d Test.asc Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/PubringDump.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.PubringDump pub.asc

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/org/bouncycastle/openpgp/examples/SignedFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.SignedFileProcessor -s -a Test secret.asc Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" org.bouncycastle.openpgp.examples.SignedFileProcessor -v Test.asc public.asc

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" src/pgp/util/CmdProc3.java
javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15

to18-165.jar;lib/jt400.jar" src/pgp/util/CmdProc.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" pgp.util.CmdProc 1 PGP Test . *YES *YES dummy2.pkr 0X1234 *SIGN

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/assertj-core-2.9.1.jar;lib/junit-4.13.jar;lib/slf4j-api-1.7.30.jar;lib/bouncy-gpg-2.2.0.jar" src/be/codesandnotes/OpenPGP.java
javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/assertj-core-2.9.1.jar;lib/junit-4.13.jar;lib/slf4j-api-1.7.30.jar;lib/bouncy-gpg-2.2.0.jar" src/be/codesandnotes/Identities.java
javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/assertj-core-2.9.1.jar;lib/junit-4.13.jar;lib/slf4j-api-1.7.30.jar;lib/bouncy-gpg-2.2.0.jar" src/be/codesandnotes/OpenPGPTest.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/assertj-core-2.9.1.jar;lib/junit-4.13.jar;lib/slf4j-api-1.7.30.jar;lib/bouncy-gpg-2.2.0.jar" be.codesandnotes.OpenPGPTest



AS400 Only
==========
javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" src/hk/com/promise/openpgp/RSAKeyPairGenerator.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" hk.com.promise.openpgp.RSAKeyPairGenerator PGPDA 2048 -a secret public "Alan Chan <cya012@promise.com.hk>" Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" src/hk/com/promise/openpgp/DataArea.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" hk.com.promise.openpgp.DataArea

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" src/hk/com/promise/openpgp/PGPExampleUtil.java
javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" src/hk/com/promise/openpgp/KeyBasedLargeFileProcessor.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" hk.com.promise.openpgp.KeyBasedLargeFileProcessor -e -ai Test public.asc
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar;lib/jt400.jar" hk.com.promise.openpgp.KeyBasedLargeFileProcessor -d Test.asc secret.asc Promise4

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/hk/com/promise/openpgp/RSASignKeyPairGen.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.RSASignKeyPairGen 2048 24 promise_private  promise_public  "Promise (Hong Kong)" pgp@promise.com.hk Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.RSASignKeyPairGen 2048 24 hangseng_private hangseng_public "Hang Seng Bank"      pgp@hangseng.com   HangSeng5

javac -d bin -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" src/hk/com/promise/openpgp/KeyBasedSignFileProcess.java
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -es Promise_To_HangSeng hangseng_public promise_private  Promise4
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -dv Promise_To_HangSeng promise_public  hangseng_private HangSeng5
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -e Send_To_HangSeng hangseng_public
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -d Send_To_HangSeng hangseng_private HangSeng5

java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -e PromiseWithEncrypt Lyods_public

java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -e PromiseWithEncrypt hangseng_public
java -cp "bin;lib/bcpg-jdk15to18-165.jar;lib/bcprov-jdk15to18-165.jar" hk.com.promise.openpgp.KeyBasedSignFileProcess -d PromiseWithEncrypt hangseng_private HangSeng5
