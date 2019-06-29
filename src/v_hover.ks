// 어떻게든 고도 1KM를 유지시켜라

SET target_alt TO 1000.0. // 목표 AP고도 (meters)
SET target_twr TO 1.0.
//SET verticalspeed_mux TO 1.0. // 이걸 오래쓰다보면 가속이 점점 올라가더라
SET verticalspeed_mux TO 2.0. // 1.0에서 나오는 문제점이 해결됬지만, AP보다 많이 낮은고도에서는 쓰로틀출력 널뛰기가 보이는 문제가 생김.

LOCK STEERING TO UP.
LOCK g TO body:mu / (altitude + body:radius)^2. // get current planet gravity: g = 현재행성:중력계수 / (고도 + 현재행성:반지름)^2
LOCK gm TO g * SHIP:MASS.
LOCK v_spd TO verticalspeed * verticalspeed_mux.
//LOCK target_alt_offset TO target_alt - altitude. // 이거 속도관성이 재대로 안먹어서 그런지, 오르락 내리락 거리는게 심하다
LOCK target_alt_offset TO target_alt - SHIP:APOAPSIS. // 이거쓰면 ORBIT_AP값이 올라갈때 한번에 정확히 5000에 맞춰짐 + 약간의 양의vertical_speed, target_alt=5000,결과지표면alt=5024
LOCK valve TO (target_twr*gm - v_spd*gm + target_alt_offset*gm)/SHIP:MAXTHRUST.
LOCK THROTTLE TO valve.

//UNLOCK THROTTLE.
//UNLOCK STEERING.
