/*=============================================================================
	FFileManagerLinux.h: Unreal Linux based file manager.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Brandon Reinhart
=============================================================================*/

#include <dirent.h>
#include <unistd.h>
#include "FFileManagerGeneric.h"

/*-----------------------------------------------------------------------------
	File Manager.
-----------------------------------------------------------------------------*/

// File manager.
class FArchiveFileReader : public FArchive
{
public:
	FArchiveFileReader( FILE* InFile, FOutputDevice* InError, INT InSize )
	:	File			( InFile )
	,	Error			( InError )
	,	Size			( InSize )
	,	Pos				( 0 )
	,	BufferBase		( 0 )
	,	BufferCount		( 0 )
	{
		fseek( File, 0, SEEK_SET );
		ArIsLoading = ArIsPersistent = 1;
	}
	~FArchiveFileReader()
	{
		if( File )
			Close();
	}
	void Precache( INT HintCount )
	{
		checkSlow(Pos==BufferBase+BufferCount);
		BufferBase = Pos;
		BufferCount = Min( Min( HintCount, (INT)(ARRAY_COUNT(Buffer) - (Pos&(ARRAY_COUNT(Buffer)-1))) ), Size-Pos );
		if( fread( Buffer, BufferCount, 1, File )!=1 && BufferCount!=0 )
		{
			ArIsError = 1;
			Error->Logf( TEXT("fread failed: BufferCount=%i Error=%i"), BufferCount, ferror(File) );
			return;
		}
	}
	void Seek( INT InPos )
	{
		check(InPos>=0);
		check(InPos<=Size);
		if( fseek(File,InPos,SEEK_SET) )
		{
			ArIsError = 1;
			Error->Logf( TEXT("seek Failed %i/%i: %i %i"), InPos, Size, Pos, ferror(File) );
		}
		Pos         = InPos;
		BufferBase  = Pos;
		BufferCount = 0;
	}
	INT Tell()
	{
		return Pos;
	}
	INT TotalSize()
	{
		return Size;
	}
	UBOOL Close()
	{
		if( File )
			fclose( File );
		File = NULL;
		return !ArIsError;
	}
	void Serialize( void* V, INT Length )
	{
		while( Length>0 )
		{
			INT Copy = Min( Length, BufferBase+BufferCount-Pos );
			if( Copy==0 )
			{
				if( Length >= ARRAY_COUNT(Buffer) )
				{
					if( fread( V, Length, 1, File )!=1 )
					{
						ArIsError = 1;
						Error->Logf( TEXT("fread failed: Length=%i Error=%i"), Length, ferror(File) );
					}
					Pos += Length;
					BufferBase += Length;
					return;
				}
				Precache( MAXINT );
				Copy = Min( Length, BufferBase+BufferCount-Pos );
				if( Copy<=0 )
				{
					ArIsError = 1;
					Error->Logf( TEXT("ReadFile beyond EOF %i+%i/%i"), Pos, Length, Size );
				}
				if( ArIsError )
					return;
			}
			appMemcpy( V, Buffer+Pos-BufferBase, Copy );
			Pos       += Copy;
			Length    -= Copy;
			V          = (BYTE*)V + Copy;
		}
	}
protected:
	FILE*			File;
	FOutputDevice*	Error;
	INT				Size;
	INT				Pos;
	INT				BufferBase;
	INT				BufferCount;
	BYTE			Buffer[1024];
};
class FArchiveFileWriter : public FArchive
{
public:
	FArchiveFileWriter( FILE* InFile, FOutputDevice* InError )
	:	File		(InFile)
	,	Error		( InError )
	,	Pos			(0)
	,	BufferCount	(0)
	{}
	~FArchiveFileWriter()
	{
		if( File )
			Close();
		File = NULL;
	}
	void Seek( INT InPos )
	{
		Flush();
		if( fseek(File,InPos,SEEK_SET) )
		{
			ArIsError = 1;
			Error->Logf( LocalizeError("SeekFailed",TEXT("Core")) );
		}
		Pos = InPos;
	}
	INT Tell()
	{
		return Pos;
	}
	UBOOL Close()
	{
		Flush();
		if( File && fclose( File ) )
		{
			ArIsError = 1;
			Error->Logf( LocalizeError("WriteFailed",TEXT("Core")) );
		}
		File = NULL;
		return !ArIsError;
	}
	void Serialize( void* V, INT Length )
	{
		Pos += Length;
		INT Copy;
		while( Length > (Copy=ARRAY_COUNT(Buffer)-BufferCount) )
		{
			appMemcpy( Buffer+BufferCount, V, Copy );
			BufferCount += Copy;
			Length      -= Copy;
			V            = (BYTE*)V + Copy;
			Flush();
		}
		if( Length )
		{
			appMemcpy( Buffer+BufferCount, V, Length );
			BufferCount += Length;
		}
	}
	void Flush()
	{
		if( BufferCount && fwrite( Buffer, BufferCount, 1, File )!=1 )
		{
			ArIsError = 1;
			Error->Logf( LocalizeError("WriteFailed",TEXT("Core")) );
		}
		BufferCount=0;
	}
protected:
	FILE*			File;
	FOutputDevice*	Error;
	INT				Pos;
	INT				BufferCount;
	BYTE			Buffer[4096];
};

