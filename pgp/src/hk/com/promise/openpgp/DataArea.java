package hk.com.promise.openpgp;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400SecurityException;
import com.ibm.as400.access.CharacterDataArea;
import com.ibm.as400.access.ErrorCompletingRequestException;
import com.ibm.as400.access.ObjectDoesNotExistException;
import com.ibm.as400.access.QSYSObjectPathName;

public class DataArea
{
    public static void main(
        String[] args)
        throws Exception
    {
        // Prepare to work with the system named "Promise3".
        AS400 system = new AS400("localhost");
        system.connectService(AS400.COMMAND);

        // Create a CharacterDataArea object.
        QSYSObjectPathName path = new QSYSObjectPathName("ALAN", "MYDATA", "DTAARA");
        CharacterDataArea dataArea = new CharacterDataArea(system, path.getPath());

        // Create the character data area on the system using default values.
        dataArea.create();

        // Clear the data area.
        dataArea.clear();

        // Write to the data area.
        dataArea.write("Hello world");

        // Read from the data area.
        String data = dataArea.read();

        // Delete the data area from the system.
        // dataArea.delete();
    }
}