.386  
.model flat,stdcall
option casemap:none
;>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>
include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib

;声明
;MessageBox Proto :dword,:dword,:dword,:dword
TestProp proto :dword,:dword
Sub1 Proto :dword,:dword
Sub2 proto :dword,:dword
Sub3 proto :dword,:dword
;>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>
	.data
szCaption db 'A MessageBox !',0
szText    db 'Hello world !',0
stWndClass WNDCLASS	<1,1,1>
	.data?
stWndClass2 WNDCLASS <?>
	.const
	.stack
;>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>
	.code
start:
	mov eax,stWndClass.lpfnWndProc
	mov esi,offset stWndClass
	mov eax,[WNDCLASS.lpfnWndProc][esi]
	
	mov esi,offset stWndClass
	assume esi:ptr WNDCLASS
	mov eax,[esi].lpfnWndProc
	assume esi:nothing
	
	lea esi,stWndClass
	push 0
	
	mov cx,11
@@:
	dec cx
	cmp cx,0
	jz @F
	jmp @B
@@:
	
	mov ax,3
	.if ax == 3
		invoke TestProp,'1230',0
	.endif
	
TestProp proc stdcall private _Var1,_Var2
	local @loc1:dword,@loc2:word
	local @loc3:byte
	mov @loc1,'XA0'
	mov eax,@loc1
	mov ax,@loc2
	mov al,@loc3
	
	lea eax,@loc1
	
	invoke MessageBox,NULL,offset szText,\
		   addr _Var1,MB_ICONWARNING or MB_YESNO
	invoke ExitProcess,NULL
	
	ret
TestProp endp
	
end start