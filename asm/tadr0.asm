assume cs:code,ds:data
data segment
a dw 1,2,3,4,5,6,7,8
b dd 0
data ends
code segment
		mov ax,data
		mov ds,ax
		
        mov cx,8
        mov ax,0
        mov si,0
        mov dx,0
loopAdd:
        mov ax,a[si]
        add word ptr b[0],ax
        adc word ptr b[2],0

        add si,2
        loop loopAdd

        mov ax,4c00h
        int 21h
code ends
end 
