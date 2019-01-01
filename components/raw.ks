<Connection RECEIVER>
<Connection SENDER>
<CLEAR LINE>
<TERMINAL INPUT STRING>
<FWRITE>
<RemoteTech Antenna Control Example>




<RemoteTech Antenna Control Example>

IF NOT addons:available("RT") {
	PRINT "ERROR: RemoteTech Addon is not available".
}

IF SHIP:PARTSNAMED("SurfAntenna"):LENGTH > 0 {
	PRINT "SurfAntenna: " + SHIP:PARTSNAMED("SurfAntenna"):LENGTH.
}

SET P TO SHIP:PARTSNAMED("SurfAntenna")[0].
SET M TO P:GETMODULE("ModuleRTAntenna").
//PRINT M:ALLEVENTNAMES.
//PRINT M:ALLFIELDS.
//PRINT ADDONS:RT:AVAILABLE.
//PRINT ADDONS:RT:GROUNDSTATIONS().

M:SETFIELD("target", "Mission Control").
//M:SETFIELD("target", mun).
//M:SETFIELD("target", somevessel).
//M:SETFIELD("target", "minmus").


<FWRITE>

CREATE("0:/log").
SET F TO OPEN("0:/log").
F:WRITELN("ENTER").
F:WRITELN("ENTER").
F:WRITELN("ENTER").

<TERMINAL INPUT STRING>

SET str TO "".
until false {
    if (terminal:input:haschar) {
        set input to terminal:input:getchar().
        if unchar(input) = 13 { // enter
            PRINT str.
			SET str TO "".
        }
        else {
            //print "Input read was: " + input + " (ascii " + unchar(input) + ")".
			SET str TO str + input.
        }
    }
    wait 0.
}


<CLEAR LINE>

SET cline TO "".
FROM {local x is terminal:width.} UNTIL x = 0 STEP {set x to x-1.} DO {
  SET cline TO cline + " ".
}

PRINT cline AT (0,0).

<Connection SENDER>

SET C TO VESSEL("B"):CONNECTION.
PRINT "Delay is " + C:DELAY + "seconds".

SET MESSAGE TO "HELLO".
IF C:SENDMESSAGE(MESSAGE) {
	PRINT "SEND MESSAGE: OK".
} ELSE {
	PRINT "SEND MESSAGE: FAIL".
}

<Connection RECEIVER>

IF NOT SHIP:MESSAGES:EMPTY {
	SET RECEIVED TO SHIP:MESSAGES:POP.
	PRINT "Sent by " + RECEIVED:SENDER:NAME + " at " + RECEIVED:SENTAT.
	PRINT RECEIVED:CONTENT.
}

