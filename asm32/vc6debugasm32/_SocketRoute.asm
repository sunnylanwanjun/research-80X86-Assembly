;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在规定的时间内等待数据到达
; 输入：dwTime = 需要等待的时间（微秒）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WaitData	proc	_hSocket,_dwTime
	LOCAL   set:fd_set	
	LOCAL	time:timeval
	
	push	_hSocket
	pop	set.fd_array
	mov	set.fd_count,1
	push	_dwTime
	pop	time.tv_usec
	mov	time.tv_sec,0
	invoke	select,0,addr set,0,0,addr time
	ret
_WaitData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 接收规定字节的数据，如果缓冲区中的数据不够则等待
; 返回：eax = TRUE，连接中断或发生错误
;	eax = FALSE，成功
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc	uses esi _hSocket,_lpData,_dwSize
	LOCAL	startTime
	invoke	GetTickCount
	mov	esi,_lpData
	mov	startTime,eax
	.while	TRUE
		invoke	GetTickCount
		sub	eax,startTime
		.if eax>=10*1000
			.break
		.endif
		invoke	_WaitData,_hSocket,100*1000
		.break .if eax==SOCKET_ERROR
		.if eax==0
			.continue
		.endif
		invoke	recv,_hSocket,esi,_dwSize,0
		 .if eax==SOCKET_ERROR || eax==0
			xor	eax,eax
			inc	eax
			ret		 	
		.else
			sub	_dwSize,eax
			add	esi,eax
			xor	eax,eax
			.if _dwSize==0
				ret
			.endif
		.endif
	.endw
	xor	eax,eax
	inc	eax
	ret
_RecvData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 接收一个符合规范的数据包
; 返回：eax = TRUE （失败）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvPacket	proc uses esi _hSocket,_lpBuffer,_dwSize
	;获取包头
	invoke	_RecvData,_hSocket,_lpBuffer,sizeof MSG_HEAD
	cmp	eax,0
	jnz	_RecvPacketErr
	mov	esi,_lpBuffer
	assume  esi:ptr MSG_HEAD
	mov	eax,[esi].dwLength
	cmp	eax,sizeof MSG_HEAD
	je	_RecvPacketFni
	jb	_RecvPacketErr
	cmp	eax,_dwSize
	ja	_RecvPacketErr
	;读取包体
	sub	eax,sizeof MSG_HEAD
	add	esi,sizeof MSG_HEAD
	invoke	_RecvData,_hSocket,esi,eax
	cmp	eax,0
	jnz	_RecvPacketErr
	jmp	_RecvPacketFni
_RecvPacketErr:
	assume esi:nothing
	mov eax,1
	ret
_RecvPacketFni:
	assume esi:nothing
	xor eax,eax
	ret
_RecvPacket	endp