#include <list>
#include <vector>
#include <string.h>
#include <pthread.h>
#include <thread>
#include <cstring>
#include <jni.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <dlfcn.h>
#include "Includes/Logger.h"
#include "Includes/obfuscate.h"
#include "Includes/Utils.h"
#include "KittyMemory/MemoryPatch.h"
#include "Menu/Setup.h"

//Target lib here
#define targetLibName OBFUSCATE("libil2cpp.so")

#include "Includes/Macros.h"

bool isSpace = false;
bool isBlast = false;

int point = 99999999;
int spaceLevel = 1;
int blastLevel = 1;

void (*SetPoinst)(int Loadedpoints);
void (*SetItemSpace)(int LoadedItemSpace);
void (*SetBlastMeter)(int LoadedBlastMeters);

void (*oriUpadte)(void* instance);
void hkUpdate(void* instance)
{
    if(instance != NULL)
    {
        LOGD("hkUpdate");
        SetPoinst(point);
        if(isSpace)
            SetItemSpace(spaceLevel);

        if(isBlast)
            SetBlastMeter(blastLevel);

    }
    oriUpadte(instance);
}

// we will run our hacks in a new thread so our while loop doesn't block process main thread
void *hack_thread(void *) {
    LOGI(OBFUSCATE("pthread created"));

    //Check if target lib is loaded
    do {
        sleep(1);
    } while (!isLibraryLoaded(targetLibName));

    LOGI(OBFUSCATE("%s has been loaded"), (const char *) targetLibName);

    //Shop::Update
    HOOK_LIB("libil2cpp.so", "0x406BE4", hkUpdate, oriUpadte);

    //PlayerEngine
    SetPoinst = (void(*)(int)) getAbsoluteAddress(targetLibName, 0x4054DC);
    SetItemSpace = (void(*)(int)) getAbsoluteAddress(targetLibName, 0x405480);
    SetBlastMeter = (void(*)(int)) getAbsoluteAddress(targetLibName, 0x405424);

    //ADS::ctor
    PATCH_LIB("libil2cpp.so", "0x3E91FC", "1E FF 2F E1");
    //ADS::start
    PATCH_LIB("libil2cpp.so", "0x3E90F4", "1E FF 2F E1");
    //MaxSdkAndroid::IsRewardedAdReady
    PATCH_LIB("libil2cpp.so", "0xA55808", "00 00 A0 E3 1E FF 2F E1");
    //MaxSdkAndroid::ctor
    PATCH_LIB("libil2cpp.so", "0xA4E278", "1E FF 2F E1");
    //MaxSdkAndroid::cctor
    PATCH_LIB("libil2cpp.so", "0xA4E48C", "1E FF 2F E1");


    // Hook example. Comment out if you don't use hook
    // Strings in macros are automatically obfuscated. No need to obfuscate!
//    HOOK("str", FunctionExample, old_FunctionExample);
//    HOOK_LIB("libFileB.so", "0x123456", FunctionExample, old_FunctionExample);
//    HOOK_NO_ORIG("0x123456", FunctionExample);
//    HOOK_LIB_NO_ORIG("libFileC.so", "0x123456", FunctionExample);
//    HOOKSYM("__SymbolNameExample", FunctionExample, old_FunctionExample);
//    HOOKSYM_LIB("libFileB.so", "__SymbolNameExample", FunctionExample, old_FunctionExample);
//    HOOKSYM_NO_ORIG("__SymbolNameExample", FunctionExample);
//    HOOKSYM_LIB_NO_ORIG("libFileB.so", "__SymbolNameExample", FunctionExample);
//
//    // Patching offsets directly. Strings are automatically obfuscated too!
//    PATCH("0x20D3A8", "00 00 A0 E3 1E FF 2F E1");
//    PATCH_LIB("libFileB.so", "0x20D3A8", "00 00 A0 E3 1E FF 2F E1");
//
//    //Restore changes to original
//    RESTORE("0x20D3A8");
//    RESTORE_LIB("libFileB.so", "0x20D3A8");

//    AddMoneyExample = (void (*)(void *, int)) getAbsoluteAddress(targetLibName, 0x123456);

    LOGI(OBFUSCATE("Done"));

    return NULL;
}

// Do not change or translate the first text unless you know what you are doing
// Assigning feature numbers is optional. Without it, it will automatically count for you, starting from 0
// Assigned feature numbers can be like any numbers 1,3,200,10... instead in order 0,1,2,3,4,5...
// ButtonLink, Category, RichTextView and RichWebView is not counted. They can't have feature number assigned
// Toggle, ButtonOnOff and Checkbox can be switched on by default, if you add True_. Example: CheckBox_True_The Check Box
// To learn HTML, go to this page: https://www.w3schools.com/

