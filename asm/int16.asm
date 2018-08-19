assume cs:code
code segment
start:
;	mov ax,0
;listen:
	mov ah,0
	int 16h
;	cmp ax,0
;	jne beginHandler
;	jmp listen
	
beginHandler:
	cmp al,'r'
	mov ah,00000100b
	je changeColor
	cmp al,'g'
	mov ah,0000010b
	je changeColor
	cmp al,'b'
	mov ah,0
	je changeColor
	
changeColor:
	mov cx,0b800h
	mov es,cx
	mov si,1
	mov cx,2000
set:
	and byte ptr es:[si],11111000b
	or es:[si],ah
	add si,2
	loop set
	mov ax,4c00h
	int 21h

code ends
end start