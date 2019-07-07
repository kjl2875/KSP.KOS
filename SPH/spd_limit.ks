
// User Manual
// 1. stell flying your airplain.
// 2. tunning value of speed_limit and tht_max_offset.
// (tht_max_offset+ => more soft throttle, tht_max_offset- => more harder throttle)

SET speed_limit TO 200.
SET tht_max_offset TO 30.
SET tht TO 0.

LOCK THROTTLE TO tht.

UNTIL FALSE {
    SET spd_offset TO speed_limit - AIRSPEED.
    IF( spd_offset < 0 ) {
        SET tht TO 0.
    } ELSE {
        SET tht TO spd_offset/tht_max_offset.
    }
}

UNLOCK THROTTLE.
