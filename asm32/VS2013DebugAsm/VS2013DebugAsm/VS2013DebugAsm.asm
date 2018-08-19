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
szExcetion	db	"要触发异常了%08X,%08X",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
_Handler	proc	c _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext
		LOCAL 	@szBuffer[1024]:byte
		pushad
		mov	esi,_lpExceptionRecord
		assume	esi:ptr	EXCEPTION_RECORD
		mov	edi,_lpContext
		assume	esi:ptr	EXCEPTION_RECORD,edi:ptr CONTEXT
		mov	eax,[esi].ExceptionFlags
		;如果标志被置位，说明异常是致命的，应该退出
		;and	eax,00000001h
		;.if	eax==1
		;	popad
		;	mov	eax,EXCEPTION_CONTINUE_SEARCH
		;	ret
		;.endif
		
		mov	eax,_lpSEH
		
		;mov	[edi].regEip,offset _SafePlace
		
		push	[eax+0ch]
		pop	[edi].regEbp
		push	[eax+8]
		pop	[edi].regEip
		push	eax
		pop	[edi].regEsp
		
		;ExceptionCode中包含了，异常的类型，严重性，触发异常的设置，是内存
		;还是网络，还是CPU，还是接口卡，还是多媒体设置
		;ExceptionFlag中指名了异常是否导致程序的终止
		invoke	wsprintf,addr @szBuffer,addr szMsg,\
			[edi].regEip,[esi].ExceptionAddress,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		
		assume	esi:nothing,edi:nothing
		popad	
		;返回值，根据ExceptionFlag来决定是否应该让程序进行下去
		mov	eax,ExceptionContinueExecution
		ret
_Handler 	endp

_Test		proc
	LOCAL 	szBuff[256]:byte
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
	mov	ebx,offset _SafePlace
	invoke 	wsprintf,addr szBuff,addr szExcetion,ebx,addr _Test
	invoke	MessageBox,NULL,addr szBuff,addr szTitle,MB_OK	
	xor 	eax,eax
	mov	dword ptr [eax],0
	
_SafePlace:
	pop	fs:[0]
	add	eax,0ch
	invoke	MessageBox,NULL,addr szSafe,addr szTitle,MB_OK	
_Test	endp

start:
	invoke	_Test
	invoke	ExitProcess,NULL
end start