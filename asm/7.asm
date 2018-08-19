assume cs:codesg
codesg segment
	mov ax,cs
	mov ds,ax
	mov ax,20h
	mov es,ax
	mov bx,0
	mov cx,1eh
	s:
	mov ax,[bx]
	mov es:[bx],ax
	add  bx,2h
	loop s
	mov ax,4c00h
	int 21h
codesg ends
end