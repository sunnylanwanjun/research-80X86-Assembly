assume cs:code
data segment
	db 'Welcome to masm!',0
data ends
code segment
start:
	mov dh,11
	mov dl,3
	mov cl,2
	mov ax,data
	mov ds,ax
	mov si,0
	call show_str

	mov ax,4c00h
	int 21h
show_str:
	push ax
	push es
	push bx
	push dx
	push cx
	push si
	push di

	mov ax,0b800h
	mov es,ax
	
	mov ax,0
	mov al,160
	dec dh
	mul dh
	mov bx,ax

	mov ax,0
	mov al,2
	mul dl
	add ax,bx
	mov di,ax
	
	mov bl,cl
print:
	mov ch,0
	mov cl,ds:[si]
	mov es:[di],cl
	mov es:[di+1],bl
	jcxz printEnd
	add di,2
	inc si
	loop print

printEnd:
	pop di
	pop si
	pop cx
	pop dx
	pop bx
	pop es
	pop ax
	ret
code ends
end start