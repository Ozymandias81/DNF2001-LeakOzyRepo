#ifndef _WINAPP_H_
#define _WINAPP_H_

#ifndef _XCORE_H_
#include <xcore.h>
#endif

class XConApp : public XApp
{
protected:
	U32 argc;
	CC8 **argv;
	U32 run_count;

	U32 run(CC8 *cmd_line);
	/* override if you want to run main multiple times */
	virtual U32 is_done(void){return run_count;}
	virtual U32 main(void)=null;
	/* override if you need to do stuff before main */
	virtual U32 app_init(void);
	/* override if you need to do stuff before shutdown */
	virtual U32 app_close(void);

public:
	XConApp(void);
	~XConApp(void);
	void give_ptr(void *ptr);
	U32 run(U32 Argc,CC8 **Argv,CC8 **Envp);
	virtual U32 return_value(void){return 0;}
};

extern XConApp *_conapp;

#endif /* ifndef _WINAPP_H_ */