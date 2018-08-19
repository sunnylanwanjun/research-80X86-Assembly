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
hPrivateHeap	dd	?
hDefaultHeap	dd	?
szBuffer	db      256 dup (?)
lpPrivateHeap	dd      ?
arrHeaps	dd      256 dup (?)
		.const
szTitle		db '打印',0
szHeapsFormat   db '堆句柄%d',0
szHeapFormat	db '默认堆句柄:%d,私有堆句柄:%d',0 
szAllocFormat	db '申请堆内存指针:%d',0
szPrivateSize	db '私有堆大小为：%d',0
szAllocSize	db '分配堆内存大小：%d',0
szHeapMemFmt	db '堆中遍历内存指针%d',0
szHeapErr	db '创建私有堆失败'
szAllocErr	db '没有足够的空间',0 
;-------------------
; code
;-------------------
.code
_MainProc proc
	;LOCAL	lcHeapEntry:PROCESS_HEAP_ENTRY
	
	pushad
	
	invoke GetProcessHeap
	mov	hDefaultHeap,eax
	
	invoke HeapCreate,HEAP_NO_SERIALIZE or HEAP_GENERATE_EXCEPTIONS,1000,0
	invoke HeapCreate,HEAP_NO_SERIALIZE or HEAP_GENERATE_EXCEPTIONS,1000,0
	invoke HeapCreate,HEAP_NO_SERIALIZE or HEAP_GENERATE_EXCEPTIONS,1000,0	
	invoke HeapCreate,HEAP_NO_SERIALIZE or HEAP_GENERATE_EXCEPTIONS,1000,0
	.if eax && eax <= 0c0000000h
		mov	hPrivateHeap,eax
		invoke wsprintf,addr szBuffer,addr szHeapFormat,hDefaultHeap,hPrivateHeap
		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	.else
		invoke MessageBox,NULL,addr szHeapErr,addr szTitle,MB_OK
		jmp codeEnd
	.endif
	
	invoke GetProcessHeaps,64,addr arrHeaps
	lea esi,arrHeaps
	mov eax,[esi]
	.while eax != 0
		invoke wsprintf,addr szBuffer,addr szHeapsFormat,eax
		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
		add esi,4
		mov eax,[esi]
	.endw
	
;	invoke HeapSize,hPrivateHeap,HEAP_NO_SERIALIZE,NULL
;	.if eax
;		invoke wsprintf,addr szBuffer,addr szPrivateSize,eax
;		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
;	.else
;		invoke wsprintf,addr szBuffer,addr szPrivateSize,0
;		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK 
;	.endif
	
	invoke HeapAlloc,hPrivateHeap,HEAP_GENERATE_EXCEPTIONS or HEAP_NO_SERIALIZE or HEAP_ZERO_MEMORY,1000
	.if eax && eax <= 0c0000000h
		mov lpPrivateHeap,eax
		invoke wsprintf,addr szBuffer,addr szAllocFormat,lpPrivateHeap
		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	.elseif eax == STATUS_NO_MEMORY
		invoke MessageBox,NULL,addr szAllocErr,addr szTitle,MB_OK
		jmp codeEnd
	.endif
	
	invoke HeapReAlloc,hPrivateHeap,HEAP_NO_SERIALIZE or HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY,lpPrivateHeap,10000
	mov	lpPrivateHeap,eax
	
;	.while TRUE
;		invoke RtlZeroMemory,addr lcHeapEntry,sizeof lcHeapEntry
;		.break .if eax == FALSE
;		invoke HeapWalk,hPrivateHeap,addr lcHeapEntry
;		invoke wsprintf,addr szBuffer,addr szHeapMemFmt,lcHeapEntry.lpData
;		invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
;	.endw
	
	invoke HeapSize,hPrivateHeap,HEAP_NO_SERIALIZE,lpPrivateHeap
	invoke wsprintf,addr szBuffer,addr szAllocSize,eax
	invoke MessageBox,NULL,addr szBuffer,addr szTitle,MB_OK
	
	invoke HeapFree,hPrivateHeap,HEAP_NO_SERIALIZE,lpPrivateHeap
	mov lpPrivateHeap,0
	
codeEnd:	
	invoke HeapDestroy,hPrivateHeap
	mov	hPrivateHeap,0	
	mov	hDefaultHeap,0
	
	popad
	ret
	
_MainProc endp

start:
	invoke _MainProc
	invoke ExitProcess,NULL
end start	