class FFileManagerLinux : public FFileManagerGeneric
{
public:
	FArchive* CreateFileReader( const TCHAR* Filename, DWORD Flags, FOutputDevice* Error )
	{
		FILE* File = fopen(TCHAR_TO_ANSI(Filename), TCHAR_TO_ANSI(TEXT("rb")));
		if( !File )
		{
			if( Flags & FILEREAD_NoFail )
				appErrorf(TEXT("Failed to read file: %s"),Filename);
			return NULL;
		}
		fseek( File, 0, SEEK_END );
		return new(TEXT("LinuxFileReader"))FArchiveFileReader(File,Error,ftell(File));
	}
	FArchive* CreateFileWriter( const TCHAR* Filename, DWORD Flags, FOutputDevice* Error )
	{
		if( Flags & FILEWRITE_EvenIfReadOnly )
			chmod(TCHAR_TO_ANSI(Filename), __S_IREAD | __S_IWRITE);
		if( (Flags & FILEWRITE_NoReplaceExisting) && FileSize(Filename)>=0 )
			return NULL;
		const TCHAR* Mode = (Flags & FILEWRITE_Append) ? TEXT("ab") : TEXT("wb"); 
		FILE* File = fopen(TCHAR_TO_ANSI(Filename),TCHAR_TO_ANSI(Mode));
		if( !File )
		{
			if( Flags & FILEWRITE_NoFail )
				appErrorf( TEXT("Failed to write: %s"), Filename );
			return NULL;
		}
		if( Flags & FILEWRITE_Unbuffered )
			setvbuf( File, 0, _IONBF, 0 );
		return new(TEXT("LinuxFileWriter"))FArchiveFileWriter(File,Error);
	}
	UBOOL Delete( const TCHAR* Filename, UBOOL RequireExists=0, UBOOL EvenReadOnly=0 )
	{
		if( EvenReadOnly )
			chmod(TCHAR_TO_ANSI(Filename), __S_IREAD | __S_IWRITE);
		return unlink(TCHAR_TO_ANSI(Filename))==0 || (errno==ENOENT && !RequireExists);
	}
	SQWORD GetGlobalTime( const TCHAR* Filename )
	{
		return 0;		
	}
	UBOOL SetGlobalTime( const TCHAR* Filename )
	{
		return 0;
	}
	UBOOL MakeDirectory( const TCHAR* Path, UBOOL Tree=0 )
	{
		if( Tree )
			return FFileManagerGeneric::MakeDirectory( Path, Tree );
		return mkdir(TCHAR_TO_ANSI(Path), __S_IREAD && __S_IWRITE && __S_IEXEC)==0 || errno==EEXIST;
	}
	UBOOL DeleteDirectory( const TCHAR* Path, UBOOL RequireExists=0, UBOOL Tree=0 )
	{
		if( Tree )
			return FFileManagerGeneric::DeleteDirectory( Path, RequireExists, Tree );
		return rmdir(TCHAR_TO_ANSI(Path))==0 || (errno==ENOENT && !RequireExists);
	}
	TArray<FString> FindFiles( const TCHAR* Filename, UBOOL Files, UBOOL Directories )
	{
		TArray<FString> Result;
	
		DIR *Dirp;
		struct dirent* Direntp;
		char Path[256];
		char File[256];
		char *Filestart;
		char *Cur;
		UBOOL Match;

		// Initialize Path to Filename.
		appStrcpy( Path, Filename );

		// Convert MS "\" to Unix "/".
		for( Cur = Path; *Cur != '\0'; Cur++ )
			if( *Cur == '\\' )
				*Cur = '/';
	
		// Separate path and filename.
		Filestart = Path;
		for( Cur = Path; *Cur != '\0'; Cur++ )
			if( *Cur == '/' )
				Filestart = Cur + 1;

		// Store filename and remove it from Path.
		appStrcpy( File, Filestart );
		*Filestart = '\0';

		// Check for empty path.
		if (appStrlen( Path ) == 0)
			appSprintf( Path, "./" );

		// Open directory, get first entry.
		Dirp = opendir( Path );
		if (Dirp == NULL)
				return Result;
		Direntp = readdir( Dirp );

		// Check each entry.
		while( Direntp != NULL )
		{
			Match = false;

			if( appStrcmp( File, "*" ) == 0 )
			{
				// Any filename.
				Match = true;
			}
			else if( appStrcmp( File, "*.*" ) == 0 )
			{
				// Any filename with a '.'.
				if( appStrchr( Direntp->d_name, '.' ) != NULL )
					Match = true;
			}
			else if( File[0] == '*' )
			{
				// "*.ext" filename.
				if( appStrstr( Direntp->d_name, (File + 1) ) != NULL )
					Match = true;
			}
			else if( File[appStrlen( File ) - 1] == '*' )
			{
				// "name.*" filename.
				if( appStrncmp( Direntp->d_name, File, appStrlen( File ) - 1 ) == 
					0 )
					Match = true;
			}
			else if( appStrstr( File, "*" ) != NULL )
			{
				// single str.*.str match.
				TCHAR* star = appStrstr( File, "*" );
				INT filelen = appStrlen( File );
				INT starlen = appStrlen( star );
				INT starpos = filelen - (starlen - 1);
				TCHAR prefix[256];
				appStrncpy( prefix, File, starpos );
				star++;
				if( appStrncmp( Direntp->d_name, prefix, starpos - 1 ) == 0 )
				{
					// part before * matches
					TCHAR* postfix = Direntp->d_name + (appStrlen(Direntp->d_name) - starlen) + 1;
					if ( appStrcmp( postfix, star ) == 0 )
						Match = true;
				}
			}
			else
			{
				// Literal filename.
				if( appStrcmp( Direntp->d_name, File ) == 0 )
					Match = true;
			}

			// Does this entry match the Filename?
			if( Match )
			{
				// Yes, add the file name to Result.
				new(Result)FString(Direntp->d_name);
			}
		
			// Get next entry.
			Direntp = readdir( Dirp );
		}

		// Close directory.
		closedir( Dirp );

		return Result;
	}
	UBOOL SetDefaultDirectory( const TCHAR* Filename )
	{
		return chdir(TCHAR_TO_ANSI(Filename))==0;
	}
	FString GetDefaultDirectory()
	{
		ANSICHAR Buffer[1024]="";
		getcwd( Buffer, ARRAY_COUNT(Buffer) );
		return appFromAnsi( Buffer );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
