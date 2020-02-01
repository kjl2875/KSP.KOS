/// Object. 낙하산 없이 지면에 안전착륙 해야 됩니다.


// Snapshot. 수직하강중인 물체의 ETA시점 계산
// 멈추는 지점을 해수면 5km로 두고, MUN에서 수직으로 하강했을 때, 5371m에서 멈춘다.


function getTouchdownTime {
    parameter targetAlt.

    SET t TO 0.
    SET talt TO ship:altitude.
    SET spd TO ship:verticalspeed.
    UNTIL talt<=targetAlt {
        SET gTmp TO body:mu / (body:radius+talt)^2.
        SET spd TO spd - gTmp.
        SET talt TO talt + spd.
        SET t TO t + 1.
    }

    SET t TO t - 1.
    return t.
}

CLEARSCREEN.

SET t0 TO time:seconds.
SET tt TO getTouchdownTime(5000).
LOCK teta TO tt - (time:seconds - t0).

UNTIL 0>=teta {
    PRINT "약 " + ROUND(teta,2) + "초 남았습니다." AT (0,0).
}

KUniverse:pause.
