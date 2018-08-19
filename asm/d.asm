assume cs:code
data segment
	dw 1,2,3,4,5,6,7,8
	dd 8 dup (0)
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	
	mov cx,8
	mov si,0
	mov di,0
cubeLoop:
	mov bx,ds:[di]
	call cube
	mov ds:[10h][si],ax
	mov ds:[10h][si+2],dx
	add si,4
	add di,2
	loop cubeLoop

	mov ax,4c00h
	int 21h

cube:
	mov ax,bx
	mul bx
	mul bx
	ret
code ends
end start