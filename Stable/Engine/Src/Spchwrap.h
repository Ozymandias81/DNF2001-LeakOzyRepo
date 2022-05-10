/**********************************************************************
SpchWrap.h - Speech API header for the C++ wrapper objects.
*/

#ifndef _SPCHWRAP_H
#define _SPCHWRAP_H

#define TAPI_VERSION_1_4 0x00010004
#define TAPI_VERSION_2_0 0x00020000
#define TAPI_CURRENT_VERSION TAPI_VERSION_1_4

#include <tapi.h>
#include "speech.h"
#include "spchtel.h"

#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
HRESULT ChooseEngineDialog(void *hwnd);
#else
HRESULT ChooseEngineDialog(HWND hwnd);
#endif

// so it compiles with old directsound 4.0, which is included with VC 5.0
#ifndef DSCBSTATUS_CAPTURING 
// DirectSound Capture Component GUID {B0210780-89CD-11d0-AF08-00A0C925CD16}
DEFINE_GUID(CLSID_DirectSoundCapture, 0xb0210780, 0x89cd, 0x11d0, 0xaf, 0x8, 0x0, 0xa0, 0xc9, 0x25, 0xcd, 0x16);

//
// IDirectSoundCapture
//

typedef struct _DSCCAPS
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwFormats;
    DWORD           dwChannels;
} DSCCAPS, *LPDSCCAPS;

typedef const DSCCAPS *LPCDSCCAPS;

typedef struct _DSCBUFFERDESC
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwBufferBytes;
    DWORD           dwReserved;
    LPWAVEFORMATEX  lpwfxFormat;
} DSCBUFFERDESC, *LPDSCBUFFERDESC;

typedef const DSCBUFFERDESC *LPCDSCBUFFERDESC;
struct IDirectSoundCapture;
struct IDirectSoundCaptureBuffer;
typedef struct IDirectSoundCaptureBuffer *LPDIRECTSOUNDCAPTUREBUFFER;

DEFINE_GUID(IID_IDirectSoundCapture, 0xb0210781, 0x89cd, 0x11d0, 0xaf, 0x8, 0x0, 0xa0, 0xc9, 0x25, 0xcd, 0x16);

#undef INTERFACE
#define INTERFACE IDirectSoundCapture

DECLARE_INTERFACE_(IDirectSoundCapture, IUnknown)
{
    // IUnknown methods
    STDMETHOD(QueryInterface)       (THIS_ REFIID, LPVOID *) PURE;
    STDMETHOD_(ULONG,AddRef)        (THIS) PURE;
    STDMETHOD_(ULONG,Release)       (THIS) PURE;

    // IDirectSoundCapture methods
    STDMETHOD(CreateCaptureBuffer)  (THIS_ LPCDSCBUFFERDESC, LPDIRECTSOUNDCAPTUREBUFFER *, LPUNKNOWN) PURE;
    STDMETHOD(GetCaps)              (THIS_ LPDSCCAPS ) PURE;
    STDMETHOD(Initialize)           (THIS_ LPGUID) PURE;
};


#endif

// #defines used so users don't have to include dsound.h
// These are exactly the same as the ones in dsound.h, but with different names
DEFINE_GUID(IID_IDirectSoundTTS,0x279AFA83,0x4981,0x11CE,0xA5,0x21,0x00,0x20,0xAF,0x0B,0xE5,0x60);
DEFINE_GUID(CLSID_DirectSoundTTS,
0x47d4d946, 0x62e8, 0x11cf, 0x93, 0xbc, 0x44, 0x45, 0x53, 0x54, 0x0, 0x0);


class CSRGram;
class CSRGramComp;
class CVoiceMenu;
class CTelControl;


/**********************************************************************
ctools  */


typedef struct {
   PVOID       pElem;      // pointer to the element
   DWORD       dwElemSize; // size of the element in bytes
   } LISTELEM, * PLISTELEM;

class CSWList {
   private:
      DWORD dwNumElems;    // number of elements stored away
      DWORD dwBufSize;     // allocated paElem buffer size in bytes
      LISTELEM   *paElems;   // pointer to the memory containing the
			   // pointers to the list elements
      BOOL  MakeListMemoryThisBig (DWORD dwNumElems);

   public:
      CSWList (void);
      ~CSWList (void);
      DWORD GetNumElems(void);
      BOOL  AddElem (PVOID pData, DWORD dwSize);
      BOOL  InsertElem (DWORD dwElemNum, PVOID pData, DWORD dwSize);
      BOOL  RemoveElem (DWORD dwElemNum);
      DWORD GetElemSize (DWORD dwElemNum);
      PVOID GetElem (DWORD dwElemNum);
      BOOL  SetElem (DWORD dwElemNum, PVOID pData, DWORD dwSize);
	  CSWList *Clone ();      // clones the current list object
   };

typedef CSWList * PCSWList;

/* Combination of tree and list so the data can be searched through
	by word, or by ID */
class CTreeList {
private:
	CSWList		m_list;	// list

public:
	CTreeList (void);
	~CTreeList (void);
   DWORD NameToNumber (PCWSTR pszName);
   PCWSTR NumberToName (DWORD dwElemNum);
	DWORD	GetNumElems(void);
	BOOL	AddElem (PCWSTR szName, PVOID pData, DWORD dwSize);
   DWORD GetElemSize (DWORD dwElemNum);
   PVOID GetElem (DWORD dwElemNum);
   BOOL  SetElem (DWORD dwElemNum, PVOID pData, DWORD dwSize);

   BOOL  m_fCaseSens;      // case sensative - defaults to false
};
typedef CTreeList * PCTreeList;



class CInfParse {

   private:

   public:

      CInfParse (LPCWSTR pszText, DWORD dwChars);
      ~CInfParse (void);
      SectionReset (void);
      BOOL SectionQuery (LPWSTR pszSectionName, DWORD *pdwSectionNameSize);
      BOOL SectionNext (void);
      BOOL SectionFind (LPCWSTR pszSectionName);
      ValueReset (void);
      BOOL ValueQuery (LPWSTR pszValueName, DWORD *pdwValueNameSize,
				  LPWSTR pszValueValue, DWORD *pdwValueValueSize);
      BOOL ValueQuery (LPWSTR pszValueName, DWORD *pdwValueNameSize,
				  LONG *plValue);
      BOOL ValueNext (void);
      BOOL ValueFind (LPCWSTR pszValueName);

      LPWSTR      m_pszInf;      // parse data
      CSWList       m_lines;       // list of line
      DWORD       m_dwCurSection; // start of the current section
      DWORD       m_dwCurValue;   // start of the current value within the section
   };

typedef CInfParse * PCInfParse;


WCHAR * NextToken (WCHAR *pCur, WCHAR **ppStart, DWORD *pdwSize);
WCHAR ExtractToken (WCHAR *pStart, DWORD dwSize, WCHAR *pszCopyTo);


/**********************************************************************
low SR */

/* SR Mode */
class CSRMode {
   public:
      CSRMode (void);
      ~CSRMode (void);

      // specify the audio source
      HRESULT  InitAudioSourceMM (DWORD dwDeviceID);
      HRESULT  InitAudioSourceDirect (LPUNKNOWN lpUnkDirect);
      HRESULT  InitAudioSourceObject (LPUNKNOWN lpUnk);

      // specify the mode
      HRESULT  Init (void);
      HRESULT  Init (GUID gMode);
      HRESULT  Init (SRMODEINFOW *pSRModeInfo, SRMODEINFORANK *pSRModeInfoRank = NULL);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // attributes
      HRESULT  AutoGainEnableGet (DWORD *pdwAutoGain);
      DWORD    AutoGainEnableGet (void);
      HRESULT  AutoGainEnableSet (DWORD dwAutoGain);
      HRESULT  EchoGet (BOOL *pfEcho);
      BOOL     EchoGet (void);
      HRESULT  EchoSet (BOOL fEcho);
      HRESULT  EnergyFloorGet (WORD *pwEnergy);
      WORD     EnergyFloorGet (void);
      HRESULT  EnergyFloorSet (WORD wEnergy);
      HRESULT  MicrophoneGet (WCHAR *pszMicrophone, DWORD dwMicrophoneSize, DWORD *pdwNeeded);
      HRESULT  MicrophoneSet (WCHAR *pszMicrophone);
      HRESULT  RealTimeGet (DWORD *pdwRealTime);
      DWORD    RealTimeGet (void);
      HRESULT  RealTimeSet (DWORD dwRealTime);
      HRESULT  SpeakerGet (WCHAR *pszSpeaker, DWORD dwSpeakerSize, DWORD *pdwNeeded);
      HRESULT  SpeakerSet (WCHAR *pszSpeaker);
      HRESULT  ThresholdGet (DWORD *pdwThreshold);
      DWORD    ThresholdGet (void);
      HRESULT  ThresholdSet (DWORD dwThreshold);
      HRESULT  TimeOutGet (DWORD *pdwIncomplete, DWORD *pdwComplete);
      HRESULT  TimeOutSet(DWORD dwIncomplete, DWORD dwComplete);

      // ISRCentral
      HRESULT  GrammarLoad (SRGRMFMT eFormat,
	 SDATA dData,
	 PVOID pNotifyInterface, IID IIDNotifyInterface,
	 LPUNKNOWN *ppiUnknown);
      HRESULT  GrammarLoad (SRGRMFMT eFormat,
	 PVOID pMem, DWORD dwSize,
	 PVOID pNotifyInterface, IID IIDNotifyInterface,
	 LPUNKNOWN *ppiUnknown);
      HRESULT  GrammarLoad (SRGRMFMT eFormat,
	 SDATA dData,
	 PISRGRAMNOTIFYSINKW pISRGramCommon,
	 LPUNKNOWN *ppiUnknown);
      HRESULT  GrammarLoad (SRGRMFMT eFormat,
	 PVOID pMem, DWORD dwSize,
	 PISRGRAMNOTIFYSINKW pISRGramCommon,
	 LPUNKNOWN *ppiUnknown);
      CSRGram* GrammarLoad (SRGRMFMT eFormat,
	 PVOID pMem, DWORD dwSize,
	 PISRGRAMNOTIFYSINKW pISRGramCommon);
      HRESULT  ModeGet (PSRMODEINFOW pModeInfo);
      HRESULT  Pause (void);
      HRESULT  PosnGet (QWORD *pqwTimeStamp);
      QWORD    PosnGet (void);
      HRESULT  Register (PVOID pNotifyInterface, IID IIDNotifyInterface, DWORD *pdwKey);
      HRESULT  Register (PISRNOTIFYSINKW pISRNotifySink, DWORD *pdwKey);
      HRESULT  Resume (void);
      HRESULT  ToFileTime (PQWORD pqWord, FILETIME *pFT);
      HRESULT  UnRegister (DWORD dwKey);


      // Create a grammar and load based upon data
      CSRGramComp *Grammar (PISRGRAMNOTIFYSINKW pISRGramNotifySink);
      CSRGramComp *GrammarFromMemory (PISRGRAMNOTIFYSINKW pISRGramNotifySink, PVOID pMem, DWORD dwSize);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  CSRGramComp *GrammarFromResource (PISRGRAMNOTIFYSINKW pISRGramNotifySink, void * hInst, DWORD dwResID);
#else
      CSRGramComp *GrammarFromResource (PISRGRAMNOTIFYSINKW pISRGramNotifySink, HINSTANCE hInst, DWORD dwResID);
#endif
      CSRGramComp *GrammarFromFile (PISRGRAMNOTIFYSINKW pISRGramNotifySink, PCWSTR pszFile);
      CSRGramComp *GrammarFromStream (PISRGRAMNOTIFYSINKW pISRGramNotifySink, IStream *pIStream);

      // ISRDialogs
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  AboutDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainPhrasesDlg (void * hWndParent, PCWSTR pszTitle = NULL, PCWSTR pszText = NULL);
#else
      HRESULT  AboutDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainPhrasesDlg (HWND hWndParent, PCWSTR pszTitle = NULL, PCWSTR pszText = NULL);
#endif
      // ISRSpeaker
      HRESULT  Delete (WCHAR *pszSpeakerName);
      HRESULT  Enum (PWSTR *ppszBuffer, DWORD *pdwBufSize);
      HRESULT  Merge (WCHAR *pszSpeakerName, PVOID pSpeakerData, DWORD dwSpeakerData);
      HRESULT  New (WCHAR *pszSpeakerName);
      HRESULT  Query (WCHAR *pszSpeakerName, DWORD dwSize, DWORD *pdwNeeded);
      HRESULT  Read (WCHAR *pszSpeakerName, PVOID *ppBuffer, DWORD *pdwBufSize);
      HRESULT  Revert (WCHAR *pszSpeakerName);
      HRESULT  Select(WCHAR *pszSpeakerName, BOOL fLock = FALSE);
      HRESULT  Write (WCHAR *pszSpeakerName, PVOID pSpeakerData, DWORD dwSpeakerData);

      HRESULT  Commit (void);
      HRESULT  Rename (PCWSTR, PCWSTR);
      HRESULT  GetChangedInfo (BOOL *, FILETIME*);

      // ILexPronounce
      HRESULT  Add(VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
         VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
         DWORD dwEngineInfoSize);
      HRESULT  Get(VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
         WCHAR *pszPronounce, DWORD dwPronounceSize, 
         DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
         PVOID pEngineInfo, DWORD dwEngineInfoSize, 
         DWORD *pdwEngineInfoNeeded);
      HRESULT  Remove(WCHAR *pszText, WORD wSense);

