EXCSQL Command
Allows the programmer to execute any SQL command without
having to use a pre-canned QMQRY member.
The principle is
feature of QMQRY to bypass this limitation of the AS/400.
This command can be executed from the command line
RPG or any other language. One point to watch out for
simply executes the SQL statement give to it. No syntax
checking is done up front.
To get this command up and running
in a source file (SRCPF) on your AS/400.
QMQRYBLDR is of type CLP
QMQRYCLP is of type CLP
QMQRYCMD is of type CMD
QMQRYGEN is of type TXT
Compile QMQRYBLDR as a CL and run it using the parameters:
Source file
Voila! You are ready to SQL on your AS/400. This command
can accomodate SQL statements up to 550 characters long.
