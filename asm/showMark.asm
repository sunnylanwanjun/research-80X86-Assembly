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
	mov si,offset myLoop
	
	mov cx,offset myLoopEnd - offset myLoop
	cld
	rep movsb
	
	mov ax,0
	mov ds,ax
	mov word ptr ds:[7ch*4],200h
	mov word ptr ds:[7ch*4+2],0

	mov ax,0b800h
	mov es,ax
	mov di,12*160
	
	mov bx,offset se - offset s
	mov cx,80
s:  mov byte ptr es:[di],'!'
	add di,2
	int 7ch
se:nop
	
	mov ax,4c00h
	int 21h
	
myLoop:
	push ax
	push bp
	
	dec cx
	cmp cx,0
	je loopEnd
	
	mov ax,sp
	mov bp,ax
	
	mov ax,ss:[bp+4]
	sub ax,bx
	mov ss:[bp+4],ax
	
loopEnd:
	pop bp
	pop ax	
	iret
myLoopEnd:nop

code ends
end start