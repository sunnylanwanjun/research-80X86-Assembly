assume cs:code
data segment
	db 'conversation'
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	mov cx,12
	call capital
	
	mov ax,4c00h
	int 21h
capital:
	and byte ptr ds:[si],11011111b
	inc si
	loop capital
	ret
code ends
end start