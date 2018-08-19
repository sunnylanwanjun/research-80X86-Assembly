.386
.model flat,stdcall
option casemap:none
.code
start:
	mov eax,1
	.if eax|1 
		mov eax,11
	.endif
	
	mov eax,11
	.while eax>0
		dec eax
	.endw
	
	mov eax,11
	.while TRUE
		dec eax
		.break .if eax<0
		.continue
		dec eax
	.endw
	
	mov eax,11
	.repeat
		dec eax
	.until eax<=0
	
	mov eax,11
	.repeat
		dec eax
		.break .if eax<=0 
		.continue
		dec eax
	.until TRUE
end start