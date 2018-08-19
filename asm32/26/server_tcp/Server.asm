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
szRecvBuf	db	20  dup(?)
		.const
szIP		db	'127.0.0.1',0
szStartErr	db	'Init Socket Err',0dh,0ah,0
szAddrErr	db	'inet_addr Err',0dh,0ah,0
szErrCode	db	'%s errorCode is %d',0
szSockErr	db	'socket',0
szBindErr	db	'bind',0
szListenErr	db	'listen',0
szAcceptErr	db	'accept',0
;代码
.code

_ShowErrCode proc lpTypeStr
	invoke	WSAGetLastError
	invoke	wsprintf,addr szErrBuf,addr szErrCode,lpTypeStr,eax
	invoke	_WriteConsole,addr szErrBuf,0
	invoke	_WriteEnter
	ret
_ShowErrCode endp

_NewThread proc uses ebx edi esi,lParam
	LOCAL	hNewSocket
	push	lParam
	pop	hNewSocket
	.while	TRUE
		invoke	recv,hNewSocket,addr szRecvBuf,sizeof szRecvBuf,0
		;返回socket_error时，并不是因为客户端主动正常关闭socket,当正常关闭的时候，会返回
		;0,从而终址循环，否则如果客户端，因为各种原因，没有发送关闭的分手信息，那么服务器会
		;产生socket_error信息，从而终址循环，客户端，像由于缓冲区溢出，导怪变量值被非法覆盖，
		;而那个变量值，刚好是socket句柄，从而使得socket无效，于是异常退出了，此时并没有发送
		;分手信息给服务器
		.if	eax==SOCKET_ERROR
			invoke	WSAGetLastError
			.if	eax!=WSAEWOULDBLOCK
				.break
			.endif
		.endif
		.break	.if !eax ;已经没有缓冲区已空
		invoke	_WriteConsole,addr szRecvBuf,eax
		;在TCP协议中RST表示复位，用来异常的关闭连接，在TCP的设计中它是不可或缺的。
		;发送RST包关闭连接时，不必等缓冲区的包都发出去，直接就丢弃缓存区的包发送RST包。
		;而接收端收到RST包后，也不必发送ACK包来确认。 
		;对一个已经关闭的socket发送数据，会收到一个rst,所以这里调用send方法后，再次使用recv
		;就产生一个socket_error了
		;invoke	send,hNewSocket,addr szRecvBuf,eax,0
	.endw
	invoke	closesocket,hNewSocket
	ret
_NewThread endp

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
	mov	wVersionRequested,101h
	invoke	WSAStartup,wVersionRequested,addr wsaData
	.if	eax
		invoke	_WriteConsole,addr szStartErr,0
		ret
	.endif
	
;	invoke	_WriteConsole,addr wsaData.szDescription,0
;	invoke	_WriteEnter
;	invoke	_WriteConsole,addr wsaData.szSystemStatus,0
;	invoke	_WriteEnter
;	movzx	eax,wsaData.iMaxSockets
;	invoke	_WriteInt,eax
;	invoke	_WriteEnter
	
	;创建sockaddr_in
	invoke	RtlZeroMemory,addr sin,sizeof sockaddr_in
	mov	sin.sin_family,AF_INET
	mov	sin.sin_addr,INADDR_ANY	;你家时有好多台电话
	invoke	htons,9999
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
	
	.while	TRUE
		mov	newSinLen,sizeof newSin
		invoke	RtlZeroMemory,addr newSin,newSinLen
		invoke	accept,hSocket,addr newSin,addr newSinLen
		.if	eax==INVALID_SOCKET
			invoke	_ShowErrCode,addr szAcceptErr
			invoke	closesocket,hSocket
			invoke	WSACleanup
			.break
		.endif
		invoke	CreateThread,0,0,offset _NewThread,eax,0,0
		invoke	CloseHandle,eax
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
