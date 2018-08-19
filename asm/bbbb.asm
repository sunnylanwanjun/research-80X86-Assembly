assume cs:code
data segment
	dw 0,0
data ends
code segment
start:
	mov ax,data
	mov ds, ax
	mov bx,0
	jmp word ptr ds:[bx+1]
code ends
end start