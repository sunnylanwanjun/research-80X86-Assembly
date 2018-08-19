assume cs:code
data segment
db '1. display      '
db '2. brows        '
db '3. replace      '
db '4. modify       '
data ends
stack segment
dw 0,0,0,0,0,0,0,0
stack ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax
	mov sp,10h

	mov cx,4
	mov bx,0
row:
	push cx
	mov cx,4
	mov si,0
	col:
		mov al,ds:[bx+si+3]
		and al,11011111b
		mov ds:[bx+si+3],al
		inc si
	loop col
	pop cx
	add bx,10h
	loop row

	mov ax,4c00h
	int 21h
code ends
end start