JNCollection={}

function JNCollection:new(_ID,_Level,_StarRare,_Achieve,_Juexing,_SkillLV,_Professional,_Rank,_Like)
    -- statements
    Collect = {}
    setmetatable(Collect, self)
    self.__index = self
    Collect.ID=_ID
    Collect.Level=_Level
    Collect.Star=_StarRare
    Collect.Achieve=_Achieve
    Collect.Juexing=_Juexing
    Collect.SkillKLV=_SkillLV
    Collect.Professional=_Professional
    Collect.Rank=_Rank
    Collect.Like=_Like
    Collect.Obj= nil
    return Collect
end

function JNCollection:newRoleData(_InfoTab)
    RoleData = {}
    setmetatable(RoleData,self)
    self.__index = self
    RoleData.ID=tonumber(_InfoTab[1])
    RoleData.Name=_InfoTab[2]
    RoleData.Level=tonumber(_InfoTab[4])
    RoleData.Star=tonumber(_InfoTab[3])
    RoleData.Achieve=tonumber(_InfoTab[1])
    RoleData.SkillKLV=tonumber(_InfoTab[6])
    RoleData.Rank=tonumber(_InfoTab[17])
    RoleData.Icon=_InfoTab[9]
    return RoleData
end

return JNCollection