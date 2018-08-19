assume cs:code
code segment
start:
	mov ax,4240h
	mov dx,000fh
	mov cx,0ah
	call divdw

	mov ax,4c00h
	int 21h
	
divdw:
	push bx

	push ax
	mov ax,dx
	mov dx,0
	div cx
	
	mov bx,ax ;∏ﬂŒª…Ã
	
	pop ax
	div cx
	mov cx,dx
	mov dx,bx

	pop bx
ret
code ends
end start