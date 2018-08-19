assume cs:code
table segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2795000,3753000,4649000,5937000
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
    dw 5,3,42,104,85,210,123,111,105,125,140,136,153,211,199,209,224,239
    dw 260,304,333
table ends
data segment
    db '1975',0
data ends
code segment
start:
	mov ax,table
	mov es,ax
	
	mov ax,data
	mov ds,ax
	mov si,0
	
	mov cx,21
	mov dh,30
	mov di,0
printTable:
	push cx
	mov cl,2 ;设置 颜色
	mov dl,30
	
	;--
	;print year
	mov ax,di
	mov bl,4
	mul bl
	mov bp,ax
	mov ax,es:[bp+0]
	mov bx,es:[bp+2]
	mov ds:[0],ax
	mov ds:[2],bx
	call show_str
	
	;print sum money	
	mov word ptr ds:[0],0
	mov word ptr ds:[2],0		
	add dl,10
	mov ax,es:[bp].84
	push dx
	mov dx,es:[bp+2].84
	call dtoc
	pop dx
	call show_str
	
	;print people num
	mov word ptr ds:[0],0
	mov word ptr ds:[2],0
	add dl,10
	mov ax,di
	mov bl,2
	mul bl
	mov bp,ax
	mov ax,es:[bp].168
	push dx
	mov dx,0
	call dtoc
	pop dx
	call show_str

	;print average	
	mov word ptr ds:[0],0
	mov word ptr ds:[2],0
	add dl,10	
	mov ax,di
	mov bl,2
	mul bl
	mov bp,ax
	mov ax,es:[bp].210
	push dx
	mov dx,0
	call dtoc
	pop dx	
	call show_str
	
	;--
	
	inc di
	inc dh
	pop cx
	dec cx
	jcxz printTableEnd
	jmp printTable
	
printTableEnd:
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
	
	mov bx,ax ;高位商
	
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
code ends
end start

