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
include		InitConsole.asm
include		ws2_32.inc
includelib	ws2_32.lib
		.data?
szErrBuf	db	512 dup(?)
szSendBuf	db	8192 dup(?)
		.const
szIP		db	'127.0.0.1',0
szStartErr	db	'Init Socket Err',0
szAddrErr	db	'inet_addr Err',0
szErrCode	db	'%s errorCode is %d',0
szSendFmt	db	'hello world %d',0dh,0ah,0
szSockErr	db	'socket',0
szConnErr	db	'connect',0
szSendErr	db	'send',0
;代码
.code

_ShowErrCode proc lpTypeStr
	invoke	WSAGetLastError
	invoke	wsprintf,addr szErrBuf,addr szErrCode,lpTypeStr,eax
	invoke	_WriteConsole,addr szErrBuf,0
	invoke	_WriteEnter
	ret
_ShowErrCode endp

_Main 	proc	uses ebx esi
	LOCAL	wVersionRequested
	LOCAL	wsaData:WSADATA
	LOCAL	sin:sockaddr_in
	LOCAL	ip
	LOCAL	hSocket
	LOCAL	szTemp[128]:byte
	LOCAL	sendAddr
	LOCAL	sendSize
	
	;初始化
	mov	wVersionRequested,202h
	invoke	WSAStartup,wVersionRequested,addr wsaData
	.if	eax
		invoke	_WriteConsole,addr szStartErr,0
		ret
	.endif
	
	invoke	_WriteConsole,addr wsaData.szDescription,0
	invoke	_WriteEnter
	invoke	_WriteConsole,addr wsaData.szSystemStatus,0
	invoke	_WriteEnter
	movzx	eax,wsaData.iMaxSockets
	invoke	_WriteInt,eax
	invoke	_WriteEnter
	
	;创建sockaddr_in
	invoke	RtlZeroMemory,addr sin,sizeof sockaddr_in
	mov	sin.sin_family,AF_INET
	invoke	inet_addr,addr szIP
	.if	eax==INADDR_NONE
		invoke	_WriteConsole,addr szAddrErr,0
		invoke	WSACleanup
		ret
	.endif
	mov	sin.sin_addr,eax
	invoke	htons,5150
	mov	sin.sin_port,ax
	
	;套接字，用来通信的对象,被定义为通信的一端,在另一端必须有另一个套接字，才能进行通信
	;套接字分为两种，流套接字，数据报套接字
	invoke	socket,AF_INET,SOCK_DGRAM,0
	.if	eax==INVALID_SOCKET
		invoke	_ShowErrCode,addr szSockErr
		invoke	closesocket,hSocket
		invoke	WSACleanup
		ret
	.endif
	mov	hSocket,eax
	
	xor	ebx,ebx
	mov	sendSize,ebx
	.while	TRUE
		inc ebx
		.break .if ebx>10
		invoke	wsprintf,addr szTemp,addr szSendFmt,ebx
		invoke	lstrcat,addr szSendBuf,addr szTemp
		invoke	lstrlen,addr szTemp
		add	sendSize,eax
	.endw	
	
	lea	eax,szSendBuf
	mov	sendAddr,eax
	.while	TRUE
		invoke  sendto,hSocket,sendAddr,sendSize,0,addr sin,sizeof sin
		.if	eax==SOCKET_ERROR
			invoke	WSAGetLastError
			.if	eax!=WSAEWOULDBLOCK
				invoke	_ShowErrCode,addr szSendErr
				.break
			.endif
		.endif
		.break
	.endw
	
	invoke	closesocket,hSocket
	invoke	WSACleanup
	ret
_Main endp
start:
	invoke	_InitConsole
	invoke	_Main
	;invoke	_ReadConsole
	invoke	ExitProcess,NULL
end start
