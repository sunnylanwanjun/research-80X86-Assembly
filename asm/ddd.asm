assume cs:code
code segment
start:
	mov ax,3
	mov bx,1
	push bx
	push ax
	call difcube
	mov ax,4c00h
	int 21h
difcube:
	push bp
	mov ax,ss:[sp+4]
	sub ax,ss:[sp+6]
	mov bp,ax
	mul bp
	mul bp
	pop bp
	ret 4
code ends
end start