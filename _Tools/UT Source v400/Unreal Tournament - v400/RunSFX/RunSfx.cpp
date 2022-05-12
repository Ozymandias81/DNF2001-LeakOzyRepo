/*=============================================================================
	RunSfx.cpp: Unreal self-extractor runner.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
	* Created by Tim Sweeney

	Note:
	* This file could be avoided by linking the Core, Window, Setup, and
	  MSVCRT files together into one executable which performs the extraction 
	  from within the context of the Unreal code. Unfortunately, I can't figure 
	  out how to get Visual C++ to do that in a way that's easier than
	  maintaining this little extractor.
=============================================================================*/

#pragma warning (disable:4115)
#pragma warning (disable:4100)
#include <windows.h>
#include <stdio.h>
#include <process.h>

/*-----------------------------------------------------------------------------
	Copied from Filer.h.
-----------------------------------------------------------------------------*/

enum {ARCHIVE_MAGIC=0x9fe3c5a3};
enum {ARCHIVE_HEADER_SIZE=5*4};
enum {ARCHIVE_VERSION=1};
enum EArchiveFlags
{
	ARCHIVEF_Compressed = 0x00000001,
	ARCHIVEF_Bootstrap  = 0x00000002,
};

/*-----------------------------------------------------------------------------
	CRC.
-----------------------------------------------------------------------------*/

// CRC 32 polynomial.
#define CRC32_POLY 0x04c11db7
DWORD GCRCTable[256];
DWORD appMemCrc( const void* InData, INT Length, DWORD CRC=0 )
{
	BYTE* Data = (BYTE*)InData;
	CRC = ~CRC;
	for( INT i=0; i<Length; i++ )
		CRC = (CRC << 8) ^ GCRCTable[(CRC >> 24) ^ Data[i]];
	return ~CRC;
}

/*-----------------------------------------------------------------------------
	Main.
-----------------------------------------------------------------------------*/

