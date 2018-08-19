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
include		_Message.inc

		.data?
szErrBuf	db	512 dup(?)

hInstance	dd	?
hWinMain	dd	?
hSocket		dd	?
hLogin		dd	?
hLoginOut	dd	?
hInputText	dd	?
hSendBtn	dd	?
dwLastTime	dd	?
szServer	db	16 dup (?)
szUserName	db	12 dup (?)
szPassword	db	12 dup (?)
szText		db	256 dup (?)

szSendMsg	MSG_STRUCT 10 dup (<>)
szRecvMsg	MSG_STRUCT 10 dup (<>)
dwSendBufSize	dd	?
dwRecvBufSize	dd	?
dbStep		db	?

		.const
szIP		db	'127.0.0.1',0
szStartErr	db	'Init Socket Err',0
szAddrErr	db	'inet_addr Err',0
szErrCode	db	'%s errorCode is %d',0
szSendFmt	db	'hello world %d',0dh,0ah,0
szSockErr	db	'socket',0
szConnErr	db	'connect',0
szSendErr	db	'send',0

szErrIP		db	'无效的服务器IP地址!',0
szErrConnect	db	'无法连接到服务器!',0
szErrLogin	db	'无法登录到服务器，请检查用户名密码!',0
szSpar		db	' : ',0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	equ 数据
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_SERVER	equ	2001
IDC_USER	equ	2002
IDC_PASS	equ	2003
IDC_LOGIN	equ	2004
IDC_LOGOUT	equ	2005
IDC_INFO	equ	2006
IDC_TEXT	equ	2007
TCP_PORT	equ	9999
WM_SOCKET       equ	WM_USER + 100

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

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 断开连接
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DisConnect	proc

	invoke	EnableWindow,hLogin,TRUE
	invoke	EnableWindow,hLoginOut,FALSE
	invoke	EnableWindow,hInputText,FALSE

	.if hSocket
		invoke	closesocket,hSocket
		mov	hSocket,0
	.endif
	ret
_DisConnect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 连接到服务器
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Connect	proc
	LOCAL	sin:sockaddr_in
	
	;创建sockaddr_in
	invoke	RtlZeroMemory,addr sin,sizeof sockaddr_in
	mov	sin.sin_family,AF_INET
	invoke	inet_addr,addr szServer
	.if	eax==INADDR_NONE
		invoke	_WriteConsole,addr szAddrErr,0
		jmp	_ConnectEnd
	.endif
	mov	sin.sin_addr,eax
	invoke	htons,9999
	mov	sin.sin_port,ax
	
	;套接字，用来通信的对象,被定义为通信的一端,在另一端必须有另一个套接字，才能进行通信
	;套接字分为两种，流套接字，数据报套接字
	invoke	socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
	.if	eax==INVALID_SOCKET
		invoke	_ShowErrCode,addr szSockErr
		jmp	_ConnectEnd
	.endif
	mov	hSocket,eax
	
	;以非阻塞模式连接服务器
	invoke	WSAAsyncSelect,hSocket,hWinMain,WM_SOCKET,FD_READ or FD_WRITE or FD_CONNECT or FD_CLOSE
	invoke	connect,hSocket,addr sin,sizeof sin
	;错误码
	;WSAECONNREFUSED 服务器没有在指定的端口监听，电话在，不过人不在电话旁边
	;WSAETIMEOUT	 网络不通，服务器不在线，    电话不在，打的是空号
	;WSAEWOULDBLOCK	 正在连接，还需等待,         电话还在响铃中
	.if	eax==SOCKET_ERROR
		invoke	WSAGetLastError
		.if	eax!=WSAEWOULDBLOCK
			invoke	_ShowErrCode,addr szConnErr
			jmp	_ConnectEnd
		.endif
	.endif
	
	ret
	
_ConnectEnd:
	.if hSocket
		invoke	CloseHandle,hSocket
		mov	hSocket,0
	.endif
	ret
