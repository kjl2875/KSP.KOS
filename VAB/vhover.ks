/// Subject 1. VAB에서 나온 로켓 공중에 호버링 하기
LOCK STEERING TO UP.
//UNLOCK STEERING.

/// Subject 1. Snapshot 1. target_altitude기준으로 engines ON/OFF
/// Test Result: Vector값이 무시되고 진행되기 때문에, target_altitude를 유지하지 못함.
SET tht TO 0.
SET target_altitude TO 100.
LOCK steering TO up.
LOCK throttle TO tht.
UNTIL FALSE {
    IF ship:altitude < target_altitude {
        SET tht TO 1.
    } ELSE {
        SET tht TO 0.
    }
}
//UNLOCK steering.
//UNLOCK throttle.


/// Subject 1. Snapshot 2. weight값 만큼만 throttle.
/// Test Result: 수직 상승속도가 조금 더 나온다. 전산 미분계산에 의한 오류 추측.

// body("kerbin")   VESSEL("TEST001")
//print body:mu. //scalar (m3s−2)
//print body:RADIUS. // scalar (m)
//print ship:altitude. // 해수면고도 (m)
LOCK g TO body:mu/(body:RADIUS+ship:altitude)^2. // gravity (m/s^2)
//print g.

//PRINT ship:mass. // tons
LOCK w TO ship:mass*g. // weight(tons)

LOCK tht TO w/maxthrust.
LOCK throttle to tht.


/// Subject 1. Snapshot 3. weight값 만큼만 throttle - 수직속도에 해당되는 throttle
/// Test Result: 수직 상승속도 0.05까지 줄고 아주 천천히 감속되는중. 전산 미분계산에 의한 오차로 추측.

LOCK g TO body:mu/(body:RADIUS+ship:altitude)^2. // gravity (m/s^2)
LOCK w TO ship:mass*g. // weight(tons)

LOCK tht TO (w-ship:verticalspeed*ship:mass)/maxthrust.
LOCK throttle to tht.

UNTIL false { PRINT ship:verticalspeed. WAIT 0.1. }


/// Subject 1. Snapshot 4. weight값 만큼만 throttle - 수직속도에 해당되는 throttle + 수직속도 0.5에 해당되는 throttle 감소
/// Test Result: 수직 상승속도 0.07까지 줄고 아주 천천히 감속되는중 Snapshot 3과 비슷함. 수직속도 throttle 배수값이 약한 것으로 추측.

STAGE.
LOCK STEERING TO UP.
LOCK g TO body:mu/(body:RADIUS+ship:altitude)^2. // gravity (m/s^2)

LOCK tht TO (ship:mass-ship:verticalspeed-0.05)*g/maxthrust.
LOCK throttle to tht.

UNTIL false { PRINT ship:verticalspeed. WAIT 0.1. }

/// Subject 1. Snapshot 5. weight값 만큼만 throttle - 수직속도에 해당되는 throttle (ship:verticalspeed => ship:verticalspeed^2)
/// Test Result: 수직 상승속도가 0.33정도로 오히려 증가함. 0이하의 실수를 제곱하면 값이 더 떨어지는게 문제.

STAGE.
LOCK STEERING TO UP.

LOCK g TO body:mu/(body:RADIUS+ship:altitude)^2. // gravity (m/s^2)

LOCK tht TO (ship:mass-(ship:verticalspeed^2))*g/maxthrust.
LOCK throttle to tht.

//UNTIL false { PRINT ship:verticalspeed. WAIT 0.1. }
UNTIL FALSE {
    // g,ship:mass,ship:verticalspeed,maxthrust
    PRINT ROUND(g,2) + "," + ROUND(ship:mass,2) + "," + ROUND(ship:verticalspeed,2) + "," + ROUND(maxthrust,2).
    WAIT 1.
}

/// Subject 1. Snapshot 6. weight값 만큼만 throttle - 수직속도에 해당되는 throttle (ship:verticalspeed^2 => CEILING(ship:verticalspeed)^2)
/// Test Result: 평균 수직속도 +-0.01m/s미만의 속도로 수직 호버링이 안정적임.

STAGE.
LOCK STEERING TO UP.

LOCK g TO body:mu/(body:RADIUS+ship:altitude)^2. // gravity (m/s^2)

LOCK tht TO (ship:mass-(CEILING(ship:verticalspeed)^2))*g/maxthrust.
LOCK throttle to tht.

UNTIL false { PRINT ship:verticalspeed. WAIT 0.1. }
