assume cs:code
data segment
	dw 64h,100
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov ax,86a1h
	mov dx,1h
	div word ptr ds:[0]

	mov ax,1001
	div byte ptr ds:[2]

	mov ax,4c00h
	int 21h
code ends
end start