      // ILexPronounce2
      HRESULT  AddTo(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
         VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
         DWORD dwEngineInfoSize);
      HRESULT  GetFrom(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
         WCHAR *pszPronounce, DWORD dwPronounceSize, 
         DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
         PVOID pEngineInfo, DWORD dwEngineInfoSize, 
         DWORD *pdwEngineInfoNeeded);
      HRESULT  RemoveFrom(DWORD dwLex, WCHAR *pszText, WORD wSense);
      HRESULT  QueryLexicons (BOOL f, DWORD *pdw);
      HRESULT  ChangeSpelling (DWORD dwLex, PCWSTR psz1, PCWSTR psz2);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // member variables
      LPUNKNOWN         m_pUnkAudio;
      PISRATTRIBUTESW   m_pISRAttributes;
      PIATTRIBUTESW     m_pIAttributes;
      PISRCENTRALW      m_pISRCentral;
      PISRDIALOGSW      m_pISRDialogs;
      PISRDIALOGS2W     m_pISRDialogs2;
      PISRSPEAKERW      m_pISRSpeaker;
      PISRSPEAKER2W     m_pISRSpeaker2;
      PILEXPRONOUNCEW   m_pILexPronounce;
      PILEXPRONOUNCE2W  m_pILexPronounce2;
   };

typedef CSRMode * PCSRMode;


/* SR Enum */
class CSREnum {
   public:
      CSREnum (void);
      ~CSREnum (void);

      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnkEnum);

      HRESULT  Next (ULONG uNum, PSRMODEINFOW pSRModeInfo, ULONG *uFound = NULL);
      HRESULT  Next (PSRMODEINFOW pSRModeInfo);
      HRESULT  Skip (ULONG uNum = 1);
      HRESULT  Reset (void);
      CSREnum* Clone (void);
      HRESULT  Select (GUID gModeID, PCSRMode *ppCSRMode, LPUNKNOWN pUnkAudio = NULL);
      HRESULT  Find (PSRMODEINFOW pSRFind, PSRMODEINFORANK pRank, PSRMODEINFOW pSRFound);
      HRESULT  Find (PSRMODEINFOW pSRFind, PSRMODEINFOW pSRFound);

      // variables
      PISRENUMW   m_pISREnum;
      PISRFINDW   m_pISRFind;

   };

typedef CSREnum * PCSREnum;


/* SRShare */
class CSRShare {
   public:
      CSRShare (void);
      ~CSRShare (void);

      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnkShare);

      HRESULT  Next (ULONG uNum, PSRSHAREW pSRShare, ULONG *uFound = NULL);
      HRESULT  Next (PSRSHAREW pSRShare);
      HRESULT  Skip (ULONG uNum = 1);
      HRESULT  Reset (void);
      CSRShare* Clone (void);
      HRESULT  New (DWORD dwDeviceID, GUID gModeID, PCSRMode *ppCSRMode, QWORD *pqwInstance);
      HRESULT  New (GUID gModeID, PCSRMode *ppCSRMode, QWORD *pqwInstance);
      HRESULT  Share (QWORD qwInstance, PCSRMode *ppCSRMode);
      HRESULT  Detach (QWORD qwInstance);

      // variables
      PIENUMSRSHAREW  m_pISRShare;
   };

typedef CSRShare * PCSRShare;


/* SRGram */
class CSRGram {
   public:
      CSRGram (void);
      ~CSRGram (void);

      // initalization. Don't have to call if created by SR Engine
      HRESULT  Init (LPUNKNOWN pUnkGram);

      // ISRGramCommon
#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
	  HRESULT  Activate (void * hWndListening = NULL, BOOL fAutoPause = FALSE, PCWSTR pszInfo = NULL);
      HRESULT  Activate (void *hWndListening, PCWSTR pszInfo);
#else
      HRESULT  Activate (HWND hWndListening = NULL, BOOL fAutoPause = FALSE, PCWSTR pszInfo = NULL);
      HRESULT  Activate (HWND hWndListening, PCWSTR pszInfo);
#endif
      HRESULT  Archive (BOOL fArchiveResults, PVOID pBuf, DWORD dwBufSize,
	 DWORD *pdwBufNeeded);
      HRESULT  BookMark (QWORD qwTime, DWORD dwBookMarkID);
      HRESULT  Deactivate(PCWSTR pszInfo = NULL);
      HRESULT  DeteriorationGet (DWORD *pdwMemory, DWORD *pdwTime,
			 DWORD *pdwObjects);
      HRESULT  DeteriorationSet(DWORD dwMemory, DWORD dwTime, DWORD dwObjects);
#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
	  HRESULT  TrainDlg (void * hWndParent, PCWSTR pszTitle = NULL);
#else
      HRESULT  TrainDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
#endif
      HRESULT  TrainPhrase (DWORD dwExtent, PSDATA pData);
      HRESULT  TrainQuery (DWORD *pdwFlags);

      // ISRGramCFG
      HRESULT  LinkQuery (WCHAR *pszLinkName, BOOL *pfExist);
      BOOL     LinkQuery (WCHAR *pszLinkName);
      HRESULT  ListAppend (WCHAR *pszListName, SDATA dWord);
      HRESULT  ListAppend (WCHAR *pszListName, PVOID pData, DWORD dwSize);
      HRESULT  ListGet (WCHAR *pszListName, PSDATA pdWord);
      HRESULT  ListQuery (WCHAR *pszListName, BOOL *fExist);
      BOOL     ListQuery (WCHAR *pszListName);
      HRESULT  ListRemove (WCHAR *pszListName, SDATA dWord);
      HRESULT  ListRemove (WCHAR *pszListName, PVOID pData, DWORD dwSize);
      HRESULT  ListSet (WCHAR *pszListName, SDATA dWord);
      HRESULT  ListSet (WCHAR *pszListName, PVOID pData, DWORD dwSize);

      // ISRGramDictation
      HRESULT  Context(PCWSTR pszPrior, PCWSTR pszAfter = NULL);
      HRESULT  Hint (PCWSTR pszHint);
      HRESULT  Words (PCWSTR pszWords);

      // ISRGramInsertionGUI
      HRESULT  Hide (void);
      HRESULT  Move (RECT rCursor);
#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
	  HRESULT  Show (void * hWnd);
#else
      HRESULT  Show (HWND hWnd);
#endif

      // ILexPronounce
      HRESULT  Add(VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
	       VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
	       DWORD dwEngineInfoSize);
      HRESULT  Get(VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
	       WCHAR *pszPronounce, DWORD dwPronounceSize, 
	       DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
	       PVOID pEngineInfo, DWORD dwEngineInfoSize, 
	       DWORD *pdwEngineInfoNeeded);
      HRESULT  Remove(WCHAR *pszText, WORD wSense);

      // ILexPronounce2
      HRESULT  AddTo(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
         VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
         DWORD dwEngineInfoSize);
      HRESULT  GetFrom(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
         WCHAR *pszPronounce, DWORD dwPronounceSize, 
         DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
         PVOID pEngineInfo, DWORD dwEngineInfoSize, 
         DWORD *pdwEngineInfoNeeded);
      HRESULT  RemoveFrom(DWORD dwLex, WCHAR *pszText, WORD wSense);
      HRESULT  QueryLexicons (BOOL f, DWORD *pdw);
      HRESULT  ChangeSpelling (DWORD dwLex, PCWSTR psz1, PCWSTR psz2);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // variables
      PISRGRAMCOMMONW   m_pISRGramCommon;
      PISRGRAMCFGW      m_pISRGramCFG;
      PISRGRAMDICTATIONW m_pISRGramDictation;
      PISRGRAMINSERTIONGUI m_pISRGramInsertionGUI;
      PILEXPRONOUNCEW   m_pILexPronounce;
      PILEXPRONOUNCE2W  m_pILexPronounce2;
      PIATTRIBUTESW     m_pIAttributes;

   };

typedef CSRGram * PCSRGram;



/* SRResult */
class CSRResult {
   public:
      CSRResult (void);
      ~CSRResult (void);

      // initalization.
      HRESULT  Init (LPUNKNOWN pUnkResult);

      // isrresaudio
      HRESULT  GetWAV (PSDATA pWav);
      HRESULT  GetWAV (PSDATA pWav, QWORD qwStart, QWORD qwEnd);

      // isrresbasic
      HRESULT  FlagsGet (DWORD dwRank, DWORD *pdwFlags);
      DWORD    FlagsGet (DWORD dwRank);
      HRESULT  Identify (GUID *pgIdentity);
      HRESULT  PhraseGet (DWORD dwRank, PSRPHRASEW pSRPhrase,
	 DWORD dwPhraseSize, DWORD *pdwPhraseNeeded);
      HRESULT  TimeGet (PQWORD pqTimeStampBegin, PQWORD pqTimeStampEnd);

      // isrrescorrection
      HRESULT  Correction (PSRPHRASEW pSRPhrase, WORD wConfidence = SRCORCONFIDENCE_SOME);
      HRESULT  Validate (WORD wConfidence = SRCORCONFIDENCE_SOME);

      // isrreseval
      HRESULT  ReEvaluate (BOOL *pfChanged);

      // isrresgraph
      HRESULT  BestPathPhoneme(DWORD dwRank, DWORD *padwPath, DWORD dwPathSize,
	 DWORD *pdwPathNeeded);
      HRESULT  BestPathWord(DWORD dwRank, DWORD *padwPath,
	 DWORD dwPathSize, DWORD *pdwPathNeeded);
      HRESULT  GetPhonemeNode (DWORD dwPhonemeNode, PSRRESPHONEMENODE pNode,
	 PWCHAR pcIPA, PWCHAR pcEngine);
      HRESULT  GetWordNode (DWORD dwWordNode, PSRRESWORDNODE pNode, 
	 PSRWORDW pSRWord, DWORD dwMemSize, DWORD *pdwMemNeeded);
      HRESULT  PathScorePhoneme(DWORD *paNodes, DWORD dwNumNodes,
	 LONG *plScore);
      HRESULT  PathScoreWord (DWORD *paNodes, DWORD dwNumNodes, LONG *plScore);

      // isrresgraphex
      HRESULT  NodeStartGet(DWORD *pdw);
      HRESULT  NodeEndGet(DWORD *pdw);
      HRESULT  ArcEnum(DWORD dwNode, DWORD *pdwBuf, DWORD dwSize,
                                  DWORD *pdwNum, BOOL fOutgoing);
      HRESULT  GetAllArcs(DWORD *padwArcID, DWORD dwSize, DWORD *pdwNumArcs,
                                     DWORD *pdwNeeded);
      HRESULT  GetAllNodes(DWORD *padwArcID, DWORD dwSize, DWORD *pdwNumArcs,
                                     DWORD *pdwNeeded);
      HRESULT  NodeGet(DWORD dwArcID, DWORD *pdwNode, BOOL fDestination);
      HRESULT  DWORDGet(DWORD dwID, GUID gAttrib, DWORD *pdwValue);
      HRESULT  DataGet(DWORD dwID, GUID gAttrib, SDATA *psData);
      HRESULT  ScoreGet(DWORD dwScoreType, DWORD *pdwPath,
                                   DWORD dwPathSteps, DWORD dwPathIndexStart,
                                   DWORD dwPathIndexCount, DWORD *pdwScore);
      HRESULT  BestPathEnum(DWORD dwRank, DWORD *pdwStartPath,
                                       DWORD dwStartPathSteps, DWORD *padwEndPath,
                                       DWORD dwEndPathSteps, BOOL fExactMatch,
                                       PSDATA psData);

      // isrresmemory
      HRESULT  Free (DWORD dwKind);
      HRESULT  Get (DWORD *pdwKind, DWORD *pdwMemory);
      HRESULT  LockGet(BOOL *pfLock);
      HRESULT  LockSet(BOOL fLock);

      // isrresmerge
      HRESULT  Merge (LPUNKNOWN pIUnkAdjacent, LPUNKNOWN *ppIUnkMerge);
      CSRResult* Merge(CSRResult * pAdjacent);
      HRESULT  Merge(CSRResult * pAdjacent, CSRResult **ppMerged);
      HRESULT  Split (QWORD qwSplitTime, LPUNKNOWN *ppIUnkLeft, 
	 LPUNKNOWN *ppIUnkRight);
      HRESULT  Split (QWORD qwSplitTime, CSRResult **ppLeft, CSRResult **ppRight);

      // isrresmmodifygui
      HRESULT  Hide (void);
      HRESULT  Move (RECT * rSelection);
#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
	  HRESULT  Show (void *hWnd);
#else
      HRESULT  Show (HWND hWnd);
#endif

      // isrresscore
      HRESULT  GetPhraseScore (DWORD dwRank, long *plScore);
      HRESULT  GetWordScores (DWORD dwRank, long *palScore,
	 DWORD dwWordScoreSize, DWORD *pdwWordScoreRequired);

