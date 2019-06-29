// 살짝떠서, 부드러운 착지가 필요합니다.

LOCK target_alt_offset TO target_alt - SHIP:APOAPSIS.
LOCK g TO body:mu / (altitude + body:radius)^2. // get current planet gravity: g = 현재행성:중력계수 / (고도 + 현재행성:반지름)^2
LOCK gm TO g * SHIP:MASS.

LOCK STEERING TO UP.
LOCK THROTTLE TO 1.0.

STAGE.
GEAR OFF.
wait(5.0).

LOCK THROTTLE TO -gm*(verticalspeed+5). // 연료를 너무 끊어서 쏨
GEAR ON.


//UNLOCK THROTTLE.
//UNLOCK STEERING.
