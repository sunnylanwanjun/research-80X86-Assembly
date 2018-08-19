assume cs:code
data segment
	db 0,2,4,7,8,9,'$'
	readBegin: db 2,2,2,2,2,4
	shiftBegin: db 0,4,8,12
	printBegin: db '0000/00/00 00:00:00','$'
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	mov di,offset printBegin + 18
	
loopRead:
	mov al,ds:[si]
	cmp al,'$'
	je print
	out 70h,al
	in ax,71h
	
	mov dx,1
	mov bp,0
parse:
	mov bx,ax
	mov cx,ds:[offset shiftBegin + bp]
	shr bx,cl
	and bx,000fh
	add bx,30h
	mov ds:[di],bl
	dec di
	mov bx,ds:[offset readBegin + si]
	cmp dl,bl
	je parseEnd
	inc dx
	inc bp
	jmp parse
	
parseEnd:
	inc si
	dec di
	jmp loopRead
	
print:
	mov ah,9
	mov dx,offset printBegin
	int 21h
	
	mov ax,4c00h
	int 21h
code ends
end start