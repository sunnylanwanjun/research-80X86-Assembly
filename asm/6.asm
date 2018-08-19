assume cs:codesg
codesg segment
	
	mov ax,20h
	mov ds,ax
	mov cx,40h
	mov bx,0h
	s:
	mov ds:[bx],bx
	inc bx
	loop s

	mov ax,4c00h
	int 21h
codesg ends
end