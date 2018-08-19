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
szMsg		db	"异常发生位置:%08X，%08X，异常代码:%08X，标志：%08X",0
szSafe		db	"回到了安全的地方",0
szTitle		db	"SEH的例子",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
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
			;ExceptionFlag 有啥用？
			invoke	wsprintf,addr @szBuffer,addr szMsg,\
				[edi].regEip,[esi].ExceptionAddress,[esi].ExceptionCode,[esi].ExceptionFlags
			invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		
			mov	eax,_lpSEH
		
			;mov	[edi].regEip,offset _SafePlace
		
			push	[eax+0ch]
			pop	[edi].regEbp
			push	[eax+8]
			pop	[edi].regEip
			push	eax
			pop	[edi].regEsp
			
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
	;pre EXCEPTION_REGISTRATION
	;handler
	mov	fs:[0],esp

	xor 	eax,eax
	mov	dword ptr [eax],0
	
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