;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
QUEUE_SIZE	equ	100		;消息队列的长度
MSG_QUEUE_ITEM	struct			;队列中单条消息的格式定义
  dwMessageId	dd	?		;消息编号
  szSender	db	12 dup (?)	;发送者
  szContent	db	256 dup (?)	;聊天内容
MSG_QUEUE_ITEM	ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data?

stCS		CRITICAL_SECTION <?>
stMsgQueue	MSG_QUEUE_ITEM QUEUE_SIZE dup (<?>)
dwMsgCount	dd	?		;队列中当前消息数量

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data

dwSequence	dd	1	;消息序号，从1开始
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在队列中加入一条消息
; -- 如果队列已经满了，则将整个队列前移一个位置，相当于最早的消息被覆盖
;    然后在队列尾部空出的位置加入新消息
; -- 如果队列未满，则在队列的最后加入新消息
; -- 消息编号从1开始递增，这样保证队列中各消息的编号是连续的
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 入口：_lpszSender = 指向发送者字符串的指针
;	_lpszContent = 指向聊天语句内容字符串的指针
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
_InsertMsgQueue	proc	_lpszSender,_lpszContent
	pushad
	
	invoke	EnterCriticalSection,addr stCS
	.if	dwMsgCount>=QUEUE_SIZE
		mov	esi,offset stMsgQueue+sizeof MSG_QUEUE_ITEM
		mov	edi,offset stMsgQueue
		mov	ecx,QUEUE_SIZE-1
		cld
		rep	movsw
	.else
		inc	dwMsgCount	
	.endif
	
	lea	esi,stMsgQueue
	
	mov	eax,dwMsgCount
	dec	eax
	mov	ecx,sizeof MSG_QUEUE_ITEM
	mul	ecx
	add	esi,eax
	assume  esi:ptr MSG_QUEUE_ITEM
	push	dwSequence
	pop	[esi].dwMessageId
	invoke	lstrcpy,addr [esi].szSender,_lpszSender
	invoke	lstrcpy,addr [esi].szContent,_lpszContent
	
	inc	dwSequence
	popad
	invoke	LeaveCriticalSection,addr stCS
	assume	esi:nothing
	ret
_InsertMsgQueue endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 从队列获取指定编号的消息
; -- 如果指定编号的消息已经被清除出消息队列，则返回编号最小的一条消息
;    当向连接速度过慢的客户端发消息的速度比不上消息被清除的速度，则中间
;    的消息等于被忽略，这样可以保证慢速链路不会影响快速链路
; -- 如果队列中的所有消息的编号都比指定编号小（意味着这些消息以前都被获取过）
;    那么不返回任何消息
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 入口：_dwMessageId = 需要获取的消息编号
;	_lpszSender = 用于返回消息中发送者字符串的缓冲区指针
;	_lpszSender = 用于返回消息中聊天内容字符串的缓冲区指针
; 返回：eax = 0（队列为空，或者队列中没有小于等于指定编号的消息）
;	eax <> 0（已经获取了一条消息，获取的消息编号返回到eax中）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetMsgFromQueue proc	uses ebx esi edi _dwMessageId,_lpszSender,_lpszContent
	mov eax,_dwMessageId
	.if eax>=dwSequence
		mov eax,0
		ret
	.endif
	
	invoke	EnterCriticalSection,addr stCS
	lea esi,stMsgQueue
	assume esi:ptr MSG_QUEUE_ITEM
	mov ebx,1
	.while TRUE		
		mov edi,[esi].dwMessageId
		.if edi==_dwMessageId
			invoke	lstrcpy,_lpszSender,addr [esi].szSender
			invoke	lstrcpy,_lpszContent,addr [esi].szContent
			inc	edi
			.break
		.endif
		add esi,sizeof MSG_QUEUE_ITEM
		inc ebx
		.if ebx>dwMsgCount
			xor edi,edi
			.break	
		.endif
	.endw
	invoke	LeaveCriticalSection,addr stCS
	assume	esi:nothing
	mov	eax,edi
	ret
_GetMsgFromQueue endp