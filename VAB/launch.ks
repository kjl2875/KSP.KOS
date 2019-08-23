// LAUNCH V1 Snapshot-1
// Description) 액체연료엔진 1개와 고체연료 부스터를 효율적으로 사용하는 GravityTurn의 구현

// Note) 액체연료의 추력이 너무 쌔면 기체가 빨리 기울기 때문에 DRAG가 많이 올라가 ㄹ수 있다.
// Note) TARGET_AP값은 적어도 대기권높이를 초과하기를 권장한다. (커빈은 70km 초과)
// Note) 대기권을 통과한 직후 생성되는 메뉴버를 실행하는것은 수동으로 진행한다.
// Note) FUNCTION CREATE_CIRC_NODE Function => https://www.reddit.com/r/Kos/comments/5rp0w5/maneuver_nodes/

LOCK g TO KERBIN:MU/(KERBIN:RADIUS+SHIP:ALTITUDE)^2. // m/s^2
LOCK m TO SHIP:MASS. // tons
LOCK w TO g*m. // tons

// INIT THT,PIT,TARGET_AP.

SET THT TO 1.0.
SET PIT TO 90.
SET TARGET_AP TO 80000.

// LOCK STEERING, THROTTLE.

LOCK STEERING TO HEADING(90,PIT).
LOCK THROTTLE TO THT.

// LAUNCH.

STAGE.

// WAIT 100m/s AIRSPEED

UNTIL SHIP:AIRSPEED >= 100 {
    PRINT "AIRSPD = " + SHIP:AIRSPEED.
    WAIT 0.1.
}

// FUNC1. PIT = 85~0deg, AP = 0~TARGET_AP
// FUNC2. SOLIDFUEL OUT THEN STAGE ONCE.
// FUNC3. IF AP = 95%~100% THEN THROTTLE TO TWR1.1

SET USED_STAGE TO 0.

SET PIT TO 85.
UNTIL SHIP:ORBIT:APOAPSIS >= TARGET_AP {

    SET TARGET_AP_RATE TO SHIP:ORBIT:APOAPSIS/TARGET_AP.

    SET PIT TO 85 - TARGET_AP_RATE*85.

    IF( USED_STAGE = 0 ) {
        IF( SHIP:SOLIDFUEL = 0 ) {
            SET USED_STAGE TO 1.
            STAGE.
        }
    }

    IF( TARGET_AP_RATE >= 0.95 ) {
        SET THT TO w*1.1/SHIP:MAXTHRUST.
        IF( THT > 1.0 ) {
            SET THT TO 1.0.
        }
    }  ELSE {
        SET THT TO 1.
    }

    PRINT "PIT = " + ROUND(PIT,2) + ", THT = " + ROUND(THT,4) + ", AP = " + ROUND(SHIP:ORBIT:APOAPSIS,4).

    WAIT 0.1.
}

SET PIT TO 0.
SET TIT TO 0.

// FUNC1. WAIT ALT 70km
// FUNC2. IF AP = 0%~100% THEN THROTTLE = 100%~0%

UNTIL SHIP:ALTITUDE >= 70000 {

    SET TARGET_AP_RATE TO SHIP:ORBIT:APOAPSIS/TARGET_AP.
    SET THT TO 1 - TARGET_AP_RATE.
    PRINT "THT = " + ROUND(THT,2) + ", TARGET_AP_RATE = " + ROUND(TARGET_AP_RATE,2).

    WAIT 0.1.
}

SET THT TO 0.

// CREATE MANEUVER = CIRCULARIZE TO AP

FUNCTION CREATE_CIRC_NODE {
    // https://www.reddit.com/r/Kos/comments/5rp0w5/maneuver_nodes/

	// create maneuver node to circularize orbit after initial ascent

	PARAMETER targetOrbit.

	// calculate surface gravity
	// SurfaceGravity = GravitationalConstant * MassOfBody / RadiusOfBody^2
	// (GravitationalConstant * MassOfBody) is also known as the Gravitational Parameter - available in kOS as BODY:MU
	LOCAL srfcGravity IS ( BODY:MU/BODY:RADIUS^2 ).

	// calculate orbital speed for desired orbit
	// OrbitalSpeed = RadiusOfBody x SQRT ( Surface Gravity / ( Radius Of Body + Desired Orbit) )
	LOCAL orbitalSpeed IS ( BODY:RADIUS * SQRT(srfcGravity/(BODY:RADIUS+targetOrbit)) ).

	// calculate speed at current apoapsis
	// SpeedAtApoapsis = SQRT ( GravitationalConstant * MassOfBody * ( 2/RadiusOfShipsOrbit - 1/SemiMajorAxisOfShipsOrbit ) )
	// (GravitationalConstant * MassOfBody) is also known as the Gravitational Parameter - available in kOS as BODY:MU
	LOCAL speedAtApo IS SQRT ( BODY:MU * ( 2/(BODY:RADIUS+SHIP:APOAPSIS) - 1/SHIP:ORBIT:SEMIMAJORAXIS ) ).

	// calculate deltaV required to circularize
	// {deltaV to Circularize} = {Orbital Speed of Desired Orbit} - {Speed at Apoapsis of Current Orbit}
	LOCAL dvCirc IS orbitalSpeed-speedAtApo.

	// create maneuver node to circularize orbit
	LOCAL circNode IS NODE ( TIME:SECONDS+ETA:APOAPSIS, 0, 0, dvCirc).
	ADD circNode.

	PRINT "Circularization maneuver node created.".

	RETURN circNode.
}

CREATE_CIRC_NODE(TARGET_AP).

// EXECUTE NODE

// https://pastebin.com/LiNNxUgK
