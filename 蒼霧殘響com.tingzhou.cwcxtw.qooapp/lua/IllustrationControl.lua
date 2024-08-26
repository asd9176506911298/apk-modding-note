IllustrationControl = {}
require("UI/ViewModel/IllustrationViewModel")  ---图鉴
require("LocalData/GuidechapterLocalData")

function IllustrationControl.InitIllustrationData(data)
    if data.manual then
        for i, v in pairs(data.manual) do
            IllustrationViewModel.RewardList[v] = v
        end
    end
    ---图鉴红点监听
    IllustrationViewModel.CheckRot()
    IllustrationControl.Init()
end

---初始化
function IllustrationControl.Init()
    SkillAtlasControl.InitData()
    TeamAtlasControl.Init()
    OriginalControl.Init()
    ArtAtlasControl.Init()
end

return IllustrationControl