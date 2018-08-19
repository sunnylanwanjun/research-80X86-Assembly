assume cs:code
code segment
	dw 0213h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
start:
	mov ax,0
	mov ds,ax

	mov ax,cs
	mov es,ax

	mov cx,8h
	mov bx,0h
s:
	mov ax,ds:[bx]
	mov es:[bx],ax
	add bx,2h
	loop s

	mov ax,4c00h
	int 21h
code ends
end start