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

;代码
.code

include		_Message.inc
include		_SocketRoute.asm
include		_MsgQueue.asm

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

_WorkThread proc uses edi esi lParam
	LOCAL	sin:sockaddr_in
	LOCAL	@szBuffer[512]:byte
	LOCAL	@stMsg:MSG_STRUCT
	
	;创建sockaddr_in
	invoke	RtlZeroMemory,addr sin,sizeof sockaddr_in
	mov	sin.sin_family,AF_INET
	invoke	inet_addr,addr szServer
	.if	eax==INADDR_NONE
		invoke	_WriteConsole,addr szAddrErr,0
		jmp	_WorkThreadEnd
	.endif
	mov	sin.sin_addr,eax
	invoke	htons,9999
	mov	sin.sin_port,ax
	
	;套接字，用来通信的对象,被定义为通信的一端,在另一端必须有另一个套接字，才能进行通信
	;套接字分为两种，流套接字，数据报套接字
	invoke	socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
	.if	eax==INVALID_SOCKET
		invoke	_ShowErrCode,addr szSockErr
		jmp	_WorkThreadEnd
	.endif
	mov	hSocket,eax
	invoke	connect,hSocket,addr sin,sizeof sin
	;错误码
	;WSAECONNREFUSED 服务器没有在指定的端口监听，电话在，不过人不在电话旁边
	;WSAETIMEOUT	 网络不通，服务器不在线，    电话不在，打的是空号
	;WSAEWOULDBLOCK	 正在连接，还需等待,         电话还在响铃中
	.if	eax==SOCKET_ERROR
		invoke	_ShowErrCode,addr szConnErr
		jmp	_WorkThreadEnd
	.endif
	
	;连接成功后，发送登陆请求
	lea	esi,@szBuffer
	lea	edi,@stMsg
	assume	esi:ptr MSG_STRUCT
	assume	edi:ptr MSG_STRUCT
	mov	[esi].MsgHead.dwCmdId,CMD_LOGIN
	mov	[esi].MsgHead.dwLength,sizeof MSG_HEAD+sizeof MSG_LOGIN
	invoke	lstrcpy,addr [esi].Login.szUserName,addr szUserName
	invoke	lstrcpy,addr [esi].Login.szPassword,addr szPassword
	invoke	send,hSocket,esi,[esi].MsgHead.dwLength,0
	
	invoke	_RecvPacket,hSocket,esi,sizeof @szBuffer
	cmp	eax,0
	jnz 	_WorkThreadEnd
	cmp	[esi].MsgHead.dwCmdId,CMD_LOGIN_RESP
	jnz	_WorkThreadEnd
	cmp	[esi].LoginResp.dbResult,0
	jnz	_WorkThreadEnd
	
	invoke	EnableWindow,hLogin,FALSE
	invoke	EnableWindow,hLoginOut,TRUE
	invoke	EnableWindow,hInputText,TRUE
	
	.while	hSocket
		invoke	_WaitData,hSocket,200*1000
		.break	.if eax==SOCKET_ERROR
		.if	eax
			invoke	_RecvPacket,hSocket,edi,sizeof @stMsg
			.break	.if eax
			.if	[edi].MsgHead.dwCmdId==CMD_MSG_DOWN
				invoke	lstrcpy,esi,addr [edi].MsgDown.szSender
				invoke	lstrcat,esi,addr szSpar
				invoke	lstrcat,esi,addr [edi].MsgDown.szContent
				invoke	SendDlgItemMessage,hWinMain,IDC_INFO,LB_INSERTSTRING,0,esi
			.endif	
		.endif
	.endw
	
_WorkThreadEnd:
	.if hSocket
		invoke	CloseHandle,hSocket
		mov	hSocket,0
	.endif
	invoke	EnableWindow,hLogin,TRUE
	invoke	EnableWindow,hLoginOut,FALSE
	invoke	EnableWindow,hInputText,FALSE
	assume	esi:nothing
	assume	edi:nothing
	ret
_WorkThread endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 主窗口程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA,@stMsg:MSG_STRUCT
	
		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_COMMAND
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
				invoke	CreateThread,0,0,offset _WorkThread,0,0,0
				invoke	CloseHandle,eax
				invoke	EnableWindow,hLogin,FALSE
;********************************************************************
			.elseif	ax ==	IDC_LOGOUT
				invoke	closesocket,hSocket
				mov	hSocket,0
;********************************************************************
			.elseif	ax ==	IDOK
				mov	@stMsg.MsgHead.dwCmdId,CMD_MSG_UP
				invoke	lstrcpy,addr @stMsg.MsgUp.szContent,addr szText
				invoke	lstrlen,addr szText
				inc	eax
				mov	@stMsg.MsgUp.dwLength,eax
				add	eax,sizeof MSG_HEAD+MSG_UP.szContent
				mov	@stMsg.MsgHead.dwLength,eax
				invoke	send,hSocket,addr @stMsg,@stMsg.MsgHead.dwLength,0
				invoke	SetDlgItemText,hWnd,IDC_TEXT,NULL
				invoke	RtlZeroMemory,addr szText,sizeof szText
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			.if hSocket
				invoke	closesocket,hSocket
				mov	hSocket,0
			.endif
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
