//========================================================================================
//	dnParentalLock.cpp
//	John Pollard
//		Parental lock support code for script
//========================================================================================
#include "EnginePrivate.h"		// Big momma include
#include "FConfigCacheIni.h"

// Local globals
static FString	CurrentPassword;
static UBOOL	bCurrentPasswordCached;
static UBOOL	bParentalLockIsOn;
static UBOOL	bParentalLockIsOnCached;

//========================================================================================
//	Local support code
//========================================================================================

//========================================================================================
//	EncodeString
//========================================================================================
static const TCHAR *EncodeString(const TCHAR *Str)
{
	ANSICHAR	*AnsiStr = (ANSICHAR*)appToAnsi(Str);

	for (INT i = 0; i < appStrlen(Str); i++)
		AnsiStr[i] ^= 0xff;

	return appFromAnsi(AnsiStr);
}

//========================================================================================
//	DecodeString
//========================================================================================
static const TCHAR *DecodeString(const TCHAR *Str)
{
	ANSICHAR	*AnsiStr = (ANSICHAR*)appToAnsi(Str);

	for (INT i = 0; i < appStrlen(Str); i++)
		AnsiStr[i] ^= 0xff;

	return appFromAnsi(AnsiStr);
}

//========================================================================================
//	g_BuildSystemIniPath
//========================================================================================
static FString g_BuildSystemIniPath()
{
	return FString(appBaseDir()) + PATH_SEPARATOR + TEXT("System.ini");
}

//========================================================================================
//	GetParentalLockPassword
//========================================================================================
static FString GetParentalLockPassword()
{
	if (bCurrentPasswordCached)
		return CurrentPassword;

	FConfigCache	*TempConfig = FConfigCacheIni::Factory();

	// Write out the current profile so we can catch it at startup
	if (TempConfig)
	{
		CurrentPassword = TempConfig->GetStr(TEXT("ParentalLock"), TEXT("Password"), *g_BuildSystemIniPath());

		CurrentPassword = DecodeString(*CurrentPassword);

		bCurrentPasswordCached = true;

		delete TempConfig;
		TempConfig = NULL;
	}

	return CurrentPassword;
}

//========================================================================================
//	PasswordIsCorrect
//========================================================================================
static UBOOL PasswordIsCorrect(FString Password)
{
	if (!appStrcmp(*Password, *GetParentalLockPassword()))
		return true;

	return false;
}

//========================================================================================
//	SetParentalLockPassword
//========================================================================================
static UBOOL SetParentalLockPassword(FString OldPassword, FString NewPassword)
{
	//if (OldPassword != GetParentalLockPassword())
	if (!PasswordIsCorrect(OldPassword))
		return false;

	FConfigCache	*TempConfig = FConfigCacheIni::Factory();

	if (TempConfig)
	{
		TempConfig->SetString(TEXT("ParentalLock"), TEXT("Password"), EncodeString(*NewPassword), *g_BuildSystemIniPath());
		
		delete TempConfig;
		TempConfig = NULL;
	}
	
	CurrentPassword = NewPassword;

	return true;
}

//========================================================================================
//	GetParentalLockStatus
//========================================================================================
static UBOOL GetParentalLockStatus(void)
{
	if (bParentalLockIsOnCached)
		return bParentalLockIsOn;

	FConfigCache	*TempConfig = FConfigCacheIni::Factory();

	if (TempConfig)
	{
		FString		Mode;

		Mode = TempConfig->GetStr(TEXT("ParentalLock"), TEXT("Status"), *g_BuildSystemIniPath());
			
		Mode = DecodeString(*Mode);

		if (Mode == TEXT("KidMode"))
			bParentalLockIsOn = true;
		else if (Mode == TEXT("ParentMode"))
			bParentalLockIsOn = false;
		else
			bParentalLockIsOn = true;

		bParentalLockIsOnCached = true;
		
		delete TempConfig;
		TempConfig = NULL;
	}

	return bParentalLockIsOn;
}

//========================================================================================
//	SetParentalLockStatus
//========================================================================================
static UBOOL SetParentalLockStatus(UBOOL bParentalLockOn, FString Password)
{
	if (PasswordIsCorrect(Password) || bParentalLockOn)
	{
		FConfigCache	*TempConfig = FConfigCacheIni::Factory();

		if (TempConfig)
		{
			FString		Mode;
			
			if (bParentalLockOn)
				Mode = TEXT("KidMode");
			else
				Mode = TEXT("ParentMode");
			
			TempConfig->SetString(TEXT("ParentalLock"), TEXT("Status"), EncodeString(*Mode), *g_BuildSystemIniPath());

			delete TempConfig;
			TempConfig = NULL;
		}
		
		bParentalLockIsOn = bParentalLockOn;

		return true;
	}

	return false;
}

//========================================================================================
//	Script support
//========================================================================================

//========================================================================================
//	execSetParentalLockPassword
//========================================================================================
void AActor::execSetParentalLockPassword( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(OldPassword);
	P_GET_STR(NewPassword);
	P_FINISH;
	
	if (SetParentalLockPassword(OldPassword, NewPassword))
		*(UBOOL*)Result = 1;
	else
		*(UBOOL*)Result = 0;
}

//========================================================================================
//	execValidateParentalLockPassword
//========================================================================================
void AActor::execValidateParentalLockPassword( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Password);
	P_FINISH;

	//if (Password == GetParentalLockPassword())
	if (PasswordIsCorrect(Password))
		*(UBOOL*)Result = 1;
	else
		*(UBOOL*)Result = 0;
}

//========================================================================================
//	AActor::execSetParentalLockStatus
//========================================================================================
void AActor::execSetParentalLockStatus( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL(bParentalLockOn);
	P_GET_STR(Password);
	P_FINISH;
	
	if (SetParentalLockStatus(bParentalLockOn, Password))
		*(UBOOL*)Result = 1;
	else
		*(UBOOL*)Result = 0;
}

//========================================================================================
//	AActor::execParentalLockIsOn
//========================================================================================
void AActor::execParentalLockIsOn( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(UBOOL*)Result = GetParentalLockStatus();
}