      // isrresspeaker
      HRESULT  SpeakerCorrection (PCWSTR pszName, WORD wConfidence = SRCORCONFIDENCE_SOME);
      HRESULT  SpeakerIdentify (DWORD dwRank, WCHAR *pszName, DWORD dwNameSize,
	 DWORD *pdwNeeded, LONG *plScore);
      HRESULT  SpeakerIdentifyForFree (BOOL *pfFree);
      HRESULT  SpeakerValidate (WORD wConfidence = SRCORCONFIDENCE_SOME);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // variable
      PISRRESAUDIO      m_pISRResAudio;
      PISRRESAUDIOEX    m_pISRResAudioEx;
      PISRRESBASICW     m_pISRResBasic;
      PISRRESCORRECTIONW m_pISRResCorrection;
      PISRRESEVAL       m_pISRResEval;
      PISRRESGRAPHW     m_pISRResGraph;
      PISRRESGRAPHEX    m_pISRResGraphEx;
      PISRRESMEMORY     m_pISRResMemory;
      PISRRESMERGE      m_pISRResMerge;
      PISRRESMODIFYGUI  m_pISRResModifyGUI;
      PISRRESSCORES     m_pISRResScores;
      PISRRESSPEAKERW   m_pISRResSpeaker;
      PIATTRIBUTESW     m_pIAttributes;

   };

typedef CSRResult * PCSRResult;

/* CSRNotifySink */
#undef   INTERFACE
#define  INTERFACE   CSRNotifySink

DECLARE_INTERFACE_ (CSRNotifySink, ISRNotifySink2) {
   unsigned long m_RefCount;
   CSRNotifySink()
   {
	m_RefCount = 0;
   }
   // IUnknown members
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // ISRNotifySink members
   STDMETHOD (AttribChanged)  (THIS_ DWORD);
   STDMETHOD (Interference)   (THIS_ QWORD, QWORD, DWORD);
   STDMETHOD (Sound)          (THIS_ QWORD, QWORD);
   STDMETHOD (UtteranceBegin) (THIS_ QWORD);
   STDMETHOD (UtteranceEnd)   (THIS_ QWORD, QWORD);
   STDMETHOD (VUMeter)        (THIS_ QWORD, WORD);

      // ISRNotifySink2
   STDMETHOD (Training)       (THIS);
   STDMETHOD (Error)          (THIS_ LPUNKNOWN);
   STDMETHOD (Warning)        (THIS_ LPUNKNOWN);
   };

typedef CSRNotifySink FAR *PCSRNotifySink;

/* CSRGramNotifySink */
#undef   INTERFACE
#define  INTERFACE   CSRGramNotifySink


DECLARE_INTERFACE_ (CSRGramNotifySink, ISRGramNotifySinkW) {
   unsigned long m_RefCount;
   CSRGramNotifySink()
   {
	m_RefCount = 0;
   }
   // IUnknown members
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // ISRGramNotifySinkW members
   STDMETHOD (BookMark)       (THIS_ DWORD);
   STDMETHOD (Paused)         (THIS);
   STDMETHOD (PhraseFinish)   (THIS_ DWORD, QWORD, QWORD, PSRPHRASEW, LPUNKNOWN);
   STDMETHOD (PhraseHypothesis)(THIS_ DWORD, QWORD, QWORD, PSRPHRASEW, LPUNKNOWN);
   STDMETHOD (PhraseStart)    (THIS_ QWORD);
   STDMETHOD (ReEvaluate)     (THIS_ LPUNKNOWN);
   STDMETHOD (Training)       (THIS_ DWORD);
   STDMETHOD (UnArchive)      (THIS_ LPUNKNOWN);
   };

typedef CSRGramNotifySink FAR * PCSRGramNotifySink;




/**********************************************************************
low TTS */

/* TTSMode */
class CTTSMode {
   public:
      CTTSMode (void);
      ~CTTSMode (void);

      // specify the audio source
      HRESULT  InitAudioDestMM (DWORD dwDeviceID);
      HRESULT  InitAudioDestDirect (LPUNKNOWN lpUnkDirect);
      HRESULT  InitAudioDestObject (LPUNKNOWN lpUnk);

      // specify the mode
      HRESULT  Init (void);
      HRESULT  Init (GUID gMode);
      HRESULT  Init (TTSMODEINFOW *pTTSModeInfo, TTSMODEINFORANK *pTTSModeInfoRank = NULL);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // ITTSAttributes
      HRESULT  PitchGet (WORD *pwPitch);
      WORD     PitchGet (void);
      HRESULT  PitchSet (WORD wPitch);
      HRESULT  RealTimeGet (DWORD *pdwRealTime);
      DWORD    RealTimeGet (void);
      HRESULT  RealTimeSet (DWORD dwRealTime);
      HRESULT  SpeedGet (DWORD *pdwSpeed);
      DWORD    SpeedGet (void);
      HRESULT  SpeedSet (DWORD dwSpeed);
      HRESULT  VolumeGet (DWORD *pdwVolume);
      DWORD    VolumeGet (void);
      HRESULT  VolumeSet (DWORD dwVolume);

      // ITTSCentral
      HRESULT  AudioPause (void);
      HRESULT  AudioReset (void);
      HRESULT  AudioResume (void);
      HRESULT  Inject (WCHAR *pszTag);
      HRESULT  ModeGet (PTTSMODEINFOW pttsInfo);
      HRESULT  Phoneme(VOICECHARSET eCharacterSet, DWORD dwFlags, 
		  SDATA dText, PSDATA pdPhoneme);
      HRESULT  PosnGet (QWORD *pqwTimeStamp);
      QWORD    PosnGet (void);
      HRESULT  Register (PVOID pNotifyInterface, IID IIDNotifyInterface,
		  DWORD *pdwKey);
      HRESULT  Register (PITTSNOTIFYSINKW pNotifyInterface, DWORD *pdwKey);
      HRESULT  TextData (VOICECHARSET eCharacterSet, DWORD dwFlags, SDATA dText, 
		  PVOID pNotifyInterface, IID IIDNotifyInterface);
      HRESULT  TextData (VOICECHARSET eCharacterSet, DWORD dwFlags, SDATA dText, 
		  PITTSBUFNOTIFYSINKW pNotifyInterface = NULL);
      HRESULT  Speak (PCWSTR pszSpeak,BOOL fTagged = FALSE,
		  PITTSBUFNOTIFYSINKW pNotifyInterface = NULL);
      HRESULT  ToFileTime (PQWORD pqTimeStamp, FILETIME *pFT);
      HRESULT  UnRegister (DWORD dwKey);

      // ITTSDialogs
#ifdef STRICT //libary is compiled without strict, so hwnd types dont match up
	  HRESULT  AboutDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  TranslateDlg (void * hWndParent, PWSTR pszTitle = NULL);
#else
      HRESULT  AboutDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  TranslateDlg (HWND hWndParent, PWSTR pszTitle = NULL);
#endif
      // ILexPronounce
      HRESULT  Add(VOICECHARSET CharSet, PCWSTR pszText, WCHAR *pszPronounce, 
	 VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
	 DWORD dwEngineInfoSize);
      HRESULT  Get(VOICECHARSET CharSet, PCWSTR pszText, WORD wSense, 
	 WCHAR *pszPronounce, DWORD dwPronounceSize, 
	 DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
	 PVOID pEngineInfo, DWORD dwEngineInfoSize, 
	 DWORD *pdwEngineInfoNeeded);
      HRESULT  Remove(PCWSTR pszText, WORD wSense);

      // ILexPronounce2
      HRESULT  AddTo(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
         VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
         DWORD dwEngineInfoSize);
      HRESULT  GetFrom(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
         WCHAR *pszPronounce, DWORD dwPronounceSize, 
         DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
         PVOID pEngineInfo, DWORD dwEngineInfoSize, 
         DWORD *pdwEngineInfoNeeded);
      HRESULT  RemoveFrom(DWORD dwLex, WCHAR *pszText, WORD wSense);
      HRESULT  QueryLexicons (BOOL f, DWORD *pdw);
      HRESULT  ChangeSpelling (DWORD dwLex, PCWSTR psz1, PCWSTR psz2);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // member variables
      LPUNKNOWN         m_pUnkAudio;
      PITTSATTRIBUTESW  m_pITTSAttributes;
      PIATTRIBUTESW     m_pIAttributes;
      PITTSCENTRALW     m_pITTSCentral;
      PITTSDIALOGSW     m_pITTSDialogs;
      PILEXPRONOUNCEW   m_pILexPronounce;
      PILEXPRONOUNCE2W  m_pILexPronounce2;
   };

typedef CTTSMode * PCTTSMode;

/* TTS Enum */
class CTTSEnum {
   public:
      CTTSEnum (void);
      ~CTTSEnum (void);

      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnkEnum);

      HRESULT  Next (ULONG uNum, PTTSMODEINFOW pTTSModeInfo, ULONG *uFound = NULL);
      HRESULT  Next (PTTSMODEINFOW pTTSModeInfo);
      HRESULT  Skip (ULONG uNum = 1);
      HRESULT  Reset (void);
      CTTSEnum* Clone (void);
      HRESULT  Select (GUID gModeID, PCTTSMode *ppCTTSMode, LPUNKNOWN pUnkAudio = NULL);
      HRESULT  Find (PTTSMODEINFOW pTTSFind, PTTSMODEINFORANK pRank, PTTSMODEINFOW pTTSFound);
      HRESULT  Find (PTTSMODEINFOW pTTSFind, PTTSMODEINFOW pTTSFound);

      // variables
      PITTSENUMW   m_pITTSEnum;
      PITTSFINDW   m_pITTSFind;

   };

typedef CTTSEnum * PCTTSEnum;


#undef   INTERFACE
#define  INTERFACE   CTTSNotifySink

