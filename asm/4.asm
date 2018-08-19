assume cs:codesg
codesg segment
	mov ax,0ffffh
	mov ds,ax

	mov cx,12h
	mov bx,0h
	mov dx,0h
	s:
	mov ax,[bx]
	mov ah,0h
	add dx,ax
	inc bx
	loop s

	mov ax,4c00h
	int 21h
codesg ends
end