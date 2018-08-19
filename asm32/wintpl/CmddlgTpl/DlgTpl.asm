.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include DlgTpl.inc
;-------------------
; include
;-------------------
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
include comdlg32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
;-------------------
; data
;-------------------
.data?

hInstance	dd	?
hWinMain	dd	?
dwFontColor	dd	?
dwBackColor	dd	?
dwCustColors	dd	16 dup (?)
stLogFont	LOGFONT		<?>
szFileName	db	256 dup (?)
szFilePathName	db	MAX_PATH dup (?)
szBuffer	db	1024 dup (?)
;********************************************************************
; 查找替换对话框使用
;********************************************************************
idFindMessage	dd	?
stFind		FINDREPLACE	<?>
szFindText	db	100 dup (?)
szReplaceText	db	100 dup (?)
szCustomFileter	db	256 dup (?)
		.const
FINDMSGSTRING	db	'commdlg_FindReplace',0
szSaveCaption	db	'请输入保存的文件名',0
szFormatColor	db	'您选择的颜色值：%08x',0
szFormatFont	db	'您的选择：',0dh,0ah,'字体名称：%s',0dh,0ah
		db	'字体颜色值：%08x，字体大小：%d',0
szFormatFind	db	'您按下了“%s”按钮',0dh,0ah,'查找字符串：%s',0dh,0ah
		db	'替换字符串：%s',0
szFormatPrt	db	'您选择的打印机：%s',0
szCaption	db	'执行结果',0
szFindNext	db	'查找下一个',0
szReplace	db	'替换',0
szReplaceAll	db	'全部替换',0

szFilter	db	'Text Files(*.txt)',0,'*.txt',0,'*.hh',0,'All Files(*.*)',0,'*.*',0,0
szDefExt	db	'txt',0
szCstDefFilter	db	'*.hh',0
szCstFmt	db	'%s',0
szMyOpenTitle	db	'我的打开',0
szOpenResFmt	db	'FilePath:%s',0dh,0ah,\
			'FileName:%s',0dh,0ah,\
			'SelFilter:%s',0dh,0ah,\
			'FileNameOffset:%d',0dh,0ah,\
			'FileExtOFfset:%d',0
;-------------------
; code
;-------------------
.code
_OpenProc proc
	LOCAL	lc_stOFN:OPENFILENAME
	LOCAL	lc_wFileOffset
	LOCAL	lc_wFileExt
	pushad
	
	invoke	RtlZeroMemory,addr lc_stOFN,sizeof OPENFILENAME
	mov	lc_stOFN.lStructSize,sizeof OPENFILENAME
	push	hWinMain
	pop	lc_stOFN.hwndOwner
	mov	lc_stOFN.hInstance,NULL
	mov	lc_stOFN.lpstrFilter,offset szFilter
	invoke	wsprintf,addr szCustomFileter,addr szCstFmt,addr szCstDefFilter
	mov	lc_stOFN.lpstrCustomFilter,offset szCustomFileter ;只有设置了 OFN_ALLOWMULTISELECT 才有效
	mov	lc_stOFN.nMaxCustFilter,sizeof szCustomFileter ;
	mov	lc_stOFN.lpstrFile,offset szFilePathName
	mov	lc_stOFN.nMaxFile,sizeof szFilePathName
	mov	lc_stOFN.lpstrFileTitle,offset szFileName
	mov	lc_stOFN.nMaxFileTitle,sizeof szFileName
	mov	lc_stOFN.lpstrInitialDir,NULL
	mov	lc_stOFN.lpstrTitle,offset szMyOpenTitle
	mov	lc_stOFN.lpstrDefExt,offset szDefExt
	mov	lc_stOFN.Flags,OFN_ALLOWMULTISELECT
	invoke	GetOpenFileName,addr lc_stOFN
	.if eax
		mov	esi,offset szCustomFileter
		invoke  lstrlen,addr szCustomFileter
		add	esi,eax
		inc	esi
		movzx	eax,lc_stOFN.nFileOffset
		mov	lc_wFileOffset,eax
		movzx	eax,lc_stOFN.nFileExtension
		mov	lc_wFileExt,eax
		invoke	wsprintf,addr szBuffer,addr szOpenResFmt,addr szFilePathName ,\
			addr szFileName,esi,lc_wFileOffset,\
			lc_wFileExt
		invoke	MessageBox,NULL,addr szBuffer,NULL,MB_OK 
	.endif
	
	popad	
	ret

_OpenProc endp

_SaveProc proc
	
	LOCAL	lc_stOFN:OPENFILENAME
	pushad
	
	invoke	RtlZeroMemory,addr lc_stOFN,sizeof OPENFILENAME
	mov	lc_stOFN.lStructSize,sizeof OPENFILENAME
	push	hWinMain
	pop     lc_stOFN.hwndOwner	
	mov	lc_stOFN.lpstrFilter,offset szFilter
	mov	lc_stOFN.lpstrFile,offset szFilePathName
	mov	lc_stOFN.nMaxFile,sizeof szFilePathName
	mov	lc_stOFN.lpstrFileTitle,offset szFileName
	mov	lc_stOFN.nMaxFileTitle,sizeof szFileName
	mov	lc_stOFN.lpstrDefExt,offset szDefExt
	invoke	GetSaveFileName,addr lc_stOFN
	.if	eax
		invoke	wsprintf,addr szBuffer,addr szOpenResFmt,addr szFilePathName ,\
			addr szFileName,0,0,0
		invoke	MessageBox,NULL,addr szBuffer,NULL,MB_OK 
	.endif
	
	popad
	ret

_SaveProc endp

_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	mov eax,uMsg
	.if	eax == WM_INITDIALOG
		invoke	LoadIcon,hInstance,ICO_MAIN
		invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
		push	hWnd
		pop	hWinMain
	.elseif eax == WM_CLOSE
		invoke	EndDialog,hWnd,0
	.elseif eax == WM_COMMAND
		mov	eax,wParam
		.if ax == IDOK
			invoke SendMessage,hWnd,WM_CLOSE,0,0
		.elseif ax == IDM_OPEN
			invoke _OpenProc
		.elseif ax == IDM_SAVEAS
			invoke _SaveProc
		.endif
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret

_WindProc endp

_WinMain proc
	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke DialogBoxParam,hInstance,DLG_MAIN,\
	       NULL,addr _WindProc,NULL
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	