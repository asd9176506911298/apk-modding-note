

JNStrTool={}

--角色基础属性里的分割 ,没有[] 有lv和start ,等级上限
--读字符串 按照{}切割添加到一个表 ,  新建数组记录{}之间的元素下标 ,依次替换  替换完毕后把表的元素依次组合  
--然后按照[]切割 替换为对应技能等级的系数
--参数 ,公式 ,施法者引用 
--字符串拼接成公式 ,返回 tempTabStr{  "1.5*" ,"lv" }
function JNStrTool.StrToScript(Str,_c1,_c2  )
   if _c1==nil then
      _c1="{"
      _c2="}"
   end



  --切割出等级上限 第一个逗号之前的
  -- print(Str)
  
     --临时存储当前切割出来的字符串
     local tempTabStr = {}
     --纪录分隔符标记的下标
     local tempCutIndex = {}
     --分隔符标记的下标最大值
     local tempCutMax = 0
     
     local tempStr =""
     local tempChar = nil
     --是否切割状态
     local tempIsCut = false
     --如果一个切割符都没有
     local tempNullCut = true
     

  --遍历字符串 直到遇到分隔符
     local stringLen = string.len(Str)
     
     for i=1,stringLen do

        tempChar=string.sub(Str ,i,i) 
           
        --如果是最后一位直接添加 如果最后一位是 } 移除
        if i==stringLen then
           -- statements
           if tempChar~=_c2 then
            tempStr=tempStr..tempChar
           end
          
           
           table.insert(tempTabStr ,tempStr) 
       --    print("gongshibufenjieshu"..tempStr)
           tempStr=""
           -- statements
        elseif tempChar== _c1 then
           --不为空则添加到表
         
           if tempStr~="" then
                 table.insert(tempTabStr ,tempStr) 
             --    print("gongshibufen"..tempStr)
                 tempStr=""
           end
           tempIsCut=true
           tempNullCut=false
           
           -- 分割符记录下标
        elseif tempChar== _c2 then
           --切割结束 纪录下标
           table.insert(tempCutIndex,i)
           tempCutMax=tempCutMax+1
           tempIsCut=false 
          
           if tempStr~="" then
        --    print("gongshibufen"..tempStr)
                 table.insert(tempTabStr ,tempStr) 
                 tempStr=""
           end
        
        else
           
                 -- 添加到临时字符串
           tempStr=tempStr..tempChar
           
        end

     end--遍历字符串 直到遇到分隔符

  --记录公式
  return tempTabStr

end


--字符串切割 第一个是 , 等分隔符 第二个是需要切的字符串 返回顺序表
function JNStrTool.strSplit(delimeter, str)
  -- print(str)
  local find, sub, insert = string.find, string.sub, table.insert
  local res = {}
  local start, start_pos, end_pos = 1, 1, 1
  while true do
      start_pos, end_pos = find(str, delimeter, start, true)
      if not start_pos then
          break
      end
      insert(res, sub(str, start, start_pos - 1))
      start = end_pos + 1  
  end
 
table.insert(res, sub(str,start))
  if res==nil or res==0 then
   res={0}
  end
 
  return res
end
--字符串切割2  根据传入的多个切割符号切割 ,返回多维数组 字符串 多维切割符号,次要切割符
function JNStrTool.StrArrArr( arrDlm ,str  ,dlm )
  local tempArrArrReturn = {}--用于返回的最终效果

  --先切割成多维
  local tempTab = JNStrTool.strSplit(arrDlm, str)
  local tempStr = ""
  local tempTabStr = {}
  
     --遍历,遇到切割符号就加入新的,否则字符继续往下加
     for k,v in pairs(tempTab) do
        tempTabStr={} --值为空
     
           local stringLen = string.len(tempTab[k])
  
              for i=1,stringLen do
        
           
                 local tempChar=string.sub(tempTab[k] ,i,i) 
                       
                    --如果是最后一位直接添加
                       if i==stringLen then
                       -- 判断最后一位是不是切割符
                       for a,b in pairs(dlm) do
                          if dlm[a]==tempChar then
                                if tempStr~="" then
                            
                                table.insert(tempTabStr ,tempStr) 
                                tempStr=""
                               
                             
                                end
                                isdlm=true
                             break
                          end
                       end
                       --
                       if isdlm==false then
                          tempStr=tempStr..tempChar
                       end
                      
                             if tempStr~="" then
                           table.insert(tempTabStr ,tempStr) 
                             tempStr=""
                             -- statements
                             break
                       end
                       end
                       local isdlm = false
                       
                       --遇到任意切割符
                       for a,b in pairs(dlm) do
                          if dlm[a]==tempChar then
                                if tempStr~="" then
                          
                                table.insert(tempTabStr ,tempStr) 
                                tempStr=""
                               
                             
                                end
                                isdlm=true
                             break
                          end
                          -- statements
                       end--for ab
                       --没有和任意切割符匹配则添加到临时字符串
                       if isdlm==false then
                          tempStr=tempStr..tempChar
                       end
                      
                 
              end--for stringLen
       
        tempArrArrReturn[k]=tempTabStr
     end
return tempArrArrReturn
  
end

--解析出本回合特效表 {{{a1,延迟},{a2,延迟}}, {b1,b2}} a和b同步 a2延迟a1的时间播放
function JNStrTool.SubAtkEffectId(_Str)
     --print( "特效表===================================="  .._Str)
     local ReturnAtkEff={}
     --按照分号切割, 
     local FenStr=JNStrTool.strSplit(";",_Str)
     --按照逗号切割
     for key, value in pairs(FenStr) do
  --     print("分号切割后" ..FenStr[key])
      local DouStr= JNStrTool.strSplit(",", FenStr[key]) 
      --用下划线分割
      local XiaStr={}
      for a, b in pairs(DouStr) do
    --   print("dou号切割后" ..DouStr[a])
      local  TempXiaStr=JNStrTool.strSplit("_", DouStr[a]) 
        for x, y in pairs(TempXiaStr) do
            --print(TempXiaStr[x])
        end
         table.insert(XiaStr,TempXiaStr)
      end
     
      table.insert(ReturnAtkEff,XiaStr)
     end
     
     return ReturnAtkEff
end

--数字缩略
function JNStrTool.numberAbbr(value)
   local tb = {}
   local len  = 0
   local num = ""
   for utfChar in string.gmatch(value, "[%z\1-\127\194-\244][\128-\191]*") do
	   table.insert(tb, utfChar)
   end
   len = #tb
    if len < 6 then
       return tostring(value)
   elseif len >= 6 and len <= 7 then --6-7位
      for index = 1, #tb - 3 do
         num = num..tostring(tb[index])
      end
      num = num ..MgrLanguageData.GetLanguageByKey("ui_suojin_k")
      return num
   else
      for index = 1, #tb - 6 do
         num = num..tostring(tb[index])
      end
      num = num ..MgrLanguageData.GetLanguageByKey("ui_suojin_m")
      return num
    end
end

return JNStrTool