assume cs:code
code segment
	dw 0213h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
	dw 0,0,0,0,0,0,0,0
start:
	mov ax,cs
	mov ds,ax
	mov ss,ax
	mov sp,20h

	mov cx,8h
	mov bx,0h
pushLog:
	push ds:[bx]
	add bx,2h
	loop pushLog

	mov cx,8h
	mov bx,0h
popLog:
	pop ds:[bx]
	add bx,2h
	loop popLog

	mov ax,4c00h
	int 21h

code ends
end start