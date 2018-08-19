assume cs:code 
data segment
	db 'conversation',0
data ends
code segment
start:
	;========== 安装 ===========
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov ax,cs
	mov ds,ax
	mov si,offset myJmpNear
	
	mov cx,offset myJmpNearEnd - offset myJmpNear
	cld
	rep movsb
	
	mov ax,0
	mov ds,ax
	mov word ptr ds:[7ch*4],200h
	mov word ptr ds:[7ch*4+2],0
	;============================
	
	mov ax,0b800h
	mov es,ax
	mov di,12*160
	
	mov ax,data
	mov ds,ax
	mov si,0
	
	mov bx,offset se - offset s
s:  cmp byte ptr ds:[si],0
	je se
	mov al,ds:[si]
	mov byte ptr es:[di],al
	mov byte ptr es:[di+1],2
	add di,2
	inc si
	int 7ch
se:
	mov ax,4c00h
	int 21h
	
myJmpNear:
	push ax
	push bp
	
	mov ax,sp
	mov bp,ax
	
	mov ax,ss:[bp+4]
	sub ax,bx
	mov ss:[bp+4],ax
	
	pop bp
	pop ax	
	iret
myJmpNearEnd:nop

code ends
end start