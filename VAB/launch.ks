// LAUNCH V1 Snapshot-2
// Description) 액체연료엔진 1개와 고체연료 부스터를 효율적으로 사용하는 GravityTurn의 구현
// STAGE) 엔진점화 => 고체부스터 분리

// Note) 액체연료의 추력이 너무 쌔면 기체가 빨리 기울기 때문에 DRAG가 많이 올라가 ㄹ수 있다.
// Note) TARGET_AP값은 적어도 대기권높이를 1km이상 초과하기를 권장한다. (커빈은 70km 초과)
// Note) 생성된 메뉴버의 AP와 PE는 실제 수행시 오차가 꽤 있다.
// Note) FUNCTION CREATE_CIRC_NODE Function => https://www.reddit.com/r/Kos/comments/5rp0w5/maneuver_nodes/
// Note) Burntime 정확도가 약간 떨어지더라.

// INIT THT,PIT,TARGET_AP.

SET THT TO 1.0.
SET PIT TO 90.
SET TARGET_AP TO 80000.

// SET Gravity Config

LOCK g TO KERBIN:MU/(KERBIN:RADIUS+SHIP:ALTITUDE)^2. // m/s^2
LOCK m TO SHIP:MASS. // tons
LOCK w TO g*m. // tons

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
        SET THT TO w*1.1/SHIP:AVAILABLETHRUST.
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

// 메뉴버 노드관련 시간정보를 설정

LOCK STEERING TO NEXTNODE.
LOCK a TO SHIP:AVAILABLETHRUST/SHIP:MASS.
LOCK burntime TO NEXTNODE:DELTAV:MAG/a.

// 메뉴버 엔진점화포인트 근처까지 WARP

SET steering_time TO 15.
KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + NEXTNODE:ETA-burntime/2 - steering_time).

// 메뉴버포인트 지점 ETA영역에 들어올때 까지 대기.

UNTIL NEXTNODE:ETA-(burntime/2) <= 0 {
    PRINT "NODE_ETA: " + ROUND(NEXTNODE:ETA,2) + ", NODE_BURNTIME: " + ROUND(burntime,2).
    WAIT 0.1.
}

// DeltaV가 조금만 남을때까지 가속

SET THT TO 1.
UNTIL burntime <= 1 {
    PRINT "NEXTNODE:DELTAV:MAG = " + NEXTNODE:DELTAV:MAG.
    WAIT 0.1.
}

// 남은 DeltaV를 0에 수렴할 때 까지 가속

UNTIL NEXTNODE:DELTAV:MAG < 1.0 {
    SET THT TO w/SHIP:AVAILABLETHRUST.

    PRINT "NEXTNODE:DELTAV:MAG = " + NEXTNODE:DELTAV:MAG + ", THT = " + THT.
    WAIT 0.01.
}

UNTIL NEXTNODE:DELTAV:MAG < 0.1 {
    SET THT TO w/20/SHIP:AVAILABLETHRUST.

    PRINT "NEXTNODE:DELTAV:MAG = " + NEXTNODE:DELTAV:MAG + ", THT = " + THT.
    WAIT 0.01.
}

UNTIL NEXTNODE:DELTAV:MAG < 0.01 {
    SET THT TO w/200/SHIP:AVAILABLETHRUST.

    PRINT "NEXTNODE:DELTAV:MAG = " + NEXTNODE:DELTAV:MAG + ", THT = " + THT.
    WAIT 0.01.
}

// REMOVE MANEUVER

REMOVE NEXTNODE.

// 제어잠금 해제

UNLOCK THROTTLE.
UNLOCK STEERING.

// 종료알림음 재생

SET V0 TO GetVoice(0).
SET hz TO 800.
SET len TO 0.1.
V0:PLAY(NOTE(hz,len)).
WAIT 1.
V0:PLAY(NOTE(hz,len)).
WAIT 1.
V0:PLAY(NOTE(hz,len)).
WAIT 1.
V0:PLAY(NOTE(hz,len)).
WAIT 1.
V0:PLAY(NOTE(hz,len)).
WAIT 1.
V0:PLAY(NOTE(hz,2)).
