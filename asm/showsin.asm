assume cs:code
code segment
start:
	mov ax,30
	call showSin
	
	mov ax,4c00h
	int 21h
showSin:
	jmp showSinBegin
	s0 db '0',0
	s30 db '0.5',0
	s60 db '0.866',0
	s90 db '1',0
	s120 db '0.866',0
	s150 db '0.5',0
	s180 db '0',0
	sinValue dw s0,s30,s60,s90,s120,s150,s180
	
showSinBegin:
	push ax
	push bx 
	push si
	push di
	push es
	
	mov bl,30
	div bl
	and ax,0ffh
	mov bl,2
	mul bl
	mov si,ax
	mov bx,sinValue[si]

	mov ax,0b800h
	mov es,ax
	mov si,bx
	mov di,160*12+40*2
showStr:
	cmp byte ptr cs:[si],0
	je showStrEnd
	mov al,cs:[si]
	mov es:[di],al
	mov es:[di+1],0cah
	inc si
	add di,2
	jmp showStr

showStrEnd:
	pop es
	pop di
	pop si
	pop bx
	pop dx
ret	

code ends
end start