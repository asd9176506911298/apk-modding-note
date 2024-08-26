#ifndef ZYCHEATS_SGUYS_FUNCTIONS_H
#define ZYCHEATS_SGUYS_FUNCTIONS_H

// here you can define variables for the patches
bool aimbot, maphack,history,heroinfo;

monoString *CreateIl2cppString(const char *str) {
    monoString *(*String_CreateString)(void *instance, const char *str) = (monoString*(*)(void*, const char*)) (g_il2cppBaseMap.startAddress + string2Offset(OBFUSCATE("0x2596B20")));
    return String_CreateString(NULL, str);
}

//void (*PurchaseRealMoney) (void* instance, monoString* itemId, monoString* receipt, void* callback);

void Pointers() {
//    PurchaseRealMoney = (void(*)(void*, monoString*, monoString*, void*)) (g_il2cppBaseMap.startAddress + string2Offset(OBFUSCATE("0xE7AADC")));
}

void Patches() {
//    PATCH_SWITCH("0x10A69A0", "200080D2C0035FD6", showAllItems);
//    PATCH_SWITCH("0xF148A4", "E07C80D2C0035FD6", freeItems);

    //SampleAndSendFrameSyncData
    PATCH("0x27B7A7C", "000080D2C0035FD6");
    //SendSyncData
    PATCH("0x27B7B80", "000080D2C0035FD6");
    //ReportAppMonitorStat
    PATCH("0x3B86684", "000080D2C0035FD6");
    //ReportGameUser
    PATCH("0x3B86A44", "000080D2C0035FD6");
    //ReportError
    PATCH("0x3B86C70", "000080D2C0035FD6");


    //Init
    PATCH("0x3BE6DE4", "000080D2C0035FD6");
    //OnRecvData
    PATCH("0x3BE75DC", "000080D2C0035FD6");
    //OnRecvSignature
    PATCH("0x3BE7AE0", "000080D2C0035FD6");
    //SetUserInfo
    PATCH("0x3BE6EBC", "000080D2C0035FD6");
    //SetUserInfoWithLicense
    PATCH("0x3BE6FC4", "000080D2C0035FD6");
    //GetReportData
    PATCH("0x3BE7260", "000080D2C0035FD6");
    PATCH("0x3BE76D4", "000080D2C0035FD6");
    PATCH("0x3BE7890", "000080D2C0035FD6");
    //AnoSDKSetUserInfo
    PATCH("0x3BE6F20", "000080D2C0035FD6");
    //AnoSDKGetReportData
    PATCH("0x3BE73C4", "000080D2C0035FD6");
    PATCH("0x3BE781C", "000080D2C0035FD6");
    PATCH("0x3BE79EC", "000080D2C0035FD6");

    //AntiDataInfo
    PATCH("0x3BE7E70", "000080D2C0035FD6");
    //EnableLog
    PATCH("0x44268D8", "000080D2C0035FD6");
    //CheckDeviceIsReal
    PATCH("0x4427B44", "000080D2C0035FD6");
    //ReportUserInfo
    PATCH("0x4427C88", "000080D2C0035FD6");
    //GetIPInfo
    PATCH("0x4298568", "000080D2C0035FD6");

    //GCloudVoice_ReportPlayer
    PATCH("0x4DE1EEC", "000080D2C0035FD6");
    //SetReportedPlayerInfo
    PATCH("0x4DEEE84", "000080D2C0035FD6");
    //ReportPlayer
    PATCH("0x4DEEF94", "000080D2C0035FD6");

}

// declare your hooks here
//void (*old_Backend)(void *instance);
//void Backend(void *instance) {
//    if (instance != NULL) {
//        if (addCurrency) {
//            LOGW("Calling Purchase");
//            PurchaseRealMoney(instance, CreateIl2cppString("special_offer1"), CreateIl2cppString("dev"), NULL);
//            addCurrency = false;
//        }
//        if (addSkins) {
//            LOGW("Calling Skins");
//            addSkins = false;
//        }
//    }
//    return old_Backend(instance);
//}

