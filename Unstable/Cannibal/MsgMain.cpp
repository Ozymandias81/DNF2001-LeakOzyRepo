//****************************************************************************
//**
//**    MSGMAIN.CPP
//**    Messenger
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include <malloc.h>
#define KRNINC_WIN32
#include "Kernel.h"
#include "LogMain.h"
#include "MemMain.h"
#include "LexMain.h"
#include "MsgMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
static unsigned long _pushbogo;
#define SCALLVOID(funcName) { void* tempPtr = funcName; void (__cdecl *tempPtr2)() = (void (__cdecl *)())tempPtr; tempPtr2(); }
#define SCALLRET(xresult, xtype, funcName) { void* tempPtr = funcName; xtype (__cdecl *tempPtr2)() = (xtype (__cdecl *)())tempPtr; xresult = tempPtr2(); }
#define SPUSH(argType, argEx) (*((argType*)_alloca(sizeof(argType))) = argEx)
#define SPUSHFLOAT(argEx) SPUSH(float, argEx)
#define SPUSHINT(argEx) SPUSH(int, argEx)
#define SPUSHSTR(argEx) SPUSH(char*, argEx)

enum
{
	MSGTOKEN_Invalid=0,
	MSGTOKEN_BlockComment,
	MSGTOKEN_Preprocessor,
	MSGTOKEN_Identifier,
	MSGTOKEN_String,
	MSGTOKEN_Character,
	MSGTOKEN_Integer,
	MSGTOKEN_HexInteger,
	MSGTOKEN_BinInteger,
	MSGTOKEN_OctInteger,
	MSGTOKEN_Float,
	
	MSGTOKEN_NumTypes
} EMsgToken;

#define MSG_HASHBITS		10
#define MSG_HASHBUCKETS		(1<<MSG_HASHBITS)
#define MSG_HASHMASK		(MSG_HASHBITS-1)

extern "C"{
NBool msg_call_stack(IMsg *msg,IMsgTarget *target,CC8 *pstr,U32 argc,IMsgToken *token,void *func);
}

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CMsgFunc
{
public:
	IMsgRouter* m_Router;
	const NChar* m_Name;
	const NChar* m_Parms;
	FMsgHandlerRaw m_FuncRaw;
	FMsgHandlerC m_FuncC;
	CMsgFunc* m_Next;
};

class CMsgRouter : public IMsgRouter
{
public:
	CMsgFunc* m_Funcs[MSG_HASHBUCKETS];
	CMsgRouter* m_NextRouter;
	CCorString m_RouterName;

	CMsgRouter()
	{
		memset(m_Funcs, 0, MSG_HASHBUCKETS*sizeof(CMsgFunc*));
		m_NextRouter = NULL;
	}
	~CMsgRouter()
	{
		CMsgFunc* next;
		for (NDword i=0;i<MSG_HASHBUCKETS;i++)
		{
			for (CMsgFunc* func = m_Funcs[i]; func; func = next)
			{
				next = func->m_Next;
				delete func;
			}
		}
	}
	NBool RegisterHandlerRaw(const NChar* inName, FMsgHandlerRaw inHandler)
	{
		NDword hash = STR_CalcHash((char*)inName) & MSG_HASHMASK;
		
		CMsgFunc* func = new CMsgFunc;
		func->m_Router = this;
		func->m_Name = inName;
		func->m_Parms = NULL;
		func->m_FuncRaw = inHandler;
		func->m_FuncC = NULL;
		func->m_Next = m_Funcs[hash];
		m_Funcs[hash] = func;
		return(1);
	}
	NBool RegisterHandlerC(const NChar* inName, FMsgHandlerC inHandler, const NChar* inParms)
	{
		NDword hash = STR_CalcHash((char*)inName) & MSG_HASHMASK;

		CMsgFunc* func = new CMsgFunc;
		func->m_Router = this;
		func->m_Name = inName;
		func->m_Parms = inParms;
		func->m_FuncRaw = NULL;
		func->m_FuncC = inHandler;
		func->m_Next = m_Funcs[hash];
		m_Funcs[hash] = func;
		return(1);
	}

