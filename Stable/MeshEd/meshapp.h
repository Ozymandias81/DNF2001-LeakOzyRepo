#ifndef _MESHAPP_H_
#define _MESHAPP_H_

class AppWnd : public XWnd
{
	static CC8 *wnd_default_class;
protected:
	CC8 *wnd_class_name;

	U32 reg_default_class(void);
	static LRESULT CALLBACK win_messaging(HWND hWnd,UINT msg,UINT wParam,LONG lParam);
public:
	AppWnd(void);
	~AppWnd(void);
	U32 Create(void);
};

class AppError : public WinMsgDef
{
	void break_error(CC8 *str);

public:
	void message(U32 level,CC8 *str);
	void throw_msg(U32 level,CC8 *str);
	void assert(CC8 *file,U32 line);
};

#pragma pack(push,4)
class AppState
{
public:
	U32 sys_parse_init : 1;
	U32 is_win2k : 1;
	U32 app_exit : 1;
	U32 window : 1;
	U32 allow_cursor : 1;
	U32 in_frame : 1;
	U32 active : 1;
	U32 app_active : 1;
	U32 vid_active : 1;
	U32 queue_activate : 1;

	AppState(void) : sys_parse_init(0),is_win2k(0),app_exit(0),window(0),allow_cursor(1),in_frame(0),active(0),app_active(0),vid_active(0),queue_activate(0) {}
};
#pragma pack(pop)

class MeshApp : public XWinApp
{
protected:
	AppState		state;
	SysParse		parse;
	I32				xres,yres;
	MSG				app_msg;

	autoptr<AppWnd>	app_wnd;
	OSVERSIONINFO	os_version;
	VidIf			*vid_if;
	VidVersion_f	vid_version;
	VidQuery_f		vid_query;
	VidRelease_f	vid_release;

	/* file info */
	StrGrow		last_save_path;
	StrGrow		last_open_path;

	autochar	multi_file_buffer;
	CC8			*multi_file_path;
	CC8			*multi_file_select;

	I64			ticks_per_second;
	I64			start_tick;
	double		seconds_per_tick;
	float		frame_begin;
	float		frame_delta;

	autochar    app_path;

	autoptr<CConsoleManager> con;
	ConQueueSystem  action_queue;

	U32 app_init(void);
	U32 main(void);
	U32 vid_init(void);
	U32 vid_close(void);
	void init_sys_parse(void);
	U32 create_window(void);
	U32 HandleMessages(void);
	void handle_queued(void);
	void begin_frame(void);
	void end_frame(void);

public:
	MeshApp(void);
	~MeshApp(void){}
	
	void sys_parse(CC8 *text,...);
	U32 get_parse_argc(void);
	CC8 **get_parse_argv(void);
	U32 sys_check_parm(CC8 *str,U32 num_parms);
	CC8 *OpenFileBox(CC8 *maskInfo, CC8 *boxTitle, CC8 *defExt);
	CC8 *SaveFileBox(CC8 *maskInfo, CC8 *boxTitle, CC8 *defExt);
	U32 OpenFileBoxMulti(CC8 *maskInfo,CC8 *boxTitle,CC8 *defExt);
	CC8 *NextMultiFile(void);
	U32 allow_cursor(void){return state.allow_cursor;}
	HWND get_app_hwnd(void)
	{
		if (!app_wnd)
			return null;
		return app_wnd->get_hwnd();
	}
	CC8 *get_app_path(void){return app_path;}
	float get_cur_time(void);
	float get_frame_begin(void){return frame_begin;}
	float get_frame_delta(void){return frame_delta;}
	void QueueConsoleAction(U32 num,CC8 **args,con_action_f func,void *data=null);

	void on_create(HWND hwnd);
	void on_close(void);

	void app_activate(U32 enable);
	void activate(void);
	void deactivate(void);
	void quit(void);
};

extern MeshApp mesh_app;

#define SYS_Parse(x) mesh_app.sys_parse(x)
#define SYS_GetParseArgv() mesh_app.get_parse_argv()
#define SYS_GetParseArgc() mesh_app.get_parse_argc()
#define SYS_CheckParm(x,y) mesh_app.sys_check_parm(x,y)
#define SYS_OpenFileBox(x,y,z) mesh_app.OpenFileBox(x,y,z)
#define SYS_OpenFileBoxMulti(x,y,z) mesh_app.OpenFileBoxMulti(x,y,z)
#define SYS_SaveFileBox(x,y,z) mesh_app.SaveFileBox(x,y,z)
#define SYS_NextMultiFile() mesh_app.NextMultiFile()

#endif /* ifndef _MESHAPP_H_ */
