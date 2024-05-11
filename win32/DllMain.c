#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN

#include <ol/vm.h>
olvm_pin_t OLVM_pin;
olvm_deref_t OLVM_deref;
olvm_unpin_t OLVM_unpin;
ol2f_t OL2F;
ol2d_t OL2D;

#include <stdio.h>

#include <windows.h>
BOOL WINAPI DllMain(
	HINSTANCE hinstDLL,  // handle to DLL module
	DWORD fdwReason,     // reason for calling function
	LPVOID lpvReserved)
{
	HINSTANCE app;
	switch (fdwReason) 
	{
		case DLL_PROCESS_ATTACH: {
			app = GetModuleHandle(NULL);
			OLVM_pin = (olvm_pin_t)GetProcAddress(app, "OLVM_pin");
			OLVM_deref = (olvm_deref_t)GetProcAddress(app, "OLVM_deref");
			OLVM_unpin = (olvm_unpin_t)GetProcAddress(app, "OLVM_unpin");

			OL2F = (ol2f_t)GetProcAddress(app, "OL2F");
			OL2D = (ol2d_t)GetProcAddress(app, "OL2D");
			break;
		}

		case DLL_PROCESS_DETACH:
			// Perform any necessary cleanup
			break;
	}
	return TRUE;
}
#endif
