assume cs:code
code segment
start:
	call showStr
	mov ax,4c00h
	int 21h
showStr:
	push ax
	push ds
	push bx
	push si
	push di
	push es
	
	call getIP
getIP:
	jmp showStrBegin
	db 30 dup (0)
	
showStrBegin:
	pop bx
	add bx,2
	mov si,bx
waitEnter:
	mov ah,0
	int 16h
	cmp al,0dh
	je showStrEnd
	cmp al,0ah
	je showStrEnd
	cmp al,8h
	je subChar
	
addChar:	
	mov cs:[bx],al
	inc bx
	mov cs:[bx],'$'
	jmp showStrToScreen
	
subChar:
	dec bx
	mov byte ptr cs:[bx],0
	
showStrToScreen:	
	mov di,12*160+5*2
	push si
showStrToScreenLoop:
	cmp byte ptr cs:[si],'$'
	je showStrToScreenEnd
	mov ax,0b800h
	mov es,ax
	mov al,cs:[si]
	mov byte ptr es:[di],al
	mov byte ptr es:[di+1],0cah
	add di,2
	inc si
	jmp showStrToScreenLoop
showStrToScreenEnd:

	pop si
	jmp waitEnter
	
showStrEnd:

	pop es
	pop di
	pop si
	pop bx
	pop ds
	pop ax
ret
code ends
end start