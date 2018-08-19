assume cs:code
data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11452,14430,15257,17800
data ends
table segment
    db 21 dup ('year summ ne ?? ')
table ends
code segment
start:
	mov ax,data
	mov ds,ax

	mov ax,table
	mov es,ax

	mov cx,21
	mov si,0
	mov di,0
row:
	mov ax,ds:[0][si]
	mov es:[bx],ax
	mov ax,ds:[0][si+2]
	mov es:[bx+2],ax

	mov ax,ds:[84][si]
	mov es:[bx].5h,ax
	mov ax,ds:[84][si+2]
	mov es:[bx+2].5h,ax

	mov ax,ds:[168][di]
	mov word ptr es:[bx].0ah,ax

	mov ax,es:[bx].5h
	mov dx,es:[bx].5h[2]
	div word ptr es:[bx].0ah

	mov es:[bx].0dh,ax
	add si,4
	add di,2
	add bx,10h
	loop row

	mov ax,4c00h
	int 21h
code ends
end start
