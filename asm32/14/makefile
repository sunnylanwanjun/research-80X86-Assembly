#nmake 工具的描述文件例子
EXE = 8.exe
#需要的目标文件
OBJS = 14.obj
#RES = MemInfo.res #需要的资源文件
#链接选项
LINK_FLAG = /subsystem:windows	
#编译选项
ML_FLAG = /c /coff /Cp
 
#定义依赖关系和执行命令
$(EXE):$(OBJS) $(RES)
	Link $(LINK_FLAG) /out:$(EXE) $(OBJS) $(RES)
#$(OBJS):Common.inc
$OBJS:rcdef.inc
#定义汇编编译和资源编译的默认规则
.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

#清除临时文件
clean:
	del *.obj
	del *.res