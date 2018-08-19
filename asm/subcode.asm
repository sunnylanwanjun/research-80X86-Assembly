assume cs:code
code segment
start:
	;安装 
	mov ax,cs
	mov ds,ax
	mov si,offset subCode
	
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov cx,offset subCodeEnd - offset subCode
	cld
	rep movsb
	
	mov ax,0
	mov es,ax
	cli
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0
	sti
	
	;mov ah,0
	;call subCode
	;int 7ch
	
	mov ah,1
	mov al,2	
	;call subCode
	int 7ch
	
	;mov ah,2
	;mov al,2
	;call subCode
	;int 7ch
	
	;mov ah,3
	;call subCode
	;int 7ch
	
	mov ax,4c00h
	int 21h
	
subCode:
	push bx
	push dx
	call getIP
getIP:
	pop dx
	jmp subCodeBegin
	subCodeAdr dw clearCode-subCodeAdr,setFrontColor-subCodeAdr,setBackColor-subCodeAdr,scrollUp-subCodeAdr
	
subCodeBegin:
	add dx,3
	;跳转到子程序
	push ax
	push cx
	
	mov cl,8
	shr ax,cl
	mov bx,0
	mov bl,2
	mul bl
	mov bx,ax
	add bx,dx
	add cs:[bx],dx
	pop cx
	pop ax
	jmp cs:[bx]
;===============================
;清屏	
clearCode:
	push cx
	push es
	push di
	
	mov cx,2000
	mov di,0b800h
	mov es,di
	mov di,0
clearLoop:
	mov byte ptr es:[di],20h
	add di,2
	loop clearLoop
clearCodeEnd:
	pop di
	pop es
	pop cx
jmp subCodeRet

;前景色
setFrontColor:
	push cx
	push es
	push di
	push ax
	
	and al,00000111b
	
	mov cx,2000
	mov di,0b800h
	mov es,di
	mov di,1
frontColorLoop:
	and byte ptr es:[di],11111000b
	or byte ptr es:[di],al
	add di,2
	loop frontColorLoop
setFrontColorEnd:
	pop ax
	pop di
	pop es
	pop cx
jmp subCodeRet

;背景色
setBackColor:
push cx
	push es
	push di
	push ax
	
	and al,00000111b
	mov cl,4
	shl al,cl
	
	mov cx,2000
	mov di,0b800h
	mov es,di
	mov di,1
backColorLoop:
	and byte ptr es:[di],10001111b
	or byte ptr es:[di],al
	add di,2
	loop backColorLoop
setBackColorEnd:
	pop ax
	pop di
	pop es
	pop cx
jmp subCodeRet

;向上滚动一行
scrollUp:
	push cx
	push ax
	
	mov cx,2000
	mov ax,0b800h
	mov es,ax
	mov di,0
	mov si,160
loopScroll:
	mov ax,es:[si]
	mov es:[di],ax
	add di,2
	add si,2
	loop loopScroll
scrollUpEnd:
	pop ax
	pop cx
jmp subCodeRet
;=================================

subCodeRet:
	pop dx
	pop bx
iret
subCodeEnd:nop
code ends
end start