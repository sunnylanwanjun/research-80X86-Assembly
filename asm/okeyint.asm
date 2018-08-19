
;功能：在屏幕中间依次显示'a'~'z'，并让人看清。在显示过程中按下Esc键后，改变显示的颜色。

assume cs:code

stack segment

     db 128 dup (0)

stack ends

data segment

     dw 0,0

data ends

code segment

start:   mov ax,stack

     mov ss,ax

     mov sp,128

 

;将原来的int 9中断例程的入口地址保存在ds:0、ds:2单元中

     mov ax,data

     mov ds,ax

 

     mov ax,0

     mov es,ax

 

     push es:[9*4]

     pop ds:[0]

     push es:[9*4+2]

     pop ds:[2]

 

;在中断向量表中设置新的int 9中断例程的入口地址

     cli           ;设置IF＝0屏蔽中断

     mov word ptr es:[9*4],offset int9

     mov word ptr es:[9*4+2],cs

     sti           ;设置IF＝1不屏蔽中断

 

;依次显示'a'~'z'

     mov ax,0b800h

     mov es,ax

     mov ah,'a'

s:   mov es:[160*12+40*2],ah ;第12行第40列

     inc ah

     cmp ah,'z'

     jnb s

 

;将中断向量表中int 9中断例程的入口恢复为原来的地址

     mov ax,0

     mov es,ax

 

     push ds:[0]

     pop ss:[9*4]

     push ds:[2]

     pop es:[9*4+2]

 

;结束

     mov ax,4c00h

     int 21h

 

;循环延时，循环100000h次

delay:   push ax

     push dx

     mov dx,1000h

     mov ax,0

delay1:  sub ax,1

     sbb dx,0      ;(dx)=(dx)-0-CF

     cmp ax,0

     jne delay1

     cmp dx,0

     jne delay1

     pop dx

     pop ax

     ret

 

;以下为新的int 9中断例程

int9:    push ax

     push bx

     push es

 

     in al,60h     ;从端口60h读出键盘输入

 

;对int指令进行模拟，调用原来的int 9中断例程

     pushf              ;标志寄存器入栈

     call dword ptr ds:[0]  ;CS、IP入栈;(IP)=ds:[0],(CS)=ds:[2]

 

;如果是ESC扫描码，改变显示颜色

     cmp al,1      ;和esc的扫描码01比较

     jne int9ret        ;不等于esc时转移

 

     mov ax,0b800h

     mov es,ax

     inc byte ptr es:[160*12+40*2+1]  ;将属性值+1，改变颜色

 

int9ret:pop es

     pop bx

     pop ax

     iret

 

code ends

end start
