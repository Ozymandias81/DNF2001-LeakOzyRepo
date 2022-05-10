#include "stdcore.h"
#include "winapp.h"

XWinApp *_winapp;

XWinApp::XWinApp(void) : cmd_line(null),run_count(0)
{
	_winapp=this;
}

XWinApp::~XWinApp(void)
{
	_winapp=null;
}

U32 XWinApp::app_close(void)
{
	return TRUE;
}

U32 XWinApp::app_init(void)
{
	return TRUE;
}

U32 build_cmd_args(CC8 *cmd_line,U32 &argc,CC8 **&argv)
{
	CmdArgs cmds(cmd_line);

	argc=cmds.get_argc();
	if (!argc)
		return FALSE;

	argv=cmds.get_argv();
	return TRUE;
}

#ifdef WIN32
U32 XWinApp::attempt_cmdline_early(void)
{
	build_cmd_args(null,argc,argv);
	return TRUE;
}
#endif

U32 XWinApp::run(CC8 *cmd_line)
{
	U32 res;

	while(!is_done())
	{
		try
		{
			build_cmd_args(cmd_line,argc,argv);

			if (!app_init())
				return FALSE;
			res=main();
			app_close();
		}
		catch(...)
		{
			xxx_fatal("XWinApp::run: Uncaught Exception");
			return FALSE;
		}
		run_count++;
	}
	return TRUE;
}

U32 XWinApp::run(HINSTANCE Hinst,HINSTANCE prev,CC8 *CmdLine,U32 show)
{
	hinst=Hinst;
	cmd_line=CmdLine;
	
	return run(cmd_line);
}

int __stdcall WinMain(HINSTANCE hinst,HINSTANCE prev_inst,LPSTR cmd_line,int cmd_show)
{
	if (!_winapp)
	{
		WinMessage(null,"WinMain: _winapp variable not initialized");
		exit(1);
	}

	_winapp->run(hinst,prev_inst,cmd_line,cmd_show);
	
	return _winapp->return_value();
}

#ifdef WIN32
U32 CmdArgs::init(CC8 *cmd_line)
{
	argc=__argc;
	argv=(CC8 **)__argv;
	arg_mem=null;
	return TRUE;
}
#endif

CmdArgs::CmdArgs(CC8 *cmd_line)
{
	if (!init(cmd_line))
		xxx_throw("CmdArgs: init failed in constructor");
}

CmdArgs::~CmdArgs(void)
{
	if (arg_mem)
		delete arg_mem;
}
