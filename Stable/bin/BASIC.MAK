# Base makefile assist file
# Author: Andy Hanson

!if "$(DEBUG)"==""
BUILD_TYPE=RETAIL
!else
BUILD_TYPE=DEBUG
!endif

!if "$(BUILD_LIST)" == ""
!MESSAGE Error: BUILD_LIST not defined in makefile
!MESSAGE        ex. BUILD_LIST=obj_dir amisc.lib install
!MESSAGE
!ERROR
!endif

all:    pre_build \
        $(BUILD_LIST) \
        post_build

rebuild: clean all

debug:  
        nmake -nologo "DEBUG=1" all

retail:
        nmake -nologo "DEBUG=" all

obj_dir:
        @if not exist obj\nul mkdir obj
        @cd obj

pre_build:
        @$(CEcho) -------$(TITLE) STARTING ($(BUILD_TYPE))--------

post_build:
        @$(CEcho) -------$(TITLE) COMPLETE ($(BUILD_TYPE))--------
