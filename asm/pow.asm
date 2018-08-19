assume cs:code 
code segment
start:
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov ax,cs
	mov ds,ax
	mov si,offset pow
	
	mov cx,offset powEnd - offset pow
	cld
	rep movsb
	
	mov ax,0
	mov ds,ax
	mov word ptr ds:[7ch*4],200h
	mov word ptr ds:[7ch*4+2],0

	mov ax,3456
	int 7ch
	add ax,ax
	adc dx,dx
	
	mov ax,4c00h
	int 21h
	
pow:
	mul ax
	iret
powEnd:nop

code ends
end start