assume cs:code
code segment
start:

	mov ax,2
	out 70h,ax
	mov ax,0ffh
	out 71h,ax

	mov ax,2
	out 70h,ax
	in ax,71h
	
	mov ax,4c00h
	int 21h
code ends
end start