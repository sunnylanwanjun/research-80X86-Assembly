assume cs:code
code segment
start:
	mov ax,0ffffh
	jmp ax
	mov ax,000bh
	jmp ax
	jmp bx
	jmp word ptr ds:[0]
	jmp word ptr es:[3]
	jmp dword ptr ds:[0]
	jmp dword ptr es:[3]
s:	jmp s
	jmp short s
	jmp near ptr s
	jmp far ptr s

	db 16 dup(0)
	jmp s0
	jmp short s0
	jmp near ptr s0
	jmp far ptr s0
s0:
	db 256 dup  (0)
	jmp s0
	;jmp short s0
	jmp near ptr s0
	jmp far ptr s0
code ends
end start