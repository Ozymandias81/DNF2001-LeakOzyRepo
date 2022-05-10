#include "conapp.h"
#include <stdlib.h>

XConApp *_conapp;

XConApp::XConApp(void) : argc(0),argv(null),run_count(0)
{
	_conapp=this;
}

XConApp::~XConApp(void)
{
	_conapp=null;
}

U32 XConApp::app_close(void)
{
	return TRUE;
}

U32 XConApp::app_init(void)
{
	return TRUE;
}

U32 XConApp::run(U32 Argc,CC8 **Argv,CC8 **Envp)
{
	argc=Argc;
	argv=Argv;

	U32 res;

	while(!is_done())
	{
		try
		{
			app_init();
			res=main();
			app_close();
		}
		catch(...)
		{
			xxx_fatal("XConApp::run: Uncaught Exception");
			return FALSE;
		}
		run_count++;
	}
	return TRUE;
}

int main(int argc,char *argv[],char *envp[])
{
	if (!_conapp)
	{
		ConMessage("main: _conapp variable not initialized");
		exit(1);
	}
	
	_conapp->run(argc,(CC8 **)argv,(CC8 **)envp);
	
	return _conapp->return_value();
}