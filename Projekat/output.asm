
y:
		WORD	1
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$8,%15
@main_body:
		MOV 	$11,-4(%14)
		MOV 	$13,-8(%14)
		MOV 	$12,y
		ADDS	y,$1,y
		ADDU	-4(%14),y,%0
		MOV 	%0,-4(%14)
		ADDU	-8(%14),$1,%0
		MOV 	%0,-8(%14)
		ADDS	-8(%14),$1,-8(%14)
		ADDS	-8(%14),$1,-8(%14)
		ADDU	-8(%14),$1,%0
		MOV 	%0,-8(%14)
@if0:
		CMPS 	-4(%14),y
		JGEU	@false0
@true0:
		ADDU	y,$1,%1
		MOV 	%1,%0
		JMP 	@exit0
@false0:
		MOV 	$0,%0
		JMP 	@exit0
@exit0:
		MOV 	%0,-8(%14)
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET