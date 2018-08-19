assume cs:code
data segment
db '1. file         '
db '2. edit         '
db '3. search       '
db '4. view         '
db '5. options      '
db '6. help         '
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov cx,6
bigFirst:
	mov al,ds:[bx+3]
	and al,11011111b
	mov ds:[bx+3],al
	add bx,10h
	loop bigFirst

	mov ax,4c00h
	int 21h
code ends
end start