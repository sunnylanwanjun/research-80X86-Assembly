.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include rcdef.inc
;-------------------
; include
;-------------------
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
;-------------------
; data
;-------------------
		.data?
hInstance	dd	?
szBuffer	db	256 dup (?)
		.const
szTitle		db 	'打印',0
dwSize		dd	4096
szAllocResFmt	db	'分配虚拟内存地址:%d',0
szAllocComFmt	db	'提交虚拟内存地址:%d',0
szTestStr	db	'哈哈哈哈，测试字符串',0
szReadStr	db	'可读内存段',0
szProtectStr	db	'不可读内存段',0
;-------------------
; code
;-------------------
.code
_MainProc proc
	LOCAL	hHeap
	LOCAL	lpHeapMem
	LOCAL	lpVirtualMem
	LOCAL	lpVirtualMemProtect
	pushad	
	
	invoke	GetProcessHeap
	mov	hHeap,eax
	.if hHeap == NULL
		jmp codeEnd 
	.endif
	
	invoke	HeapAlloc,hHeap,HEAP_NO_SERIALIZE or HEAP_ZERO_MEMORY,256
	mov	lpHeapMem,eax
	
	invoke	lstrcpy,lpHeapMem,addr szTestStr
	invoke	MessageBox,NULL,lpHeapMem,addr szTitle,MB_OK
	
	invoke	VirtualAlloc,NULL,256,MEM_RESERVE or MEM_COMMIT ,PAGE_READWRITE
	mov	lpVirtualMem,eax
	
	mov	esi,lpHeapMem
	mov	edi,lpVirtualMem
	invoke	lstrlen,lpHeapMem
	mov	ecx,eax 
	cld
	rep	movsb
	invoke	MessageBox,NULL,lpVirtualMem,addr szTitle,MB_OK
	
	invoke  RtlFillMemory,lpVirtualMem,256,0
	
	mov	al,41h
	mov	edi,lpVirtualMem
	mov	ecx,10
	cld
	rep	stosb
	invoke	MessageBox,NULL,lpVirtualMem,addr szTitle,MB_OK
	
	invoke	HeapFree,hHeap,HEAP_NO_SERIALIZE,lpHeapMem
	
	invoke	VirtualAlloc,NULL,256,MEM_RESERVE,PAGE_NOACCESS
	mov	lpVirtualMemProtect,eax
	invoke	IsBadReadPtr,lpVirtualMemProtect,256
	.if eax
		invoke	MessageBox,NULL,addr szProtectStr,addr szTitle,MB_OK
	.else
		invoke	MessageBox,NULL,addr szReadStr,addr szTitle,MB_OK
	.endif
codeEnd:	
	popad
	ret
_MainProc endp

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax	
	invoke	_MainProc
	invoke	ExitProcess,NULL
end start	