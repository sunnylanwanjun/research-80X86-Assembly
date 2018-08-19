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
szRecvBuf	db	1024  dup(?)
		.const
szIP		db	'127.0.0.1',0
szStartErr	db	'Init Socket Err',0dh,0ah,0
szAddrErr	db	'inet_addr Err',0dh,0ah,0
szErrCode	db	'%s errorCode is %d',0
szSockErr	db	'socket',0
szBindErr	db	'bind',0
szListenErr	db	'listen',0
szAcceptErr	db	'accept',0
szRecvErr	db	'recv',0
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
	LOCAL	hSocket			;这个相当于一个专门用来监听的电话线
	LOCAL	hNewSocket		;这个是用来通话的电话线,是数据线路
	LOCAL	newSin:sockaddr_in
	LOCAL	newSinLen
	
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
	mov	sin.sin_addr,INADDR_ANY	;你家时有好多台电话
	invoke	htons,5150
	mov	sin.sin_port,ax
	
	;套接字，用来通信的对象,被定义为通信的一端,在另一端必须有另一个套接字，才能进行通信
	;套接字分为两种，流套接字，数据报套接字
	invoke	socket,AF_INET,SOCK_DGRAM,0
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
	
	mov	newSinLen,sizeof newSin
	invoke	RtlZeroMemory,addr newSin,newSinLen
	
	;使用UDP要注意socket的类型，一定要是SOCK_DGRAM，否则会报10057的错
	;接收缓冲区如果不够大，会报10040的错
	.while	TRUE
		invoke	recvfrom,hSocket,addr szRecvBuf,sizeof szRecvBuf,0,addr newSin,addr newSinLen
		.if	eax==SOCKET_ERROR
			invoke	WSAGetLastError
			.if	eax!=WSAEWOULDBLOCK
				invoke	_ShowErrCode,addr szRecvErr
				.break
			.endif
			.continue
		.endif
		invoke	_WriteConsole,addr szRecvBuf,0
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
