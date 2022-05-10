//****************************************************************************
//**
//**    IMPBP2.CPP
//**    Bones Pro 2.0
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "CpjMain.h"
#include "PlgMain.h"
#include "LexMain.h"
#include "WinCtrl.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
enum
{
	T_INVALID=0,

	T_IDENTIFIER,
	T_VALUE,
	T_LT,
	T_GT,
	T_STAR,

	T_NUMTYPES
};

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class __declspec(dllexport) OCpjImpSklBP2
: public OCpjImporter
{
    OBJ_CLASS_DEFINE(OCpjImpSklBP2, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
    CObjClass* GetImportClass() { return(OCpjSkeleton::GetStaticClass()); }
    NChar* GetFileExtension() { return("txt"); }
    NChar* GetFileDescription() { return("Bones Pro 2 Structure"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpSklBP2, OCpjImporter, 0);

class __declspec(dllexport) OCpjImpSeqBP2
: public OCpjImporter
{
    OBJ_CLASS_DEFINE(OCpjImpSeqBP2, OCpjImporter);

	NFloat configPlayRate;
	OCpjSkeleton* configSkeleton;
	TCorArray<CCorString> configIgnoreBones;

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);
	NBool Configure(OObject* inRes, NChar* inFileName);

	// OCpjImporter
    CObjClass* GetImportClass() { return(OCpjSequence::GetStaticClass()); }
    NChar* GetFileExtension() { return("txt"); }
    NChar* GetFileDescription() { return("Bones Pro 2 Animation"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpSeqBP2, OCpjImporter, 0);

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
	char* GetTitle() { return("Bones Pro 2.0 Importer"); }
	char* GetDescription() { return("No description"); }
	char* GetAuthor() { return("3D Realms Entertainment"); }
	float GetVersion() { return(1.0f); }
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static CImpPlugin imp_Plugin;
static ILexLexer* imp_Lexer = NULL;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static ILexLexer* GetLexer()
{
	if (imp_Lexer)
		return(imp_Lexer);

	imp_Lexer = LEX_CreateLexer();
	imp_Lexer->CaseSensitivity(1);

	imp_Lexer->TokenPriority(0);
	imp_Lexer->RegisterToken(0, "."); // trash monster

	imp_Lexer->TokenPriority(1);
	imp_Lexer->RegisterToken(0, "[ \\t\\n]*"); // whitespace
	imp_Lexer->RegisterToken(0, "//.*"); // eol comments
	imp_Lexer->RegisterToken(T_IDENTIFIER, "[a-zA-Z_]([a-zA-Z_]|[0-9])*");
	imp_Lexer->RegisterToken(T_VALUE, "\\-?[0-9]+");
	imp_Lexer->RegisterToken(T_VALUE, "\\-?[0-9]+[Ee][\\+\\-]?[0-9]+");
	imp_Lexer->RegisterToken(T_VALUE, "\\-?[0-9]*\\.[0-9]+([Ee][\\+\\-]?[0-9]+)?");
	imp_Lexer->RegisterToken(T_VALUE, "\\-?[0-9]+\\.[0-9]*([Ee][\\+\\-]?[0-9]+)?");
	imp_Lexer->RegisterToken(T_LT, "<");
	imp_Lexer->RegisterToken(T_GT, ">");
	imp_Lexer->RegisterToken(T_STAR, "\\*");

	imp_Lexer->Finalize();

	return(imp_Lexer);
}

static NFloat ReadValue()
{
	SLexToken token;
	static char buf[256];
	while (GetLexer()->GetToken(&token))
	{
		switch(token.tag)
		{
		case T_VALUE: sprintf(buf, "%0.*s", token.lexemeLen, token.lexeme); return((NFloat)atof(buf)); break;
		case T_STAR: return(-1.0); break;
		case T_IDENTIFIER: LOG_Errorf("Expecting value, found identifier %0.*s", token.lexemeLen, token.lexeme); break;
		case T_LT: LOG_Errorf("Expecting value, found '<'"); break;
		case T_GT: LOG_Errorf("Expecting value, found '>'"); break;
		}	
	}
	LOG_Errorf("Expecting value, found invalid");
	return(0.f);
}

static NChar* ReadIdentifier(NChar* inMatch)
{
	SLexToken token;
	static char buf[1024];
	while (GetLexer()->GetToken(&token))
	{
		switch(token.tag)
		{
		case T_VALUE: LOG_Errorf("Expecting identifier, found value %0.*s", token.lexemeLen, token.lexeme); break;
		case T_IDENTIFIER: sprintf(buf, "%0.*s", token.lexemeLen, token.lexeme);
			if (inMatch && stricmp(buf, inMatch))
				LOG_Errorf("Expecting \"%s\", found \"%s\"", inMatch, buf);
			return(buf);
			break;
		case T_LT: LOG_Errorf("Expecting identifier, found '<'"); break;
		case T_GT: LOG_Errorf("Expecting identifier, found '>'"); break;
		}	
	}
	LOG_Errorf("Expecting identifier, found invalid");
	return("");
}

static void ReadLT()
{
	SLexToken token;
	while (GetLexer()->GetToken(&token))
	{
		switch(token.tag)
		{
		case T_VALUE: LOG_Errorf("Expecting '<', found value"); break;
		case T_IDENTIFIER: LOG_Errorf("Expecting '<', found identifier %0.*s", token.lexemeLen, token.lexeme); break;
		case T_LT: return; break;
		case T_GT: LOG_Errorf("Expecting '<', found '>'"); break;
		}	
	}
	LOG_Errorf("Expecting '<', found invalid");
}

static void ReadGT()
{
	SLexToken token;
	while (GetLexer()->GetToken(&token))
	{
		switch(token.tag)
		{
		case T_VALUE: LOG_Errorf("Expecting '>', found value"); break;
		case T_IDENTIFIER: LOG_Errorf("Expecting '>', found identifier %0.*s", token.lexemeLen, token.lexeme); break;
		case T_LT: LOG_Errorf("Expecting '>', found '<'"); break;
		case T_GT: return; break;
		}	
	}
	LOG_Errorf("Expecting '>', found invalid");
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
extern "C" __declspec(dllexport) IPlgPlugin* __cdecl CannibalPluginCreate(void)
{
	return(&imp_Plugin);
}

//============================================================================
//    CLASS METHODS
//============================================================================
/*
    OCpjImpSklBP2
*/
NBool OCpjImpSklBP2::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	VQuat3 q; q.AxisAngle(VVec3(1,0,0), M_PI/2.f);
	VCoords3 bp2AdjustCoords(q);

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
    OCpjSkeleton* skl = (OCpjSkeleton*)inRes;

	// wipe existing data
	skl->m_Bones.Purge(); skl->m_Bones.Shrink();
	skl->m_Verts.Purge(); skl->m_Verts.Shrink();
	skl->m_Mounts.Purge(); skl->m_Mounts.Shrink();

	// set up lexer
	GetLexer()->SetText((NChar*)inImagePtr, 0, 0, 4);

	// read header info
	NDword numBones = (NDword)ReadValue();
	NDword numVerts = (NDword)ReadValue();	

	// generate bones
	skl->m_Bones.Add(numBones);	
	for (NDword i=0;i<numBones;i++)
	{
		CCpjSklBone* bone = &skl->m_Bones[i];
		ReadLT();
		bone->name = ReadIdentifier(NULL); // bone name
		bone->nameHash = STR_CalcHash((NChar*)*bone->name);
		ReadGT();
		
		bone->parentBone = NULL;
		NFloat parent = ReadValue(); // parent bone index, -1 for no parent
		if (parent >= 0)
			bone->parentBone = &skl->m_Bones[(NDword)parent]; // parent bone index
		
		ReadValue(); ReadValue(); ReadValue(); // dim

#if 1
		for (int j=0;j<12;j++)
			ReadValue(); // bone frame, skip
#endif

		VCoords3 baseOCS;
		baseOCS.r.vX.x = ReadValue();
		baseOCS.r.vX.y = ReadValue();
		baseOCS.r.vX.z = ReadValue();
		baseOCS.r.vY.x = ReadValue();
		baseOCS.r.vY.y = ReadValue();
		baseOCS.r.vY.z = ReadValue();
		baseOCS.r.vZ.x = ReadValue();
		baseOCS.r.vZ.y = ReadValue();
		baseOCS.r.vZ.z = ReadValue();
		baseOCS.t.x = ReadValue();
		baseOCS.t.y = ReadValue();
		baseOCS.t.z = ReadValue();
		baseOCS.s = VVec3(1,1,1);
		
		// reorient due to bones pro rotation
		baseOCS <<= bp2AdjustCoords;
		
		bone->baseCoords = baseOCS;

#if 0		
		for (int j=0;j<12;j++)
			ReadValue(); // node frame, skip
#endif
	}

	// build vertices and their weights
	skl->m_Verts.Add(numVerts);
	for (i=0;i<numVerts;i++)
	{
		VVec3 worldPos;
		worldPos.x = ReadValue(); // vertex world position
		worldPos.y = ReadValue();
		worldPos.z = ReadValue();

		// reorient due to bones pro rotation
		worldPos <<= bp2AdjustCoords;

		NDword numWeights = (NDword)ReadValue();
		CCpjSklVert* v = &skl->m_Verts[i];
		v->weights.Add(numWeights);

		for (NDword j=0;j<numWeights;j++)
		{
			CCpjSklWeight* w = &v->weights[j];
			w->bone = &skl->m_Bones[(NDword)ReadValue()]; // bone index
			w->factor = ReadValue(); // weight factor
			w->offsetPos = worldPos >> w->bone->baseCoords;
		}
	}

	// make bone coords relative to parent instead of absolute
	VCoords3 absCoords[256];
	for (i=0;i<numBones;i++)
		absCoords[i] = skl->m_Bones[i].baseCoords;
	for (i=0;i<numBones;i++)
	{
		CCpjSklBone* bone = &skl->m_Bones[i];
		if (bone->parentBone)
			bone->baseCoords >>= absCoords[bone->parentBone - &skl->m_Bones[0]];
	}

	// calculate bone lengths by average of child translations
	for (i=0;i<numBones;i++)
	{
		CCpjSklBone* bA = &skl->m_Bones[i];
		NDword numChild = 0;
		NFloat lengthTotal = 0.f;
		for (NDword j=0;j<numBones;j++)
		{
			CCpjSklBone* bB = &skl->m_Bones[j];
			if (bB->parentBone != bA)
				continue;
			lengthTotal += bB->baseCoords.t.Length();
			numChild++;
		}
		bA->length = 1.f;
		if (numChild)
			bA->length = lengthTotal / (NFloat)numChild;
	}

    return(1);
}

NBool OCpjImpSklBP2::Import(OObject* inRes, NChar* inFileName, NChar* outError)
{	
	FILE* fp;
	NDword fplen;
	if (!(fp = fopen(inFileName, "rb")))
	{
		sprintf(outError, "Could not open file \"%s\"", inFileName);
		return(0);
	}
	fseek(fp, 0, SEEK_END);
	fplen = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	NByte* buf = MEM_Malloc(NByte, fplen+1); // additional byte for null terminator
	fread(buf, 1, fplen, fp);
	buf[fplen] = 0;
	fclose(fp);
	NBool result = ImportMem(inRes, buf, fplen, outError);
	MEM_Free(buf);
	if (result)
	{
        OCpjSkeleton* skl = (OCpjSkeleton*)inRes;
        skl->SetName(STR_FileRoot(inFileName));
        skl->mIsLoaded = 1;
	}
	return(result);
}

/*
    OCpjImpSeqBP2
*/
NBool OCpjImpSeqBP2::Configure(OObject* inRes, NChar* inFileName)
{
	configPlayRate = 20.f;
	configSkeleton = NULL;
	configIgnoreBones.Purge(); configIgnoreBones.Shrink();

	if (!inRes || !inRes->IsA(GetImportClass()))
		return(0);
    OCpjSequence* seq = (OCpjSequence*)inRes;
	if (!seq->GetParent() || !seq->GetParent()->IsA(OCpjProject::GetStaticClass()))
		return(0);
	OCpjProject* prj = (OCpjProject*)seq->GetParent();

	// choose a skeleton from parent
	NDword numSkeletons = 0;
	NChar sklNames[1024];
	NChar* sklNamePtr = sklNames;
	OCpjSkeleton* skl = NULL;
	for (TObjIter<OCpjSkeleton> iter(prj); iter; iter++)
	{
		strcpy(sklNamePtr, iter->GetName());
		sklNamePtr += strlen(sklNamePtr)+1;
		skl = *iter;
		numSkeletons++;
	}
	*sklNamePtr = 0;
	if (!numSkeletons)
	{
		//strcpy(outError, "Sequence's parent project must have a skeleton for sequence to be based on");
		return(0);
	}
	if (numSkeletons > 1)
	{
		NChar* sklChoice = NULL;
		if (!(sklChoice = WIN_SelectionBox("Import Sequence", sklNames, "Please choose the skeleton this sequence is based on:")))
		{
			//strcpy(outError, "A skeleton is needed for the sequence to be based on");
			return(0);
		}
		for (iter.Reset(prj); iter; iter++)
		{
			if (!stricmp(sklChoice, iter->GetName()))
			{
				skl = *iter;
				break;
			}
		}
	}
	if (!skl)
	{
		//strcpy(outError, "A skeleton is needed for the sequence to be based on");
		return(0);
	}
	configSkeleton = skl;

	// pick a play rate
	NChar* rate;
	if (!(rate = WIN_InputBox("Import Sequence", "20.000000", "Please enter the play rate in frames per second:")))
		rate = "20.000000";
	configPlayRate = (NFloat)atof(rate);

	// choose any bones that should be ignored
	NChar boneNames[1024];
	NChar* boneNamePtr = boneNames;
	for (NDword iBone=0; iBone<skl->m_Bones.GetCount(); iBone++)
	{
		strcpy(boneNamePtr, *skl->m_Bones[iBone].name);
		boneNamePtr += strlen(boneNamePtr)+1;
	}
	*boneNamePtr = 0;
	if (WIN_SelectionBoxMulti("Import Sequence", boneNames, "Please choose any bones you'd like to ignore:"))
	{
		while (boneNamePtr = WIN_SelectionBoxMultiGet())
			configIgnoreBones.AddItem(CCorString(boneNamePtr));
	}

	return(1);
}

NBool OCpjImpSeqBP2::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	VQuat3 q; q.AxisAngle(VVec3(1,0,0), M_PI/2.f);
	VCoords3 bp2AdjustCoords(q);

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
    OCpjSequence* seq = (OCpjSequence*)inRes;

	if (!seq->GetParent() || !seq->GetParent()->IsA(OCpjProject::GetStaticClass()))
	{
		strcpy(outError, "Sequence must be inside a project to be valid");
		return(0);
	}
	OCpjProject* prj = (OCpjProject*)seq->GetParent();

	// set up lexer
	GetLexer()->SetText((NChar*)inImagePtr, 0, 0, 4);

	// read header info
	NDword numBones = (NDword)ReadValue();
	NDword numVerts = (NDword)ReadValue();
	NDword numFrames = (NDword)ReadValue();

	OCpjSkeleton* skl = configSkeleton;
	if (!skl)
	{
		strcpy(outError, "A skeleton is needed for the sequence to be based on");
		return(0);
	}
	
	// make sure the bone counts match up
	if (numBones != skl->m_Bones.GetCount())
	{
		strcpy(outError, "Skeleton's bone count does not match the sequence");
		return(0);
	}

	ReadIdentifier("Bones");
	ReadIdentifier("Relative"); ReadIdentifier("to"); ReadIdentifier("parent");
	ReadIdentifier("Matrix");
	ReadIdentifier("XYZ");
	ReadIdentifier("Radians");
	ReadValue(); // firstframe
	ReadValue(); // lastframe
	ReadValue(); // step

	// wipe existing data
	seq->m_Frames.Purge(); seq->m_Frames.Shrink();
	seq->m_Events.Purge(); seq->m_Events.Shrink();
	seq->m_BoneInfo.Purge(); seq->m_BoneInfo.Shrink();

	seq->m_Rate = configPlayRate;

	static VCoords3 baseOCSOriginal[256];
	static VCoords3 tempOCS[256];

	// extract bones-pro-based relative OCSs from base OCSs
	for (NDword i=0;i<numBones;i++)
	{
		// get relative ocs's, make them absolute, and transform them into bones pro coordinates
		CCpjSklBone* bone = &skl->m_Bones[i];
		baseOCSOriginal[i] = bone->baseCoords;
		for (CCpjSklBone* b = bone->parentBone; b; b = b->parentBone)
			baseOCSOriginal[i] <<= b->baseCoords;
		baseOCSOriginal[i] >>= bp2AdjustCoords;
		tempOCS[i] = baseOCSOriginal[i]; // back up the transformed absolutes for re-relative calculation below
	}
	for (i=0;i<numBones;i++)
	{
		CCpjSklBone* bone = &skl->m_Bones[i];
		if (bone->parentBone)
			baseOCSOriginal[i] >>= tempOCS[bone->parentBone - &skl->m_Bones[0]]; // make the bones pro absolutes relative to adjusted parent
	}

	// add bone info for all bones
	seq->m_BoneInfo.Add(numBones);
	for (i=0;i<numBones;i++)
	{
		seq->m_BoneInfo[i].name = skl->m_Bones[i].name;
		seq->m_BoneInfo[i].srcLength = skl->m_Bones[i].length;
	}

	// add frames
	for (i=0;i<numFrames;i++)
	{
		CCpjSeqFrame* frame = &seq->m_Frames[seq->m_Frames.Add()];
		
		// create bone keys
		for (NDword j=0;j<numBones;j++)
		{
			// read input coords
			VCoords3 animOCS;
			ReadValue(); ReadValue(); ReadValue(); // dim

#if 1
			for (int k=0;k<12;k++)
				ReadValue(); // bone frame, skip
#endif

			animOCS.r.vX.x = ReadValue();
			animOCS.r.vX.y = ReadValue();
			animOCS.r.vX.z = ReadValue();
			animOCS.r.vY.x = ReadValue();
			animOCS.r.vY.y = ReadValue();
			animOCS.r.vY.z = ReadValue();
			animOCS.r.vZ.x = ReadValue();
			animOCS.r.vZ.y = ReadValue();
			animOCS.r.vZ.z = ReadValue();
			animOCS.t.x = ReadValue();
			animOCS.t.y = ReadValue();
			animOCS.t.z = ReadValue();
			animOCS.s = VVec3(1,1,1);
		
			// compute a total transformation so we're relative to nothing
			VCoords3 totalOCSFrom;
			for (CCpjSklBone* b = skl->m_Bones[j].parentBone; b; b = b->parentBone)
				totalOCSFrom <<= baseOCSOriginal[b - &skl->m_Bones[0]];
			VCoords3 totalOCSTo;
			for (b = skl->m_Bones[j].parentBone; b; b = b->parentBone)
				totalOCSTo <<= b->baseCoords;
		
			// bring animocs out into the world, reorient due to bones pro rotation, and put it back
			animOCS <<= totalOCSFrom;
			animOCS <<= bp2AdjustCoords;
			animOCS >>= totalOCSTo;

			// make animOCS relative to base OCS
			animOCS >>= skl->m_Bones[j].baseCoords;

#if 0
			for (int k=0;k<12;k++)
				ReadValue(); // node frame, skip
#endif

			// add a rotation to the frame
			CCpjSeqRotate* br = &frame->rotates[frame->rotates.Add()];
			VEulers3 eulers(animOCS.r);
			eulers.r *= 32768.f / M_PI; while (eulers.r < 0.f) eulers.r += 65536.f;
			eulers.p *= 32768.f / M_PI; while (eulers.p < 0.f) eulers.p += 65536.f;
			eulers.y *= 32768.f / M_PI; while (eulers.y < 0.f) eulers.y += 65536.f;			
			br->boneIndex = (NWord)j;
			br->roll = (NSWord)eulers.r;
			br->pitch = (NSWord)eulers.p;
			br->yaw = (NSWord)eulers.y;
#ifndef CPJ_SEQ_NOQUATOPT
			eulers.r = (float)br->roll * M_PI / 32768.f;
			eulers.p = (float)br->pitch * M_PI / 32768.f;
			eulers.y = (float)br->yaw * M_PI / 32768.f;
			br->quat = VQuat3(~VAxes3(eulers));
#endif

			// add a translation and/or scale if required
			if (animOCS.t.Length() > M_EPSILON)
			{
				CCpjSeqTranslate* bt = &frame->translates[frame->translates.Add()];
				bt->boneIndex = (NWord)j;
				bt->translate = animOCS.t;
			}
			if ((animOCS.s & VVec3(1,1,1)) > M_EPSILON)
			{
				CCpjSeqScale* bs = &frame->scales[frame->scales.Add()];
				bs->boneIndex = (NWord)j;
				bs->scale = animOCS.s;
			}
		}
	}

	// kill off references to ignored bones
	for (NDword iIgnore=0; iIgnore<configIgnoreBones.GetCount(); iIgnore++)
	{
		for (NDword selIndex=0; selIndex<seq->m_BoneInfo.GetCount(); selIndex++)
		{
			if (!stricmp(*seq->m_BoneInfo[selIndex].name, *configIgnoreBones[iIgnore]))
				break;
		}
		if (selIndex >= seq->m_BoneInfo.GetCount())
			continue;
	
		// remove this boneinfo item
		seq->m_BoneInfo.Remove(selIndex);

		// run through all frames and remove all elements that refer to this bone
		for (i=0;i<seq->m_Frames.GetCount();i++)
		{
			CCpjSeqFrame* frame = &seq->m_Frames[i];
			for (NDword j=0;j<frame->rotates.GetCount();j++)
			{
				CCpjSeqRotate* r = &frame->rotates[j];
				if (r->boneIndex == (NDword)selIndex)
				{
					frame->rotates.Remove(j--);
					continue;
				}
				if (r->boneIndex > (NDword)selIndex)
					r->boneIndex--;
			}
			for (j=0;j<frame->translates.GetCount();j++)
			{
				CCpjSeqTranslate* t = &frame->translates[j];
				if (t->boneIndex == (NDword)selIndex)
				{
					frame->translates.Remove(j--);
					continue;
				}
				if (t->boneIndex > (NDword)selIndex)
					t->boneIndex--;
			}
			for (j=0;j<frame->scales.GetCount();j++)
			{
				CCpjSeqScale* s = &frame->scales[j];
				if (s->boneIndex == (NDword)selIndex)
				{
					frame->scales.Remove(j--);
					continue;
				}
				if (s->boneIndex > (NDword)selIndex)
					s->boneIndex--;
			}
		}	
	}

    return(1);
}

NBool OCpjImpSeqBP2::Import(OObject* inRes, NChar* inFileName, NChar* outError)
{	
	FILE* fp;
	NDword fplen;
	if (!(fp = fopen(inFileName, "rb")))
	{
		sprintf(outError, "Could not open file \"%s\"", inFileName);
		return(0);
	}
	fseek(fp, 0, SEEK_END);
	fplen = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	NByte* buf = MEM_Malloc(NByte, fplen+1); // additional byte for null terminator
	fread(buf, 1, fplen, fp);
	buf[fplen] = 0;
	fclose(fp);
	NBool result = ImportMem(inRes, buf, fplen, outError);
	MEM_Free(buf);
	if (result)
	{
        OCpjSequence* seq = (OCpjSequence*)inRes;
        seq->SetName(STR_FileRoot(inFileName));
        seq->mIsLoaded = 1;
	}
	return(result);
}

//****************************************************************************
//**
//**    END MODULE IMPBP2.CPP
//**
//****************************************************************************

