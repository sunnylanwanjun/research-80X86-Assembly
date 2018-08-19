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
szBuffer	db	256 dup (0)
		.const
szTitle		db 	'打印',0
dwSize		dd	4096
szAllocResFmt	db	'分配虚拟内存地址:%d',0
szAllocComFmt	db	'提交虚拟内存地址:%d',0
;-------------------
; code
;-------------------
.code
_MainProc proc
	LOCAL	lpAddress
	pushad	
	;分配虚拟地址
	invoke	VirtualAlloc,NULL,dwSize,MEM_RESERVE,PAGE_NOACCESS
	mov	lpAddress,eax
	invoke	wsprintf,addr szBuffer,addr szAllocResFmt,lpAddress
	invoke	MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	;提交保留虚拟地址
	invoke	VirtualAlloc,lpAddress,4096,MEM_COMMIT,PAGE_READWRITE
	mov	lpAddress,eax
	invoke	wsprintf,addr szBuffer,addr szAllocComFmt,lpAddress
	invoke	MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK	
	
	;锁定提交的虚拟地址，不允许被放置在磁盘文件中，不允许超过30个
	invoke	VirtualLock,lpAddress,4096
	invoke  VirtualUnlock,lpAddress,4096
	
	;修改虚拟地址属性
	invoke	VirtualProtect,lpAddress,4096,PAGE_READONLY,NULL
	
	;不提交虚拟地址
	invoke	VirtualFree,lpAddress,0,MEM_DECOMMIT
	
	;释放虚拟地址
	invoke	VirtualFree,lpAddress,0,MEM_RELEASE
	popad
	ret
_MainProc endp

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax	
	invoke	_MainProc
	invoke	ExitProcess,NULL
end start	