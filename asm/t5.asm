assume cs:code,ds:data
data segment
	db 'BaSic'
	db 'inFoRMaTiOn'
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov cx,5
	mov bx,0
big:
	mov al,01100000b
	or ds:[bx],al
	inc bx
	loop big

	mov cx,11
	mov bx,5
small:
	mov al,11011111b
	and ds:[bx],al
	inc bx
	loop small

	mov ax,4c00h
	int 21h
code ends
end start