//void* (*old_ProductDefinition)(void *instance, monoString* id, monoString* storeSpecificId, int type, bool enabled, void* payouts);
//void* ProductDefinition(void *instance, monoString* id, monoString* storeSpecificId, int type, bool enabled, void* payouts) {
//    if (instance != NULL) {
//        LOGW("Called ProductDefinition! Here are the parameters:");
//        LOGW("id: %s", id->getChars());
//        LOGW("storeSpecificId: %s", storeSpecificId->getChars());
//        LOGW("type: %i", type);
//    }
//    return old_ProductDefinition(instance, id, storeSpecificId, type, enabled, payouts);
//}

void* (*old_GetTargetImpl)(void* useslot, int searchRadius, int targetActorType);
void* GetTargetImpl(void* useslot, int searchRadius, int targetActorType) {
    if(aimbot){
        LOGI("Aimbot Enable");
        if(*(int*)((uint64_t)useslot + 0x78) == 2){
            return old_GetTargetImpl(useslot, 99999, targetActorType);
        }else{
            return old_GetTargetImpl(useslot, searchRadius, targetActorType);
        }
    }
    else{
        LOGI("Aimbot Disable");
        return old_GetTargetImpl(useslot, searchRadius, targetActorType);
    }
}

bool (*old_SetVisible)(void *instance, void* actor, bool bVisible, bool forceSync);
bool SetVisible(void *instance, void* actor, bool bVisible, bool forceSync){
    if (instance != NULL) {
        if(maphack){
            LOGI("MapHack Enable");
            return old_SetVisible(instance, actor, true, forceSync);
        }
    }
    return old_SetVisible(instance, actor, bVisible, forceSync);
}

bool (*old_IsHostProfile)(void *instance);
bool IsHostProfile(void *instance){
    if (instance != NULL) {
        if(history){
            LOGI("showHistory Enable");
            return true;
        }
    }
    return old_IsHostProfile(instance);
}

void (*old_ShowHeroCampFrame)(void *instance, bool bShow);
void ShowHeroCampFrame(void *instance, bool bShow){
    if (instance != NULL) {
        if(heroinfo){
            return old_ShowHeroCampFrame(instance, true);
        }
    }
    return old_ShowHeroCampFrame(instance, bShow);
}

void (*old_ShowHeroHpInfo)(void *instance, bool bShow);
void ShowHeroHpInfo(void *instance, bool bShow){
    if (instance != NULL) {
        if(heroinfo){
            return old_ShowHeroHpInfo(instance, true);
        }
    }
    return old_ShowHeroHpInfo(instance, bShow);
}

void (*old_ShowSkillStateInfo)(void *instance, bool bShow);
void ShowSkillStateInfo(void *instance, bool bShow){
    if (instance != NULL) {
        if(heroinfo){
            return old_ShowSkillStateInfo(instance, true);
        }
    }
    return old_ShowSkillStateInfo(instance, bShow);
}

void (*old_ShowReviveTimeInfo)(void *instance, bool bShow);
void ShowReviveTimeInfo(void *instance, bool bShow){
    if (instance != NULL) {
        if(heroinfo){
            return old_ShowReviveTimeInfo(instance, true);
        }
    }
    return old_ShowReviveTimeInfo(instance, bShow);
}

void (*old_ShowHeroInfo)(void *instance, void* unknow1, void* unknow2, bool bShow);
void ShowHeroInfo(void *instance, void* unknow1, void* unknow2, bool bShow){
    if (instance != NULL) {
        if(heroinfo){
            return old_ShowHeroInfo(instance, unknow1, unknow2, true);
        }
    }
    return old_ShowHeroInfo(instance, unknow1, unknow2, bShow);
}

void Hooks() {
    HOOK("0x26CAC48", GetTargetImpl, old_GetTargetImpl);
    HOOK("0x2D3E7E4", SetVisible, old_SetVisible);
    HOOK("0x21AF064", IsHostProfile, old_IsHostProfile);

    HOOK("0x29C9610", ShowHeroHpInfo, old_ShowHeroHpInfo);
    HOOK("0x29C9748", ShowSkillStateInfo, old_ShowSkillStateInfo);
    HOOK("0x29C987C", ShowReviveTimeInfo, old_ShowReviveTimeInfo);

    HOOK("0x266A840", ShowHeroInfo, old_ShowHeroInfo);
}

#endif //ZYCHEATS_SGUYS_FUNCTIONS_H
