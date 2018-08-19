assume cs:code
data segment
	db 10 dup (0)
data ends
code segment
start:
	mov ax,data 
	mov ds,ax
	mov si,0
	
	mov al,8
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b
	add ah,30h
	add al,30h
	mov ds:[si],ah
	mov ds:[si+1],al
	mov byte ptr ds:[si+2],24h
	
	mov ah,9
	mov dx,0
	int 21h
	
	mov ax,4c00h
	int 21h
code ends
end start