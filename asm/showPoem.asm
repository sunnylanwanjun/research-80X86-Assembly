assume cs:code
code segment
  s1:  db 'Good,better,best,','$'
  s2:  db 'Never let it rest,','$'
  s3:  db 'Till good is better,','$'
  s4:  db 'And better,best.','$'
  s :  dw offset s1,offset s2,offset s3,offset s4
  row: db 2,4,6,8
start:
	mov ax,cs
	mov ds,ax
	
	mov ax,offset s
	mov si,ax
	
	mov ax,offset row
	mov di,ax
	
	mov cx,4
printPoem:
	mov ah,2
	mov bh,0
	mov dh,ds:[di]
	mov dl,12
	int 10h
	
	mov dx,ds:[si]
	mov ah,9
	int 21h
	add si,2
	inc di
	loop printPoem
	
	mov ax,4c00h
	int 21h
	
code ends
end start
