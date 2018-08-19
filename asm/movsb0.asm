assume cs:code
data segment
	db 16 dup (0)
data ends
code segment
start:
	mov ax,0f000h
	mov ds,ax
	mov si,0ffffh
	
	mov ax,data
	mov es,ax
	mov di,15
	
	std
	mov cx,16
	rep movsb ; 这里使用movsw 为异常退出，为啥？？？
	
	mov ax,4c00h
	int 21h
code ends
end start
