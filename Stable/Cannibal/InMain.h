#ifndef __INMAIN_H__
#define __INMAIN_H__
//****************************************************************************
//**
//**    INMAIN.H
//**    Header - User Input Main Interface
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "InDefs.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================

// initialization/shutdown
KRN_API void IN_Init();
KRN_API void IN_Shutdown();

// tracker management
KRN_API IInTracker* IN_CreateTracker(void* inInstance, void* inWindow, NBool inExclusive);
KRN_API NBool IN_DestroyTracker(IInTracker* inTracker);
KRN_API NBool IN_ProcessAll();
KRN_API IInTracker* IN_GetCurrentTracker();
KRN_API NBool IN_SetCurrentTracker(IInTracker* inTracker);

// key names and shifted equivalents
KRN_API NChar* IN_NameForKey(EInKey inKey, NDword inFlags);
KRN_API EInKey IN_KeyForName(NChar* inName);
KRN_API EInKey IN_GetShiftedKey(EInKey inKey);

// binding executions
KRN_API HInBindMap IN_MakeBindMap(NChar* inName);
KRN_API NBool IN_BindKey(HInBindMap inMap, EInKey inKey, NDword inFlags, NChar* inCmd);
KRN_API NChar* IN_TranslateBindMap(HInBindMap inMap, SInEvent* inEvent);
KRN_API NBool IN_DeTranslateBindMap(HInBindMap inMap, NChar* inCmd, EInKey* outKey, NDword* outFlags);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER INMAIN.H
//**
//****************************************************************************
#endif // __INMAIN_H__
