#nmake 工具的描述文件例子
EXE = 
#需要的目标文件
OBJS = 
#链接选项
LINK_FLAG = /subsystem:windows	
#编译选项
ML_FLAG = /c /coff /Cp

$(EXE):$(OBJS)
	Link $(LINK_FLAG) /out:$(EXE) $(OBJS)
#$(OBJS):Common.inc
$OBJS:
#定义汇编编译和资源编译的默认规则
.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

#清除临时文件
clean:
	del *.obj
	del *.res