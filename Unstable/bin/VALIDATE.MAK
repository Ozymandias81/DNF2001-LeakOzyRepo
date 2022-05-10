# Validate makefile assist file
# Author: Andy Hanson
# Created 7/5/98

!if "$(BUILD_ROOT_DUKE)" == ""
!MESSAGE Error: BUILD_ROOT_DUKE not defined in makefile
!MESSAGE        ex. BUILD_ROOT_DUKE=f:\duke4
!MESSAGE
!ERROR
!endif

!if "$(TITLE)" == ""
!MESSAGE Error: TITLE not defined in makefile
!MESSAGE        ex. TITLE=LOG BUILD
!MESSAGE
!ERROR
!endif

!if "$(THISDIR)" == ""
!MESSAGE Error: THISDIR not defined in makefile
!MESSAGE        ex. THISDIR=$$(BUILD_ROOT_HOME)\libsrc\asock
!MESSAGE
!ERROR
!endif

!if "$(C32BIN)" == ""
!MESSAGE Error: C32BIN not defined
!MESSAGE        ex. set C32BIN=d:\msdv6\vc98\bin
!MESSAGE
!ERROR
!endif

!if "$(C32RC)" == ""
!MESSAGE Error: C32RC not defined
!MESSAGE        ex. set C32RC=d:\msdv6\common\msdev98\bin
!MESSAGE
!ERROR
!endif

!if "$(MASM_BIN)" == ""
!MESSAGE Error: MASM_BIN not defined
!MESSAGE        ex. set MASM_BIN=d:\masm
!MESSAGE
!ERROR
!endif

