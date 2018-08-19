assume cs:code
code segment
start:
	mov al,0bfh
	call showHex
	
	mov ax,4c00h
	int 21h
	
showHex:
	jmp showHexBegin
	hexAscii db '0123456789abcdef'

showHexBegin:
	push ax
	push bx
	push cx
	push dx
	push es

	mov bx,ax
	mov cl,4
	shr bx,cl
	and bx,000fh
	mov dl,hexAscii[bx]	
	mov bx,0b800h
	mov es,bx
	mov byte ptr es:[160*12+39*2],dl
	mov byte ptr es:[160*12+39*2+1],0cah
	
	mov bx,ax
	and bx,000fh
	mov dl,hexAscii[bx]
	mov byte ptr es:[160*12+40*2],dl
	mov byte ptr es:[160*12+40*2+1],0cah
	
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
ret
code ends
end start