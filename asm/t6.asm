assume cs:code 
data segment
	db 'BasIc'
	db 'Minix'
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov cx,5
	mov bx,0
change:
	mov al,01100000b
	or ds:[bx],al
	mov al,11011111b
	and ds:[bx+5],al
	inc bx
	loop change

	mov ax,4c00h
	int 21h
code ends
end start