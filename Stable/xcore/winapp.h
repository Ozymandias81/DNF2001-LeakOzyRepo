#ifndef _WINAPP_H_
#define _WINAPP_H_

#ifndef _WINDOWS_
#include <windows.h>
#endif

#ifndef _XCORE_H_
#include <xcore.h>
#endif

#ifndef _XWND_H_
#include <xwnd.h>
#endif

/* builds up argc/argv command array */
class CmdArgs
{
   U32 argc;
   CC8 **argv;
   char *arg_mem;

public:
   CmdArgs(CC8 *cmd_line);
   CmdArgs(void) : argc(0),argv(null),arg_mem(null) {}
   U32 init(CC8 *cmd_line);
   ~CmdArgs(void);
   void *take_mem(void)
   {
      void *mem=arg_mem;
      arg_mem=null;
      return mem;
   }
   __inline CC8 **get_argv(void){return argv;}
   __inline U32 get_argc(void){return argc;}
};

class XWinApp : public XApp
{
protected:
	HINSTANCE hinst;
	U32 argc;
	CC8 **argv;

	CC8	*cmd_line;
	U32 run_count;

	U32 run(CC8 *cmd_line);
	/* override if you want to run main multiple times */
	virtual U32 is_done(void){return run_count;}
	virtual U32 main(void)=null;
	/* override if you need to do stuff before main */
	virtual U32 app_init(void);
	/* override if you need to do stuff before shutdown */
	virtual U32 app_close(void);

	/* attempt to get cmd args before main() */
	U32 attempt_cmdline_early(void);

public:
	XWinApp(void);
	~XWinApp(void);
	void give_ptr(void *ptr);
	U32 run(HINSTANCE hinst,HINSTANCE prev,CC8 *cmd_line,U32 show);
	virtual U32 return_value(void){return 0;}
	HINSTANCE get_hinst(void){return hinst;}
};

extern XWinApp *_winapp;

#endif /* ifndef _WINAPP_H_ */