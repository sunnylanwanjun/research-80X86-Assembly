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
szTitle		db	"筛选器异常处理的例子",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
_Handler	proc	_lpExceptionPoint
		LOCAL 	@szBuffer[256]:byte
		pushad
		mov	esi,_lpExceptionPoint
		assume	esi:ptr	EXCEPTION_POINTERS
		mov	edi,[esi].ContextRecord
		mov	esi,[esi].pExceptionRecord
		assume	esi:ptr	EXCEPTION_RECORD,edi:ptr CONTEXT
		mov	eax,[esi].ExceptionFlags
		;如果标志被置位，说明异常是致命的，应该退出
		and	eax,00000001h
		.if	eax==1
			mov	eax,EXCEPTION_CONTINUE_SEARCH
			ret
		.endif
		;ExceptionCode中包含了，异常的类型，严重性，触发异常的设置，是内存
		;还是网络，还是CPU，还是接口卡，还是多媒体设置
		;ExceptionFlag中指名了异常是否导致程序的终止
		invoke	wsprintf,addr @szBuffer,addr szMsg,\
			[edi].regEip,[esi].ExceptionAddress,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		mov	[edi].regEip,offset _SafePlace
		assume	esi:nothing,edi:nothing
		popad	
		;返回值，根据ExceptionFlag来决定是否应该让程序进行下去
		mov	eax,EXCEPTION_CONTINUE_EXECUTION
		ret
_Handler endp

start:
	invoke	SetUnhandledExceptionFilter,addr _Handler
	mov	lpOldHandler,eax
	xor 	eax,eax
	mov	dword ptr [eax],0
_SafePlace:
	invoke	MessageBox,NULL,addr szSafe,addr szTitle,MB_OK
	invoke	ExitProcess,NULL
end start