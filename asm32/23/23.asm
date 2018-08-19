.386
.model flat,stdcall
option casemap:none
;预定义
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_COUNTER1	equ	1001
IDC_COUNTER2	equ	1002
;头文件
include		windows.inc   	;常量定义
include		kernel32.inc  	;GetModuleHandle ExitProcess 的定义
includelib	kernel32.lib	
include		user32.inc	;EndDialog DialogBoxParam 的定义
includelib	user32.lib
;数据
.data?
hInstance	dd			?
hWinMain	dd			?
dwThread	dd			?
dwCounter0	dd			?
dwCounter1	dd			?
hEvent		dd			?
stCritical	CRITICAL_SECTION       <?>
hMutex		dd			?
hSemaphore	dd			?
.const
nCounter	dd	10
F_THREADING	equ	0001h
szStop		db	'停止计数',0
szStart		db	'计数',0
;代码
.code
_Counter proc uses ebx edi esi,lParam

;	使用事件对象，优点由于可以指定名称，所以跨进程，但缺点也正因为可以跨进程，占用的资源比较多
;	所以比较耗时
;	.while  dwThread&F_THREADING
;		;发现单线程如果不使用同步的方法，也会出现不同步的情况，是因为显示数目与设置数目不同步
;		;只有显示的时候不修改，修改的时候不显示，才有可能显示出真正的数目
;		invoke	WaitForSingleObject,hEvent,INFINITE ;自动复位，也就是帮你加了一行代码 invoke ResetEvent,hEvent
;		inc	dwCounter0
;		mov	eax,dwCounter1
;		inc	eax
;		mov	dwCounter1,eax
;		invoke	SetEvent,hEvent
;	.endw
	
;	使用临界区	
;	.while  dwThread&F_THREADING	
;		invoke	EnterCriticalSection,addr stCritical
;		inc	dwCounter0
;		mov	eax,dwCounter1
;		inc	eax
;		mov	dwCounter1,eax
;		invoke	LeaveCriticalSection,addr stCritical
;	.endw
	
;	使用互斥量
;	.while	dwThread&F_THREADING	
;		invoke	WaitForSingleObject,hMutex,INFINITE
;		inc	dwCounter0
;		mov	eax,dwCounter1
;		inc	eax
;		mov	dwCounter1,eax
;		invoke	ReleaseMutex,hMutex	
;	.endw

;	使用信号灯	
	.while	dwThread&F_THREADING
		invoke	WaitForSingleObject,hSemaphore,INFINITE;每获取一栈灯，会灭掉一栈
		inc	dwCounter0
		mov	eax,dwCounter1
		inc	eax
		mov	dwCounter1,eax		
		invoke	ReleaseSemaphore,hSemaphore,1,0;重新点亮一栈
	.endw
	
	ret
_Counter endp
_DialogProc proc hWnd,uMsg,wParam,lParam
	mov	eax,uMsg
	.if	eax==WM_TIMER

;		使用事件对象	
;		invoke	WaitForSingleObject,hEvent,INFINITE
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER1,dwCounter0,FALSE
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER2,dwCounter1,FALSE
;		invoke	SetEvent,hEvent

;		使用临界区
;		invoke	EnterCriticalSection,addr stCritical
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER1,dwCounter0,FALSE
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER2,dwCounter1,FALSE
;		invoke	LeaveCriticalSection,addr stCritical	

;		使用互斥量
;		invoke	WaitForSingleObject,hMutex,INFINITE
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER1,dwCounter0,FALSE
;		invoke	SetDlgItemInt,hWnd,IDC_COUNTER2,dwCounter1,FALSE
;		invoke	ReleaseMutex,hMutex			

;		信号灯		
		invoke	WaitForSingleObject,hSemaphore,INFINITE;每获取一栈灯，会灭掉一栈
		invoke	SetDlgItemInt,hWnd,IDC_COUNTER1,dwCounter0,FALSE
		invoke	SetDlgItemInt,hWnd,IDC_COUNTER2,dwCounter1,FALSE	
		invoke	ReleaseSemaphore,hSemaphore,1,0;重新点亮一栈		
		
	.elseif	eax==WM_COMMAND
		mov	eax,wParam
		.if	ax==IDOK		
			.if dwThread&F_THREADING
				and	dwThread,not F_THREADING
				invoke	SetDlgItemText,hWnd,IDOK,addr szStart
				invoke	KillTimer,hWnd,1
				invoke	CloseHandle,hEvent
				invoke	CloseHandle,hMutex
				invoke	CloseHandle,hSemaphore
				invoke	DeleteCriticalSection,addr stCritical
			.else
				mov	dwCounter0,0
				mov	dwCounter1,0
				invoke	SetDlgItemText,hWnd,IDOK,addr szStop
				or	dwThread,F_THREADING
				xor 	ebx,ebx
				.while ebx<nCounter
					inc	ebx
					invoke	CreateThread,0,0,offset _Counter,0,0,0
					invoke	CloseHandle,eax
				.endw
				invoke	SetTimer,hWnd,1,500,0
				;事件对象，置位用True，复位用False，而置位的意思是空闲True
				;互斥量，空闲用False,占用用True,这与事件对象是刚好相反的，
				;可以把事件对象想象成开关，开关打开为true，此时允许通过，否则不允许
				;互斥量，为true表示正在互斥，所以不能通过，false表示没有互斥
;				invoke	OpenEvent,eventName
;				invoke	OpenMutex,muTexName
;				invoke	OpenSemaphore,semaphoreName
;				事件
				invoke	CreateEvent,0,FALSE,TRUE,0
				mov	hEvent,eax
;				临界区				
				invoke	InitializeCriticalSection,addr stCritical
;				互斥量				
				invoke	CreateMutex,0,FALSE,0
				mov	hMutex,eax
;				信号灯  初始值表示当时还有多少栈灯是亮的，后面一个参数是表示一共有多少栈灯
				invoke	CreateSemaphore,0,1,1,0	
				mov	hSemaphore,eax			
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWnd,0
	.elseif	eax==WM_INITDIALOG
		push	hWnd
		pop	hWinMain
	.else	
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
_DialogProc endp

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _DialogProc,0	
	invoke	ExitProcess,0
end start
