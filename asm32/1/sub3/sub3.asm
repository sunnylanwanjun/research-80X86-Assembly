.386
.model flat,stdcall
option casemap:none

Sub3 proto :dword,:dword
.code
start:
	invoke Sub3,66h,77h
Sub3 proc stdcall p1,p2
	pushad
	mov eax,p1
	mov ebx,p2
	popad
	ret
Sub3 endp
end start