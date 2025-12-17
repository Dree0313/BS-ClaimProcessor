*>Identifies the program
IDENTIFICATION DIVISION.
*>Name of the program
PROGRAM-ID. PROCESS-CLAIMS.

*>Describes external resources(files, devices, printers). Tells how program how to interact with the outside world
ENVIRONMENT DIVISION.
*>Subsection for handling files
INPUT-OUTPUT SECTION.
*>Defines local file names and how they map to physical files
FILE-CONTROL.
	*>Declares input file named CLAIM-FILE that physically maps to claims.csv
	SELECT CLAIM-FILE ASSIGN TO "claims.csv"
		*>Records are read top to bottom, no random access
		ORGANIZATION IS SEQUENTIAL.
	*>Declares output file name OUTPUT-FILE that physically maps to processed_claims.txt
	SELECT OUTPUT-FILE ASSIGN TO "processed_claims.txt"
		ORGANIZATION IS SEQUENTIAL.

*>Where all data structures live, definitions
DATA DIVISION.
*>Describes the record layout for each file
FILE SECTION.

*>FD - File Description, Associates a record structure with CLAIM-FILE
FD CLAIM-FILE.

*>Each line read from claims.csv, treated as raw text, 200 characters wide to be safe
01 CLAIM-RECORD	PIC X(200).

FD OUTPUT-FILE.
*> One output line, built manually using STRING
01 OUTPUT-RECORD	PIC X(200).

*>Program memory, variables live here, reset only when program restarts
WORKING-STORAGE SECTION.
*>Holds approval or rejection message, WS = Working Storage
01 WS-REASON		PIC X(50).
*>End-of-file flag, "N" = not done, "Y" = stop processing, loop control
01 EOF-FLAG		PIC X VALUE "N".
*>Parsed claim identifier, alphanumeric
01 WS-CLAIM-ID		PIC X(10).
*>Stored as text to avoid formatting issue
01 WS-MEMBER-ID		PIC X(5).
01 WS-CLAIM-DATE	PIC X(8).
*>Claim amount as text
01 WS-CLAIM-AMOUNT-TEXT	PIC X(6).
*>Numeric version of the claim amount, used for math and comparison
01 WS-CLAIM-AMOUNT	PIC 9(6).

*>Excecutable logic
PROCEDURE DIVISION.
*>Paragraph label, entry point of program logic
BEGIN.
	*>Opens both files, required before READ or WRITE
	OPEN INPUT CLAIM-FILE
	OPEN OUTPUT OUTPUT-FILE
	*>Main processing loop, runs until end of file reached
	PERFORM UNTIL EOF-FLAG = "Y"
		*>Reads one line into CLAIM-RECORD
		READ CLAIM-FILE
			*>Triggered when file ends, stops loop
			AT END
				MOVE "Y" TO EOF-FLAG
			*>Normal record processing path
			NOT AT END
				*>Splits the line on tab characters (X'09' = tab)
				UNSTRING CLAIM-RECORD DELIMITED BY X'09'
					*>Each column stored in respective variable
					INTO WS-CLAIM-ID, WS-MEMBER-ID, WS-CLAIM-DATE, WS-CLAIM-AMOUNT-TEXT
				END-UNSTRING
				*>Converts text to number
				COMPUTE WS-CLAIM-AMOUNT = FUNCTION NUMVAL(WS-CLAIM-AMOUNT-TEXT)
				*> Calls a reusable paragraph
				PERFORM PROCESS-RECORD
		*>Closes READ
		END-READ
	*>Closes loop
	END-PERFORM
	*>Clean shutdown, releases file handles, signals successful job completion
	CLOSE CLAIM-FILE
	CLOSE OUTPUT-FILE
	STOP RUN.

*>Encapsulates business logic
PROCESS-RECORD.
	*>Business rule, this is the claims policy logic
	IF WS-CLAIM-AMOUNT > 1000
		*>Sets rejection reason
		MOVE "REJECTED: Amount exceeds limit" TO WS-REASON
	*> Sets approval path
	ELSE
		MOVE "APPROVED" TO WS-REASON
	END-IF

	*>Builds output line Claim ID, tab
	STRING WS-CLAIM-ID DELIMITED BY SPACE
		X'09'
		*>Status message
		WS-REASON DELIMITED BY SPACE
		*>Newline
		X'0A'
		INTO OUTPUT-RECORD
	END-STRING
	*>Writes one line to output file
	WRITE OUTPUT-RECORD FROM CLAIM-RECORD AFTER ADVANCING 1 LINE
	.

*>Explicit program termination
END PROGRAM PROCESS-CLAIMS.
