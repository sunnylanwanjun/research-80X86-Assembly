.386
.model flat,c
option casemap:none

Sub2 proto :dword,:dword
.code
start:
	invoke Sub2,44h,55h
Sub2 proc c p1,p2
	 pushad
	 mov eax,p1
	 mov ebx,p2
	 popad
	 ret
Sub2 endp
end start