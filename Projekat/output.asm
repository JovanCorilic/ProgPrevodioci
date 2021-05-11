
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$8,%15
@main_body:
		MOV 	$11,-4(%14)
		MOV 	$13,-8(%14)
		ADDU	-8(%14),$1,%0
		MOV 	%0,-8(%14)
		ADDS	-8(%14),$1,-8(%14)
		ADDS	-8(%14),$1,-8(%14)
		ADDU	-8(%14),$1,%0
		MOV 	%0,-8(%14)
@if1:
		CMPS 	-8(%14),$0
		JGEU	@false1
@true1:
		ADDS	-8(%14),$1,-8(%14)
		JMP 	@exit1
@false1:
@exit1:
		ADDU	-4(%14),-8(%14),%0
		MOV 	%0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET