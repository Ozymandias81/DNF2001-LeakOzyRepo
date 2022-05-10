/*****************************************************************
Spchtel.H - Header file to use the Microsoft Speech telephony controls.

Copyright 1998 by Microsoft corporation.All rights reserved.
*/

#ifndef _SPCHTEL_H_
#define _SPCHTEL_H_

// Flag values for the ITelControl::TypeSet call
#define     INFOTYPE_PC         0x00000001
#define     INFOTYPE_TAPI20     0x00000002
#define     INFOTYPE_TAPI30     0x00000004

// Common return codes from controls
// not usually handled, often returned
#define  TCR_ABORT         ((DWORD)-1L)      // the user has hung up
#define  TCR_NORESPONSE    ((DWORD)-2L)      // the user hasn't repsonded to the questions
#define  TCR_ASKOPERATOR   ((DWORD)-3L)      // the user has asked for an operator (often control just auto replies)
#define  TCR_ASKHANGUP     ((DWORD)-4L)      // the user has asked to hang up. App must handle
#define  TCR_ASKBACK       ((DWORD)-5L)      // the user has asked to go back and redo the previous thing

// usually handled by control, unless overrided
#define  TCR_ASKWHERE      ((DWORD)-10L)     // the user has asked where he/she is (usualy handled by control)
#define  TCR_ASKHELP       ((DWORD)-11L)     // the user has asked for help (usually handled by control)
#define  TCR_ASKREPEAT     ((DWORD)-12L)     // the user has asked for the question to be repeated (usually handled by the control)
#define  TCR_ASKSPEAKFASTER ((DWORD)-13L)    // the user has asked to speak faster. usually handled by the control
#define  TCR_ASKSPEAKSLOWER ((DWORD)-14L)    // the user has asked to speak slower. Usually handled by the control



// {F9D18BF8-E0ED-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID (CLSID_TelInfo,
0xf9d18bf8, 0xe0ed, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

/*
 *  ITelNotifySink
 */
#undef   INTERFACE
#define  INTERFACE   ITelNotifySink

// {CD0C7D7C-E1CD-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(IID_ITelNotifySink, 
0xcd0c7d7c, 0xe1cd, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

DECLARE_INTERFACE_ (ITelNotifySink, IUnknown) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // ITelNotifySink members
    STDMETHOD (DTMF)            (THIS_ WCHAR) PURE;
    STDMETHOD (Abort)           (THIS_ DWORD) PURE;
};
typedef ITelNotifySink FAR *PITELNOTIFYSINK;


/*
 *  ITelControlNotifySink
 */
#undef   INTERFACE
#define  INTERFACE   ITelControlNotifySink

// {A55E2436-E297-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(IID_ITelControlNotifySink, 
0xa55e2436, 0xe297, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

DECLARE_INTERFACE_ (ITelControlNotifySink, IUnknown) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // ITelControlNotifySink members
    STDMETHOD (Finish)          (THIS_ DWORD, PVOID, DWORD) PURE;
    STDMETHOD (Info)            (THIS_ DWORD, PVOID, DWORD) PURE;
};
typedef ITelControlNotifySink FAR *PITELCONTROLNOTIFYSINK;


/*
 *  ITelInfo
 */
#undef   INTERFACE
#define  INTERFACE   ITelInfo

// {250F0433-E0EB-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(IID_ITelInfo, 
0x250f0433, 0xe0eb, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

DECLARE_INTERFACE_ (ITelInfo, IUnknown) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // ITelInfo members
    STDMETHOD (ObjectGet)          (THIS_ GUID, LPUNKNOWN *) PURE;
    STDMETHOD (ObjectSet)          (THIS_ GUID, LPUNKNOWN) PURE;
    STDMETHOD (DWORDGet)           (THIS_ GUID, DWORD *) PURE;
    STDMETHOD (DWORDSet)           (THIS_ GUID, DWORD) PURE;
    STDMETHOD (MemoryGet)          (THIS_ GUID, PVOID *, DWORD *) PURE;
    STDMETHOD (MemorySet)          (THIS_ GUID, PVOID, DWORD) PURE;
    STDMETHOD (SendDTMF)           (THIS_ WCHAR) PURE;
    STDMETHOD (SendAbort)          (THIS_ DWORD) PURE;
    STDMETHOD (TypeSet)            (THIS_ DWORD) PURE;
    STDMETHOD (WaveDeviceSet)      (THIS_ DWORD, DWORD) PURE;
    STDMETHOD (AudioSourceCreate)  (THIS_ LPUNKNOWN *) PURE;
    STDMETHOD (AudioDestCreate)    (THIS_ LPUNKNOWN *) PURE;
    STDMETHOD (QuickCreate)        (THIS_ HMODULE, PSRMODEINFOW, PTTSMODEINFOW,
                                          PCWSTR, BOOL) PURE;
};
typedef ITelInfo FAR *PITELINFO;


/*
 *  ITelControl
 */
#undef   INTERFACE
#define  INTERFACE   ITelControl

// {17674DEB-E298-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(IID_ITelControl, 
0x17674deb, 0xe298, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

DECLARE_INTERFACE_ (ITelControl, IUnknown) {
    // IUnkown members
    STDMETHOD (QueryInterface)  (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // ITelControl members
    STDMETHOD (FromMemory) (THIS_ PVOID, DWORD) PURE;
    STDMETHOD (FromStream) (THIS_ IStream *) PURE;
#ifdef STRICT
    STDMETHOD (FromResource) (THIS_ PVOID, DWORD) PURE;
#else
    STDMETHOD (FromResource) (THIS_ HINSTANCE, DWORD) PURE;
#endif
    STDMETHOD (FromFile) (THIS_ PCWSTR) PURE;
    STDMETHOD (Compile) (THIS_ LPWSTR*, DWORD*) PURE;
    STDMETHOD (IsCompiled) (THIS_ BOOL*) PURE;
    STDMETHOD (LanguageGet) (THIS_ LANGUAGEW*) PURE;
    STDMETHOD (ToMemory) (THIS_ PVOID*, DWORD*) PURE;
    STDMETHOD (ToStream) (THIS_ IStream *) PURE;
    STDMETHOD (ToFile) (THIS_ PCWSTR) PURE;
    STDMETHOD (TextGet) (THIS_ LPWSTR*, DWORD*) PURE;
    STDMETHOD (TextDefaultGet) (THIS_ LPWSTR*, DWORD*) PURE;
    STDMETHOD (ObjectSet) (THIS_ PITELINFO) PURE;
    STDMETHOD (Start) (THIS_ PITELCONTROLNOTIFYSINK) PURE;
    STDMETHOD (Abort) (THIS) PURE;
};
typedef ITelControl FAR *PITELCONTROL;


//
// GUID identifiers for objects
//
// {44DB6739-E10E-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(TELOBJ_SPEECHRECOG,
0x44db6739, 0xe10e, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

// {44DB673B-E10E-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(TELOBJ_TTSQUEUE,
0x44db673b, 0xe10e, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

// {44DB673C-E10E-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(TELOBJ_LOGGING,
0x44db673c, 0xe10e, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

// {44DB673D-E10E-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(TELOBJ_TAPI30,
0x44db673d, 0xe10e, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);

// {44DB673E-E10E-11d0-AB8B-08002BE4E3B7}
DEFINE_GUID(TELOBJ_NOTIFYSINK,
0x44db673e, 0xe10e, 0x11d0, 0xab, 0x8b, 0x8, 0x0, 0x2b, 0xe4, 0xe3, 0xb7);