DECLARE_INTERFACE_ (CTTSNotifySink, ITTSNotifySink2W) {

   unsigned long m_RefCount;
   CTTSNotifySink()
   {
	m_RefCount = 0;
   }
// IUnknown members

   STDMETHOD (QueryInterface) (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

// CTTSNotifySinkW members

   STDMETHOD (AttribChanged)  (THIS_ DWORD);
   STDMETHOD (AudioStart)     (THIS_ QWORD);
   STDMETHOD (AudioStop)      (THIS_ QWORD);
   STDMETHOD (Visual)         (THIS_ QWORD, WCHAR, WCHAR, DWORD, PTTSMOUTH);

   // Sink2
   STDMETHOD (Error)          (THIS_ LPUNKNOWN);
   STDMETHOD (Warning)        (THIS_ LPUNKNOWN);
   STDMETHOD (VisualFuture)   (THIS_ DWORD, QWORD, WCHAR, WCHAR, DWORD, PTTSMOUTH);
   };

typedef CTTSNotifySink FAR * PCTTSNotifySink;



#undef   INTERFACE
#define  INTERFACE   CTTSBufNotifySink

DECLARE_INTERFACE_ (CTTSBufNotifySink, ITTSBufNotifySink) {
 
   unsigned long m_RefCount;
   CTTSBufNotifySink()
   {
	m_RefCount = 0;
   }
// IUnknown members

   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

// CTTSBufNotifySink members

   STDMETHOD (TextDataDone)   (THIS_ QWORD, DWORD);
   STDMETHOD (TextDataStarted)(THIS_ QWORD);
   STDMETHOD (BookMark)       (THIS_ QWORD, DWORD);  
   STDMETHOD (WordPosition)   (THIS_ QWORD, DWORD);
   };

typedef CTTSBufNotifySink FAR * PCTTSBufNotifySink;



/**********************************************************************
speech tools */

/* STGramComp */
class CSTGramComp {
   public:
      CSTGramComp (void);
      ~CSTGramComp (void);

      // intialization functions
      HRESULT  Init (void);
      HRESULT  Init (PISTGRAMCOMP pISTGramComp);
      HRESULT  Init (PVOID pMem, DWORD dwSize);       // also loads
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  HRESULT  InitResource (void * hInst, DWORD dwResID); // also loads
#else
      HRESULT  InitResource (HINSTANCE hInst, DWORD dwResID); // also loads
#endif
      HRESULT  Init (PCWSTR pszFile);                 // also loads
      HRESULT  Init (IStream *pIStream);              // also loads

      // gramcomp functions
      HRESULT  FromMemory (PVOID pMem, DWORD dwSize);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  HRESULT  FromResource (void * hInst, DWORD dwResID);
#else
      HRESULT  FromResource (HINSTANCE hInst, DWORD dwResID);
#endif
      HRESULT  FromFile (PCWSTR pszFile);
      HRESULT  FromStream (IStream *pIStream);
      HRESULT  Compile (LPWSTR* ppszError = NULL, DWORD *pdwSize = NULL);
      HRESULT  IsCompiled (BOOL *pfCompiled);
      BOOL     IsCompiled (void);
      HRESULT  ToMemory (PVOID *ppMem, DWORD *pdwSize);
      HRESULT  ToFile (PCWSTR pszFile);
      HRESULT  ToStream (IStream *pIStream);
      HRESULT  TextGet (LPWSTR *pszText, DWORD *pdwSize);
      HRESULT  LanguageGet (LANGUAGEW *pLang);
      LANGID   LanguageGet (void);
      HRESULT  GrammarFormatGet (SRGRMFMT* pFmt);
      SRGRMFMT GrammarFormatGet (void);
      HRESULT  GrammarDataGet (BOOL fEngine, PVOID *ppMem, DWORD *pdwSize);
      HRESULT  GrammarDataSet (PVOID pMem, DWORD dwSize);
      HRESULT  AutoList (PISRGRAMCFGW pISRGramCFG);
      HRESULT  AutoList (PCSRGram pCSRGram);
      HRESULT  PhraseParse (PSRPHRASEW pSRPhrase, DWORD *pdwCmdID = NULL,
	 LPWSTR *ppszParse = NULL, DWORD *pdwSize = NULL);
      DWORD    PhraseParse (PSRPHRASEW pSRPhrase,
	 LPWSTR *ppszParse = NULL, DWORD *pdwSize = NULL);
      HRESULT  GrammarLoad (LPUNKNOWN lpUnkMode, PVOID pNotifySink,
	 IID IIDGramNotifySink, LPUNKNOWN *ppIUnkGram);
      PCSRGram GrammarLoad (PCSRMode pCSRMode, PISRGRAMNOTIFYSINKW pNotifySink);

      // variables
      PISTGRAMCOMP   m_pISTGramComp;

   };

typedef CSTGramComp * PCSTGramComp;

/* SRGramComp - Multiple inheretence*/
class CSRGramComp : public CSRGram, public CSTGramComp {
   public:
      CSRGramComp (void);
      ~CSRGramComp (void);

      // intialization functions
      HRESULT  Init (PCSRMode pCSRMode, PISRGRAMNOTIFYSINKW pISRGramNotifySink);

      // Function do FromXXX, compile (if necessary), and GrammarLoad()
      // If any of these fails then it's all freed
      HRESULT  GrammarFromMemory (PVOID pMem, DWORD dwSize);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  HRESULT  GrammarFromResource (void * hInst, DWORD dwResID);
#else
      HRESULT  GrammarFromResource (HINSTANCE hInst, DWORD dwResID);
#endif
      HRESULT  GrammarFromFile (PCWSTR pszFile);
      HRESULT  GrammarFromStream (IStream *pIStream);

      // overloaded functions because now the grammar, central, or isrgramnotifysink
      HRESULT  AutoList (void);
      HRESULT  GrammarLoad (void);
      HRESULT  GrammarDataSet (short fArchiveResults = FALSE);

      // variables
      PISRCENTRALW         m_pISRCentral;
      PISRGRAMNOTIFYSINKW  m_pISRGramNotifySink;

   };
typedef CSRGramComp * PCSRGramComp;


/* STMicWizard */
class CSTMicWizard {
   public:
      CSTMicWizard (void);
      ~CSTMicWizard (void);

      // initalization
      HRESULT  Init (void);

      // ISTMicWizard
      HRESULT  InfoGet (PMICWIZARDINFO pInfo);
      HRESULT  InfoSet (PMICWIZARDINFO pInfo);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  Wizard (void * hWndParent, DWORD dwUse = STMWU_CNC,
		  DWORD dwWaveInDevice = WAVE_MAPPER,
		  DWORD dwSamplesPerSec = 16000,
		  DWORD dwFlags = 0);
#else
      HRESULT  Wizard (HWND hWndParent, DWORD dwUse = STMWU_CNC,
		  DWORD dwWaveInDevice = WAVE_MAPPER,
		  DWORD dwSamplesPerSec = 16000,
		  DWORD dwFlags = 0);
#endif
      // variables
      PISTMICWIZARD     m_pISTMicWizard;

   };
typedef CSTMicWizard * PCSTMicWizard;

#ifdef STRICT
#define  HWNDHACK void *
#else
#define  HWNDHACK HWND
#endif

/* STLexDlg */
class CSTLexDlg {
   public:
      CSTLexDlg (void);
      ~CSTLexDlg (void);

      // initalization
      HRESULT  Init (void);

      // ISTLexDlg
      HRESULT LexDlg(HWNDHACK hWndParent,
                     PCWSTR pszWord,
                     DWORD dwFlags,
                     LANGID langID,
                     LPUNKNOWN pUnkLex,
                     LPUNKNOWN pUnkTTS = NULL,
                     LPUNKNOWN pUnkBackupLex = NULL,
                     PCWSTR pszPhonemes = NULL,
                     PCWSTR pszTitle = NULL);

      // variables
      PISTLEXDLG     m_pISTLexDlg;

   };
typedef CSTLexDlg * PCSTLexDlg;

/* STPhoneConv */
class CSTPhoneConv {
   public:
      CSTPhoneConv (void);
      ~CSTPhoneConv (void);

      // initalization
      HRESULT  Init (void);

      // ISTPhoneConv
      HRESULT  FromIPA (LPCWSTR pszFromIPA, DWORD *pdwFirstInvalid,
	 LPWSTR pszToSet, DWORD dwNumChars, DWORD *pdwCharsNeeded);
      HRESULT  Get (SDATA *pData);
      HRESULT  SetByLang (LANGID lang);
      HRESULT  SetByText (LPCWSTR pszText);
      HRESULT  ToIPA(LPCWSTR pszFromSet, DWORD *pdwFirstInvalid,
	 LPWSTR pszToIPA, DWORD dwNumChars, DWORD *pdwCharsNeeded);

      // variables
      PISTPHONECONV     m_pISTPhoneConv;

   };
typedef CSTPhoneConv * PCSTPhoneConv;



/* STLog */
class CSTLog {
   public:
      CSTLog (void);
      ~CSTLog (void);

      // initalization
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // ISTLog
      HRESULT  ToFile (PCWSTR pszFile);
      HRESULT  ToStream (IStream *pIStream);
      HRESULT  Text (PCWSTR pszSource, PCWSTR pszMessage, WORD wDetail = 1);
      HRESULT  Data (PCWSTR pszSource, PCWSTR pszMessage, WORD wDetail,
		  PVOID pMem, DWORD dwSize);
      HRESULT  MaxDetailSet (WORD wDetail);
      HRESULT  MaxDetailGet (WORD *pwDetail);
      WORD     MaxDetailGet (void);
      HRESULT  ShowOutput (BOOL fShow);

      // variables
      PISTLOG     m_pISTLog;

   };
typedef CSTLog * PCSTLog;



/* STTTSQueue */
class CSTTTSQueue {
   public:
      CSTTTSQueue (void);
      ~CSTTTSQueue (void);

      // initalization
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // ISTTTSQueue
      HRESULT  WaveAddFromFile (PCWSTR pszSpeakString, PCWSTR pszFile);
      HRESULT  WaveAddFromStream (PCWSTR pszSpeakString, IStream *pIStream);
      HRESULT  WaveAddFromMemory (PCWSTR pszSpeakString, PVOID pMem, DWORD dwSize);
#ifdef STRICT
      HRESULT  WaveAddFromResource (PCWSTR pszSpeakString, void *hModule, DWORD dwID);
      HRESULT  WaveAddFromList (PCWSTR pszString, void* hModule);
      HRESULT  WaveAddFromList (DWORD dwResourceID, void* hModule);
#else
      HRESULT  WaveAddFromResource (PCWSTR pszSpeakString, HMODULE hModule, DWORD dwID);
      HRESULT  WaveAddFromList (PCWSTR pszString, HMODULE hModule);
      HRESULT  WaveAddFromList (DWORD dwResourceID, HMODULE hModule);
#endif
      HRESULT  WaveRemove (PCWSTR pszSpeakString);
      HRESULT  WaveAudioDestSet (LPUNKNOWN pIUnk);
      HRESULT  WaveLevelSet (DWORD dwLevel);
      HRESULT  WaveLevelGet (DWORD *pdwLevel);
      DWORD    WaveLevelGet (void);
      HRESULT  TTSAdd (PCWSTR pszVoice, LPUNKNOWN pUnkTTS);
      HRESULT  TTSAdd (PCWSTR pszVoice, PCTTSMode pCTTSMode);
      HRESULT  TTSRemove (PCWSTR pszVoice);
      HRESULT  TTSGet (PCWSTR pszVoice, LPUNKNOWN *ppUnkTTS);
      PCTTSMode TTSGet (PCWSTR pszVoice);
      HRESULT  Speak (PCWSTR pszSpeak, PCWSTR pszVoice = NULL, DWORD dwID = 0);
      HRESULT  TextData (VOICECHARSET eCharSet, DWORD dwFlags,
	      SDATA dData, PCWSTR pszVoice = NULL, DWORD dwID = 0);
      HRESULT  AudioPause (void);
      HRESULT  AudioResume (void);
      HRESULT  AudioReset (void);
      HRESULT  Register (PVOID pNotifySink, REFIID IIDNotifySink);
      HRESULT  Register (PISTTTSQUEUENOTIFYSINK pNotifySink);
      HRESULT  UseLogging (LPUNKNOWN pUnkLog);
      HRESULT  UseLogging (PCSTLog pLog);
      HRESULT  IsSpeaking (DWORD *pdwSpeak);
      DWORD    IsSpeaking (void);

      void     WaitUntilDoneSpeaking (void);

      // variables
      PISTTTSQUEUE     m_pISTTTSQueue;

   };
typedef CSTTTSQueue * PCSTTTSQueue;


// CSTTTSQueueNotifySink Interface

#undef   INTERFACE
#define  INTERFACE   CSTTTSQueueNotifySink

DECLARE_INTERFACE_ (CSTTTSQueueNotifySink, IUnknown) {
   unsigned long m_RefCount;
   CSTTTSQueueNotifySink()
   {
	m_RefCount = 0;
   }
   // IUnknown members
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // CSTTTSQueueNotifySink members
   STDMETHOD (Start) (THIS);
   STDMETHOD (Stop) (THIS);
   STDMETHOD (SpeakID) (THIS_ DWORD);
   STDMETHOD (Error) (THIS_ HRESULT);
   STDMETHOD (Bookmark) (THIS_ DWORD);
   };

typedef CSTTTSQueueNotifySink FAR * PCSTTTSQueueNotifySink;



/**********************************************************************
voice commands */

/* CVoiceCommands */
class CVoiceCommands {
   public:
      CVoiceCommands (void);
      ~CVoiceCommands (void);

      // initalization
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN pIUnkVCmd);
      
      // initialization and registration combined
      HRESULT  Init (PCWSTR pszSite, PVOID pNotifyInterface,
	 IID IIDNotifyInterface, DWORD dwFlags = VCMDRF_ALLBUTVUMETER,
	 PVCSITEINFOW pSiteInfo = NULL);
      HRESULT  Init (PIVCMDNOTIFYSINKW pNotifyInterface, PCWSTR pszSite = NULL,
	 DWORD dwFlags = VCMDRF_ALLBUTVUMETER, PVCSITEINFOW pSiteInfo = NULL);

      // IVoiceCommands
      HRESULT  CmdMimic (PVCMDNAMEW pMenu, PCWSTR pszCommand);
      HRESULT  CmdMimic (PCWSTR pszApplication, PCWSTR pszState, PCWSTR pszCommand);
      HRESULT  MenuCreate (PVCMDNAMEW pName, PLANGUAGEW pLanguage, DWORD dwFlags,
	    PIVCMDMENUW *ppIVCmdMenu);
      HRESULT  MenuCreate (PCWSTR pszApplication, PCWSTR pszState,
	    CVoiceMenu **ppCVoiceMenu,
	    DWORD dwFlags = VCMDMC_CREATE_TEMP);
      CVoiceMenu* MenuCreate (PCWSTR pszApplication, PCWSTR pszState,
	    DWORD dwFlags = VCMDMC_CREATE_TEMP);
      HRESULT  MenuDelete (PVCMDNAMEW pName);
      HRESULT  MenuDelete (PCWSTR pszApplication, PCWSTR pszState);
      HRESULT  MenuEnum (DWORD dwFlags, PCWSTR pszApplicationFilter, 
	    PCWSTR pszStateFilter, PIVCMDENUMW *ppiVCmdEnum);
      HRESULT  Register (PCWSTR pszSite, PVOID pNotifyInterface,
	 IID IIDNotifyInterface, DWORD dwFlags = VCMDRF_ALLBUTVUMETER,
	 PVCSITEINFOW pSiteInfo = NULL);
      HRESULT  Register (PIVCMDNOTIFYSINKW pNotifyInterface, PCWSTR pszSite = NULL,
	 DWORD dwFlags = VCMDRF_ALLBUTVUMETER, PVCSITEINFOW pSiteInfo = NULL);

      // IVCmdAttributes
      HRESULT  AutoGainEnableGet (DWORD *pdwAutoGain);
      DWORD    AutoGainEnableGet (void);
      HRESULT  AutoGainEnableSet (DWORD dwAutoGain);
      HRESULT  AwakeStateGet (DWORD *pdwAwakeState);
      DWORD    AwakeStateGet (void);
      HRESULT  AwakeStateSet (DWORD pdwAwakeState);
      HRESULT  DeviceGet (DWORD *pdwDevice);
      DWORD    DeviceGet (void);
      HRESULT  DeviceSet (DWORD pdwDevice);
      HRESULT  EnabledGet (DWORD *pdwEnabled);
      DWORD    EnabledGet (void);
      HRESULT  EnabledSet (DWORD pdwEnabled);
      HRESULT  MicrophoneGet (WCHAR *pszMicrophone, DWORD dwMicrophoneSize, DWORD *pdwNeeded);
      HRESULT  MicrophoneSet (WCHAR *pszMicrophone);
      HRESULT  SpeakerGet (WCHAR *pszSpeaker, DWORD dwSpeakerSize, DWORD *pdwNeeded);
      HRESULT  SpeakerSet (WCHAR *pszSpeaker);
      HRESULT  SRModeGet (GUID *pgMode);
      HRESULT  SRModeSet (GUID gMode);
      HRESULT  ThresholdGet (DWORD *pdwThreshold);
      DWORD    ThresholdGet (void);
      HRESULT  ThresholdSet (DWORD dwThreshold);

      // ISRDialogs
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  AboutDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (void *hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (void * hWndParent, PCWSTR pszTitle = NULL);
#else
      HRESULT  AboutDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
#endif

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // variables
      PIVOICECMDW       m_pIVoiceCmd;
      PIVCMDATTRIBUTESW m_pIVCmdAttributes;
      PIATTRIBUTESW     m_pIAttributes;
      PIVCMDDIALOGSW    m_pIVCmdDialogs;
   };
typedef CVoiceCommands * PCVoiceCommands;


/* CVoiceMenu */
class CVoiceMenu {
   public:
      CVoiceMenu (void);
      ~CVoiceMenu (void);

      // initalization
      HRESULT  Init (LPUNKNOWN pIUnkVMenu);

      // IVCmdMenu
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  Activate (void * hWndListening = NULL, DWORD dwFlags = NULL);
#else
      HRESULT  Activate (HWND hWndListening = NULL, DWORD dwFlags = NULL);
#endif
      HRESULT  Add (DWORD dwCmdNum, SDATA dData, DWORD *pdwCmdStart);
      HRESULT  AddOneCommand (DWORD dwID, PCWSTR pszCommand,
	 PCWSTR pszDescription = NULL, PCWSTR pszCategory = NULL,
	 DWORD dwFlags = 0, PVOID pAction = NULL, DWORD dwActionSize = NULL);
      HRESULT  Deactivate (void);
      HRESULT  EnableItem (DWORD dwEnable, DWORD dwCmdNum, DWORD dwFlag = VCMD_BY_POSITION);
      HRESULT  Get (DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag,
	 PSDATA pdData, DWORD *pdwCmdNum);
      HRESULT  ListGet (PCWSTR pszList, PSDATA pdList, DWORD *pdwListNum);
      HRESULT  ListSet (PCWSTR pszList, DWORD dwListNum, SDATA dList);
      HRESULT  Num (DWORD *pdwNumCmd);
      DWORD    Num (void);
      HRESULT  Remove (DWORD dwCmdStart, DWORD dwCmdNum = 1, DWORD dwFlag = VCMD_BY_POSITION);
      HRESULT  Set (DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag, 
	 SDATA dData);
      HRESULT  SetOneCommand (DWORD dwCmdNum, DWORD dwFlag,
	 DWORD dwID, PCWSTR pszCommand,
	 PCWSTR pszDescription = NULL, PCWSTR pszCategory = NULL,
	 DWORD dwFlags = 0, PVOID pAction = NULL, DWORD dwActionSize = NULL);
      HRESULT  SetItem (DWORD dwEnable, DWORD dwCmdNum, DWORD dwFlag = VCMD_BY_POSITION);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  TrainMenuDlg (void * hWndParent, PCWSTR pszTitle = NULL);
#else
      HRESULT  TrainMenuDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
#endif
	 
      PIVCMDMENUW       m_pIVCmdMenu;
   };
typedef CVoiceMenu * PCVoiceMenu;


/* CVCmdNotifySink */
#undef   INTERFACE
#define  INTERFACE   CVCmdNotifySink

DECLARE_INTERFACE_ (CVCmdNotifySink, IVCmdNotifySinkW) {
   unsigned long m_RefCount;
   CVCmdNotifySink()
   {
	m_RefCount = 0;
   }
   // IUnknown members
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // IVCmdNotifySink members

   STDMETHOD (CommandRecognize) (THIS_ DWORD, PVCMDNAMEW, DWORD, DWORD, PVOID, 
				 DWORD, PWSTR, PWSTR);
   STDMETHOD (CommandOther)     (THIS_ PVCMDNAMEW, PWSTR);
   STDMETHOD (CommandStart)     (THIS);
   STDMETHOD (MenuActivate)     (THIS_ PVCMDNAMEW, BOOL);
   STDMETHOD (UtteranceBegin)   (THIS);
   STDMETHOD (UtteranceEnd)     (THIS);
   STDMETHOD (VUMeter)          (THIS_ WORD);
   STDMETHOD (AttribChanged)    (THIS_ DWORD);
   STDMETHOD (Interference)     (THIS_ DWORD);
};

typedef CVCmdNotifySink * PCVCmdNotifySink;




/**********************************************************************
voice dictation */

/* CVoiceDictation */
class CVoiceDictation {
   public:
      CVoiceDictation (void);
      ~CVoiceDictation (void);

      // initalization
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN pIUnkVDct);
      
      // initialization and registration combined
      HRESULT  Init (PCWSTR pszApplication, PCWSTR pszTopic,
	 IStorage* pISessionData, PCWSTR pszSite,
	 PVOID pNotifyInterface, IID IIDNotifyInterface, DWORD dwFlags);
      HRESULT  Init (PCWSTR pszApplication, PIVDCTNOTIFYSINKW pNotifyInterface,
	 PCWSTR pszTopic = NULL,
	 PCWSTR pszSite = NULL,
	 DWORD dwFlags = VCMDRF_ALLBUTVUMETER,
	 IStorage* pISessionDat = NULL);

      // IVDctAttributes
      HRESULT  AutoGainEnableGet (DWORD *pdwAutoGain);
      DWORD    AutoGainEnableGet (void);
      HRESULT  AutoGainEnableSet (DWORD dwAutoGain);
      HRESULT  EchoGet (BOOL *pfEcho);
      BOOL     EchoGet (void);
      HRESULT  EchoSet (BOOL fEcho);
      HRESULT  EnergyFloorGet (WORD *pwEnergy);
      WORD     EnergyFloorGet (void);
      HRESULT  EnergyFloorSet (WORD wEnergy);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  IsAnyoneDictating(void * hWnd, WCHAR *pszName, DWORD dwNameSize, DWORD *pdwNameNeeded);
#else
      HRESULT  IsAnyoneDictating(HWND hWnd, WCHAR *pszName, DWORD dwNameSize, DWORD *pdwNameNeeded);
#endif
      HRESULT  MemoryGet (VDCTMEMORY *pDctMemory);
      HRESULT  MemorySet (VDCTMEMORY *pDctMemory);
      HRESULT  MicrophoneGet (WCHAR *pszMicrophone, DWORD dwMicrophoneSize, DWORD *pdwNeeded);
      HRESULT  MicrophoneSet (WCHAR *pszMicrophone);
      HRESULT  ModeGet (DWORD *pdwMode);
      DWORD    ModeGet (void);
      HRESULT  ModeSet (DWORD dwMode);
      HRESULT  RealTimeGet (DWORD *pdwRealTime);
      DWORD    RealTimeGet (void);
      HRESULT  RealTimeSet (DWORD dwRealTime);
      HRESULT  SpeakerGet (WCHAR *pszSpeaker, DWORD dwSpeakerSize, DWORD *pdwNeeded);
      HRESULT  SpeakerSet (WCHAR *pszSpeaker);
      HRESULT  ThresholdGet (DWORD *pdwThreshold);
      DWORD    ThresholdGet (void);
      HRESULT  ThresholdSet (DWORD dwThreshold);
      HRESULT  TimeOutGet (DWORD *pdwIncomplete, DWORD *pdwComplete);
      HRESULT  TimeOutSet(DWORD dwIncomplete, DWORD dwComplete);

      // IVDctCommands
      HRESULT  CommandAdd (BOOL fGlobal, DWORD dwCmdNum, SDATA dData, DWORD *pdwCmdStart);
      HRESULT  CommandGet (BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag,
	 PSDATA pdData, DWORD *pdwCmdNum);
      HRESULT  CommandNum (BOOL fGlobal, DWORD *pdwNumCmd);
      DWORD    CommandNum (BOOL fGlobal = FALSE);
      HRESULT  CommandRemove (BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag);
      HRESULT  CommandSet(BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag, 
	 SDATA dData);
      HRESULT  CommandEnableItem (BOOL fGlobal, DWORD dwEnable, DWORD dwCmdNum, DWORD dwFlag);

      // IVDctDialogs
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  AboutDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (void * hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (void *hWndParent, PCWSTR pszTitle = NULL);
#else
      HRESULT  AboutDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainGeneralDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
      HRESULT  TrainMicDlg (HWND hWndParent, PCWSTR pszTitle = NULL);
#endif
	
      // IVDctGlossary
      HRESULT  GlossaryAdd (BOOL fGlobal, DWORD dwCmdNum, SDATA dData, DWORD *pdwCmdStart);
      HRESULT  GlossaryGet (BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag,
	 PSDATA pdData, DWORD *pdwCmdNum);
      HRESULT  GlossaryNum (BOOL fGlobal, DWORD *pdwNumCmd);
      DWORD    GlossaryNum (BOOL fGlobal = FALSE);
      HRESULT  GlossaryRemove (BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag);
      HRESULT  GlossarySet(BOOL fGlobal, DWORD dwCmdStart, DWORD dwCmdNum, DWORD dwFlag, 
	 SDATA dData);
      HRESULT  GlossaryEnableItem (BOOL fGlobal, DWORD dwEnable, DWORD dwCmdNum, DWORD dwFlag);

      // IVDctGUI
      HRESULT  FlagsGet (DWORD *pdwFlags);
      DWORD    FlagsGet (void);
      HRESULT  FlagsSet (DWORD dwFlags);
      HRESULT  SetSelRect (RECT *pRect);

      // IVDctTextNorm
      HRESULT  OptionsEnum (PWSTR *ppOptions, DWORD *pdwSize);
      HRESULT  OptionsGet (PCWSTR pszOptionName, BOOL *pfOn);
      HRESULT  OptionsSet (PCWSTR pszOptionName, BOOL fOn);

      // IVDctText
      HRESULT  BookmarkAdd (VDCTBOOKMARK *pBookMark);
      HRESULT  BookmarkEnum (DWORD dwStart, DWORD dwNumChars,
	 PVDCTBOOKMARK *ppBookMark, DWORD *pdwNumMarks);
      HRESULT  BookmarkQuery (DWORD dwID, VDCTBOOKMARK *pBookMark);
      HRESULT  BookmarkRemove (DWORD dwMark);
      HRESULT  FX(DWORD dwFX);
      HRESULT  GetChanges (DWORD *pdwNewStart, DWORD *pdwNewEnd,
	 DWORD *pdwOldStart, DWORD *pdwOldEnd);
      HRESULT  Hint (PCWSTR pszHint);
      HRESULT  Lock ();
      HRESULT  ResultsGet (DWORD dwStart, DWORD dwNumChars,
	 DWORD *pdwPhraseStart, DWORD *pdwPhraseNumChars,
	 LPUNKNOWN *ppIUnkPhraseResults);
      HRESULT  ResultsGet (DWORD dwStart, DWORD dwNumChars,
	 DWORD *pdwPhraseStart, DWORD *pdwPhraseNumChars,
	 PCSRResult *ppCSRResult);
      HRESULT  TextGet (DWORD dwStart, DWORD dwNumChars, PSDATA pData);
      HRESULT  TextMove (DWORD dwStart, DWORD dwNumChars,
	 DWORD dwMoveTo, DWORD dwReason);
      HRESULT  TextRemove (DWORD dwStart, DWORD dwNumChars,
	 DWORD dwReason);
      HRESULT  TextSelGet (DWORD *pdwStart, DWORD *pdwNumChars);
      HRESULT  TextSelSet (DWORD dwStart, DWORD dwNumChars);
      HRESULT  TextSet (DWORD dwStart, DWORD dwNumChars,
	 PCWSTR pszBuf, DWORD dwReason);
      HRESULT  UnLock();
      HRESULT  Words (PCWSTR pszWords);

      // IVDctText2
      HRESULT  ITNApply (DWORD dwStart, DWORD dwNumChars);
      HRESULT  ITNExpand (DWORD dwStart, DWORD dwNumChars);
      HRESULT  ResultsGet2 (DWORD dwStart, DWORD dwNumChars,
         DWORD *pdwPhraseStart, DWORD *pdwPhraseNumChars,
			LPUNKNOWN *ppIUnkPhraseResults,
         DWORD *pdwNodeLeft, DWORD *pdwNodeRight);
      HRESULT  ResultsSet (DWORD dwStart, DWORD dwNumChars, 
				                     LPUNKNOWN pIUnkPhraseResults, DWORD dwNodeLeft, DWORD dwNodeRight);

      // IVoiceDictation
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under stric
	  HRESULT  Activate(void * hWnd = NULL);
#else
      HRESULT  Activate(HWND hWnd = NULL);
#endif
      HRESULT  CFGSet(LANGID lang, PCWSTR pszTopic, PCWSTR pszCFG);
      HRESULT  Deactivate(void);
      HRESULT  Register (PCWSTR pszApplication, PCWSTR pszTopic,
	 IStorage* pISessionData, PCWSTR pszSite,
	 PVOID pNotifyInterface, IID IIDNotifyInterface, DWORD dwFlags);
      HRESULT  Register (PCWSTR pszApplication, PIVDCTNOTIFYSINKW pNotifyInterface,
	 PCWSTR pszTopic = NULL,
	 PCWSTR pszSite = NULL,
	 DWORD dwFlags = VCMDRF_ALLBUTVUMETER,
	 IStorage* pISessionDat = NULL);
      HRESULT  SessionDeserialize (IStorage* pISessionData);
      HRESULT  SessionSerialize (IStorage* pISessionData);
      HRESULT  SiteInfoGet (PCWSTR pszSite, PVDSITEINFOW pSiteInfo);
      HRESULT  SiteInfoSet (PCWSTR pszSite, PVDSITEINFOW pSiteInfo);
      HRESULT  TopicAddGrammar (PCWSTR pszTopic, SDATA sData);
      HRESULT  TopicAddString (PCWSTR pszTopic, LANGUAGEW *pLanguage);
      HRESULT  TopicDeserialize (IStorage* pITopicData);
      HRESULT  TopicEnum (PSDATA pData);
      HRESULT  TopicRemove (PCWSTR pszTopic);
      HRESULT  TopicSerialize (IStorage* pITopicData);

      // ISRSpeaker
      HRESULT  Delete (WCHAR *pszSpeakerName);
      HRESULT  Enum (PWSTR *ppszBuffer, DWORD *pdwBufSize);
      HRESULT  Merge (WCHAR *pszSpeakerName, PVOID pSpeakerData, DWORD dwSpeakerData);
      HRESULT  New (WCHAR *pszSpeakerName);
      HRESULT  Query (WCHAR *pszSpeakerName, DWORD dwSize, DWORD *pdwNeeded);
      HRESULT  Read (WCHAR *pszSpeakerName, PVOID *ppBuffer, DWORD *pdwBufSize);
      HRESULT  Revert (WCHAR *pszSpeakerName);
      HRESULT  Select(WCHAR *pszSpeakerName, BOOL fLock);
      HRESULT  Write (WCHAR *pszSpeakerName, PVOID pSpeakerData, DWORD dwSpeakerData);

      // ILexPronounce
      HRESULT  Add(VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
	       VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
	       DWORD dwEngineInfoSize);
      HRESULT  Get(VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
	       WCHAR *pszPronounce, DWORD dwPronounceSize, 
	       DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
	       PVOID pEngineInfo, DWORD dwEngineInfoSize, 
	       DWORD *pdwEngineInfoNeeded);
      HRESULT  Remove(WCHAR *pszText, WORD wSense);

      // ILexPronounce2
      HRESULT  AddTo(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WCHAR *pszPronounce, 
         VOICEPARTOFSPEECH PartOfSpeech, PVOID pEngineInfo, 
         DWORD dwEngineInfoSize);
      HRESULT  GetFrom(DWORD dwLex, VOICECHARSET CharSet, WCHAR *pszText, WORD wSense, 
         WCHAR *pszPronounce, DWORD dwPronounceSize, 
         DWORD *pdwPronounceNeeded, VOICEPARTOFSPEECH *pPartOfSpeech, 
         PVOID pEngineInfo, DWORD dwEngineInfoSize, 
         DWORD *pdwEngineInfoNeeded);
      HRESULT  RemoveFrom(DWORD dwLex, WCHAR *pszText, WORD wSense);
      HRESULT  QueryLexicons (BOOL f, DWORD *pdw);
      HRESULT  ChangeSpelling (DWORD dwLex, PCWSTR psz1, PCWSTR psz2);

      // vdctcommandsbuiltin
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
      HRESULT  BuiltInActivate (void * hWnd, DWORD dwFlags);
#else
      HRESULT  BuiltInActivate (HWND hWnd, DWORD dwFlags);
#endif
      HRESULT  BuiltInDeactivate (void);
      HRESULT  BuiltInFromMemory (PVOID pMem, DWORD dwSize);

      HRESULT  BuiltInFromFile (PCWSTR pszFile);
      HRESULT  BuiltInFromStream (IStream *pIStream);
      HRESULT  BuiltInListSet (PCWSTR pszList, PVOID pMem, DWORD dwSize);
      HRESULT  BuiltInTextGet (LPWSTR* pszText, DWORD* pdwSize);
      HRESULT  BuiltInToMemory (PVOID* ppMem, DWORD* pdwSize);
      HRESULT  BuiltInToFile (PCWSTR pszFile);
      HRESULT  BuiltInToStream (IStream *pIStream);

      // vdctcommandsApp
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
      HRESULT  AppActivate (void * hWnd, DWORD dwFlags);
#else
      HRESULT  AppActivate (HWND hWnd, DWORD dwFlags);
#endif
      HRESULT  AppDeactivate (void);
      HRESULT  AppFromMemory (PVOID pMem, DWORD dwSize);
      HRESULT  AppFromFile (PCWSTR pszFile);
      HRESULT  AppFromStream (IStream *pIStream);
      HRESULT  AppListSet (PCWSTR pszList, PVOID pMem, DWORD dwSize);
      HRESULT  AppTextGet (LPWSTR* pszText, DWORD* pdwSize);
      HRESULT  AppToMemory (PVOID* ppMem, DWORD* pdwSize);
      HRESULT  AppToFile (PCWSTR pszFile);
      HRESULT  AppToStream (IStream *pIStream);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // IVDctTextCache
      HRESULT  CopyToBin (DWORD, DWORD, DWORD);
      HRESULT  CopyToMemory (DWORD, DWORD, PVOID*, DWORD*, LPUNKNOWN**, DWORD*);
      HRESULT  PasteFromBin (DWORD, DWORD, DWORD);
      HRESULT  PasteFromMemory (DWORD, DWORD, PVOID, DWORD, LPUNKNOWN*, DWORD);

      // variables
      PIVDCTATTRIBUTESW m_pIVDctAttributes;
      PIATTRIBUTESW     m_pIAttributes;
      PIVDCTCOMMANDSW   m_pIVDctCommands;
      PIVDCTCOMMANDSBUILTINW m_pIVDctCommandsBuiltIn;
      PIVDCTCOMMANDSAPPW m_pIVDctCommandsApp;
      PIVDCTDIALOGSW    m_pIVDctDialogs;
      PIVDCTGLOSSARYW   m_pIVDctGlossary;
      PIVDCTGUI         m_pIVDctGUI;
      PIVDCTINVTEXTNORMW m_pIVDctInvTextNorm;
      PIVDCTTEXTW       m_pIVDctText;
      PIVOICEDICTATIONW m_pIVoiceDictation;
      PISRSPEAKERW      m_pISRSpeaker;
      PILEXPRONOUNCEW   m_pILexPronounce;
      PILEXPRONOUNCE2W  m_pILexPronounce2;
      PIVDCTTEXTCACHE   m_pIVDctTextCache;
      PIVDCTTEXT2W      m_pIVDctText2;       
   }; 
typedef CVoiceDictation * PCVoiceDictation;


/* CVDctNotifySink */
#undef   INTERFACE
#define  INTERFACE   CVDctNotifySink

DECLARE_INTERFACE_ (CVDctNotifySink, IVDctNotifySink2W) {

   // IUnknown members
   unsigned long m_RefCount;
   CVDctNotifySink()
   {
	m_RefCount = 0;
   }
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // CVDctNotifySink members
   STDMETHOD (CommandBuiltIn)       (THIS_ PWSTR);
   STDMETHOD (CommandOther)         (THIS_ PWSTR);
   STDMETHOD (CommandRecognize)     (THIS_ DWORD, DWORD, DWORD, PVOID, PWSTR);
   STDMETHOD (TextSelChanged)       (THIS);
   STDMETHOD (TextChanged)          (THIS_ DWORD);
   STDMETHOD (TextBookmarkChanged)  (THIS_ DWORD);
   STDMETHOD (PhraseStart)          (THIS);
   STDMETHOD (PhraseFinish)         (THIS_ DWORD, PSRPHRASEW);
   STDMETHOD (PhraseHypothesis)     (THIS_ DWORD, PSRPHRASEW);
   STDMETHOD (UtteranceBegin)       (THIS);
   STDMETHOD (UtteranceEnd)         (THIS);
   STDMETHOD (VUMeter)              (THIS_ WORD);
   STDMETHOD (AttribChanged)        (THIS_ DWORD);
   STDMETHOD (Interference)         (THIS_ DWORD);
   STDMETHOD (Training)             (THIS_ DWORD);
   STDMETHOD (Dictating)            (THIS_ PCWSTR, BOOL);

   STDMETHOD (Error)                (THIS_ LPUNKNOWN);
   STDMETHOD (Warning)              (THIS_ LPUNKNOWN);
};

typedef CVDctNotifySink * PCVDctNotifySink;




/**********************************************************************
voice text */

/* CVoiceText */
class CVoiceText {
   public:
      CVoiceText (void);
      ~CVoiceText (void);

      // initalization
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN pIUnkVTxt);
      
      // initialization and registration combined
      HRESULT  Init (PCWSTR pszSite, PCWSTR pszApplication, 
	 PVOID pNotifyInterface, IID IIDNotifyInterface,
	 DWORD dwFlags, PVTSITEINFO pSiteInfo);
      HRESULT  Init (PCWSTR pszApplication, PIVTXTNOTIFYSINKW pNotifyInterface = NULL,
	 PCWSTR pszSite = NULL,
	 DWORD dwFlags = 0, PVTSITEINFO pSiteInfo = NULL);

      // IVTxtAttributes
      HRESULT  DeviceGet (DWORD *pdwDeviceID);
      DWORD    DeviceGet (void);
      HRESULT  DeviceSet (DWORD dwDeviceID);
      HRESULT  EnabledGet (DWORD *dwEnabled);
      DWORD    EnabledGet (void);
      HRESULT  EnabledSet (DWORD dwEnabled);
      HRESULT  IsSpeaking (BOOL *pfSpeaking);
      BOOL     IsSpeaking (void);
      HRESULT  SpeedGet (DWORD *pdwSpeed);
      DWORD    SpeedGet (void);
      HRESULT  SpeedSet (DWORD dwSpeed);
      HRESULT  TTSModeGet (GUID *pgVoice);
      HRESULT  TTSModeSet (GUID gVoice);

      // IVTxtDialogs
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	  HRESULT  AboutDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (void * hWndParent, PWSTR pszTitle = NULL);
      HRESULT  TranslateDlg (void * hWndParent, PWSTR pszTitle = NULL);
#else
      HRESULT  AboutDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  GeneralDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  LexiconDlg (HWND hWndParent, PWSTR pszTitle = NULL);
      HRESULT  TranslateDlg (HWND hWndParent, PWSTR pszTitle = NULL);
#endif
      // IVoiceText
      HRESULT  AudioFastForward (void);
      HRESULT  AudioPause (void);
      HRESULT  AudioResume (void);
      HRESULT  AudioRewind (void);
      HRESULT  Register (PCWSTR pszSite, PCWSTR pszApplication, 
	 PVOID pNotifyInterface, IID IIDNotifyInterface,
	 DWORD dwFlags, PVTSITEINFO pSiteInfo);
      HRESULT  Register (PCWSTR pszApplication, PIVTXTNOTIFYSINKW pNotifyInterface = NULL,
	 PCWSTR pszSite = NULL,
	 DWORD dwFlags = 0, PVTSITEINFO pSiteInfo = NULL);
      HRESULT  Speak (PCWSTR pszSpeak, DWORD dwFlags = 0, PCWSTR pszTags = NULL);
      HRESULT  SpeakAndWait (PCWSTR pszSpeak, DWORD dwFlags = 0, PCWSTR pszTags = NULL);
      HRESULT  StopSpeaking (void);

      // IAttributes
      HRESULT  DWORDGet (DWORD, DWORD*);
      HRESULT  DWORDSet (DWORD, DWORD);
      HRESULT  StringGet (DWORD, PWSTR, DWORD, DWORD *);
      HRESULT  StringSet (DWORD, PCWSTR);
      HRESULT  MemoryGet (DWORD, PVOID*, DWORD*);
      HRESULT  MemorySet (DWORD, PVOID, DWORD);

      // variables
      PIVTXTATTRIBUTESW    m_pIVTxtAttributes;
      PIATTRIBUTESW     m_pIAttributes;
      PIVTXTDIALOGSW       m_pIVTxtDialogs;
      PIVOICETEXTW         m_pIVoiceText;
   }; 
