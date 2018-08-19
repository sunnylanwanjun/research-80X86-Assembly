assume cs:code 
data segment
	db 'Welcome to masm',0
data ends
code segment
start:
	;========== 安装 ===========
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov ax,cs
	mov ds,ax
	mov si,offset showStr
	
	mov cx,offset showStrEnd - offset showStr
	cld
	rep movsb
	
	mov ax,0
	mov ds,ax
	mov word ptr ds:[7ch*4],200h
	mov word ptr ds:[7ch*4+2],0
	;============================
	
	mov dh,12
	mov dl,5
	mov cl,0cah
	mov ax,data
	mov ds,ax
	mov si,0
	int 7ch
	
	mov ax,4c00h
	int 21h
	
showStr:
	push ax
	push es
	push si
	push di
	
	mov ax,160
	mul dh
	mov di,ax
	mov ax,2
	mul dl
	add di,ax
	
	mov ax,0b800h
	mov es,ax
showLoop:
	mov al,ds:[si]
	mov es:[di],al
	mov es:[di+1],cl
	cmp byte ptr ds:[si],0
	je showLoopEnd
	inc si
	add di,2
	jmp showLoop
	
showLoopEnd:	
	pop di
	pop si
	pop es
	pop ax
	iret
showStrEnd:nop

code ends
end start