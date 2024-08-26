/*
 * Credits:
 *
 * Octowolve - Mod menu: https://github.com/z3r0Sec/Substrate-Template-With-Mod-Menu
 * And hooking: https://github.com/z3r0Sec/Substrate-Hooking-Example
 * VanHoevenTR A.K.A Nixi: https://github.com/LGLTeam/VanHoevenTR_Android_Mod_Menu
 * MrIkso - Mod menu: https://github.com/MrIkso/FloatingModMenu
 * Rprop - https://github.com/Rprop/And64InlineHook
 * MJx0 A.K.A Ruit - KittyMemory: https://github.com/MJx0/KittyMemory
 * */
#include <list>
#include <vector>
#include <string.h>
#include <pthread.h>
#include <cstring>
#include <jni.h>
#include <unistd.h>
#include <fstream>
#include "src/Includes/base64.hpp"
#include "src/KittyMemory/MemoryPatch.h"
#include "src/Includes/Logger.h"
#include "src/Includes/Utils.h"
#include "src/Includes/obfuscate.h"

#include "Menu/Sounds.h"
#include "Menu/Menu.h"

#include "Toast.h"

#if defined(__aarch64__) //Compile for arm64 lib only
#include <src/And64InlineHook/And64InlineHook.hpp>
#else //Compile for armv7 lib only. Do not worry about greyed out highlighting code, it still works

#include <src/Substrate/SubstrateHook.h>
#include <src/Substrate/CydiaSubstrate.h>

#endif
int combo = -1;
int (*get_oldComboTextDisplayNum)(void *instance);

int get_newComboTextDisplayNum(void *instance) {
    if(instance && combo > 0) return combo;

    return get_oldComboTextDisplayNum(instance);
}

bool isSpeedUp = false;
void (*old_Speed)(void *instance, float seconds);

void new_Speed(void *instance, float seconds) {
    if(instance && isSpeedUp) {
        old_Speed(instance, 0);
        return;
    }
    old_Speed(instance, seconds);
}


// fancy struct for patches for kittyMemory
struct My_Patches {
    // let's assume we have patches for these functions for whatever game
    // like show in miniMap boolean function
    MemoryPatch Victory,currentWaveIndex,AttackAll;
    MemoryPatch EnemyAttribute,NewEnemyAttribute,MustKillTogether,GlobalSpeedUp,ultSkill1,ultSkill2,combo,goldenChain,bypass1,bypass2,bypass3,InventoryFull,TeamSize,SkipVictoryAnimation;
    // etc...
} hexPatches;

MemoryPatch Victory;

bool feature1 = false, feature2 = false,feature3 = false,feature4 = false,feature5 = false,feature6 = false,feature7 = false, featureHookToggle = false;
int sliderValue = 0;
void *instanceBtn;

// Function pointer splitted because we want to avoid crash when the il2cpp lib isn't loaded.
// If you putted getAbsoluteAddress here, the lib tries to read the address without il2cpp loaded,
// will result in a null pointer which will cause crash
// See https://guidedhacking.com/threads/android-function-pointers-hooking-template-tutorial.14771/
void (*AddMoneyExample)(void *instance, int amount);

extern "C" {
JNIEXPORT void JNICALL
Java_uk_lgl_modmenu_Preferences_Changes(JNIEnv *env, jclass clazz, jobject obj,
                                        jint feature, jint value, jboolean boolean, jstring str) {

    const char *featureName = env->GetStringUTFChars(str, 0);
    feature += 1;  // No need to count from 0 anymore. yaaay :)))

    LOGD(OBFUSCATE("Feature name: %d - %s | Value: = %d | Bool: = %d"), feature, featureName, value,
         boolean);

    // Changed to if-statement because modders can easly mess up with cases.
    if (feature == 1) {
        // The category was 1 so is not used
    } else if (feature == 2) {
        feature2 = boolean;
        if (feature2) {
            hexPatches.Victory.Modify();
            hexPatches.currentWaveIndex.Modify();
            hexPatches.GlobalSpeedUp.Modify();
        } else {
            hexPatches.Victory.Restore();
            hexPatches.currentWaveIndex.Restore();
            hexPatches.GlobalSpeedUp.Restore();
        }
    } else if (feature == 3) {
        feature3 = boolean;
        if (feature3) {
            hexPatches.AttackAll.Modify();
        } else {
            hexPatches.AttackAll.Restore();
        }
    } else if (feature == 4) {
        feature4 = boolean;
        if (feature4) {
            hexPatches.EnemyAttribute.Modify();
        } else {
            hexPatches.EnemyAttribute.Restore();
        }
    } else if (feature == 5) {
        feature5 = boolean;
        if (feature5) {
            hexPatches.NewEnemyAttribute.Modify();
            hexPatches.MustKillTogether.Modify();
        } else {
            hexPatches.NewEnemyAttribute.Restore();
            hexPatches.MustKillTogether.Restore();
        }
    } else if (feature == 6) {
        isSpeedUp = boolean;
    } else if (feature == 7) {
        feature7 = boolean;
        if (feature7) {
            hexPatches.ultSkill1.Modify();
            hexPatches.ultSkill2.Modify();
            hexPatches.goldenChain.Modify();
        } else {
            hexPatches.ultSkill1.Restore();
            hexPatches.ultSkill2.Restore();
            hexPatches.goldenChain.Restore();
        }
    }
        else if (feature == 8)
        {
            combo = value;

        }





    }

    //You can still do cases if you prefer that but careful not to remove break; by accidently
    /*switch (feature) {
        case 0:
            feature1 = boolean;
            break;
        case 1:
            feature2 = boolean;
            break;
        case 2:
            //etc.
            break;
        case 3:
            //etc.
            break;
    }*/
}