typedef CVoiceText * PCVoiceText;

/* CVTxtNotifySink */
#undef   INTERFACE
#define  INTERFACE   CVTxtNotifySink

DECLARE_INTERFACE_ (CVTxtNotifySink, IVTxtNotifySinkW) {
   unsigned long m_RefCount;
   CVTxtNotifySink()
   {
	m_RefCount = 0;
   }
   // IUnknown members
   STDMETHOD(QueryInterface)  (THIS_ REFIID riid, LPVOID FAR* ppvObj);
   STDMETHOD_(ULONG,AddRef)   (THIS);
   STDMETHOD_(ULONG,Release)  (THIS);

   // IVTxtNotifySinkW members
   STDMETHOD (AttribChanged)    (THIS_ DWORD);
   STDMETHOD (Visual)           (THIS_ WCHAR, WCHAR, DWORD, PTTSMOUTH);
   STDMETHOD (Speak)            (THIS_ PWSTR, PWSTR, DWORD);
   STDMETHOD (SpeakingStarted)  (THIS);
   STDMETHOD (SpeakingDone)     (THIS);
};

typedef CVTxtNotifySink * PCVTxtNotifySink;




/**********************************************************************
telephony */

/* CTelInfo */
class CTelInfo {
   public:
      CTelInfo (void);
      ~CTelInfo (void);

