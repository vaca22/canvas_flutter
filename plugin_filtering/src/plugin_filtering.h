#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif


typedef void (*callback)(short *shortArray, int arraySize);
FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data);
FFI_PLUGIN_EXPORT void shortfilter(short *shortArray, int arraySize,callback cb ) ;
#ifdef __cplusplus
};
#endif