.386
.model flat,c
option casemap:none
 
Sub1 proto :dword,:dword
.code
start:
	invoke Sub1,22h,33h
	mov eax,0
	
Sub1 proc c p1,p2
	 pushad
	 mov eax,p1
	 mov ebx,p2
	 popad
	 ret
Sub1 endp
end start