      // Init
      HRESULT  Init (void);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // Init, type set, and quick create
      HRESULT  Init (DWORD dwType, PSRMODEINFOW pSRModeInfo = NULL,
	 PTTSMODEINFOW pTTSModeInfo = NULL, PCWSTR pszWave = NULL,
	 HMODULE hModApp = NULL);

      // ITelInfo
      HRESULT  ObjectGet (GUID gObject, LPUNKNOWN *ppIUnk);
      HRESULT  ObjectGet (GUID gObject, IID iid, PVOID* ppI);
      HRESULT  ObjectSet (GUID gObject, LPUNKNOWN pIUnk);
      HRESULT  DWORDGet (GUID gDWORD, DWORD *pdwValue);
      DWORD    DWORDGet (GUID gDWORD);
      HRESULT  DWORDSet (GUID gDWORD, DWORD dwValue);
      HRESULT  MemoryGet (GUID gMem, PVOID *ppMem, DWORD *pdwSize);
      HRESULT  MemorySet (GUID gMem, PVOID pMem, DWORD dwSize);
      HRESULT  SendDTMF (WCHAR cDTMF);
      HRESULT  SendAbort (DWORD dwVal);
      HRESULT  TypeSet (DWORD dwType);
      HRESULT  AudioSourceCreate (LPUNKNOWN *ppIUnk);
      HRESULT  AudioDestCreate (LPUNKNOWN *ppIUnk);
      HRESULT  QuickCreate (HMODULE hModApp, PSRMODEINFOW pSRModeInfo = NULL,
	 PTTSMODEINFOW pTTSModeInfo = NULL, PCWSTR pszWave = NULL,
	 BOOL fUseLogging = FALSE);
      HRESULT  QuickCreate (HMODULE hModApp, PSRMODEINFOW pSRModeInfo,
	 PTTSMODEINFOW pTTSModeInfo, DWORD dwResourceID,
	 BOOL fUseLogging);

