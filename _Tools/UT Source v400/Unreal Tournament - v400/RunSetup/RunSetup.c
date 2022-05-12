#include <stdio.h>
#include <windows.h>

int WINAPI WinMain(  HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow )
{
	char path[MAX_PATH], drive[MAX_PATH], dir[MAX_PATH], fname[MAX_PATH], ext[MAX_PATH], newsetup[MAX_PATH];
	GetModuleFilename( NULL, path, sizeof(path) );
	GetLastError();
	_splitpath( path, drive, dir, fname, ext );
	strcpy( newsetup, drive );
	strcat( newsetup, dir );
	strcat( newsetup, "system\\setup.exe" );
	printf( newsetup );
	//_spawnl( P_NOWAIT, newsetup, NULL );
}