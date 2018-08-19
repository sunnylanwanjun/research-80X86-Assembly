assume cs:code
code segment
start:
	mov ax,100
	mov dx,ax
	
	shl ax,1
	mov cl,3
	shl dx,cl
	
	add ax,dx
	
	mov ax,4c00h
	int 21h
code ends
end start