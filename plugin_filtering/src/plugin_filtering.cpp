#include "plugin_filtering.h"
#include "commalgorithm.h"
#include "swt.h"
#include "streamswtqua.h"

#include <android/log.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <pthread.h>
#include <stdio.h>
#include <string>
#include <sys/socket.h>
#include <thread>
#include <unistd.h>
#include <vector>


FFI_PLUGIN_EXPORT void shortfilter(short *shortArray, int arraySize,Dart_Port_DL filter_result_port ) {
    deque<double> inputt;
    deque<double> realInput;

    inputt.clear();


    for (int j = 0; j < arraySize; j++) {
        inputt.push_back(shortArray[j]);
    }
    int inputLength = (int) inputt.size();

    int i = 0;
    int j = 0;
    int flag = 0;

    StreamSwtQua streamSwtQua;
    deque<double> outputPoints;
    deque<double> allSig;
    deque<double> outputsize;

    int lenthOfData = 0;
    int ReduntLength = 0;
    int MultipleSize = 0;
    int padDataLen = 0;

    lenthOfData = inputt.size();
    MultipleSize = lenthOfData / 256;
    ReduntLength = lenthOfData - 256 * MultipleSize;

    padDataLen = (MultipleSize + 1) * 256 - lenthOfData;

    for (j = 0; j < lenthOfData; ++j) {
        realInput.push_back(inputt[j]);
    }


    if (0 != ReduntLength) {
        if (padDataLen < 64) {
            flag = 1;

            for (j = lenthOfData - 1; j >= lenthOfData - padDataLen; j--) {
                realInput.push_back(inputt[j]);
            }

            for (j = 256 * (MultipleSize + 1) - 128; j < 256 * (MultipleSize + 1); j++) {
                realInput.push_back(realInput[j]);
            }
        } else {
            for (j = lenthOfData - 1; j >= lenthOfData - padDataLen; j--) {
                realInput.push_back(inputt[j]);
            }
        }
    }

    if (0 == ReduntLength) {
        for (i = 0; i < 256 * MultipleSize; ++i) {
            streamSwtQua.GetEcgData(realInput[i], outputPoints);

            for (j = 0; j < outputPoints.size(); ++j) {
                allSig.push_back(outputPoints[j]);
            }
        }

        for (i = 256 * MultipleSize - 128; i < 256 * MultipleSize; ++i) {
            streamSwtQua.GetEcgData(inputt[i], outputPoints);
        }

        for (j = 0; j < 64; j++) {
            allSig.push_back(outputPoints[j]);
        }
    } else {
        for (i = 0; i < realInput.size(); i++) {
            streamSwtQua.GetEcgData(realInput[i], outputPoints);

            for (j = 0; j < outputPoints.size(); ++j) {
                allSig.push_back(outputPoints[j]);
            }
        }

        if (ReduntLength < 192) {
            for (i = 0; i < 192 - ReduntLength; i++) {
                allSig.pop_back();
            }
        }

        if (1 == flag) {
            for (i = 0; i < 64 + padDataLen; i++) {
                allSig.pop_back();
            }
        }
    }


    long length = allSig.size();

    short array[length];
    for (i = 0; i < length; i++) {
        array[i] = (short) allSig[i];
    }

    int  size =  allSig.size();

    Dart_CObject dart_cObject;
    dart_cObject.type = Dart_CObject_kTypedData;
    dart_cObject.value.as_typed_data.type = Dart_TypedData_kInt16;
    dart_cObject.value.as_typed_data.values = (unsigned char *) array;
    dart_cObject.value.as_typed_data.length = size;
    Dart_PostCObject_DL(filter_result_port, &dart_cObject);
}
FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data) {
  return Dart_InitializeApiDL(data);
}
