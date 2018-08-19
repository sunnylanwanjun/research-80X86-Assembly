assume cs:code
data segment
db 'ibm             '
db 'dec             '
db 'dos             '
db 'vax             '
data ends
stack segment
dw 0,0
stack ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax
	mov sp,4h

	mov cx,4
	mov bx,0
row:
	push cx
	mov cx,3
	mov si,0
	col:
		mov al,ds:[bx+si]
		and al,11011111b
		mov ds:[bx+si],al
		inc si
	loop col
	pop cx
	add bx,10h
	loop row

	mov ax,4c00h
	int 21h
code ends
end start