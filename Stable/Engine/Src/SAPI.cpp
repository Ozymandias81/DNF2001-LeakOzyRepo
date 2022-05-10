#include <windows.h>
#include <mmsystem.h>
//#include <initguid.h>
#include "spchwrap.h"

void SpeakText(void *string)
{
	static PCVoiceText pCVTxt=NULL;
	if(!pCVTxt) 
	{
		CoInitialize(NULL);
 
		pCVTxt = new CVoiceText;
		if(pCVTxt->Init(L"Unreal Tournament")) 
		{
			delete pCVTxt;
			pCVTxt=NULL;
			return;
		}
	}
	if(!pCVTxt) return;
    
	pCVTxt->Speak((const unsigned short *)string);
}