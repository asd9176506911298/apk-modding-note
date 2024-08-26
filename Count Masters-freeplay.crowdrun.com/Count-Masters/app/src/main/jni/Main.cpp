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

#include "Includes/Macros.h"

//Target lib here
#define targetLibName OBFUSCATE("libil2cpp.so")

bool changeHuman = false;

void* customDebugInstance = NULL;

int humanCount = 1;

void* (*get_SoftCurrency)();
void* (*get_HardCurrency)();
void* (*get_Diamond)();
void* (*get_PurchaseNoAds)();
void* (*get_DidRateUs)();
void* (*get_LevelUpgradeHumans)();

void (*set_Value)(void* instance, int value);

void (*_Start)(void* instance);
void Start(void* instance)
{
    if(instance != NULL)
    {
        void* instance = get_SoftCurrency();
        set_Value(instance, 99999999);

        instance = get_HardCurrency();
        set_Value(instance, 99999999);

        instance = get_Diamond();
        set_Value(instance, 99999999);

        instance = get_PurchaseNoAds();
        set_Value(instance, 1);

        instance = get_DidRateUs();
        set_Value(instance, 1);

        LOGD(OBFUSCATE("Start Hook"));
    }
    _Start(instance);
}

void (*_buildStart)(void* instance);
void buildStart(void* instance)
{
    if(instance != NULL)
    {
        void* instance = get_Diamond();
        set_Value(instance, 99999999);

        LOGD(OBFUSCATE("buildStart Hook"));
    }
    _buildStart(instance);
}

void (*_DoUpgrade)(void* instance);
void DoUpgrade(void* instance)
{
    if(instance != NULL )
    {
        LOGD(OBFUSCATE("HOOK DoUpgrade"));
        if(changeHuman)
        {
            void* instance = get_LevelUpgradeHumans();
            set_Value(instance, humanCount);
        }
        else
            _DoUpgrade(instance);
    }
}

bool IsLocked(void* instance)
{
    if(instance != NULL)
    {
        LOGD(OBFUSCATE("HOOK IsLocked"));
        return false;
    }
}

// we will run our hacks in a new thread so our while loop doesn't block process main thread
void *hack_thread(void *) {
    LOGI(OBFUSCATE("pthread created"));

    //Check if target lib is loaded
    do {
        sleep(1);
    } while (!isLibraryLoaded(targetLibName));

    LOGI(OBFUSCATE("%s has been loaded"), (const char *) targetLibName);

    //IronSourceAdapter::Start
    //LocationComponent::Start
    //UpgradeStartUnits::DoUpgrade
    //StoreItemPrefs::get_IsLocked

    HOOK_LIB("libil2cpp.so", "0xB1CAF4", Start, _Start);
    HOOK_LIB("libil2cpp.so", "0x931774", buildStart, _buildStart);
    HOOK_LIB("libil2cpp.so", "0x97E314", DoUpgrade, _DoUpgrade);
    HOOK_LIB_NO_ORIG("libil2cpp.so", "0x9E5178", IsLocked);


    get_SoftCurrency = (void*(*)())getAbsoluteAddress(targetLibName, 0xA00464);
    get_HardCurrency = (void*(*)())getAbsoluteAddress(targetLibName, 0xA004D8);
    get_Diamond = (void*(*)())getAbsoluteAddress(targetLibName, 0xA01268);
    get_PurchaseNoAds = (void*(*)())getAbsoluteAddress(targetLibName, 0xA02414);
    get_DidRateUs = (void*(*)())getAbsoluteAddress(targetLibName, 0xA01D48);
    get_LevelUpgradeHumans = (void*(*)())getAbsoluteAddress(targetLibName, 0xA01E30);

//    PrefsInt::set_Value
    set_Value = (void(*)(void*, int))getAbsoluteAddress(targetLibName, 0xCCD3A4);



//    // Hook example. Comment out if you don't use hook
//    // Strings in macros are automatically obfuscated. No need to obfuscate!
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
//
//    AddMoneyExample = (void (*)(void *, int)) getAbsoluteAddress(targetLibName, 0x123456);

    LOGI(OBFUSCATE("Done"));

    //Anti-leech
    /*if (!iconValid || !initValid || !settingsValid) {
        //Bad function to make it crash
        sleep(5);
        int *p = 0;
        *p = 0;
    }*/

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
            OBFUSCATE("Toggle_Toggle Change Start Human Count"),
            OBFUSCATE("InputValue_Start Human Count")

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
            changeHuman = boolean;
            break;
        case 1:
            humanCount = value;
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
