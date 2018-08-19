assume cs:code
data segment
	db 'welcome to masm!'
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov ax,0b800h
	mov es,ax

	mov cx,10h
	mov bx,0720h
	mov si,0h
copy:
	mov al,ds:[si]
	mov es:[bx],al
	mov es:[bx].0a0h,al
	mov es:[bx].140h,al
	mov es:[bx+1],0cah
	mov es:[bx+1].0a0h,0cah
	mov es:[bx+1].140h,0cah

	add bx,2
	inc si
	loop copy

	mov ax,4c00h
	int 21h
code ends
end start