assume cs:code
data segment
	db 'welcome to masm!'
	db '........................................'
data ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov cx,8
	mov si,0
copy:
	mov ax,ds:[si]
	mov ds:16[si],ax
	add si,2
	loop copy

	mov ax,4c00h
	int 21h

code ends
end start