_Connect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 发送缓冲区中的数据，上次的数据有可能未发送完，故每次发送前，
; 先将发送缓冲区合并
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SendData	proc	_lpData,_dwSize
	pushad
	mov	esi,_lpData
	mov	ecx,_dwSize
	
	.if	esi && ecx
		lea	edi,szSendMsg
		add	edi,dwSendBufSize
		cld
		rep	movsb
		mov	ecx,_dwSize
		add	dwSendBufSize,ecx
	.endif
	
	cmp	dwSendBufSize,0
	jz	_SendDataEnd
	mov	ecx,dwSendBufSize
	lea	esi,szSendMsg
@@:
	invoke	send,hSocket,esi,ecx,0
	.if	eax==SOCKET_ERROR
		invoke	WSAGetLastError
		.if	eax!=WSAEWOULDBLOCK
			invoke	_DisConnect
		.endif
		jmp	_SendDataEnd
	.endif
	sub	dwSendBufSize,eax
	jz	_SendDataEnd
	.if	eax!=0 ;如果发送数据为0，说明缓冲区已经满了，等下次收到FD_WRITE时再发，等待的话，会影响界面相应
		mov	ecx,dwSendBufSize
		add	esi,eax
		jmp	@B
	.endif
_SendDataEnd:
	popad
	ret
_SendData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 处理消息
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcMessage	proc
	LOCAL	@szBuffer[512]:byte
	pushad
	assume	esi:ptr MSG_STRUCT
	lea	esi,szRecvMsg
	mov	ax,[esi].MsgHead.dwCmdId
	.if	ax==CMD_LOGIN_RESP
		.if	[esi].LoginResp.dbResult!=0
			invoke	EnableWindow,hLogin,TRUE
			invoke	EnableWindow,hLoginOut,FALSE
			invoke	EnableWindow,hInputText,FALSE
			invoke	_DisConnect
		.else
			invoke	EnableWindow,hLogin,FALSE
			invoke	EnableWindow,hLoginOut,TRUE
			invoke	EnableWindow,hInputText,TRUE
		.endif
	.elseif	ax==CMD_MSG_DOWN
		invoke	lstrcpy,addr @szBuffer,addr [esi].MsgDown.szSender
		invoke	lstrcat,addr @szBuffer,addr szSpar
		invoke	lstrcat,addr @szBuffer,addr [esi].MsgDown.szContent
		invoke	SendDlgItemMessage,hWinMain,IDC_INFO,LB_INSERTSTRING,0,addr @szBuffer
	.endif
	
_ProcMessageEnd:
	popad	
	assume	esi:nothing
	ret
_ProcMessage	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 接收数据包
; 异步的读取不用自己去循环读取，如果缓冲区中有数据，会一直有FD_READ消息
; 但是同步的必须自己循环读，直到缓冲区没有数据读为止，而对于写，不管是异步还是
; 同步，都必须自己去写，因为只有只有你自己才知道要写多少，
; 如果程序在写的过程中，发生了错误，会终止写的过程,同步的情况下，要你自己不断
; 地去询问可以写了没，可以写了没，而异步的情况下，会有FD_WRITE的消息通知,所以
; 总结一点，同步的情况下，用select函数循环不断的询问可以写或读了没，而异步的情况下
; 会有系统消息通知
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc

	;szRecvMsg	读取缓冲
	;dwRecvBufSize	记录上次读了多少数据,为0表示从新开始读一个协议

	pushad
	lea	esi,szRecvMsg
	assume  esi:ptr MSG_STRUCT
	
	.if	dwRecvBufSize==0
		mov	eax,sizeof MSG_HEAD
	.elseif	dwRecvBufSize<sizeof MSG_HEAD
		mov	eax,sizeof MSG_HEAD
		sub	eax,dwRecvBufSize
	.else
		mov	eax,[esi].MsgHead.dwLength
		sub	eax,dwRecvBufSize
	.endif
	add	esi,dwRecvBufSize
	invoke	recv,hSocket,esi,eax,0
	.if	eax==SOCKET_ERROR
		invoke	WSAGetLastError
		.if	eax!=WSAEWOULDBLOCK
			invoke	_DisConnect
		.endif
		jmp _RecvDataEnd
	.endif
	add	dwRecvBufSize,eax
	.if	dwRecvBufSize>=sizeof MSG_HEAD
		mov	eax,szRecvMsg.MsgHead.dwLength
		.if	eax==dwRecvBufSize
			invoke	_ProcMessage
			mov	dwRecvBufSize,0
		.endif
	.endif
