assume cs:code 
data segment
	db 'conversation',0
data ends
code segment
start:
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov ax,cs
	mov ds,ax
	mov si,offset capital
	
	mov cx,offset capitalEnd - offset capital
	cld
	rep movsb
	
	mov ax,0
	mov ds,ax
	mov word ptr ds:[7ch*4],200h
	mov word ptr ds:[7ch*4+2],0

	mov ax,data
	mov ds,ax
	mov si,0
	int 7ch
	
	mov ax,4c00h
	int 21h
	
capital:
	push cx
	push si
	
change:
	mov cl,ds:[si]
	jcxz changeEnd
	and cl,11011111b
	mov ds:[si],cl
	inc si
	jmp change
changeEnd:
	pop si
	pop cx
	iret
capitalEnd:nop

code ends
end start