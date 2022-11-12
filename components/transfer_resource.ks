// Flow Control
// 1. if non-input parameter then input from CUI.
// 2. select source part and target part-list.
// 3. transfer resource to part-list.
// 4. E.O.F.

RUNONCEPATH("select_part_in_list.ksm").

PARAMETER resource_name is "". // 옮길리소스 종류
PARAMETER transfer_amount is 0. // 옮겨질수량 (transfer_amount * recv_parts = send_part's send amount, 옮겨지기전 수량이 충분한지 직접 확인후 입력 필수)

SET flag_abort TO False.
SET highlight_list TO list().

/// Flow 1-1. input parameter from CUI of resource_name

IF resource_name:LENGTH=0
{
    SET resnm_list TO LIST(
        "LIQUIDFUEL",
        "OXIDIZER",
        "ELECTRICCHARGE",
        "MONOPROPELLANT",
        "INTAKEAIR",
        //"SOLIDFUEL",
        "XENONGAS"
    ).
    
    UNTIL not(resource_name:LENGTH=0)
    {
        PRINT("----------------------").
        PRINT("Q) Resource name?").
        SET i TO 0.
        UNTIL i >= resnm_list:length
        {
            SET n TO i+1.
            PRINT(n + ". " + resnm_list[i]).
            SET i TO i + 1.
        }
        PRINT("----------------------").
        SET n TO TERMINAL:INPUT:GETCHAR().
        SET n TO n:TONUMBER(0).
        IF 0<n AND n<=resnm_list:length
        {
            SET i TO n - 1.
            SET resource_name TO resnm_list[i].
        }
    }
    PRINT("resource_name: " + resource_name).
}

/// Flow 1-2. input parameter from CUI of transfer_amount

IF(transfer_amount = 0)
{
    print("Q) Transfer Amount?").
    SET c TO "".
    SET s TO "".
    UNTIL(c = TERMINAL:INPUT:ENTER)
    {
        SET c TO TERMINAL:INPUT:GETCHAR().
        SET s TO s+c.
        PRINT(s).
    }
    SET transfer_amount TO s:TOSCALAR(0).
    PRINT("transfer_amount: " + transfer_amount).
}

/// Flow 2-1. find part_list with PARTS and resource_name parameter.

SET part_list TO list().
LIST PARTS IN part_list_all.
FOR part IN part_list_all
{
    FOR res IN part:RESOURCES
    {
        IF resource_name = res:name
        {
            part_list:add(part).
            BREAK.
        }
    }
}

/// Flow 2-2. select source part. (with highlight)

SET part_from_idx TO select_part_in_list(part_list).
SET flag_abort TO part_from_idx < 0.
IF NOT(flag_abort)
{
    SET part_from TO part_list[part_from_idx].
    part_list:REMOVE(part_from_idx).

    SET hl TO HIGHLIGHT(part_from,RGBA(0,255,0,0.4)).
    SET hl:ENABLED TO true.
    highlight_list:add(hl).
}

/// Flow 2-3. select target part-list. (with highlight)

IF NOT(flag_abort)
{
    SET part_to_list TO list().
    UNTIL(part_list:length <= 0)
    {
        SET prtidx_to TO select_part_in_list(part_list).
        IF prtidx_to < 0
        {
            BREAK.
        }
        part_to_list:add(part_list[prtidx_to]).
        part_list:REMOVE(prtidx_to).

        SET hl TO HIGHLIGHT(part_to_list[part_to_list:length-1],RGBA(0,255,255,0.4)).
        SET hl:ENABLED TO true.
        highlight_list:add(hl).
    }
}

/// Flow 3. transfer resource to part-list with parameters(resource_name,transfer_amount).

IF( NOT(flag_abort) )
{
    FOR part_to IN part_to_list
    {
        SET tf TO TRANSFER(resource_name, part_from, part_to, transfer_amount).
        SET tf:active TO true.
    }
}

// 4. E.O.F.

IF( NOT(flag_abort) )
{
    print("Active all.").
    print("E.O.F.").
}
ELSE
{
    print("Abort program.").
}

FOR hl IN highlight_list
{
    SET hl:ENABLED TO false.
}