      // Easy to get
      PCSRMode          SRModeGet (void);
      PCSTTTSQueue      STTTSQueueGet (void);
      PCSTLog           STLogGet (void);
      PITELNOTIFYSINK   TelNotifySinkGet (void);
      HRESULT           TelNotifySinkSet (PITELNOTIFYSINK pITel);
      HRESULT           EnableOperatorSet (BOOL f = TRUE);
      BOOL              EnableOperatorGet (void);
      HRESULT           DisableSpeedChangeSet (BOOL f = TRUE);
      BOOL              DisableSpeedChangeGet (void);
      HRESULT           EnableAskHangUpSet (BOOL f = TRUE);
      BOOL              EnableAskHangUpGet (void);

      // variables
      PITELINFO         m_pITelInfo;
   }; 
typedef CTelInfo * PCTelInfo;

/* CTelControl */
class CTelControl : public ITelControlNotifySink {
   public:
      CTelControl (void);
      ~CTelControl (void);

      // Init
      HRESULT  Init (CLSID clsid);
      HRESULT  Init (LPUNKNOWN lpUnk);

      // Initialization that also does ObjectSet
      HRESULT  Init (CLSID clsid, PITELINFO pITelInfo);
      HRESULT  Init (CLSID clsid, PCTelInfo pCTelInfo);

      // ITelControl
      HRESULT  FromMemory (PVOID pMem, DWORD dwSize);
      HRESULT  FromStream (IStream *pIStream);
      HRESULT  FromFile (PCWSTR pszFile);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  HRESULT  FromResource (void * hInst, DWORD dwResID);
#else
      HRESULT  FromResource (HINSTANCE hInst, DWORD dwResID);
#endif
      HRESULT  Compile (LPWSTR *ppszErr = NULL, DWORD *pdwErr = NULL);
      HRESULT  IsCompiled (BOOL *pfCompiled);
      BOOL     IsCompiled (void);
      HRESULT  LanguageGet (LANGUAGEW *pLang);
      HRESULT  ToMemory (PVOID *ppMem, DWORD *pdwSize);
      HRESULT  ToStream (IStream *pIStream);
      HRESULT  ToFile (PCWSTR pszFile);
      HRESULT  TextGet (LPWSTR *ppszText, DWORD *pdwSize);
      HRESULT  TextDefaultGet (LPWSTR *ppszText, DWORD *pdwSize);
      HRESULT  ObjectSet (PITELINFO pITelInfo);
      HRESULT  Start (PITELCONTROLNOTIFYSINK pITelControlNotifySink);
      HRESULT  Abort (void);

      // Syncrhonous execution (must be compiled)
      HRESULT  Go (DWORD *pdwResult, PVOID *ppMem = NULL, DWORD *pdwSize = NULL);

      // Load & compile if necessary & do syncrhronous
      HRESULT  GoFromMemory (PVOID pMem, DWORD dwSize,
	 DWORD *pdwResult, PVOID *ppMem = NULL, DWORD *pdwSize = NULL);
      HRESULT  GoFromStream (IStream *pIStream,
	 DWORD *pdwResult, PVOID *ppMem = NULL, DWORD *pdwSize = NULL);
      HRESULT  GoFromFile (PCWSTR pszFile,
	 DWORD *pdwResult, PVOID *ppMem = NULL, DWORD *pdwSize = NULL);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
	  HRESULT  GoFromResource (void * hInst, DWORD dwResID,
#else
      HRESULT  GoFromResource (HINSTANCE hInst, DWORD dwResID,
#endif
	 DWORD *pdwResult, PVOID *ppMem = NULL, DWORD *pdwSize = NULL);

      // variables
      PITELCONTROL         m_pITelControl;
      DWORD                m_dwResultFinish;
      PVOID                m_pMemFinish;
      DWORD                m_dwSizeFinish;
      BOOL                 m_fFinish;


      // Members for ITelControlNotifySink. Apps should not call this
      STDMETHODIMP         QueryInterface (REFIID, LPVOID FAR *);
      STDMETHODIMP_(ULONG) AddRef(void);
      STDMETHODIMP_(ULONG) Release(void);
      STDMETHODIMP         Finish (DWORD, PVOID, DWORD);
      STDMETHODIMP         Info(DWORD, PVOID, DWORD);
   }; 
typedef CTelControl * PCTelControl;


/* CTelControlNotifySink */
#undef   INTERFACE
#define  INTERFACE   CTelControlNotifySink

DECLARE_INTERFACE_ (CTelControlNotifySink, ITelControlNotifySink) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *);
    STDMETHOD_(ULONG,AddRef)    (THIS);
    STDMETHOD_(ULONG,Release)   (THIS);

    // ITelControlNotifySink members
    STDMETHOD (Finish)          (THIS_ DWORD, PVOID, DWORD);
    STDMETHOD (Info)            (THIS_ DWORD, PVOID, DWORD);
};
typedef CTelControlNotifySink *PCTelControlNotifySink;

/* CTelNotifySInk */
#undef   INTERFACE
#define  INTERFACE   CTelNotifySink

DECLARE_INTERFACE_ (CTelNotifySink, ITelNotifySink) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *);
    STDMETHOD_(ULONG,AddRef)    (THIS);
    STDMETHOD_(ULONG,Release)   (THIS);

    // ITelNotifySink members
    STDMETHOD (DTMF)            (THIS_ WCHAR);
    STDMETHOD (Abort)           (THIS_ DWORD);
};
typedef CTelNotifySink *PCTelNotifySink;



/* CTelControlFramwork */

#define  STATE_VERIFY      ((DWORD)-1L)      // verification state

class CTelControlFramework;

class CTCSRNotifySink : public ISRNotifySinkW {
   private:
      CTelControlFramework *m_pTelControl;

   public:
      CTCSRNotifySink (CTelControlFramework *);
      ~CTCSRNotifySink (void);

      // IUnkown members that delegate to m_punkOuter
      // Non-delegating object IUnknown
      STDMETHODIMP         QueryInterface (REFIID, LPVOID FAR *);
      STDMETHODIMP_(ULONG) AddRef(void);
      STDMETHODIMP_(ULONG) Release(void);

      // ISRNotifySink
      STDMETHODIMP AttribChanged  (DWORD);
      STDMETHODIMP Interference   (QWORD, QWORD, DWORD);
      STDMETHODIMP Sound          (QWORD, QWORD);
      STDMETHODIMP UtteranceBegin (QWORD);
      STDMETHODIMP UtteranceEnd   (QWORD, QWORD);
      STDMETHODIMP VUMeter        (QWORD, WORD);
   };
typedef CTCSRNotifySink * PCTCSRNotifySink;

class CTCTelNotifySink : public ITelNotifySink {

    protected:
       CTelControlFramework *m_pTelControl;

    public:
	CTCTelNotifySink(CTelControlFramework *);
	~CTCTelNotifySink(void);

	// IUnknown members
	STDMETHODIMP         QueryInterface (REFIID, LPVOID FAR *);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);

	// ITelNotifySink members
	STDMETHODIMP         DTMF (WCHAR);
	STDMETHODIMP         Abort(DWORD);
};
typedef CTCTelNotifySink *PCTCTelNotifySink;


class CTCSRGramNotifySink : public ISRGramNotifySinkW {

    protected:
       CTelControlFramework *m_pTelControl;

    public:
	CTCSRGramNotifySink(CTelControlFramework *);
	~CTCSRGramNotifySink(void);

	// IUnknown members
	STDMETHODIMP         QueryInterface (REFIID, LPVOID FAR *);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);

	// ISRGramNotifySinkW members
	STDMETHODIMP BookMark (DWORD);
	STDMETHODIMP Paused (void);
	STDMETHODIMP PhraseFinish (DWORD, QWORD, QWORD, PSRPHRASEW, LPUNKNOWN);
	STDMETHODIMP PhraseHypothesis(DWORD, QWORD, QWORD, PSRPHRASEW, LPUNKNOWN);
	STDMETHODIMP PhraseStart (QWORD);
	STDMETHODIMP ReEvaluate (LPUNKNOWN);
	STDMETHODIMP Training (DWORD);
	STDMETHODIMP UnArchive (LPUNKNOWN);
};
typedef CTCSRGramNotifySink *PCTCSRGramNotifySink;


class CTCSTTTTSQueueNotifySink : public ISTTTSQueueNotifySink {

    protected:
       CTelControlFramework *m_pTelControl;

    public:
	CTCSTTTTSQueueNotifySink(CTelControlFramework *);
	~CTCSTTTTSQueueNotifySink(void);

	// IUnknown members
	STDMETHODIMP         QueryInterface (REFIID, LPVOID FAR *);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);

	// ITTSNotifySinkW members
	STDMETHODIMP Start (void);
	STDMETHODIMP Stop (void);
	STDMETHODIMP SpeakID (DWORD);
	STDMETHODIMP Error (HRESULT);
	STDMETHODIMP Bookmark (DWORD);
};
typedef CTCSTTTTSQueueNotifySink *PCTCSTTTTSQueueNotifySink;


class CTelControlFramework : public ITelControl {
    public:
	 CTelControlFramework ();
	 ~CTelControlFramework (void);

	 // virtual functions
	 virtual PCWSTR GetControlName (void);
	 virtual DWORD GetDefaultTextResID (LANGID langID);
	 virtual void GetCLSID (CLSID *pCLSID);
	 virtual void OnState (DWORD dwStateID);
	 virtual void OnNoAnswer (void);
	 virtual void OnPhraseParse (DWORD dwParseID, PVOID pParseMem,
						  DWORD dwParseMemSize,
						  PSRPHRASEW pSRPhrase, LPUNKNOWN lpUnkResult);
	 virtual void OnPhraseUnrecognized (PSRPHRASEW pSRPhrase, LPUNKNOWN lpUnkResult);
	 virtual void OnDTMF (WORD wDTMF);
	 virtual void OnInterference (DWORD dwInterference);
	 virtual void OnTTSStop (void);
	 virtual void OnTTSBookmark (DWORD dwMark);
	 virtual HRESULT FromMemoryArchive (PVOID pMem, DWORD dwSize);
	 virtual void OnAbort (void);
	 virtual void OnPhraseHypothesisParse (DWORD dwParseID, PVOID pParseMem,
						  DWORD dwParseMemSize,
						  PSRPHRASEW pSRPhrase, LPUNKNOWN lpUnkResult);
	 virtual void OnPhraseStart (void);
	 virtual void OnTTSStart (void);
	 virtual void OnTTSSpeakID (DWORD dwSpeakID);
	 virtual void OnTTSError (HRESULT hRes);
	 virtual void OnAskBack (void);
	 virtual void OnAskHelp (void);
	 virtual void OnAskWhere (void);
	 virtual void OnAskOperator (void);
	 virtual void OnAskHangUp (void);
	 virtual void OnAskSpeakFaster (void);
	 virtual void OnAskSpeakSlower (void);
	 virtual void OnAskRepeat (void);
	 virtual void FreeUpControlData (void);
    virtual void OnVerify (void);

	 // non-overriding functions
#ifdef STRICT
	 HRESULT Init (LONG *pObjCount, PVOID hModule);
#else
	 HRESULT Init (LONG *pObjCount, HINSTANCE hModule);
#endif
	 void DoState (DWORD dwState);
	 void StopAllMedia (void);
	 HRESULT StartSR (PCWSTR pszRule = NULL);
	 HRESULT StartSRWhenReady (PCWSTR pszRule = NULL);
	 HRESULT StopSR (void);
	 HRESULT PlayTAPIBeep (DWORD);
	 HRESULT ReadyToListenBeep (void);
	 HRESULT RecognizedBeep (void);
	 HRESULT RecordingBeep (void);
	 HRESULT UnrecognizedBeep (void);
	 HRESULT FreeUpDefaultControlData (void);
	 HRESULT LoadInDefaultText (LANGID lang);
	 void DoFinish (DWORD dwResult, PVOID pMem = NULL, DWORD dwSize = 0);
	 void DoInfo (DWORD dwResult, PVOID pMem = NULL, DWORD dwSize = 0);
	 BOOL GetValue (PCWSTR pszSection, PCWSTR pszValue,
					     PWSTR pszRet, DWORD *dwSize);
	 LONG GetValue (PCWSTR pszSection, PCWSTR pszValue, LONG lDefault = 0);
	 HRESULT TTSSpeak (PCWSTR pszSection, PCWSTR pszValue);
	 void UnregisterNotificationSinks (void);
	 void RegisterNotificationSinks (void);
	 HRESULT DoVerify (PCWSTR pszPreSpeakItem, PCWSTR pszPostSpeakItem,
	    PCWSTR pszVerifySpeak, DWORD dwOnCorrectState, DWORD dwOnWrongState);

