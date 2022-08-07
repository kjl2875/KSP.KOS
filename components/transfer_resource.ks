RUNONCEPATH("select_part_in_list.ksm").

// compile transfer_resource.ks to transfer_resource.ksm.
// run transfer_resource.ksm("LIQUIDFUEL",200).

PARAMETER resource_name. // LIQUIDFUEL | OXIDIZER | ELECTRICCHARGE | MONOPROPELLANT | INTAKEAIR | SOLIDFUEL
PARAMETER transfer_amount.

/// part_list

LIST PARTS IN part_list.

/// part_from, part_to

SET part_from TO select_part_in_list(part_list).
SET abort_program TO true.
IF part_from >= 0
{
    SET part_from TO part_list[part_from].

    SET part_to TO select_part_in_list(part_list).
    IF part_to >= 0
    {
        SET part_to TO part_list[part_to].
        SET abort_program TO false.
    }
}

/// transfer resource

IF( NOT abort_program )
{
    SET tf TO TRANSFER(resource_name, part_from, part_to, transfer_amount).
    SET tf:active TO true.
    PRINT("Active.").
}
ELSE
{
    PRINT("ABORT PART SELECT.").
}
