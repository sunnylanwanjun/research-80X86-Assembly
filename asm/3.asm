assume cs:codesg
codesg segment
	mov ax,0ffffh
	mov ds,ax
	mov dx,0h
	mov bx,6
	mov cx,3h
	s:
	add dx,[bx]
	mov dh,0
	loop s

	mov ax,4c00h
	int 21h
codesg ends
end