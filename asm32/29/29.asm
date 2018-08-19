.386
.model 	flat,stdcall
option 	casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include 	windows.inc
include 	user32.inc
includelib	user32.lib
include 	kernel32.inc
includelib 	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data
lpOldHandler	dd	?
.const
szMsg		db	"外异常发生位置:%08X，异常代码:%08X，标志：%08X",0
szInMsg		db	"内异常发生位置:%08X，异常代码:%08X，标志：%08X",0
szSafe		db	"回到了外安全的地方",0
szInSafe	db	"回到了内安全的地方",0
szTitle		db	"SEH的例子",0
szFSMsg		db	"FS:[0] %08X",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code

_InTest	proc
	assume	fs:nothing
	push	ebp
	push	offset _InSafePlace
	push	offset _InHandler
	push	fs:[0]
	mov	fs:[0],esp

	xor 	eax,eax
	mov	dword ptr [eax],0
	
_InSafePlace:
	invoke	MessageBox,NULL,addr szInSafe,addr szTitle,MB_OK
	pop	fs:[0]
	add	esp,0ch	
	ret

_InTest endp

_InHandler	proc	c _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext
		LOCAL 	@szBuffer[1024]:byte
		pushad
		
		mov	esi,_lpExceptionRecord
		mov	edi,_lpContext
		assume	esi:ptr	EXCEPTION_RECORD,edi:ptr CONTEXT
		mov	eax,[esi].ExceptionCode
		
		;ExceptionCode中包含了，异常的类型，严重性，触发异常的设置，是内存
		;还是网络，还是CPU，还是接口卡，还是多媒体设备
		;ExceptionFlag 有啥用？
		invoke	wsprintf,addr @szBuffer,addr szInMsg,\
			[edi].regEip,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		
		popad
		mov	eax,ExceptionContinueSearch
		
		assume	esi:nothing,edi:nothing
		ret
_InHandler 	endp

_Handler	proc	c _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext
		LOCAL 	@szBuffer[1024]:byte
		pushad
		
		mov	esi,_lpExceptionRecord
		mov	edi,_lpContext
		assume	esi:ptr	EXCEPTION_RECORD,edi:ptr CONTEXT
		mov	eax,[esi].ExceptionCode
		
		;由于栈展开操作而被调用
		.if 	eax == STATUS_UNWIND
			popad
			mov	eax,ExceptionContinueSearch
		;访问非法
		.elseif eax == EXCEPTION_ACCESS_VIOLATION
			;ExceptionCode中包含了，异常的类型，严重性，触发异常的设置，是内存
			;还是网络，还是CPU，还是接口卡，还是多媒体设置
			;ExceptionFlag 标识符，继续执行，还是栈展开？
			invoke	wsprintf,addr @szBuffer,addr szMsg,\
				[edi].regEip,[esi].ExceptionCode,[esi].ExceptionFlags
			invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		
			mov	eax,_lpSEH
		
			push	[eax+0ch]
			pop	[edi].regEbp
			push	[eax+8]
			pop	[edi].regEip
			push	eax
			pop	[edi].regEsp
			
			invoke	wsprintf,addr @szBuffer,addr szFSMsg,dword ptr fs:[0]
			invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
			invoke	RtlUnwind,_lpSEH,NULL,NULL,NULL
			invoke	wsprintf,addr @szBuffer,addr szFSMsg,dword ptr fs:[0]
			invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
			popad
			mov	eax,ExceptionContinueExecution
		.else
			popad
			mov	eax,ExceptionContinueSearch		
		.endif
		
		assume	esi:nothing,edi:nothing
		ret
_Handler 	endp

_Test		proc
	assume	fs:nothing
	push	ebp
	push	offset _SafePlace
	push	offset _Handler
	;fs:[0]处保留了EXCEPTION_REGISTRATION结构的地址
	push	fs:[0]
	;修改了fs:[0]的指向，栈中的前8个字段刚好吻合了EXCEPTION_REGISTRATION结构中的ExceptionList字段
	mov	fs:[0],esp

	invoke 	_InTest
	
_SafePlace:
	invoke	MessageBox,NULL,addr szSafe,addr szTitle,MB_OK
	pop	fs:[0]
	add	esp,0ch	
	ret
_Test	endp

start:
	invoke	_Test
	invoke	ExitProcess,NULL
end start