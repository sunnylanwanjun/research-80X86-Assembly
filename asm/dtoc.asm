assume cs:code
data segment
	db 10 dup (0)
data ends
code segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	mov ax,9768h
	mov dx,5ah
	call dtoc

	mov dh,11
	mov dl,3
	mov cl,2
	call show_str

	mov ax,4c00h
	int 21h
;=====================dtoc func begin ============================
dtoc:
	push ax
	push dx
	push bx
	push si
	push cx
	
	mov bx,0
ergodic:
	inc bx
	mov cx,10
	call divdw
	add cx,30h
	push cx
	mov cx,ax
	jcxz endErgodic
jmp ergodic

endErgodic:
setData:
	pop dx
	mov ds:[si],dl
	dec bx
	inc si
	mov cx,bx
	jcxz endSetData
jmp setData
endSetData:
	mov byte ptr ds:[si],0
	
	pop cx
	pop si
	pop bx
	pop dx
	pop ax
ret
;====================== dtoc func end ======================
;====================== divdw func begin =====================
divdw:
	push bx

	push ax
	mov ax,dx
	mov dx,0
	div cx
	
	mov bx,ax ;∏ﬂŒª…Ã
	
	pop ax
	div cx
	mov cx,dx
	mov dx,bx

	pop bx
ret
;====================== divdw func end =====================
;====================== show_str func begin ==================
show_str:
	push ax
	push es
	push bx
	push dx
	push cx
	push si
	push di

	mov ax,0b800h
	mov es,ax
	
	mov ax,0
	mov al,160
	dec dh
	mul dh
	mov bx,ax

	mov ax,0
	mov al,2
	mul dl
	add ax,bx
	mov di,ax
	
	mov bl,cl
print:
	mov ch,0
	mov cl,ds:[si]
	mov es:[di],cl
	mov es:[di+1],bl
	jcxz printEnd
	add di,2
	inc si
	loop print

printEnd:
	pop di
	pop si
	pop cx
	pop dx
	pop bx
	pop es
	pop ax
ret
;====================== show_str func end =====================
code ends
end start