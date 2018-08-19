assume cs:code
data segment
	db 'word',0
	db 'unix',0
	db 'wind',0
	db 'good',0
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov cx,4
	mov si,0
	mov bx,0
changeLoop:
	push bx
	call funcChange
	add bx,5
	loop changeLoop

	mov ax,4c00h
	int 21h

funcChange:
	push cx
	push si
	push bp

	mov bp,sp
	mov si,[bp+8]
change:
	mov cl,ds:[si]
	mov ch,0h
	and byte ptr ds:[si],11011111b
	inc si
	jcxz endChange
	loop change
endChange:
	pop bp
	pop si
	pop cx
	ret
code ends
end start