;数据
.data?
IC_hStdIn		dd	?		;控制台输入句柄
IC_hStdOut		dd	?		;控制台输出句柄
IC_szBuffer		db	1024 dup (?)
.const
IC_szTitle		db	'控制台程序',0
IC_Enter		db	0dh,0ah,0
IC_Int			db	'%d',0
;代码
.code

_CtrlHandler	proc	_dwCtrlType

		pushad
		mov	eax,_dwCtrlType
		.if	eax ==	CTRL_C_EVENT || eax == CTRL_BREAK_EVENT
			invoke	CloseHandle,IC_hStdIn
		.endif
		popad
		mov	eax,TRUE
		ret

_CtrlHandler	endp

_InitConsole	proc
	
	invoke	GetStdHandle,STD_INPUT_HANDLE
	mov	IC_hStdIn,eax
	invoke	GetStdHandle,STD_OUTPUT_HANDLE
	mov	IC_hStdOut,eax
	invoke	SetConsoleMode,IC_hStdIn,ENABLE_ECHO_INPUT or ENABLE_LINE_INPUT or ENABLE_PROCESSED_OUTPUT
	invoke	SetConsoleCtrlHandler,offset _CtrlHandler,TRUE
	invoke	SetConsoleTitle,offset IC_szTitle
	ret

_InitConsole    endp

_ReadConsole	proc
	LOCAL	dwBytesRead
	.if	!IC_hStdIn
		mov	eax,0 
		ret
	.endif
	invoke	ReadFile,IC_hStdIn,offset IC_szBuffer,sizeof IC_szBuffer,addr dwBytesRead,0	
	.if	!eax
		ret
	.endif
	lea	eax,IC_szBuffer
	mov	edx,dwBytesRead
	ret
_ReadConsole 	endp

_WriteConsole	proc	lpWriteBuffer,dwWriteBytes
	LOCAL	dwWriteByteNum
	
	.if	!dwWriteBytes
		invoke	lstrlen,lpWriteBuffer
		mov	dwWriteBytes,eax
	.endif
	
	.if	!IC_hStdOut
		mov	eax,0
		ret
	.endif
	invoke	WriteFile,IC_hStdOut,lpWriteBuffer,dwWriteBytes,addr dwWriteByteNum,0
	mov	eax,dwWriteByteNum 
	ret
_WriteConsole 	endp

_ConcatEnter	proc	lpStr
	.if !lpStr
		mov eax,0
		ret
	.endif
	invoke	lstrcat,lpStr,addr IC_Enter
	invoke	lstrlen,lpStr
	ret
_ConcatEnter	endp

_WriteEnter	proc
	invoke	_WriteConsole,addr IC_Enter,2
	ret
_WriteEnter endp

_WriteInt	proc dwInt
	invoke	wsprintf,addr IC_szBuffer,addr IC_Int,dwInt
	invoke	_WriteConsole,addr IC_szBuffer,0
	ret
_WriteInt endp