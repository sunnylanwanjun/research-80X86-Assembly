assume cs:codesg
codesg segment
	mov cx,12h
	mov bx,0h
	mov ax,0ffffh
	mov ds,ax
	mov ax,20h
	mov es,ax
	s:
	mov ax,ds:[bx]
	mov es:[bx],ax
	inc bx
	inc bx
	loop s

	mov ax,4c00h
	int 21h
codesg ends
end