jobjectArray GetFeatureList(JNIEnv *env, jobject context) {
    jobjectArray ret;

    const char *features[] = {
            OBFUSCATE("Category_This is free mod"), //Not counted
            OBFUSCATE("InputValue_Custom Scraps"),
            OBFUSCATE("Toggle_Toggle Change Space Count"),
            OBFUSCATE("InputValue_Space Count"),
            OBFUSCATE("Toggle_Toggle Change Blast Count"),
            OBFUSCATE("InputValue_Blast Count")

    };

    //Now you dont have to manually update the number everytime;
    int Total_Feature = (sizeof features / sizeof features[0]);
    ret = (jobjectArray)
            env->NewObjectArray(Total_Feature, env->FindClass(OBFUSCATE("java/lang/String")),
                                env->NewStringUTF(""));

    for (int i = 0; i < Total_Feature; i++)
        env->SetObjectArrayElement(ret, i, env->NewStringUTF(features[i]));

    return (ret);
}

void Changes(JNIEnv *env, jclass clazz, jobject obj,
                                        jint featNum, jstring featName, jint value,
                                        jboolean boolean, jstring str) {

    LOGD(OBFUSCATE("Feature name: %d - %s | Value: = %d | Bool: = %d | Text: = %s"), featNum,
         env->GetStringUTFChars(featName, 0), value,
         boolean, str != NULL ? env->GetStringUTFChars(str, 0) : "");

    //BE CAREFUL NOT TO ACCIDENTLY REMOVE break;

    switch (featNum) {
        case 0:
            point = value;
            break;
        case 1:
            isSpace = boolean;
            break;
        case 2:
            spaceLevel = value;
            break;
        case 3:
            isBlast = boolean;
            break;
        case 4:
            blastLevel = value;
            break;
    }
}

__attribute__((constructor))
void lib_main() {
    // Create a new thread so it does not block the main thread, means the game would not freeze
    pthread_t ptid;
    pthread_create(&ptid, NULL, hack_thread, NULL);
}

int RegisterMenu(JNIEnv *env) {
    JNINativeMethod methods[] = {
            {OBFUSCATE("Icon"), OBFUSCATE("()Ljava/lang/String;"), reinterpret_cast<void *>(Icon)},
            {OBFUSCATE("IconWebViewData"),  OBFUSCATE("()Ljava/lang/String;"), reinterpret_cast<void *>(IconWebViewData)},
            {OBFUSCATE("IsGameLibLoaded"),  OBFUSCATE("()Z"), reinterpret_cast<void *>(isGameLibLoaded)},
            {OBFUSCATE("Init"),  OBFUSCATE("(Landroid/content/Context;Landroid/widget/TextView;Landroid/widget/TextView;)V"), reinterpret_cast<void *>(Init)},
            {OBFUSCATE("SettingsList"),  OBFUSCATE("()[Ljava/lang/String;"), reinterpret_cast<void *>(SettingsList)},
            {OBFUSCATE("GetFeatureList"),  OBFUSCATE("()[Ljava/lang/String;"), reinterpret_cast<void *>(GetFeatureList)},
    };

    jclass clazz = env->FindClass(OBFUSCATE("com/android/support/Menu"));
    if (!clazz)
        return JNI_ERR;
    if (env->RegisterNatives(clazz, methods, sizeof(methods) / sizeof(methods[0])) != 0)
        return JNI_ERR;
    return JNI_OK;
}

int RegisterPreferences(JNIEnv *env) {
    JNINativeMethod methods[] = {
            {OBFUSCATE("Changes"), OBFUSCATE("(Landroid/content/Context;ILjava/lang/String;IZLjava/lang/String;)V"), reinterpret_cast<void *>(Changes)},
    };
    jclass clazz = env->FindClass(OBFUSCATE("com/android/support/Preferences"));
    if (!clazz)
        return JNI_ERR;
    if (env->RegisterNatives(clazz, methods, sizeof(methods) / sizeof(methods[0])) != 0)
        return JNI_ERR;
    return JNI_OK;
}

int RegisterMain(JNIEnv *env) {
    JNINativeMethod methods[] = {
            {OBFUSCATE("CheckOverlayPermission"), OBFUSCATE("(Landroid/content/Context;)V"), reinterpret_cast<void *>(CheckOverlayPermission)},
    };
    jclass clazz = env->FindClass(OBFUSCATE("com/android/support/Main"));
    if (!clazz)
        return JNI_ERR;
    if (env->RegisterNatives(clazz, methods, sizeof(methods) / sizeof(methods[0])) != 0)
        return JNI_ERR;

    return JNI_OK;
}

extern "C"
JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    vm->GetEnv((void **) &env, JNI_VERSION_1_6);
    if (RegisterMenu(env) != 0)
        return JNI_ERR;
    if (RegisterPreferences(env) != 0)
        return JNI_ERR;
    if (RegisterMain(env) != 0)
        return JNI_ERR;
    return JNI_VERSION_1_6;
}