	// IMsgRouter
	NBool MsgRoute(IMsgTarget* inTarget, IMsg* inMsg)
	{
		if (!inMsg || !inMsg->Argc())
			return(0);

		NDword hash = STR_CalcHash(inMsg->Argv(0)->GetString()) & MSG_HASHMASK;
		for (CMsgFunc* func = m_Funcs[hash]; func; func = func->m_Next)
		{
			if (stricmp(func->m_Name, inMsg->Argv(0)->GetString()))
				continue;
			if (func->m_FuncRaw)
			{
				// raw function
				return(func->m_FuncRaw(inTarget, inMsg));
			}
			if (func->m_FuncC && func->m_Parms)
			{
				// c function
				void* impFunc = func->m_FuncC;
				NChar* pstr = (NChar*)(func->m_Parms+strlen(func->m_Parms)-1);
				if (inMsg->Argc() != (NDword)strlen(func->m_Parms)+1)
				{
					LOG_Warnf("Argument count mismatch on console call to %s (found %d, expecting %d)", func->m_Name, inMsg->Argc(), (int)strlen(func->m_Parms)+1);
					return(0);
				}
				return msg_call_stack(inMsg,inTarget,pstr,inMsg->m_Argc,&inMsg->m_Argv[inMsg->m_Argc - 1],impFunc);
			}
			return(0);
		}
		return(0);
	}
	U32 Delete(void)
	{
		delete this;
		return TRUE;
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static ILexLexer* msg_Lexer = NULL;
static CMsgRouter* msg_GlobalRouter = NULL;

//============================================================================
//    GLOBAL DATA
//============================================================================
extern "C"{
U32 _msg_string_off=0;
U32 _msg_float_off=0;
U32 _msg_int_off=0;
U32 _msg_token_size=0;
}

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static void BlockCommentInterceptor(ILexLexer* lex, SLexToken* token)
{
    while(1)
    {
        char c = lex->GetChar();
        if (!c)
            LOG_Errorf("Comment without completing \"*/\"");
        if ((c == '*') && (lex->PeekChar() == '/'))
        {
            lex->GetChar();
            break;
        }
    }
    token->tag = 0;
}

static void PreprocessorInterceptor(ILexLexer* lex, SLexToken* token)
{
	char c;
	do
		c = lex->GetChar();
	while (c && (c != '\n'));
	token->tag = 0; // ignore for now
}

static void MSG_InitLexer(ILexLexer* lex)
{
	lex->CaseSensitivity(0);
	
	lex->TokenPriority(0);
	lex->RegisterToken(0, "."); // trash monster
	
	lex->TokenPriority(1);
	lex->RegisterToken(0, "[ \\t\\n]*"); // whitespace
	lex->RegisterToken(0, "//.*"); // eol comments
	lex->RegisterToken(MSGTOKEN_BlockComment, "\\/\\*");
	lex->RegisterToken(MSGTOKEN_Preprocessor, "\\#");
	lex->RegisterToken(MSGTOKEN_Identifier, "[a-zA-Z_\\.\\\\]([a-zA-Z0-9_\\.\\\\])*");
	lex->RegisterToken(MSGTOKEN_Integer, "[\\+\\-]?[0-9]+");
	lex->RegisterToken(MSGTOKEN_HexInteger, "0[xX][0-9a-fA-F]+");
	lex->RegisterToken(MSGTOKEN_BinInteger, "0[bB][0-1]+");
	lex->RegisterToken(MSGTOKEN_OctInteger, "0[qQ][0-7]+");
	lex->RegisterToken(MSGTOKEN_Float, "[\\+\\-]?[0-9]+[Ee][\\+\\-]?[0-9]+");
	lex->RegisterToken(MSGTOKEN_Float, "[\\+\\-]?[0-9]*\\.[0-9]+([Ee][\\+\\-]?[0-9]+)?");
	lex->RegisterToken(MSGTOKEN_Float, "[\\+\\-]?[0-9]+\\.[0-9]*([Ee][\\+\\-]?[0-9]+)?");
	lex->RegisterToken(MSGTOKEN_String, "\\\"((\\\\.)|[^\\\\\\\"])*\\\"");
	lex->RegisterToken(MSGTOKEN_Character, "'((\\\\.)|[^\\\\'])+'");

	lex->TokenIntercept(MSGTOKEN_BlockComment, BlockCommentInterceptor);
	lex->TokenIntercept(MSGTOKEN_Preprocessor, PreprocessorInterceptor);

	lex->Finalize();
}

static IMsgTarget* MSG_StaticGetPathTarget(IMsgTarget* inBase, NChar* inPath)
{
	if (!inPath)
		return(NULL);

	IMsgTarget* r = NULL;
	NChar nameBuf[256];
	NChar inBuf[1024];
	NChar* optr = nameBuf;
	NChar* iptr = inBuf;
	
	strcpy(inBuf, inPath);

	// if there's no trailing backslash, tack one on
	if (inBuf[strlen(inBuf)-1] != '\\')
		strcat(inBuf, "\\");

	do
	{
		if (*iptr == '\\')
		{
			*optr = 0;
			if (!nameBuf[0])
			{
				if (!r)
					r = inBase->MsgGetRoot(); // r is still null, which means this is a starting slash; go to the root
				goto wouldUseContinueKeywordIfPossible; // continue keyword starts at top of loop, but this is a do-while and I need to check the condition
			}
			if (!r)
				r = inBase;
			// see if path is all dots
			for (optr = nameBuf; *optr; optr++)
			{
				if (*optr != '.')
					break;
			}
			if (!(*optr))
			{
				// all dots, move up number of parents
				NDword count = strlen(nameBuf)-1; // first dot is "this"
				for (NDword i=0;i<count;i++)
				{
					r = r->MsgGetParent();
					if (!r)
						return(NULL); // went past the root, invalid
				}
			}
			else
			{
				// not all dots, must be a child name
				r = r->MsgGetChild(nameBuf);
				if (!r)
					return(NULL); // no child by that name
			}
			optr = nameBuf; // restart buffer
		}
		else
		{
			*optr++ = *iptr;
		}
wouldUseContinueKeywordIfPossible:
		iptr++;
	} while(*iptr);
	return(r);
}

static NBool MSG_StaticMsg(IMsgRouter* inRouter, IMsgTarget* inTarget, NChar* inText)
{
	IMsg theMsg;
	theMsg.m_Argc = 0;

	msg_Lexer->SetText(inText, 0, 0, 4);
	SLexToken lextoken;
	while (msg_Lexer->GetToken(&lextoken))
	{		
		if (theMsg.m_Argc >= 32)
			break;

		IMsgToken* t = &theMsg.m_Argv[theMsg.m_Argc];
		t->m_String[0] = 0;
		t->m_Int = 0;
		t->m_Float = 0.0f;

		switch(lextoken.tag)
		{
		case MSGTOKEN_Identifier:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Float = (NFloat)atof(t->m_String);
			t->m_Int = (NInt)t->m_Float;
			break;
		case MSGTOKEN_String:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen-2, lextoken.lexeme+1);
			t->m_Float = (NFloat)atof(t->m_String);
			t->m_Int = (NInt)t->m_Float;
			break;
		case MSGTOKEN_Character:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen-2, lextoken.lexeme+1);
			t->m_Int = STR_Chartoi(t->m_String);
			t->m_Float = (NFloat)t->m_Int;
			break;
		case MSGTOKEN_Integer:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Int = (NInt)atoi(t->m_String);
			t->m_Float = (NFloat)t->m_Int;
			break;
		case MSGTOKEN_HexInteger:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Int = STR_Hexatoi(t->m_String);
			t->m_Float = (NFloat)t->m_Int;
			break;
		case MSGTOKEN_BinInteger:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Int = STR_Binatoi(t->m_String);
			t->m_Float = (NFloat)t->m_Int;
			break;
		case MSGTOKEN_OctInteger:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Int = STR_Octatoi(t->m_String);
			t->m_Float = (NFloat)t->m_Int;
			break;
		case MSGTOKEN_Float:
			sprintf(t->m_String, "%0.*s", lextoken.lexemeLen, lextoken.lexeme);
			t->m_Float = (NFloat)atof(t->m_String);
			t->m_Int = (NInt)t->m_Float;
			break;
		default:
			break;
		}			
		theMsg.m_Argc++;
	}

