;syscall
;0x00
;kernel console ,read/write file

;0x01
;GIF

;0x02
;SIF

;0x03
;input (clavier/souris/joypad)

;0x04
;Net

;0x05
;GUI

	
	include "macro.asm"
	include "vector.asm"
 
	movei r60,1


	fmovei v0,1.5


	fmovei v1,1.0


	addi r63,r63,5



	fadd.p v0,v0,v1
	nop
	
	syscall 0x00
	nop
	
lab2:
	smove.w r5,$8000
	smove.b r5,$0400



	movei r8,1


	ldi r6,0[r5]
	movei r7,'0'

	;addi r6,r6,1
	add r6,r7,r8
	sti r6,0[r5]
	
	movei r4,$01

	syscall 0x00
	nop
	
	call lfunc
	nop
	
	
	movei r10,$1	
	cmpi r10,0
	beq test
	nop
	movei r4,$00
	syscall 0x00
	nop
	
test:
	
	endp
	nop

	
lfunc:
	nop

	ret
	nop


	org $400
	dc.b "Hello World",$A,0
	
	