void Failed( char* Msg )
{
	MessageBox( NULL, Msg, TEXT("Self-Extractor Failed"), MB_OK );
	ExitProcess( 0 );
}
void ReadFileChecked( HANDLE hFile, void* Data, int Count )
{
	int Result=0;
	if( ReadFile( hFile, Data, Count, (DWORD*)&Result, NULL )==0 || Result!=Count )
		Failed("ReadFile failed");
}
void WriteFileChecked( HANDLE hFile, void* Data, int Count )
{
	int Result=0;
	if( WriteFile( hFile, Data, Count, (DWORD*)&Result, NULL )==0 || Result!=Count )
		Failed("WriteFile failed");
}
void SeekChecked( HANDLE hFile, INT Pos )
{
	if( SetFilePointer(hFile,Pos,0,FILE_BEGIN)==0xFFFFFFFF )
		Failed("SetFilePointer failed");
}
INT TellChecked( HANDLE hFile )
{
	INT Result = SetFilePointer(hFile,0,0,FILE_CURRENT);
	if( Result==0xFFFFFFFF )
		Failed("SetFilePointer failed");
	return Result;
}
#define READ_FILE_CHECKED(hFile,Item) ReadFileChecked(hFile,&Item,sizeof(Item));
INT ReadIndex( HANDLE hFile )
{
	INT IValue=0;
	BYTE B0=0, B1=0, B2=0, B3=0, B4=0;
	READ_FILE_CHECKED(hFile,B0);
	if( B0 & 0x40 )
	{
		READ_FILE_CHECKED(hFile,B1);
		if( B1 & 0x80 )
		{
			READ_FILE_CHECKED(hFile,B2);
			if( B2 & 0x80 )
			{
				READ_FILE_CHECKED(hFile,B3);
				if( B3 & 0x80 )
				{
					READ_FILE_CHECKED(hFile,B4);
					IValue = B4;
				}
				IValue = (IValue << 7) + (B3 & 0x7f);
			}
			IValue = (IValue << 7) + (B2 & 0x7f);
		}
		IValue = (IValue << 7) + (B1 & 0x7f);
	}
	IValue = (IValue << 6) + (B0 & 0x3f);
	if( B0 & 0x80 )
		IValue = -IValue;
	return IValue;
}
int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow )
{
	// Get temp path.
	char TempBase[MAX_PATH], TempDir[MAX_PATH];
	if( GetTempPath( sizeof(TempBase), TempBase )==0 )
		Failed("GetTempPath failed");
	if( TempBase[strlen(TempBase)-1]!='\\' )
		strcat(TempBase,"\\");
	srand((DWORD)hInstance);
	INT i=0;
	do
	{
		strcpy( TempDir, TempBase );
		itoa( rand(), TempDir+strlen(TempDir), 16 );
	} while( CreateDirectory(TempDir,NULL)==0 && i++<65536 );
	if( i>=65536 )
		Failed("Failed creating temporary directory");
	strcat( TempDir,"\\");

	// CRC.
    for( DWORD iCRC=0; iCRC<256; iCRC++ )
		for( DWORD c=iCRC<<24, j=8; j!=0; j-- )
			GCRCTable[iCRC] = c = c & 0x80000000 ? (c << 1) ^ CRC32_POLY : (c << 1);

	// Get path of this self-extractor executable.
	char ModuleFilename[MAX_PATH], QuotedModuleFilename[MAX_PATH+2];
	if( GetModuleFileName(NULL,ModuleFilename,sizeof(ModuleFilename))==0 )
		Failed("GetModuleFilename failed");
	strcpy(QuotedModuleFilename,"\"");
	strcat(QuotedModuleFilename,ModuleFilename);
	strcat(QuotedModuleFilename,"\"");
 
	// Open module file.
	HANDLE hFile = CreateFile(ModuleFilename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
	if( hFile==INVALID_HANDLE_VALUE )
		Failed("CreateFile failed");
	INT RealSize = GetFileSize(hFile,NULL);
	if( RealSize==0xFFFFFFFF )
		Failed("GetFileSize failed");
	INT HeaderPos = RealSize-ARCHIVE_HEADER_SIZE;

	// Read file header.
	INT Magic, TableOffset, FileSize, Ver; DWORD CRC;
	SeekChecked( hFile, HeaderPos );
	READ_FILE_CHECKED( hFile, Magic );
	READ_FILE_CHECKED( hFile, TableOffset );
	READ_FILE_CHECKED( hFile, FileSize );
	READ_FILE_CHECKED( hFile, Ver );
	READ_FILE_CHECKED( hFile, CRC );
	if( Magic!=ARCHIVE_MAGIC || Ver!=ARCHIVE_VERSION || RealSize!=FileSize )
		Failed("Installer file is incomplete -- probably due to an incomplete or failed download");

	// Verify file CRC.
	SeekChecked( hFile, 0 );
	BYTE Buffer[16384]; DWORD CheckCRC=0;
	for( INT Pos=0; Pos<HeaderPos; Pos+=sizeof(Buffer) )
	{
		INT Count = min(sizeof(Buffer),HeaderPos-Pos);
		ReadFileChecked( hFile, Buffer, Count );
		CheckCRC = appMemCrc( Buffer, Count, CheckCRC );
	}
	if( CheckCRC!=CRC )
		Failed("Installer file is corrupt -- probably due to an incomplete or corrupted download");

	// Examine each file.
	SeekChecked( hFile, TableOffset );
	INT Count = ReadIndex(hFile), BootFileCount=0;
	char* BootFiles[1024];
	for( i=0; i<Count; i++ )
	{
		INT StringSize, Offset, Size, Flags;
		char Filename[256];
		StringSize = ReadIndex(hFile);
		if( StringSize>=sizeof(Filename) )
			Failed("Invalid file table");
		ReadFileChecked( hFile, Filename, StringSize );
		READ_FILE_CHECKED( hFile, Offset );
		READ_FILE_CHECKED( hFile, Size   );
		READ_FILE_CHECKED( hFile, Flags  );
		if( Flags & ARCHIVEF_Bootstrap )
		{
			INT SavedPos = TellChecked( hFile );
			char* Partial = Filename;
			if( strchr(Partial,'\\') )
				Partial = strchr(Partial,'\\')+1;
			char Full[256];
			strcpy(Full,TempDir);
			strcat(Full,Partial);
			BootFiles[BootFileCount++] = strdup(Full);
			HANDLE hDest = CreateFile(Full,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
			if( hDest==INVALID_HANDLE_VALUE )
				Failed("CreateFile failed");
			void* Buffer = malloc( Size );
			SeekChecked( hFile, Offset );
			ReadFileChecked( hFile, Buffer, Size );
			WriteFileChecked( hDest, Buffer, Size );
			if( !Buffer )
				Failed("malloc failed");
			free( Buffer );
			CloseHandle( hDest );
			SeekChecked( hFile, SavedPos );
		}
	}

	// Run the bootstrap "setup" program.
	char Run[256];
	strcpy(Run,TempDir);
	strcat(Run,"setup.exe");
	_spawnl( _P_WAIT, Run, "setup.exe", "install", QuotedModuleFilename, NULL );

	// Remove temp directory.
	TempDir[strlen(TempDir)-1] = 0;
	for( i=0; i<BootFileCount; i++ )
		if( DeleteFile(BootFiles[i])==0 )
			Failed( "DeleteFile failed" );
	if( RemoveDirectory(TempDir)==0 )
		Failed( "RemoveDirectory failed" );

	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