	if (!theMsg.m_Argc)
		return(0);

	NChar* ptr;
	if (inTarget && (ptr = strchr(theMsg.m_Argv[0].m_String, '\\')))
	{
		inTarget = inTarget->MsgGetPathTarget(STR_FilePath(theMsg.m_Argv[0].m_String));
		if (!inTarget)
			return(0);
		strcpy(theMsg.m_Argv[0].m_String, STR_FileRoot(theMsg.m_Argv[0].m_String));
	}

	if (inRouter)
		return(inRouter->MsgRoute(inTarget, &theMsg));
	else if (inTarget)
		return(inTarget->Msg(&theMsg));
	else
		return(0);
}

static NBool MSG_StaticMsgFile(IMsgRouter* inRouter, IMsgTarget* inTarget, NChar* inFileName)
{
	NChar execBuf[256];
	NChar* ptr, *scrbuf;
	NDword len, elen;
	FILE* fp;

	if (!inFileName)
		return(0);
	if (!(fp = fopen(STR_FileSuggestedExt(inFileName, "cfg"), "rb")))
		return(0);
	fseek(fp, 0, SEEK_END);
	len = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	scrbuf = MEM_Malloc(NChar, len+1);
	scrbuf[len] = 0;
	fread(scrbuf, 1, len, fp);
	fclose(fp);

	elen = 0;
	execBuf[0] = 0;
	for (ptr=scrbuf;*ptr;ptr++)
	{
		switch(*ptr)
		{
		case '\r': break; // skip carriage return
		case '\n':
			// execute command on line feed
			if (!execBuf[0])
				break;
			
			MSG_StaticMsg(inRouter, inTarget, execBuf);
			
			elen = 0;
			execBuf[0] = 0;
			break;
		default:
			// any other character gets tacked on
			execBuf[elen++] = *ptr;
			execBuf[elen] = 0;
			break;
		}
	}
	MEM_Free(scrbuf);
	return(1);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MSG_Init()
{
	msg_Lexer = LEX_CreateLexer();
	if (!msg_Lexer)
		LOG_Errorf("MSG_Init: LEX_CreateLexer failure");

	MSG_InitLexer(msg_Lexer);
}

KRN_API void InitMsgAsm(void)
{
	_msg_string_off=oof(IMsgToken,m_String);
	_msg_float_off=oof(IMsgToken,m_Float);
	_msg_int_off=oof(IMsgToken,m_Int);
	_msg_token_size=sizeof(IMsgToken);
}

KRN_API void MSG_Shutdown()
{
	if (msg_GlobalRouter)
		delete msg_GlobalRouter;
	
	if (msg_Lexer)
	{
		msg_Lexer->Destroy();
		msg_Lexer = NULL;
	}
}

KRN_API IMsgRouter* MSG_MakeRouter(NChar* inName)
{
	static CMsgRouter* staticRouters = NULL;

	if (!msg_GlobalRouter)
		msg_GlobalRouter = new CMsgRouter;
	if (!inName)
		return(msg_GlobalRouter);
	
	CMsgRouter* router;
	for (router = staticRouters; router; router = router->m_NextRouter)
	{
		if (!stricmp(inName, *router->m_RouterName))
			return(router);
	}
	router = new CMsgRouter;
	router->m_RouterName = inName;
	router->m_NextRouter = staticRouters;
	staticRouters = router;
	return(router);
}

KRN_API NBool MSG_RegisterHandlerRaw(const NChar* inRouterName, const NChar* inName, FMsgHandlerRaw inHandler)
{
	CMsgRouter* router = (CMsgRouter*)MSG_MakeRouter((NChar*)inRouterName);
	return(router->RegisterHandlerRaw(inName, inHandler));
}
KRN_API NBool MSG_RegisterHandlerC(const NChar* inRouterName, const NChar* inName, FMsgHandlerC inHandler, const NChar* inParms)
{
	CMsgRouter* router = (CMsgRouter*)MSG_MakeRouter((NChar*)inRouterName);
	return(router->RegisterHandlerC(inName, inHandler, inParms));
}

//============================================================================
//    CLASS METHODS
//============================================================================
KRN_API NBool IMsgTarget::Msgf(NChar* inFmt, ... )
{
	char buf[1024];
	strcpy(buf, STR_Va(inFmt));
	return(MSG_StaticMsg(NULL, this, buf));
}
KRN_API NBool IMsgTarget::MsgFile(NChar* inFileName)
{
	return(MSG_StaticMsgFile(NULL, this, inFileName));
}
KRN_API IMsgTarget* IMsgTarget::MsgGetPathTarget(NChar* inPath)
{
	return(MSG_StaticGetPathTarget(this, inPath));
}

KRN_API NBool IMsgRouter::MsgRoutef(IMsgTarget* inTarget, NChar* inFmt, ... )
{
	char buf[1024];
	strcpy(buf, STR_Va(inFmt));
	return(MSG_StaticMsg(this, inTarget, buf));
}
KRN_API NBool IMsgRouter::MsgRouteFile(IMsgTarget* inTarget, NChar* inFileName)
{
	return(MSG_StaticMsgFile(this, inTarget, inFileName));
}

//****************************************************************************
//**
//**    END MODULE MSGMAIN.CPP
//**
//****************************************************************************

