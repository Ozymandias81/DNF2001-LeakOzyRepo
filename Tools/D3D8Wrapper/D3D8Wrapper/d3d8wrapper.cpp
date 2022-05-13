#pragma comment(linker, "/export:DebugSetMute=_callDebugSetMute@0")
#pragma comment(linker, "/export:Direct3DCreate8=_callDirect3DCreate8@4")
#pragma comment(linker, "/export:ValidatePixelShader=_callValidatePixelShader@16")
#pragma comment(linker, "/export:ValidateVertexShader=_callValidateVertexShader@20")

#include <Windows.h>
#include <stdbool.h>
#include <Psapi.h>

struct D3DCAPS8;

interface IDirect3D8;

static HMODULE D3D8;

void Initialize(void);

static void(WINAPI *DebugSetMute)(void) = [](void)
{
	Initialize();
	DebugSetMute();
};

static IDirect3D8* (WINAPI* Direct3DCreate8)(UINT) = [](UINT SDKVersion)
{
	Initialize();
	return Direct3DCreate8(SDKVersion);
};

static HRESULT(WINAPI* ValidatePixelShader)(const DWORD*, const D3DCAPS8*, BOOL, CHAR**) = [](const DWORD* PixelShader, const D3DCAPS8* Caps, BOOL ReturnErrors, CHAR** Errors)
{
	Initialize();
	return ValidatePixelShader(PixelShader, Caps, ReturnErrors, Errors);
};

static HRESULT(WINAPI* ValidateVertexShader)(const DWORD*, const DWORD*, const D3DCAPS8*, BOOL, CHAR**) = [](const DWORD* VertexShader, const DWORD* Declaration, const D3DCAPS8* Caps, BOOL ReturnErrors, CHAR** Errors)
{
	Initialize();
	return ValidateVertexShader(VertexShader, Declaration, Caps, ReturnErrors, Errors);
};

extern "C" void WINAPI callDebugSetMute(void)
{
	DebugSetMute();
}

extern "C" IDirect3D8* WINAPI callDirect3DCreate8(UINT SDKVersion)
{
	return Direct3DCreate8(SDKVersion);
}

extern "C" HRESULT WINAPI callValidatePixelShader(const DWORD* PixelShader, const D3DCAPS8* Caps, BOOL ReturnErrors, CHAR** Errors)
{
	return ValidatePixelShader(PixelShader, Caps, ReturnErrors, Errors);
}

extern "C" HRESULT WINAPI callValidateVertexShader(const DWORD* VertexShader, const DWORD* Declaration, const D3DCAPS8* Caps, BOOL ReturnErrors, CHAR** Errors)
{
	return ValidateVertexShader(VertexShader, Declaration, Caps, ReturnErrors, Errors);
}

void Initialize(void)
{
	if (D3D8)
		return;

	WCHAR ImageName[MAX_PATH];
	DWORD NameSize = MAX_PATH;
	QueryFullProcessImageNameW(GetCurrentProcess(), 0, ImageName, &NameSize);

	if (wcsicmp(wcsrchr(ImageName, L'\\') + 1, L"DukeEd.exe") == 0)
		D3D8 = LoadLibraryW(L"d3d8.on12.dll");
	else
		D3D8 = LoadLibraryW(L"d3d8.wine.dll");

	*(void**)&DebugSetMute = GetProcAddress(D3D8, "DebugSetMute");
	*(void**)&Direct3DCreate8 = GetProcAddress(D3D8, "Direct3DCreate8");
	*(void**)&ValidatePixelShader = GetProcAddress(D3D8, "ValidatePixelShader");
	*(void**)&ValidateVertexShader = GetProcAddress(D3D8, "ValidateVertexShader");
}