// ---------- Hooking ---------- //
/*
bool (*old_get_BoolExample)(void *instance);

bool get_BoolExample(void *instance) {
    if (instance != NULL && featureHookToggle) {
        return true;
    }
    return old_get_BoolExample(instance);
}

float (*old_get_FloatExample)(void *instance);

float get_FloatExample(void *instance) {
    if (instance != NULL && sliderValue > 1) {
        return (float) sliderValue;
    }
    return old_get_FloatExample(instance);
}

void (*old_Update)(void *instance);

void Update(void *instance) {
    instanceBtn = instance;
    old_Update(instance);
}
*/


// we will run our patches in a new thread so our while loop doesn't block process main thread
// Don't forget to remove or comment out logs before you compile it.

//KittyMemory Android Example: https://github.com/MJx0/KittyMemory/blob/master/Android/test/src/main.cpp
//Note: We use OBFUSCATE_KEY for offsets which is the important part xD
void *hack_thread(void *) {
    LOGI(OBFUSCATE("pthread called"));

    //Default lib target is Il2Cpp. Uncomment if you want to target other lib
    //libName = OBFUSCATE("libil2cpp.so");

    //Check if target lib is loaded
    do {
        sleep(1);
    } while (!isLibraryLoaded(libName));
    LOGI(OBFUSCATE("Lib %s has been loaded"), libName);






#if defined(__aarch64__) //Compile for arm64 lib only
    // New way to patch hex via KittyMemory without need to  specify len. Spaces or without spaces are fine


    // Offset Hook example
    A64HookFunction((void *) getAbsoluteAddress(libName, string2Offset(OBFUSCATE_KEY("0x123456", 'l'))), (void *) get_BoolExample,
                    (void **) &old_get_BoolExample);

    // Symbol hook example (untested). Symbol/function names can be found in IDA if the lib are not stripped. This is not for il2cpp games
    A64HookFunction((void *)("__SymbolNameExample"), (void *) get_BoolExample,
                   (void **) &old_get_BoolExample);

    // Function pointer splitted because we want to avoid crash when the il2cpp lib isn't loaded.
    // See https://guidedhacking.com/threads/android-function-pointers-hooking-template-tutorial.14771/
    AddMoneyExample = (void(*)(void *,int))getAbsoluteAddress(libName, 0x123456);

#else //Compile for armv7 lib only. Do not worry about greyed out highlighting code, it still works

    // New way to patch hex via KittyMemory without need to specify len. Spaces or without spaces are fine

    hexPatches.Victory = MemoryPatch::createWithHex(libName,
                                                    string2Offset(OBFUSCATE_KEY("0x11A17FC", '-')),
                                                    OBFUSCATE("14 00 90 E5 7A 5C F4 EA 1E FF 2F E1"));

    hexPatches.currentWaveIndex = MemoryPatch::createWithHex(libName,
                                                    string2Offset(OBFUSCATE_KEY("0x17E24F4", '-')),
                                                    OBFUSCATE("E7 03 00 E3 1E FF 2F E1"));

    hexPatches.AttackAll = MemoryPatch::createWithHex(libName,
                                                             string2Offset(OBFUSCATE_KEY("0x2112094", '-')),
                                                             OBFUSCATE("01 00 00 E3 1E FF 2F E1"));

    hexPatches.EnemyAttribute = MemoryPatch::createWithHex(libName,
                                                      string2Offset(OBFUSCATE_KEY("0x88C1B4", '-')),
                                                      OBFUSCATE("00 40 00 E3"));

    hexPatches.NewEnemyAttribute = MemoryPatch::createWithHex(libName,
                                                         string2Offset(OBFUSCATE_KEY("0x1415490", '-')),
                                                         OBFUSCATE("1E FF 2F E1"));

    hexPatches.MustKillTogether = MemoryPatch::createWithHex(libName,
                                                              string2Offset(OBFUSCATE_KEY("0x142BB2C", '-')),
                                                              OBFUSCATE("1E FF 2F E1"));

    hexPatches.GlobalSpeedUp = MemoryPatch::createWithHex(libName,
                                                         string2Offset(OBFUSCATE_KEY("0x3BCCE34", '-')),
                                                         OBFUSCATE("00 40 00 E3"));

    hexPatches.ultSkill1 = MemoryPatch::createWithHex("libil2cpp.so",
                                                      string2Offset(OBFUSCATE_KEY("0xFA4BB4", '-')),
                                                      OBFUSCATE("01 00 A0 E3 1E FF 2F E1"));

    hexPatches.ultSkill2 = MemoryPatch::createWithHex(libName,
                                                      string2Offset(OBFUSCATE_KEY("0x12F9F60", '-')),
                                                      OBFUSCATE("01 00 A0 E3 1E FF 2F E1"));

    hexPatches.goldenChain = MemoryPatch::createWithHex("libil2cpp.so",
                                                      string2Offset(OBFUSCATE_KEY("0x1531FC8", '-')),
                                                      OBFUSCATE("1E FF 2F E1"));

    hexPatches.bypass1 = MemoryPatch::createWithHex("libil2cpp.so",
                                                        string2Offset(OBFUSCATE_KEY("0x11DE938", '-')),
                                                        OBFUSCATE("1E FF 2F E1"));

    hexPatches.bypass2 = MemoryPatch::createWithHex("libil2cpp.so",
                                                        string2Offset(OBFUSCATE_KEY("0x11DE9E8", '-')),
                                                        OBFUSCATE("1E FF 2F E1"));

    hexPatches.bypass3 = MemoryPatch::createWithHex("libil2cpp.so",
                                                        string2Offset(OBFUSCATE_KEY("0x11DEA98", '-')),
                                                        OBFUSCATE("1E FF 2F E1"));

    hexPatches.InventoryFull = MemoryPatch::createWithHex("libil2cpp.so",
                                                    string2Offset(OBFUSCATE_KEY("0x1A63228", '-')),
                                                    OBFUSCATE("00 00 00 E3 1E FF 2F E1"));

    hexPatches.TeamSize = MemoryPatch::createWithHex("libil2cpp.so",
                                                    string2Offset(OBFUSCATE_KEY("0x1D567E4", '-')),
                                                    OBFUSCATE("00 00 00 E3 1E FF 2F E1"));

    hexPatches.SkipVictoryAnimation = MemoryPatch::createWithHex("libil2cpp.so",
                                                     string2Offset(OBFUSCATE_KEY("0xECDDFC", '-')),
                                                     OBFUSCATE("00 00 A0 E3 01 10 A0 E3 00 20 A0 E3 85 45 29 EB 44 00 00 EA"));

    hexPatches.bypass1.Modify();
    hexPatches.bypass2.Modify();
    hexPatches.bypass3.Modify();
    hexPatches.InventoryFull.Modify();
    hexPatches.TeamSize.Modify();
    hexPatches.SkipVictoryAnimation.Modify();

    MSHookFunction(
            (void *) getAbsoluteAddress(libName, string2Offset(OBFUSCATE_KEY("0x2111EFC", '?'))),
            (void *) get_newComboTextDisplayNum,
            (void **) &get_oldComboTextDisplayNum);
    MSHookFunction(
            (void *) getAbsoluteAddress(libName, string2Offset(OBFUSCATE_KEY("0x3BCCE2C", '?'))),
            (void *) new_Speed,
            (void **) &old_Speed);
    /*
    // Offset Hook example
    MSHookFunction(
            (void *) getAbsoluteAddress(libName, string2Offset(OBFUSCATE_KEY("0x123456", '?'))),
            (void *) get_BoolExample,
            (void **) &old_get_BoolExample);

    // Symbol hook example (untested). Symbol/function names can be found in IDA if the lib are not stripped. This is not for il2cpp games
    MSHookFunction((void *) ("__SymbolNameExample"), (void *) get_BoolExample,
                   (void **) &old_get_BoolExample);

    // Function pointer splitted because we want to avoid crash when the il2cpp lib isn't loaded.
    // See https://guidedhacking.com/threads/android-function-pointers-hooking-template-tutorial.14771/
    AddMoneyExample = (void (*)(void *, int)) getAbsoluteAddress(libName, 0x123456);
    */
    LOGI(OBFUSCATE("Hooked"));
#endif

    return NULL;
}

//No need to use JNI_OnLoad, since we don't use JNIEnv
//We do this to hide OnLoad from disassembler
__attribute__((constructor))
void lib_main() {
    LOGI(OBFUSCATE("Own lib has been loaded"));
    // Create a new thread so it does not block the main thread, means the game would not freeze
    pthread_t ptid;
    pthread_create(&ptid, NULL, hack_thread, NULL);

    //Run anti-leech
    pthread_t p;
    pthread_create(&p, NULL, antiLeech, NULL);
}

/*
JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *globalEnv;
    vm->GetEnv((void **) &globalEnv, JNI_VERSION_1_6);

    pthread_t ptid;
    pthread_create(&ptid, NULL, hack_thread, NULL);

    return JNI_VERSION_1_6;
}

//Does not work yet
//\ndk\21.3.6528147\sources\android\native_app_glue
//#include <android_native_app_glue.h>

void android_main(struct android_app* state) {
    LOGI(OBFUSCATE("android_main"));
}
 */
