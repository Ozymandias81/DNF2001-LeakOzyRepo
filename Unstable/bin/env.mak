# Setup basic environment for duke stuff

ROOT_XCORE = $(BUILD_ROOT_DUKE)\xcore
ROOT_XIMAGE = $(BUILD_ROOT_DUKE)\ximage

XCORE_DEP = $(ROOT_XCORE)\xcore.h $(ROOT_XCORE)\xclass.h \
            $(ROOT_XCORE)\xstring.h $(ROOT_XCORE)\filex.h \
            $(ROOT_XCORE)\xstream.h

XWINAPP_DEP = $(XCORE_DEP) $(ROOT_XCORE)\winapp.h $(ROOT_XCORE)\xwnd.h

XCONAPP_DEP = $(XCORE_DEP) $(ROOT_XCORE)\conapp.h

XIMAGE_DEP = $(ROOT_XIMAGE)\ximage.h $(ROOT_XIMAGE)\xbmp.h \
            $(ROOT_XIMAGE)\xtga.h


