assume cs:code,ds:data
data segment
	a: dw 1,2,3,4
	b: dw 4,5,6,7
	e  dw 8,9,10,11
data ends
code segment
start:
	mov ax,data        ;MOV     AX,14CE
	mov ds,ax          ;MOV     DS,AX
	                   
	mov ax,ds:[a]      ;MOV     AX,0000
	mov ax,a           ;MOV     AX,0000
	mov ax,offset a    ;MOV     AX,0000
	mov ax,seg a       ;MOV     AX,14CE
	mov bx,0ffffh      ;MOV     BX,FFFF
	                   
	mov ax,ds:[b]      ;MOV     AX,0008
	mov ax,b           ;MOV     AX,0008
	mov ax,offset b    ;MOV     AX,0008
	mov ax,seg b       ;MOV     AX,14CE
	mov bx,0ffffh      ;MOV     BX,FFFF
	                   
	mov ax,ds:[e]      ;MOV     AX,[0010]
	mov ax,e           ;MOV     AX,[0010]
	mov ax,offset e    ;MOV     AX,0010
	mov ax,seg e       ;MOV     AX,14CE
	                   
	mov ax,4c00h       ;MOV     AX,4C00
	int 21h            ;INT     21
code ends
end start

;从以上实验可以看出，地址标号(带有:号的)，只保存有地址信息，不具备数据信息，无论采用何种方式都是无法
;取出标号处的数据，所以加不加offset的效果是一样的，都是取得便宜地址信息，如果要取段地址信息，就必须加seg
;而数据标号不同，它如果C++中的变量名，如果不加任何修改，取得就是标号代表的数值，而offset就相当于&符号了，
;如果要取得数据标号对应的段地址，也必须加seg,他们都是编译器决定的，所以也没有说为什么，记住就可以了



