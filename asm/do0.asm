assume cs:code 
code segment
start:
	;安装
	mov ax,cs
	mov ds,ax
	mov si,offset do0
	
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov cx,offset doEnd - offset do0
	cld
	rep movsb
	
	;设置中断向量
	mov ax,0
	mov ds,ax
	mov word ptr ds:[0],200h
	mov word ptr ds:[2],0
	
	mov ax,4c00h
	int 21h
do0:
	jmp do0Begin
	db "overflow!",0
do0Begin:
	push ax
	push es
	push di
	push ds
	push si
	push cx
	
	;显示字符串
	mov ax,0b800h
	mov es,ax
	mov di,12*160+36*2
	
	mov ax,cs
	mov ds,ax
	mov si,202h
	mov cx,0
print:
	mov cl,ds:[si]
	jcxz printEnd
	mov es:[di],cl
	mov es:[di+1],2
	add di,2
	inc si
	jmp print
	
printEnd:
	pop cx
	pop si
	pop ds
	pop di
	pop es
	pop ax
	
	mov ax,4c00h
	int 21h

doEnd:nop

code ends
end start