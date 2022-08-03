LIST PARTS IN part_list. // 부품목록. (SHIP:PARTS는 오류 - Message: Unexpected token ':' found. Expected EOI)
SET part_idx TO 0. // part_list 사용자커서로 사용.
SET flag_stop TO false. // roof중단 flag값으로 사용.
SET color_yellow_a25 TO RGBA(255,255,0,0.25). // 고정값, 하이라이트 색상지정

/// TERMINAL INIT
SET TERMINAL:HEIGHT TO 24.
SET TERMINAL:WIDTH TO 80.
PRINT("------------------------------------").
PRINT("UP: NEXT PART").
PRINT("DOWN: PREV PART").
PRINT("BACKSPACE: EXIT").
PRINT("------------------------------------").

/// PROCESSING
UNTIL flag_stop
{
	/// enable highlight
	
	SET hlt TO HIGHLIGHT(part_list[part_idx],color_yellow_a25).
	SET hlt:ENABLED TO true.
	
	/// new part_add
	
	SET part_add TO 0.

	SET c TO TERMINAL:INPUT:GETCHAR().
	IF( c = TERMINAL:INPUT:UPCURSORONE )
	{
		SET part_add TO -1.
	}
	ELSE IF( c = TERMINAL:INPUT:DOWNCURSORONE )
	{
		SET part_add TO 1.
	}
	ELSE IF( c = TERMINAL:INPUT:BACKSPACE )
	{
		SET flag_stop TO true.
	}
	
	/// new part_idx(using part_add: 0,1,-1) + change highlight(old part_idx to new part_idx)
	
	IF( part_add <> 0 )
	{	
		/// disable highlight
		
		SET hlt TO HIGHLIGHT(part_list[part_idx],color_yellow_a25).
		SET hlt:ENABLED TO false.
	
		/// new part_idx
		
		SET part_idx TO part_idx + part_add.
		if( part_idx < 0 )
		{
			SET part_idx TO part_list:length-1.
		}
		else if( part_idx >= part_list:length )
		{
			SET part_idx TO 0.
		}
		print("part_list["+part_idx+"]: " + part_list[part_idx]).
		
		/// enable highlight
	
		SET hlt TO HIGHLIGHT(part_list[part_idx],color_yellow_a25).
		SET hlt:ENABLED TO true.
	}
}

/// disable highlight

SET hlt TO HIGHLIGHT(part_list[part_idx],color_yellow_a25).
SET hlt:ENABLED TO false.

/// terminate message
		
PRINT("Bye.").
PRINT("------------------------------------").
