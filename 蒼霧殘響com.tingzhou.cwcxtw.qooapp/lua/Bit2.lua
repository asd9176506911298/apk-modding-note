-- Sample
-- 0x0F & 2
-- bit2._and(0x0F,2)
-- 0x0F | 2
-- bit2._or(0x0F,2)
-- 0x0F ^ 2
-- bit2._xor(0x0F,2)
-- !0x0F 
-- bit2._not(0x0F)
-- 8<<2( negative number supported if -8<<2)
-- bit2._lshift(8,2) 【bit2._lshift(-8,2) 】
-- local str 	=	'你好' 
-- local allBytes = bit2.charCodeAt(str)

local utf8 = {}
bit2={}
bit2.data32={}
for i=1,32 do  
    bit2.data32[i]=2^(32-i)  
end 
local toby = string.byte
function utf8.charbytes(s,i) 
   i = i or 1
   local c = string.byte(s,i)  
   if c > 0 and c <= 127 then 
      return 1
   elseif c >= 194 and c <= 223 then  
      return 2
   elseif c >= 224 and c <= 239 then  
      return 3
   elseif c >= 240 and c <= 244 then  
      return 4
   end
   return 1
end  
function bit2.d2b(arg)
    local   tr,c={},arg<0 
    if c then arg=0-arg end
    for i=1,32 do  
        if arg >= bit2.data32[i] then  
          tr[i]=1  
          arg=arg-bit2.data32[i]  
        else  
          tr[i]=0  
        end  
    end
    if c then
      tr = bit2._bnot(tr); 
      tr = bit2.b2d(tr)+ 1
      tr = bit2.d2b(tr)
    end 
    return   tr  
end

function bit2.b2d(arg,neg)
    local nr=0
    if arg[1]==1 and neg==true then
        arg = bit2._bnot(arg); 
        nr = bit2.b2d(arg)  + 1
        nr = 0 - nr;
    else 
      for i=1,32 do  
          if arg[i] ==1  then  
            nr=nr+2^(32-i)  
          end  
      end   
    end 
    return  nr  
end  
function bit2._and(a,b)  
    local   op1=bit2.d2b(a)  
    local   op2=bit2.d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if op1[i]==1 and op2[i]==1  then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  bit2.b2d(r,true)  
end

function bit2._or(a,b)  
    local op1=bit2.d2b(a)  
    local op2=bit2.d2b(b)  
    local r={}
    for i=1,32 do  
        if  op1[i]==1 or   op2[i]==1   then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  bit2.b2d(r,true)  
end

function bit2._xor(a,b)  
    local   op1=bit2.d2b(a)  
    local   op2=bit2.d2b(b)  
    local   r={}   
    for i=1,32 do  
        if op1[i]==op2[i] then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  bit2.b2d(r,true)  
end

local switch = {
	[1]		=	function (s,pos)
		local c1  =toby(s, pos);
		return c1
	end,
	[2]		=	function (s,pos)
	
		local c1  =toby(s, pos);
		local c2  =toby(s, pos+1);
		
		local int1 	=	bit2._and(0x1F,c1)
		local int2 	=	bit2._and(0x3F,c2)  
		return 	bit2._or(bit2._lshift(int1,6),int2)
	end,
	[3]		=	function (s,pos)

		local c1  =toby(s, pos);
		local c2  =toby(s, pos+1);
		local c3  =toby(s, pos+2);
		
		local int1 	=	bit2._and(0x0F,c1)
		local int2 	=	bit2._and(0x3F,c2)  
		local int3 	=	bit2._and(0x3F,c3)  
		
		local o2 = bit2._or(bit2._lshift(int1,12), bit2._lshift(int2,6))
		local dt =	bit2._or(o2,int3);
		
		return dt 
	end,
	[4]		=	function (s,pos)
		local c1  = toby(s, pos);
		local c2  = toby(s, pos+1);
		local c3  = toby(s, pos+2);
		local c4  = toby(s, pos+3);
		
		local int1 	=	bit2._and(0x0F,c1)
		local int2 	=	bit2._and(0x3F,c2)  
		local int3 	=	bit2._and(0x3F,c3)  
		local int4 	=	bit2._and(0x3F,c4)  

		local o2 = bit2._or(bit2._lshift(int1,18), bit2._lshift(int2,12))
		local o3 = bit2._or(o2,bit2._lshift(int3,6))
		local o4 = bit2._or(o3,int4) 
		return o4  
	end,
}

function bit2._bnot(op1)
   local   r={}  
    for i=1,32 do  
        if op1[i]==1 then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end
    return r
end

function bit2._not(a)  
    local op1=bit2.d2b(a)  
    local r=bit2._bnot(op1)
    return bit2.b2d(r,true)  
end
  
function bit2.charCodeAt(s)
	local pos,int,H,L=1,0,0,0
	local slen = string.len(s)
	local allByte 	= {} 
	while pos <= slen do
	 local tLen 	=	utf8.charbytes(s,pos) 
	 if tLen >=1 and tLen<=4 then
		if tLen == 4 then  
			int = switch[4](s,pos )  
			-- according to this formula ,the 4 bytes utf8 word needs calculate in this way
			-- H = Math.floor((c-0x10000) / 0x400)+0xD800  
			-- L = (c - 0x10000) % 0x400 + 0xDC00
			H = math.floor((int-0x10000) / 0x400)+0xD800
			L = (int - 0x10000) % 0x400 + 0xDC00  
			table.insert(allByte,H)	 	
			table.insert(allByte,L)	 	
		else
			int = switch[tLen](s,pos )
			table.insert(allByte,int)			
		end 
	 end 
	  pos = pos + tLen
	end
	return allByte;
end
 
function bit2._rshift(a,n)  
        local r=0
        if a < 0 then
          r=0-bit2._frshift(0-a,n); 
        elseif a>= 0 then 
          r=bit2._frshift(a,n);
        end 
        return r
end
function bit2._frshift(a,n) 
    local op1=bit2.d2b(a)  
    local r=bit2.d2b(0)  
    local left = 32 -n 
    if n < 32 and n > 0 then  
      for i=left,1,-1 do  
        r[i+n]=op1[i]  
      end   
    end
    return bit2.b2d(r)        
end
function bit2._lshift(a,n)
    if n == 0 then return a end
    local  op1 = bit2.d2b(a)  
    local  r = bit2.d2b(0)    
    if n < 32 and n > 0 then   
      for i=n,31 do
        r[i-n+1]=op1[i+1]  
      end     
    end      
    return bit2.b2d(r,true)
end

return bit2