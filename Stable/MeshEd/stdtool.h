#define CANNIBAL_TOOL
#define XCORE_PURE

#include <windows.h>
#include <xcore.h>
#include <winapp.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include "resource.h"

#define MEMCAST(type, val) (*((type *)&(val)))
#define BITF(x) (1<<x)

#include "math_vec.h"
#include "cam_man.h"
#include "sys_win.h"
#include "sys_main.h"
#include "vid_main.h"
extern VidIf *vid;
#include "in_main.h"
#include "ovl_man.h"
#include "ovl_defs.h"
#include "con_man.h"
#include "vcr_man.h"
#include "mdx_man.h"
#include "ovl_cc.h"
#include "ovl_work.h"
#include "ovl_skin.h"
#include "ovl_mdl.h"
#include "ovl_frm.h"
#include "ovl_seq.h"
#include "in_win.h"
#include "file_imp.h"
#include "meshapp.h"