	 // interfaces
	 STDMETHODIMP QueryInterface (REFIID, LPVOID FAR *);
	 STDMETHODIMP_(ULONG) AddRef (void);
	 STDMETHODIMP_(ULONG) Release(void);

	 // ITelControl members
	 STDMETHODIMP FromMemory     (PVOID, DWORD);
	 STDMETHODIMP FromStream     (IStream *);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
		 STDMETHODIMP FromResource   (void *, DWORD);
#else
	 STDMETHODIMP FromResource   (HINSTANCE, DWORD);
#endif
	 STDMETHODIMP FromFile       (PCWSTR);
	 STDMETHODIMP Compile        (LPWSTR*, DWORD*);
	 STDMETHODIMP IsCompiled     (BOOL*);
	 STDMETHODIMP LanguageGet    (LANGUAGEW*);
	 STDMETHODIMP ToMemory       (PVOID*, DWORD*);
	 STDMETHODIMP ToStream       (IStream *);
	 STDMETHODIMP ToFile         (PCWSTR);
	 STDMETHODIMP TextGet        (LPWSTR*, DWORD*);
	 STDMETHODIMP TextDefaultGet (LPWSTR*, DWORD*);
	 STDMETHODIMP ObjectSet      (PITELINFO);
	 STDMETHODIMP Start          (PITELCONTROLNOTIFYSINK);
	 STDMETHODIMP Abort          (void);

	 // variables
	 PWSTR       m_pszText;
	 PWSTR       m_pszDefaultText;
	 PCInfParse  m_pTextParse;
	 PCInfParse  m_pDefaultTextParse;
	 BOOL        m_fStarted;
	 BOOL        m_fIsCompiled;
	 DWORD       m_cRef;
	 LONG*       m_plObjCount;
	 HMODULE     m_hModule;
	 DWORD       m_dwDefaultTextResIDLoaded;
	 CTCSRNotifySink* m_pISRNotifySink;
	 CTCSRGramNotifySink* m_pISRGramNotifySink;
	 DWORD       m_dwSRKey;
	 CTCSTTTTSQueueNotifySink* m_pISTTTSQueueNotifySink;
	 CTCTelNotifySink* m_pITelNotifySink;
	 BOOL        m_fNotifySinksUsed;
	 PCSRMode    m_pSRMode;
	 PCSTGramComp m_pGramComp;
	 PCSRGram    m_pGram;
	 PCSTTTSQueue m_pQueue;
	 PCSTLog     m_pLog;
	 PCTelInfo   m_pTelInfo;
	 PITELCONTROLNOTIFYSINK m_pITelControlNotifySink;
	 DWORD       m_dwTimeOut;
	 DWORD       m_dwNoAnswerTime;
	 DWORD       m_dwNoAnswer;
	 DWORD       m_dwNoAnswerMax;
	 LANGUAGEW   m_lang;
	 WCHAR       m_szRuleActive[64];
	 BOOL        m_fActiveWhenDoneTalking;
	 WCHAR       m_szRuleToActivate[64];
	 BOOL        m_fIsSRActive;
	 BOOL        m_fFullDuplex;
	 DWORD       m_dwCurState;
	 BOOL        m_fActivateWhenDoneTalking;
	 PCWSTR      m_pszPreSpeakItem;
	 PCWSTR      m_pszPostSpeakItem;
	 PCWSTR      m_pszVerifySpeak;
	 DWORD       m_dwOnCorrectState;
	 DWORD       m_dwOnWrongState;
	 BOOL        m_fVerify;
    PCTreeList  m_pTLSpoken;
    BOOL        m_fUseTAPIBeep;
    HCALL       m_hCall;      // of TAPI
    DWORD       m_dwPlayBeep; // if TRUE, and TAPI beep, then play this beep when done speaking
    BOOL        m_fDisableRecogBeep;   // if TRUE, disable the recognition beeps
         long        m_DTMFcount;
#define MAXDTMFCOUNT 25
         WCHAR       m_DTMFString[MAXDTMFCOUNT+1];
};
typedef CTelControlFramework *PCTelControlFramework;


/**********************************************************
The following defines are used by the objects defined below
*/
#define MAXBUFSIZE      256
#define ERR_NONE        0

#define ALLOC(x) HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, x);
#define FREE(x)  HeapFree(GetProcessHeap(), NULL, x);

#define WM_TELCONTROL_CALLDONE  WM_USER + 1375
#define WM_TELCONTROL_INITDONE  WM_USER + 1376
#define WM_TELCONTROL_CALLSTATE WM_USER + 1377

#define TM_STOP                 WM_USER + 1389
#define TM_RUN                  WM_USER + 1390
#define TM_ABORT                WM_USER + 1391
#define TM_DTMF                 WM_USER + 1392

#define CALLSTATE_INITIALIZING  0x00000001
#define CALLSTATE_CONNECTING    0x00000002
#define CALLSTATE_INPROGRESS    0x00000003
#define CALLSTATE_DISCONNECTING 0x00000004
#define CALLSTATE_IDLE          0x00000005
#define CALLSTATE_DISABLED      0x00000006

// pure virtual functions to define the interfaces for the telephony objects
class CCall
{
    public:
	virtual HRESULT Init(PITELINFO);
	virtual HRESULT Shutdown(void);
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
		virtual HRESULT DoQuickCreate(PITELINFO, void *);
#else
	virtual HRESULT DoQuickCreate(PITELINFO, HINSTANCE);
#endif
	virtual HRESULT DoPhoneCall(void) = 0;
};
typedef CCall *PCCALL;


class CTelLine
{
    public:
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		virtual HRESULT Init(void *, PVOID, PCCALL) = 0;
#else
	virtual HRESULT Init(HWND, PVOID, PCCALL) = 0;
#endif
	virtual HRESULT ThreadLoop(void);
	virtual HRESULT NewCall(void) = 0;
	virtual HRESULT Go(void) = 0;
	virtual HRESULT Stop(void);
	virtual HRESULT Abort(void) = 0;
	virtual HRESULT AbortControl(void);
	virtual HRESULT GotDTMF(WCHAR) = 0;
	virtual HRESULT SendDTMF(WCHAR);
};
typedef CTelLine *PCTELLINE;


class CTelMain
{
    public:
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		virtual HRESULT Init(void *, void *) = 0;
#else
	virtual HRESULT Init(HWND, HINSTANCE) = 0;
#endif
	virtual HRESULT Shutdown(void) = 0;
	virtual HRESULT Callback(DWORD, DWORD, DWORD, DWORD, DWORD, DWORD) = 0;
	virtual HRESULT Callback(void) = 0;
	virtual HRESULT CreateLineObject(PCCALL *) = 0;
	virtual HRESULT CallDone(DWORD) = 0;
	virtual HRESULT CallDialog(void) = 0;
	virtual HRESULT Abort(void) = 0;
	virtual HRESULT UseLogging(void);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		virtual HRESULT CallLoggingDialog(void *);
#else
	virtual HRESULT CallLoggingDialog(HWND);
#endif
	virtual HRESULT GotDTMF(DWORD) = 0;

   DWORD    m_dwAnswerAfterRings;      // answer the phone after this many rings
   DWORD    m_dwMaxLines;              // maximum lines that can be connected
};
typedef CTelMain *PCTELMAIN;



// structs
typedef struct tagLINEINFO
{
    PCTELLINE   pTelLine;               // Line object
    PCCALL      pAppCall;               // Apps call logic
    HLINEAPP    hApp;                   // App handle returned from intialize
    DWORD       nAddr;                  // Number of avail. addresses on the line
    BOOL        fVoiceLine;             // Is this a voice line?
    DWORD       dwAPIVersion;           // API version which the line supports
    HLINE       hLine;                  // line handle returned by lineOpen
    HCALL       hCall;                  // handle to a call on this line
    DWORD       dwPermanentLineID;      // Permanent line ID retreived from devcaps
    DWORD       dwState;                // line status
    DWORD       dwLineReplyNum;         // identifier if expecting a reply
    char        szLineName[MAXBUFSIZE]; // the line's name

} LINEINFO, *LPLINEINFO;


class CTelLineTAPI14 : public CTelLine
{
    private:
	HINSTANCE       m_hInst;
	HWND            m_hWnd;
	HWND            m_hAppWnd;
	PITELINFO       m_pITelInfo;

	DWORD           m_dwLine;
	DWORD           m_dwWaveIn;
	DWORD           m_dwWaveOut;
	LINEINFO        m_li;

	HANDLE          m_hThread;
	DWORD           m_dwThreadID;
	PCCALL          m_pCall;

	PVOID           m_pTelMain;


    public:
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
		CTelLineTAPI14(void *, DWORD, LPLINEINFO);
#else
	CTelLineTAPI14(HINSTANCE, DWORD, LPLINEINFO);
#endif
	~CTelLineTAPI14(void);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		HRESULT Init(void *, PVOID, PCCALL);
#else
	HRESULT Init(HWND, PVOID, PCCALL);
#endif
	HRESULT ThreadLoop(void);
	HRESULT NewCall(void);
	HRESULT Go(void);
	HRESULT Stop(void);
	HRESULT Abort(void);
	HRESULT AbortControl(void);
	HRESULT GotDTMF(WCHAR);
	HRESULT SendDTMF(WCHAR);
	HRESULT CTelLineTAPI14::MakeCall(LPCSTR number,DWORD countrycode);
	HRESULT CTelLineTAPI14::DropCall();
	HRESULT CTelLineTAPI14::SetHCALL(HCALL hCall);

   HANDLE  m_eFreeForAnotherCall;   // if set, free for another call, if not, on a call
};
typedef CTelLineTAPI14 *PCTELLINETAPI14;


class CTelMainTAPI14 : public CTelMain
{
   friend class CTelLineTAPI14;

    private:
	HLINEAPP        m_hLineApp;

	DWORD           m_dwState;
	DWORD           *m_pdwAddr;
	HINSTANCE       m_hInst;

	HWND            m_hAppWnd;
	HWND            m_hDlgWnd;
	HCALL           m_hCall;



	int             m_iReq;         // request ID

    public:
	DWORD           m_dwNumLines;
	LPLINEINFO      m_lpLineInfo;
	CTelMainTAPI14(void);
	~CTelMainTAPI14(void);

	void GetNumLines(DWORD *pdwNum) {*pdwNum = m_dwNumLines;}
	void GetState(DWORD dwLine, DWORD *pdwState) {*pdwState = m_lpLineInfo[dwLine].dwState;}
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		void SetDlgHWND(void * hwnd) {m_hDlgWnd = (HWND) hwnd;}
#else
	void SetDlgHWND(HWND hwnd) {m_hDlgWnd = hwnd;}
#endif
	void LineNotify(DWORD dwLine, DWORD dwNotification);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
	HRESULT Init(void *, void *);
#else
		HRESULT Init(HWND, HINSTANCE);
#endif
	HRESULT Shutdown(void);
	HRESULT Callback(DWORD, DWORD, DWORD, DWORD, DWORD, DWORD);
	HRESULT Callback(void);
	virtual HRESULT CreateLineObject(PCCALL *) = 0;
	HRESULT CallDone(DWORD);
	HRESULT CallDialog(void);
	HRESULT Abort(void);
	HRESULT GotDTMF(DWORD);
};
typedef CTelMainTAPI14 *PCTELMAINTAPI14;


class CTelLinePC : public CTelLine
{
    private:
	HINSTANCE       m_hInst;
	HWND            m_hAppWnd;
	PITELINFO       m_pITelInfo;
	PVOID           m_pCallback;

	PCCALL          m_pCall;
	PVOID           m_pTelMain;


    public:
#ifdef STRICT //library is compiled without strict, so hinstance type does not match up under strict
		CTelLinePC(void *);
#else
	CTelLinePC(HINSTANCE);
#endif
	~CTelLinePC(void);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		HRESULT Init(void *, PVOID, PCCALL);
#else
	HRESULT Init(HWND, PVOID, PCCALL);
#endif
	HRESULT NewCall(void);
	HRESULT Go(void);
	HRESULT Abort(void);
	HRESULT GotDTMF(WCHAR);
};
typedef CTelLinePC *PCTELLINEPC;


class CTelMainPC : public CTelMain
{
    private:
	HINSTANCE       m_hInst;
	HWND            m_hAppWnd;
	PCTELLINEPC     m_pLine;
	PCCALL          m_pAppCall;

    public:
	CTelMainPC(void);
	~CTelMainPC(void);
#ifdef STRICT //library is compiled without strict, so hwnd type does not match up under strict
		HRESULT Init(void *, void *);
#else
	HRESULT Init(HWND, HINSTANCE);
#endif
	HRESULT Shutdown(void);
	HRESULT Callback(DWORD, DWORD, DWORD, DWORD, DWORD, DWORD);
	HRESULT Callback(void);
	HRESULT CallDone(DWORD);
	HRESULT CallDialog(void);
	HRESULT Abort(void);
	HRESULT GotDTMF(DWORD);
};
typedef CTelMainPC *PCTELMAINPC;

#endif // _SPCHWRAP_H