// hcall for TAPI
// {F40CC4C0-0D0A-11d2-BEF0-006008317CE8}
DEFINE_GUID(TELDWORD_HCALL, 
0xf40cc4c0, 0xd0a, 0x11d2, 0xbe, 0xf0, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// hline for tapi
// {F40CC4C1-0D0A-11d2-BEF0-006008317CE8}
DEFINE_GUID(TELDWORD_HLINE, 
0xf40cc4c1, 0xd0a, 0x11d2, 0xbe, 0xf0, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// If this is set to TRUE, then beeps on a recognition are enabled.
// Disabling speeds up the response time of the system, but some people
// will speak before the beep. It's a tradeoff.
// {DB7F6130-0D2D-11d2-BEF1-006008317CE8}
DEFINE_GUID(TELDWORD_EnableRecognizeBeeps, 
0xdb7f6130, 0xd2d, 0x11d2, 0xbe, 0xf1, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// if set to true, and we're using tapi, then we should use tapi
// beeps rather than recordings for recognition acknowledgement
// beeps. This doesn't work properly on most telephony cards, and there's no
// way to tell, so be careful about using it
// {F40CC4C2-0D0A-11d2-BEF0-006008317CE8}
DEFINE_GUID(TELDWORD_UseTAPIBeep, 
0xf40cc4c2, 0xd0a, 0x11d2, 0xbe, 0xf0, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// disable the ability for a user to change the speed
// {59596FBE-F936-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(TELDWORD_DisableSpeedChange, 
0x59596fbe, 0xf936, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// enable the ability for the user to ask for an operator
// {59596FBF-F936-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(TELDWORD_EnableOperator, 
0x59596fbf, 0xf936, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// eanble the user to ask to hang up. If TRUE application must handle
// {59596FC0-F936-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(TELDWORD_EnableAskHangUp, 
0x59596fc0, 0xf936, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// if TRUE, then the system supports full duplex
// both full duplex and echo cancelling must be TRUE for telephony controls to have barge in
// {10FEF992-343F-11d1-BE71-006008317CE8}
DEFINE_GUID(TELDWORD_FullDuplex, 
0x10fef992, 0x343f, 0x11d1, 0xbe, 0x71, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// if TRUE, then the system has echo cancelling built in.
// both full duplex and echo cancelling must be TRUE for telephony controls to have barge in
// {10FEF991-343F-11d1-BE71-006008317CE8}
DEFINE_GUID(TELDWORD_EchoCancel, 
0x10fef991, 0x343f, 0x11d1, 0xbe, 0x71, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

/**************************************************************************
Telephon controls in spchtel.dll. */

// {53961A01-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_YesNoControl, 
0x53961a01, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A02-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_ExtensionControl, 
0x53961a02, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A03-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_PhoneNumControl, 
0x53961a03, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A04-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_GrammarControl, 
0x53961a04, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A05-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_DateControl, 
0x53961a05, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A06-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_TimeControl, 
0x53961a06, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A07-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_RecordControl, 
0x53961a07, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A08-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_SpellingControl, 
0x53961a08, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);

// {53961A09-459B-11d1-BE77-006008317CE8}
DEFINE_GUID(CLSID_NameControl, 
0x53961a09, 0x459b, 0x11d1, 0xbe, 0x77, 0x0, 0x60, 0x8, 0x31, 0x7c, 0xe8);



/**************************************************************************
Sample telephony controls GUIDs. These samples appear in the SDK. */
// {C869F0DE-EF29-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleYesNoControl, 
0xc869f0de, 0xef29, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BA9-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleExtensionControl, 
0x9de44ba9, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAA-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SamplePhoneNumControl, 
0x9de44baa, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAB-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleGrammarControl, 
0x9de44bab, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAC-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleDateControl, 
0x9de44bac, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAD-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleTimeControl, 
0x9de44bad, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {275931C6-FD27-11d0-8FAE-08002BE4E62A}
DEFINE_GUID(CLSID_SampleRecordControl, 
0x275931c6, 0xfd27, 0x11d0, 0x8f, 0xae, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAE-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleSpellingControl, 
0x9de44bae, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);

// {9DE44BAF-F94A-11d0-8FAD-08002BE4E62A}
DEFINE_GUID(CLSID_SampleNameControl, 
0x9de44baf, 0xf94a, 0x11d0, 0x8f, 0xad, 0x8, 0x0, 0x2b, 0xe4, 0xe6, 0x2a);


#endif // _SPCHTEL_H_