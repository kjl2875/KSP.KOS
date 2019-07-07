
// User Manual
// 1. tunning value of hdg and pit.
// 2. turn on engines.


// 방위 90도, 각도 15도
SET hdg TO 90.0.
SET pit TO 5.0.

LOCK STEERING TO HEADING(hdg,pit).
print "Lock steering.".

LOCK THROTTLE TO 1.0.
print "throttle to 1.0".

UNTIL ALT:RADAR>=1000 {
    print "Radar: " + ALT:RADAR.
    WAIT 0.1.
}

UNLOCK THROTTLE.
print "Unlock throttle.".
UNLOCK STEERING.
print "Unlock steering.".
