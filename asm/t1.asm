assume cs:code,ds:data,ss:stack
data segment
	dw 0213h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends
stack segment
	dw 0,0,0,0,0,0,0,0,0,0
stack ends
code segment
start:
	mov ax,stack
	mov ss,ax
	mov sp,14h

	mov ax,data
	mov ds,ax

	mov cx,8h
	mov bx,0
s:
	push ds:[bx]
	pop cs:[bx]
	add bx,2h
	loop s

	mov ax,4c00h
	int 21h

code ends
end start