assume cs:code
data segment
	db "Beginner's All-purpose Symbolic Instruction Code.",0
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	call letterc
	mov ax,4c00h
	int 21h
	
letterc:
	push ax
	push si
changeBig:
	mov al,ds:[si]
	cmp al,61
	jb next
	cmp al,122
	ja next
	and al,11011111b
	mov ds:[si],al
next:
	inc si
	cmp al,0
	je changeEnd
	jmp ChangeBig
changeEnd:
	pop si
	pop ax
ret
code ends
end start