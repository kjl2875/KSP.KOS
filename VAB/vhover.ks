/// Subject 1. VAB에서 나온 로켓 공중에 호버링 하기
SET target_altitude TO 100.

/// Subject 1. Snapshot 1. target_altitude기준으로 engines ON/OFF
/// Test Result: Vector값이 무시되고 진행되기 때문에, target_altitude를 유지하지 못함.
SET tht TO 0.
LOCK steering TO up.
LOCK throttle TO tht.
UNTIL FALSE {
    IF ship:altitude < target_altitude {
        SET tht TO 1.
    } ELSE {
        SET tht TO 0.
    }
}
UNLOCK steering.
UNLOCK throttle.
