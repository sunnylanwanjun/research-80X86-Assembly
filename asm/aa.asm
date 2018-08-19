assume cs:code
data segment
db 'DEC'
db 'Ken Oslen'
dw 137
dw 40
db 'PDP'
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov bx,0h

	mov word ptr ds:[bx].0ch,38
	mov word ptr ds:[bx].0eh,70
	
	mov si,0h
	mov byte ptr ds:[bx].10h[si],'V'
	inc si
	mov byte ptr ds:[bx].10h[si],'A'
	inc si
	mov byte ptr ds:[bx].10h[si],'X'

	mov ax,4c00h
	int 21h
code ends
end start