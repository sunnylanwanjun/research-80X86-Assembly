.386
.model flat,stdcall
option casemap:none
;预定义

;头文件
include		windows.inc   	;常量定义
include		kernel32.inc  	;GetModuleHandle ExitProcess 的定义
includelib	kernel32.lib	
include		user32.inc	;EndDialog DialogBoxParam 的定义
includelib	user32.lib
include		ws2_32.inc
includelib	ws2_32.lib

ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_COUNT	equ	2001
TCP_PORT	equ	9999

		.data?
hModule		dd	?	
hWinMain	dd	?	
szErrBuf	db	512 dup(?)
szRecvBuf	db	20  dup(?)
hSocket		dd	?;这个相当于一个专门用来监听的电话线
dwStopListen	dd	?
dwServerThread	dd	?

		.const
szIP		db	'127.0.0.1',0
szStartErr	db	'Init Socket Err',0dh,0ah,0
szAddrErr	db	'inet_addr Err',0dh,0ah,0
szErrCode	db	'%s errorCode is %d',0
szSockErr	db	'socket',0
szBindErr	db	'bind',0
szListenErr	db	'listen',0
szAcceptErr	db	'accept',0
FStop		equ	0001h
;代码
.code

_WriteConsole	proc	lpWriteBuffer,dwWriteBytes
	invoke	MessageBox,NULL,lpWriteBuffer,NULL,MB_OK
	ret
_WriteConsole 	endp

_WriteEnter	proc
	ret
_WriteEnter endp

_ShowErrCode proc lpTypeStr
	invoke	WSAGetLastError
	invoke	wsprintf,addr szErrBuf,addr szErrCode,lpTypeStr,eax
	invoke	_WriteConsole,addr szErrBuf,0
	invoke	_WriteEnter
	ret
_ShowErrCode endp

_ServiceThread proc uses ebx edi esi,lParam
	LOCAL	hNewSocket
	LOCAL   set:fd_set	
	LOCAL	time:timeval
	
	invoke	RtlZeroMemory,addr set,sizeof fd_set
	
	inc	dwServerThread
	invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwServerThread,FALSE
	.while	!(dwStopListen&FStop)
	
		push	lParam
		pop	hNewSocket
		push	lParam
		pop	set.fd_array
		mov	set.fd_count,1
		mov	time.tv_usec,200*1000
		mov	time.tv_sec,0
		
		invoke	select,0,addr set,0,0,addr time
		.break .if eax==SOCKET_ERROR
		.if 	eax
			invoke	recv,hNewSocket,addr szRecvBuf,sizeof szRecvBuf,0
			.if	eax==SOCKET_ERROR
				invoke	WSAGetLastError
				.if	eax!=WSAEWOULDBLOCK
					.break
				.endif
			.endif
			.break	.if !eax ;缓冲区已空
			invoke	send,hNewSocket,addr szRecvBuf,eax,0
			.break  .if eax==SOCKET_ERROR 
 		.endif
	.endw
	invoke	closesocket,hNewSocket
	dec	dwServerThread
	invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwServerThread,FALSE
	ret
_ServiceThread endp

_ListenThread proc
	LOCAL	sin:sockaddr_in
	LOCAL	newSin:sockaddr_in
	LOCAL	newSinLen
	
	;创建sockaddr_in
	invoke	RtlZeroMemory,addr sin,sizeof sockaddr_in
	mov	sin.sin_family,AF_INET
	mov	sin.sin_addr,INADDR_ANY	;你家时有好多台电话
	invoke	htons,TCP_PORT
	mov	sin.sin_port,ax
	
	;套接字，用来通信的对象,被定义为通信的一端,在另一端必须有另一个套接字，才能进行通信
	;套接字分为两种，流套接字，数据报套接字
	invoke	socket,AF_INET,SOCK_STREAM,0
	.if	eax==INVALID_SOCKET
		invoke	_ShowErrCode,addr szSockErr
		invoke	WSACleanup
		ret
	.endif
	mov	hSocket,eax
	
	invoke	bind,hSocket,addr sin,sizeof sin
	;错误码
	;WSAEADDRINUSE	端口已经正在使用       该地址已经被其它人用过了，一台电话，只能被一个人用
	;WSAEFAULT	端口已经绑定过一次了   已经注册过一次地址了
	.if	eax==SOCKET_ERROR
		invoke	_ShowErrCode,addr szBindErr
		invoke	closesocket,hSocket
		invoke	WSACleanup
	.endif
	
	invoke	listen,hSocket,3
	;错误码
	;WSAEINVAL	还没有bind就进行监听 没有注册一个准确的地址，就想准备听电话
	.if	eax==SOCKET_ERROR
		invoke	_ShowErrCode,addr szListenErr
		invoke	closesocket,hSocket
		invoke	WSACleanup
		ret
	.endif
	
	.while	!(dwStopListen&FStop)
		mov	newSinLen,sizeof newSin
		invoke	RtlZeroMemory,addr newSin,newSinLen
		invoke	accept,hSocket,addr newSin,addr newSinLen
		.if	eax==INVALID_SOCKET
			invoke	_ShowErrCode,addr szAcceptErr
			invoke	closesocket,hSocket
			invoke	WSACleanup
			.break
		.endif
		invoke	CreateThread,0,0,offset _ServiceThread,eax,0,0
		invoke	CloseHandle,eax
	.endw
	
	ret
_ListenThread endp

_DialogProc proc hWnd,uMsg,wParam,lParam
	LOCAL	wVersionRequested
	LOCAL	wsaData:WSADATA
	
	mov	eax,uMsg
;********************************************************************
	.if	eax ==	WM_INITDIALOG
		push	hWnd
		pop	hWinMain
		
		;初始化
		mov	wVersionRequested,101h
		invoke	WSAStartup,wVersionRequested,addr wsaData
		.if	eax
			invoke	_WriteConsole,addr szStartErr,0
			jmp	dlgEnd
		.endif
		invoke	CreateThread,0,0,offset _ListenThread,0,0,0
		invoke	CloseHandle,eax
;********************************************************************
	.elseif	eax ==	WM_CLOSE
		or	dwStopListen,FStop
		invoke	closesocket,hSocket
		.while	dwServerThread
		.endw
		invoke	WSACleanup
		invoke	EndDialog,hWinMain,NULL
;********************************************************************
	.else
		mov	eax,FALSE
		ret
	.endif

dlgEnd:
	mov	eax,TRUE
	ret	
_DialogProc endp

start:
	invoke	GetModuleHandle,NULL
	mov	hModule,eax
	invoke	DialogBoxParam,hModule,DLG_MAIN,NULL,offset _DialogProc,0
	invoke	ExitProcess,NULL
end start
