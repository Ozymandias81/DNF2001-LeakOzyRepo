#=============================================================================
# Unreal Engine makefile for Linux.
#
# Revision history:
# 	* Created by Brandon Reinhart 
#=============================================================================

# Unreal directory. (Required by makefile-header.)
UNREAL_DIR	= ../..

# Include global definitions.
include $(UNREAL_DIR)/makefile-header

#-----------------------------------------------------------------------------
# Directories.
#-----------------------------------------------------------------------------

SRC_DIRS	= $(ENGINE_SRC)
BUILD_DIR	= $(ENGINE_BUILD)

#-----------------------------------------------------------------------------
# Compiler/linker options.
#-----------------------------------------------------------------------------

CXX		= $(STD_CXX)
CXXFLAGS	= $(STD_CXXFLAGS) -Werror -fPIC -I$(ENGINE_INC) -I$(CORE_INC) \
			-DGPackage=GPackageEngine
LDFLAGS		= $(STD_LDFLAGS) -shared -Wl,-soname,$(ENGINE_SONAME)
LIBS		= $(STD_LIBS) $(CORE)

#-----------------------------------------------------------------------------
# Files.
#-----------------------------------------------------------------------------

OBJS =			\
	Engine.o	\
	UnActCol.o	\
	UnActor.o	\
	UnAudio.o	\
	UnBunch.o	\
	UnCamera.o	\
	UnCamMgr.o	\
	UnCanvas.o	\
	UnChan.o	\
	UnCon.o		\
	UnConn.o	\
	UnDemoPenLev.o	\
	UnDemoRec.o	\
	UnDynBsp.o	\
	UnEngine.o	\
	UnFPoly.o	\
	UnFont.o	\
	UnGame.o	\
	UnIn.o		\
	UnLevAct.o	\
	UnLevel.o	\
	UnLevTic.o	\
	ULodMesh.o	\
	UnMesh.o	\
	UnModel.o	\
	UnMover.o	\
	UnNetDrv.o	\
	UnParams.o	\
	UnPath.o	\
	UnPawn.o	\
	UnPenLev.o	\
	UnPhysic.o	\
	UnPlayer.o	\
	UnPrim.o	\
	UnReach.o	\
	UnRenderIterator.o	\
	UnRoute.o	\
	UnScript.o	\
	UnScrTex.o	\
	UnTex.o		\
	UnTrace.o	\
	UnURL.o		\
	AStatLog.o

OUT = $(ENGINE)

#-----------------------------------------------------------------------------
# Rules.
#-----------------------------------------------------------------------------

# Use general rules.
include $(UNREAL_DIR)/makefile-general

#-----------------------------------------------------------------------------
# The End.
#-----------------------------------------------------------------------------
