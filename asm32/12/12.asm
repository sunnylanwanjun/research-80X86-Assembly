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
lpMemory	dd 	?
lpMemory0	dd      ?
szBuffer	db 256 dup (?)
		.const
szTitle		db '¥Ú”°',0		
szFormat	db 'mem add is %d:%d - %d',0
;-------------------
; code
;-------------------
.code
start:
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,100
	.if eax
		mov lpMemory,eax
	.endif
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,100
	.if eax
		mov lpMemory0,eax
	.endif
	invoke wsprintf,addr szBuffer,addr szFormat,100,eax,lpMemory0
	invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	invoke GlobalReAlloc,lpMemory,50,0
	.if eax 
		mov lpMemory,eax
	.endif
	invoke wsprintf,addr szBuffer,addr szFormat,50,eax,lpMemory0
	invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	invoke GlobalReAlloc,lpMemory,200,GMEM_ZEROINIT or GMEM_MOVEABLE
	.if eax 
		mov lpMemory,eax
	.endif
	invoke wsprintf,addr szBuffer,addr szFormat,200,eax,lpMemory0
	invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	invoke GlobalReAlloc,lpMemory,1000,GMEM_ZEROINIT or GMEM_MOVEABLE
	.if eax 
		mov lpMemory,eax
	.endif
	invoke wsprintf,addr szBuffer,addr szFormat,1000,eax,lpMemory0
	invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	invoke GlobalFree,lpMemory
	mov    lpMemory,0
	invoke GlobalFree,lpMemory0
	mov    lpMemory0,0
	invoke ExitProcess,NULL
end start	