_RecvDataEnd:
	assume  esi:nothing
	popad
	ret
_RecvData	endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 主窗口程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA,@stMsg:MSG_STRUCT
	
		mov	eax,wMsg
		.if	eax==WM_SOCKET
			mov	eax,lParam
			.if	ax==FD_READ
				invoke	_RecvData
			.elseif	ax==FD_WRITE
				invoke	_SendData,0,0
			.elseif ax==FD_CONNECT
				shr	eax,16
				.if	ax==0
					;连接成功后，发送登陆请求
					mov	@stMsg.MsgHead.dwCmdId,CMD_LOGIN
					mov	@stMsg.MsgHead.dwLength,sizeof MSG_HEAD+sizeof MSG_LOGIN
					invoke	lstrcpy,addr @stMsg.Login.szUserName,addr szUserName
					invoke	lstrcpy,addr @stMsg.Login.szPassword,addr szPassword
					invoke	_SendData,addr @stMsg,@stMsg.MsgHead.dwLength
				.else
					invoke	_ShowErrCode,addr szConnErr
					invoke	_DisConnect
				.endif
			.elseif ax==FD_CLOSE
				invoke	_DisConnect
			.endif
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
;********************************************************************
; 全部输入IP地址，用户名和密码后则激活"登录"按钮
;********************************************************************
			.if	(ax == IDC_SERVER) || (ax == IDC_USER) || (ax == IDC_PASS)
				invoke	GetDlgItemText,hWnd,IDC_SERVER,addr szServer,sizeof szServer
				invoke	GetDlgItemText,hWnd,IDC_USER,addr szUserName,sizeof szUserName
				invoke	GetDlgItemText,hWnd,IDC_PASS,addr szPassword,sizeof szPassword
				.if	szServer&&szUserName&&szPassword&& !hSocket
					invoke	EnableWindow,hLogin,TRUE
				.else
					invoke	EnableWindow,hLogin,FALSE
				.endif
;********************************************************************
; 登录成功后，输入聊天语句后才激活"发送"按钮
;********************************************************************
			.elseif	ax ==	IDC_TEXT
				invoke	GetWindowText,hInputText,addr szText,sizeof szText
				.if	szText && hSocket
					invoke	EnableWindow,hSendBtn,TRUE
				.else
					invoke	EnableWindow,hSendBtn,FALSE				
				.endif
;********************************************************************
			.elseif	ax ==	IDC_LOGIN
				invoke	_Connect
				invoke	EnableWindow,hLogin,FALSE
;********************************************************************
			.elseif	ax ==	IDC_LOGOUT
				invoke	_DisConnect
;********************************************************************
			.elseif	ax ==	IDOK
				mov	@stMsg.MsgHead.dwCmdId,CMD_MSG_UP
				invoke	lstrcpy,addr @stMsg.MsgUp.szContent,addr szText
				invoke	lstrlen,addr szText
				inc	eax
				mov	@stMsg.MsgUp.dwLength,eax
				add	eax,sizeof MSG_HEAD+MSG_UP.szContent
				mov	@stMsg.MsgHead.dwLength,eax
				invoke	_SendData,addr @stMsg,eax
				invoke	SetDlgItemText,hWnd,IDC_TEXT,NULL
				invoke	RtlZeroMemory,addr szText,sizeof szText
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	_DisConnect
			invoke	WSACleanup
			invoke  EndDialog,hWnd,0
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	GetDlgItem,hWnd,IDC_LOGIN
			mov	hLogin,eax
			invoke	GetDlgItem,hWnd,IDC_LOGOUT
			mov	hLoginOut,eax
			invoke	GetDlgItem,hWnd,IDC_TEXT
			mov	hInputText,eax
			invoke	GetDlgItem,hWnd,IDOK
			mov	hSendBtn,eax
			invoke	EnableWindow,hLogin,FALSE
			invoke	EnableWindow,hLoginOut,FALSE
			
			invoke	WSAStartup,101h,addr @stWsa
			.if	eax
				invoke	_WriteConsole,addr szStartErr,0
			.endif
			
;********************************************************************
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
	invoke	ExitProcess,NULL
end start
