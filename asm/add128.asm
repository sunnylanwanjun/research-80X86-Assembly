assume cs:code
data segment
	dw 1000,0f000,001e,0,0,0,0,0
	dw 1ef0,1000,0020,0,0,0,0
data ends
code segment
start:
;==================== add128 func begin ======================
	mov ax,data
	mov ds,ax
	mov si,0
	mov di,10h
	call add128
	
	mov ax,4c00h
	int 21h
add128:
	push cx
	push si
	push ax
	push di
	
	sub ax,ax ;清空标识位
	mov cx,8
loopAdd:
	mov ax,ds:[si]
	adc ax,ds:[di]
	mov ds:[si],ax
	inc si
	inc si
	inc di
	inc di
	loop loopAdd
	
	pop di
	pop ax
	pop si
	pop cx
ret
;==================== add128 func end ========================
code ends
end start