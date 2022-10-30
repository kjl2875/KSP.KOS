// AutoFold Parts in Atmosphere. (defance broken parts software)
// run autofold_parts.ks(70000).
// 1. IF SHIP:ALTITUDE>=70000 THEN UNFOLD PARTS(ANTENA,SOLARPANEL)
// 2. ELSE IF SHIP:ALTITUDE<70000 THEN FOLD PARTS(ANTENA,SOLARPANEL)
// 3. AND IF ALT:RADAR<100 THEN UNFOLD PARTS(ANTENA,SOLARPANEL)
// 4. Exit is Ctrl+C.

parameter terminal_altitude.

UNTIL 0
{
	/// ACTION_NAME_POSTFIX

	SET ACTION_NAME_POSTFIX TO "전개".
	SET FLAG_FOLD TO (SHIP:ALTITUDE < terminal_altitude AND ALT:RADAR>=100).
	IF( FLAG_FOLD )
	{
		SET ACTION_NAME_POSTFIX TO "수납".
	}
	print ACTION_NAME_POSTFIX.

	/// SET ACTIONS

	SET antennas TO SHIP:PARTSNAMEDPATTERN(".*antenna.*"). // HighGainAntenna
	SET solars TO SHIP:PARTSNAMEDPATTERN(".*solar.*"). // solarPanels2
	FOR item IN antennas
	{
		SET ACTION_NAME TO "안테나 "+ACTION_NAME_POSTFIX. // TODO 안테나
		IF item:HASMODULE("ModuleDeployableAntenna")
		{
			SET module TO item:GETMODULE("ModuleDeployableAntenna").
			IF module:HASACTION(ACTION_NAME)
			{
				module:DOACTION(ACTION_NAME, True).
			}
		}
	}
	FOR item IN solars
	{
		SET ACTION_NAME TO "태양전지 "+ACTION_NAME_POSTFIX. // TODO 태양전지
		IF item:HASMODULE("ModuleDeployableSolarPanel")
		{
			SET module TO item:GETMODULE("ModuleDeployableSolarPanel").
			if( module:HASACTION(ACTION_NAME) )
			{
				module:DOACTION(ACTION_NAME, True).
			}
		}
	}

	// WAIT

	WAIT 1. // TODO 1
}
