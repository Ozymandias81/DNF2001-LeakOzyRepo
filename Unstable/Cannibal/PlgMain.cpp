//****************************************************************************
//**
//**    PLGMAIN.CPP
//**    Plugins
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "PlgMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define PLG_DLLFUNCNAME		"CannibalPluginCreate"
#define PLG_DLLEXTENSION	"p"
#define PLG_DLLDIR			"plugins\\"
#define PLG_MAXPLUGINS		1024

typedef IPlgPlugin* (__cdecl *FPlgPluginCreateFunc)(void);

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CPlgPluginHook
{
public:
	HINSTANCE dllInstance;
	IPlgPlugin* plugin;

	CPlgPluginHook()
		: dllInstance(NULL), plugin(NULL)
	{
	}
	~CPlgPluginHook()
	{
		Close();
	}

	NBool Open(NChar* inFileName)
	{
		Close();
		if (!inFileName)
			return(0);
		if (!(dllInstance = LoadLibrary(inFileName)))
			return(0);
		FPlgPluginCreateFunc cf = (FPlgPluginCreateFunc)GetProcAddress(dllInstance, PLG_DLLFUNCNAME);
		if ((!cf) || (!(plugin = cf())))
		{
			Close();
			return(0);
		}
		if (!plugin->Create())
		{
			plugin = NULL; // do not call destroy if create fails
			Close();
			return(0);
		}
		return(1);
	}
	void Close()
	{
		if (plugin)
			plugin->Destroy();
		plugin = NULL;
		if (dllInstance)
			FreeLibrary(dllInstance);
		dllInstance = NULL;
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static CPlgPluginHook plg_Plugins[PLG_MAXPLUGINS];
static NDword plg_NumPlugins;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void PLG_Init(NChar* inPluginDir)
{
	if (!inPluginDir)
		inPluginDir = PLG_DLLDIR;
	char specbuf[256];
	sprintf(specbuf, "%s*.%s", inPluginDir, PLG_DLLEXTENSION);
	
	char* spec = specbuf;
	char* specfile;
	char buf[256];

	plg_NumPlugins = 0;
	while (specfile = STR_FileFind(spec, NULL, NULL))
	{
		spec = NULL;
		strcpy(buf, specfile);
		if (plg_Plugins[plg_NumPlugins].Open(buf))
		{
			LOG_Debugf("PLG_Init: Registered Plugin \"%s\"", buf);
			plg_NumPlugins++;
		}
	}
}
KRN_API void PLG_Shutdown()
{
	for (NDword i=0;i<plg_NumPlugins;i++)
		plg_Plugins[i].Close();
}
KRN_API NDword PLG_GetPluginCount()
{
	return(plg_NumPlugins);
}
KRN_API IPlgPlugin* PLG_GetPlugin(NDword inIndex)
{
	return(plg_Plugins[inIndex].plugin);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE PLGMAIN.CPP
//**
//****************************************************************************

