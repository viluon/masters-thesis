
-- lua source code compression algorithm
-- based on LZW, but using only ASCII that doesn't need escaping in Lua strings

local source_chars =
    "\n \"#%'()*+,-./0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{}~"

local allowed_chars =
    "\t !#%'()*+,-./0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ[$]^_abcdefghijklmnopqrstuvwxyz{}~&?@`"
-- | is also ok but we use it to introduce a dictionary string
-- || is reset dictionary

local source_char_lookup = {}
for i = 1, #source_chars do
    local ch = source_chars:sub(i, i)
    source_char_lookup[ch] = i
    source_char_lookup[i] = ch
end

local allowed_char_lookup = {}
for i = 1, #allowed_chars do
    local ch = allowed_chars:sub(i, i)
    allowed_char_lookup[ch] = i
    allowed_char_lookup[i] = ch
end

local function luz(t)
    -- convert the input
    local input = {}
    for i = 1, #t do
        local ch = t:sub(i, i)
        local n = source_char_lookup[ch]
        if not n then
            error("unexpected char in input: " .. ch, 2)
        end
        input[i] = ch
    end

    local dict = {}
    local dict_size = #source_chars
    -- init the dictionary
    for i = 1, #source_chars do
        local ch = source_chars:sub(i, i)
        dict[ch] = allowed_chars:sub(i, i)
    end

    local output = {}
    local w = ""
    for i = 1, #input do
        local ch = input[i]
        if dict[w .. ch] then
            w = w .. ch
        else
            output[#output + 1] = dict[w]
            dict_size = dict_size + 1
            local offset = (dict_size - #source_chars) % #allowed_chars + 1
            dict[w .. ch] =
                ("|"):rep(math.ceil((dict_size - #source_chars) / #allowed_chars)) ..
                allowed_chars:sub(offset, offset)
            w = ch
        end
    end

    if w ~= "" then
        output[#output + 1] = dict[w]
    end

    print(dict_size, "/", #source_chars + #allowed_chars)

    return table.concat(output)
end

local function unluz(t)
    local dict = {}
    local dict_size, entry, w = #source_chars, "", t:sub(1, 1)
    local result = {w}
    for i = 1, #source_chars do
        local ch = allowed_chars:sub(i, i)
        dict[ch] = source_chars:sub(i, i)
    end

    local i = 2
    local prefix = "|"
    while i <= #t do
        local c = t:sub(i, i)
        local ch = c
        while c == "|" do
            i = i + 1
            c = t:sub(i, i)
            ch = ch .. c
        end

        if dict[ch] then
            entry = dict[ch]
        elseif (#ch - 1) * #allowed_chars + allowed_char_lookup[ch:sub(-1, -1)] == dict_size - #source_chars + 1 then
            entry = w .. w:sub(1, 1)
            if #ch - 1 > prefix then
                prefix = prefix .. "|"
            end
        else
            error("unexpected char in input: " .. ch, 2)
        end

        result[#result + 1] = entry
        dict_size = dict_size + 1
        local offset = dict_size - #source_chars
        dict[prefix .. allowed_chars:sub(offset, offset)] = w .. entry:sub(1, 1)
        w = entry
        i = i + 1
    end

    return table.concat(result)
end

local src = "local function x(a) local b = a[#a + 1 ^ 0 - 2 * 4]; return b:sub(0x1, 1) end"
local src2 = table.concat({
    "local a={_TYPE='module',_NAME='bitop.funcs',_VERSION='1.0-0'}local b=math.floor",
    "local c=2^32",
    "local d=c-1",
    "local function e(f)local g={}local h=setmetatable({},g)function",
    "g:__index(i)local j=f(i)h[i]=j",
    "return j end",
    "return h end",
    "local function k(h,l)local function m(n,o)local p,q=0,1",
    "while n~=0 and o~=0 do local r,s=n%l,o%l",
    "p=p+h[r][s]*q",
    "n=(n-r)/l",
    "o=(o-s)/l",
    "q=q*l end",
    "p=p+(n+o)*q",
    "return p end",
    "return m end",
    "local function t(h)local u=k(h,2^1)local v=e(function(n)",
    "return e(function(o)return u(n,o)end)end)return k(v,2^(h.n or 1))end",
    "function a.tobit(w)return w%2^32 end",
    "a.bxor=t{[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0},n=4}local x=a.bxor",
    "function a.bnot(n)return d-n end",
    "local y=a.bnot",
    "function a.band(n,o)return(n+o-x(n,o))/2 end",
    "local z=a.band",
    "function a.bor(n,o)return d-z(d-n,d-o)end",
    "local A=a.bor",
    "local B,C",
    "function a.rshift(n,D)if D<0 then return B(n,-D)end",
    "return b(n%2^32/2^D)end",
    "C=a.rshift",
    "function a.lshift(n,D)if D<0 then return C(n,-D)end",
    "return n*2^D%2^32 end",
    "B=a.lshift",
    "function a.tohex(w,E)E=E or 8",
    "local F",
    "if E<=0 then if E==0 then return''end",
    "F=true",
    "E=-E end",
    "w=z(w,16^E-1)return('%0'..E..(F and'X'or'x')):format(w)end",
    "local G=a.tohex",
    "function a.extract(E,H,I)I=I or 1",
    "return z(C(E,H),2^I-1)end",
    "local J=a.extract",
    "function a.replace(E,j,H,I)I=I or 1",
    "local K=2^I-1",
    "j=z(j,K)local L=y(B(K,H))return z(E,L)+B(j,H)end",
    "local M=a.replace",
    "function a.bswap(w)local n=z(w,0xff)w=C(w,8)local",
    "o=z(w,0xff)w=C(w,8)local N=z(w,0xff)w=C(w,8)local O=z(w,0xff)return",
    "B(B(B(n,8)+o,8)+N,8)+O end",
    "local P=a.bswap",
    "function a.rrotate(w,D)D=D%32",
    "local Q=z(w,2^D-1)return C(w,D)+B(Q,32-D)end",
    "local R=a.rrotate",
    "function a.lrotate(w,D)return R(w,-D)end",
    "local S=a.lrotate",
    "a.rol=a.lrotate",
    "a.ror=a.rrotate",
    "function a.arshift(w,D)local T=C(w,D)if w>=0x80000000 then T=T+B(2^D-1,32-D)end",
    "return T end",
    "local U=a.arshift",
    "function a.btest(w,V)return z(w,V)~=0 end",
    "a.bit32={}local function W(w)return(-1-w)%c end",
    "a.bit32.bnot=W",
    "local function X(n,o,N,...)local T",
    "if o then n=n%c",
    "o=o%c",
    "T=x(n,o)if N then T=X(T,N,...)end",
    "return T elseif n then return n%c else return 0 end end",
    "a.bit32.bxor=X",
    "local function Y(n,o,N,...)local T",
    "if o then n=n%c",
    "o=o%c",
    "T=(n+o-x(n,o))/2",
    "if N then T=Y(T,N,...)end",
    "return T elseif n then return n%c else return d end end",
    "a.bit32.band=Y",
    "local function Z(n,o,N,...)local T",
    "if o then n=n%c",
    "o=o%c",
    "T=d-z(d-n,d-o)if N then T=Z(T,N,...)end",
    "return T elseif n then return n%c else return 0 end end",
    "a.bit32.bor=Z",
    "function a.bit32.btest(...)return Y(...)~=0 end",
    "function a.bit32.lrotate(w,D)return S(w%c,D)end",
    "function a.bit32.rrotate(w,D)return R(w%c,D)end",
    "function a.bit32.lshift(w,D)if D>31 or D<-31 then return 0 end",
    "return B(w%c,D)end",
    "function a.bit32.rshift(w,D)if D>31 or D<-31 then return 0 end",
    "return C(w%c,D)end",
    "function a.bit32.arshift(w,D)w=w%c",
    "if D>=0 then if D>31 then return w>=0x80000000 and d or 0 else local T=C(w,D)if",
    "w>=0x80000000 then T=T+B(2^D-1,32-D)end",
    "return T end else return B(w,-D)end end",
    "function a.bit32.extract(w,H,...)local I=...or 1",
    "if H<0 or H>31 or I<0 or H+I>32 then error'out of range'end",
    "w=w%c",
    "return J(w,H,...)end",
    "function a.bit32.replace(w,j,H,...)local I=...or 1",
    "if H<0 or H>31 or I<0 or H+I>32 then error'out of range'end",
    "w=w%c",
    "j=j%c",
    "return M(w,j,H,...)end",
    "a.bit={}function a.bit.tobit(w)w=w%c",
    "if w>=0x80000000 then w=w-c end",
    "return w end",
    "local _=a.bit.tobit",
    "function a.bit.tohex(w,...)return G(w%c,...)end",
    "function a.bit.bnot(w)return _(y(w%c))end",
    "local function a0(n,o,N,...)if N then return",
    "a0(a0(n,o),N,...)elseif o then return _(A(n%c,o%c))else return _(n)end end",
    "a.bit.bor=a0",
    "local function a1(n,o,N,...)if N then return",
    "a1(a1(n,o),N,...)elseif o then return _(z(n%c,o%c))else return _(n)end end",
    "a.bit.band=a1;local function a2(n,o,N,...)if N then",
    "return a2(a2(n,o),N,...)elseif o then",
    "return _(x(n%c,o%c))else return _(n)end end",
    "a.bit.bxor=a2",
    "function a.bit.lshift(w,E)return _(B(w%c,E%32))end",
    "function a.bit.rshift(w,E)return _(C(w%c,E%32))end",
    "function a.bit.arshift(w,E)return _(U(w%c,E%32))end",
    "function a.bit.rol(w,E)return _(S(w%c,E%32))end",
    "function a.bit.ror(w,E)return _(R(w%c,E%32))end",
    "function a.bit.bswap(w)return _(P(w%c))end",
    "return a",
}, "\n")
local src2 = table.concat({
    'local a={}local bit=bit32 or bit',
    'a.band=bit.band',
    'a.rshift=bit.rshift',
    'function a.bitstream_init(b)local c={file=b,buf=nil,len=nil,pos=1,b=0,n=0}function',
    'c:flushb(d)self.n=self.n-d',
    'self.b=bit.rshift(self.b,d)end',
    'function c:next_byte()if self.pos>self.len then',
    'self.buf=self.file:read(4096)self.len=self.buf:len()self.pos=1 end',
    'local e=self.pos',
    'self.pos=e+1',
    'return self.buf:byte(e)end',
    'function c:peekb(d)while',
    'self.n<d do self.b=self.b+bit.lshift(self:next_byte(),self.n)self.n=self.n+8 end',
    'return bit.band(self.b,bit.lshift(1,d)-1)end',
    'function c:getb(d)local f=c:peekb(d)self.n=self.n-d',
    'self.b=bit.rshift(self.b,d)return f end',
    'function c:getv(g,d)local h=g[c:peekb(d)]local',
    'i=bit.band(h,15)local f=bit.rshift(h,4)self.n=self.n-i',
    'self.b=bit.rshift(self.b,i)return f end',
    'function c:close()if self.file then self.file:close()end end',
    'if type(b)=="string"then c.file=nil',
    'c.buf=b else c.buf=b:read(4096)end',
    'c.len=c.buf:len()return c end',
    'local function j(k)local l=#k',
    'local m=1',
    'local n={}local o={}for p=1,l do local q=k[p]if q>m then m=q end',
    'n[q]=(n[q]or 0)+1 end',
    'local table={}local r=0',
    'n[0]=0',
    'for p=1,m do r=(r+(n[p-1]or 0))*2',
    'o[p]=r end',
    'for p=1,l do local i=k[p]or 0',
    'if i>0 then local h=(p-1)*16+i',
    'local r=o[i]local s=0',
    'for t=1,i do s=s+bit.lshift(bit.band(1,bit.rshift(r,t-1)),i-t)end',
    'for t=0,2^m-1,2^i do table[t+s]=h end',
    'o[i]=o[i]+1 end end',
    'return table,m end',
    'local function u(v,c,w,x,y,z)local A',
    'repeat A=c:getv(y,w)if A<256 then table.insert(v,A)elseif A>256 then local m=0',
    'local B=3',
    'local C=1',
    'if A<265 then B=B+A-257 elseif A<285 then',
    'm=bit.rshift(A-261,2)B=B+bit.lshift(bit.band(A-261,3)+4,m)else B=258 end',
    'if m>0 then B=B+c:getb(m)end',
    'local D=c:getv(z,x)if D<4 then C=C+D else',
    'm=bit.rshift(D-2,1)C=C+bit.lshift(bit.band(D,1)+2,m)C=C+c:getb(m)end',
    'local E=#v-C+1',
    'while B>0 do table.insert(v,v[E])E=E+1',
    'B=B-1 end end until A==256 end',
    'local function F(v,c)local G={17,18,19,1,9,8,10,7,11,6,12,5,13,4,14,3,15,2,16}local',
    'H=257+c:getb(5)local I=1+c:getb(5)local J=4+c:getb(4)local k={}for p=1,J do',
    'local D=c:getb(3)k[G[p]]=D end',
    'for p=J+1,19 do k[G[p]]=0 end',
    'local K,L=j(k)local p=1',
    'while p<=H+I do local D=c:getv(K,L)if D<16 then k[p]=D',
    'p=p+1 elseif D<19 then local M={2,3,7}local N=M[D-15]local O=0',
    'local d=3+c:getb(N)if D==16 then O=k[p-1]elseif D==18 then d=d+8 end',
    'for t=1,d do k[p]=O',
    'p=p+1 end else',
    'error("wrong entry in depth table for literal/length alphabet: "..D)end end',
    'local P={}for p=1,H do table.insert(P,k[p])end',
    'local y,w=j(P)local Q={}for p=H+1,#k do table.insert(Q,k[p])end',
    'local z,x=j(Q)u(v,c,w,x,y,z)end',
    'local function R(v,c)local S={144,112,24,8}local T={8,9,7,8}local k={}for p=1,4 do',
    'local q=T[p]for',
    't=1,S[p]do table.insert(k,q)end end',
    'local y,w=j(k)k={}for p=1,32 do k[p]=5 end',
    'local z,x=j(k)u(v,c,w,x,y,z)end',
    'local function U(v,c)c:flushb(bit.band(c.n,7))local i=c:getb(16)if c.n>0 then',
    'error("Unexpected.. should be zero remaining bits in buffer.")end',
    'local L=c:getb(16)if bit.bxor(i,L)~=65535 then error("LEN and NLEN don\'t match")end',
    'for p=1,i do table.insert(v,c:next_byte())end end',
    'function a.main(c)local V,type',
    'local W={}repeat local X',
    'V=c:getb(1)type=c:getb(2)if type==0 then U(W,c)elseif type==1 then',
    'R(W,c)elseif type==2 then',
    'F(W,c)else error("unsupported block type")end until V==1',
    'c:flushb(bit.band(c.n,7))return W end',
    'local Y',
    'function a.crc32(Z,_)if not Y then Y={}for p=0,255 do local a0=p',
    'for t=1,8 do',
    'a0=bit.bxor(bit.rshift(a0,1),bit.band(0xedb88320,bit.bnot(bit.band(a0,1)-1)))end',
    'Y[p]=a0 end end',
    '_=bit.bnot(_ or 0)for p=1,#Z do',
    'local O=Z:byte(p)_=bit.bxor(Y[bit.bxor(O,bit.band(_,0xff))],bit.rshift(_,8))end',
    '_=bit.bnot(_)if _<0 then _=_+4294967296 end',
    'return _ end',
    'return a',
}, "\n")

local src2 = table.concat({
'local unpack=table.unpack or unpack',
'local a=inflate',
'local b=tonumber(_VERSION:match("^Lua (.*)"))',
'local c={}local function d(e)local f={}local g=#e',
'local h=1',
'local i=1',
'while g>0 do local j=g>=2048 and 2048 or g',
'local k=string.char(unpack(e,h,h+j-1))h=h+j',
'g=g-j',
'local l=1',
'while f[l]do k=f[l]..k',
'f[l]=nil',
'l=l+1 end',
'if l>i then i=l end',
'f[l]=k end',
'local m=""for l=1,i do if f[l]then m=f[l]..m end end',
'return m end',
'local function n(o)local p,q,r,s=o.buf:byte(1,4)if p~=31 or q~=139 then',
'error("invalid gzip header")end',
'if r~=8 then error("only deflate format is supported")end',
'o.pos=11',
'if a.band(s,4)~=0 then local t,u=o.buf.byte(o.pos,o.pos+1)local v=u*256+t',
'o.pos=o.pos+v+2 end',
'if a.band(s,8)~=0 then local h=o.buf:find("\0",o.pos)o.pos=h+1 end',
'if a.band(s,16)~=0 then local h=o.buf:find("\0",o.pos)o.pos=h+1 end',
'if a.band(s,2)~=0 then o.pos=o.pos+2 end',
'local w=d(a.main(o))local',
'x=o:getb(8)+256*(o:getb(8)+256*(o:getb(8)+256*o:getb(8)))o:close()if',
'x~=a.crc32(w)then error("checksum verification failed")end',
'return w end',
'local function y(k)local z=1',
'local A=0',
'for l=1,#k do local B=k:byte(l)z=(z+B)%65521',
'A=(A+z)%65521 end',
'return A*65536+z end',
'local function C(o)local D=o.buf:byte(1)local s=o.buf:byte(2)if(D*256+s)%31~=0 then',
'error("zlib header check bits are incorrect")end',
'if a.band(D,15)~=8 then error("only deflate format is supported")end',
'if a.rshift(D,4)~=7 then error("unsupported window size")end',
'if a.band(s,32)~=0 then error("preset dictionary not implemented")end',
'o.pos=3',
'local w=d(a.main(o))local',
'E=((o:getb(8)*256+o:getb(8))*256+o:getb(8))*256+o:getb(8)o:close()if',
'E~=y(w)then error("checksum verification failed")end',
'return w end',
'local function F(G,H,x)local o=a.bitstream_init(G)o.pos=H',
'local w=d(a.main(o))if x and x~=a.crc32(w)then error("checksum verification failed")end',
'return w end',
'function c.gunzipf(I)local J,K=io.open(I,"rb")if not J then return nil,K end',
'return n(a.bitstream_init(J))end',
'function c.gunzip(m)return n(a.bitstream_init(m))end',
'function c.inflate(m)return C(a.bitstream_init(m))end',
'local function L(m,h)local M,N=m:byte(h,h+1)return N*256+M end',
'local function O(m,h)local M,N,B,P=m:byte(h,h+3)return((P*256+B)*256+N)*256+M end',
'local function Q(G,R)if O(G,R)~=0x02014b50 then return end',
'local S=L(G,R+10)~=0',
'local x=O(G,R+16)local T=L(G,R+28)local U=G:sub(R+46,R+45+T)local H=O(G,R+42)+1',
'R=R+46+T+L(G,R+30)+L(G,R+32)if O(G,H)~=0x04034b50 then',
'error("invalid local header signature")end',
'local g=O(G,H+18)local V=L(G,H+28)H=H+30+T+V',
'return R,U,H,g,S,x end',
'function c.files(G)',
'for off=0,math.min(#G-22,65535) do',
'local R=#G-21-off',
'if O(G,R)==0x06054b50 then',
'local W=O(G,R+16)+1',
'return Q,G,W',
'end',
'end',
'error"invalid ZIP file"',
'end',
'function c.unzip(G,X,Y)if type(X)=="number"then return F(G,X,Y)end',
'local I=X',
'for Z,U,H,g,S,x in c.files(G)do if U==I then local w',
'if not S then w=G:sub(H,H+g-1)else w=F(G,H,x)end',
'return w end end',
'error("file \'"..I.."\' not found in ZIP archive")end',
'return c',
}, "\n")


-- local encoded = luz(src)
-- print(#src, src)
-- print(#encoded, encoded)
-- local decoded = unluz(encoded)
-- print(#decoded, decoded)
-- print(decoded == src)
-- print(encoded)

--- Search for compressing substitutions.
--- @param t string
local function subst_search(t)
    local results = {}
    local needles = {}
    for len = 1, 20 do
        for i = 1, #t - len + 1 do
            local needle = t:sub(i, i + len - 1)
            if not needles[needle] then
                needles[needle] = true
                local escaped = needle:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])", "%%%1")
                local _, count = string.gsub(t, escaped, "")
                if count > 1 then
                    results[#results + 1] = {needle, count}
                end
            end
        end
    end

    table.sort(results, function(a, b) return (#a[1] - 1) * a[2] > (#b[1] - 1) * b[2] end)
    return results
end

-- subst_search(src)

local replaced = src2
    :gsub("return ?", "$")
    :gsub("function", "`")
    :gsub("local ", "|")
    :gsub("end", "!")
    :gsub(" ?then ?", "&")
    :gsub("a%.bit", "?")
    :gsub("self%.", "@")

print(replaced:gsub("[$`|!&?]", {
    ["$"] = "return ",
    ["`"] = "function",
    ["|"] = "local ",
    ["!"] = "end",
    ["&"] = " then ",
    ["?"] = "a.bit",
    ["@"] = "self.",
}))

-- local results = subst_search(replaced)
-- for i = 1, 5 do
--     print(string.format("%2d. %2db (%2dx) %q", i, #results[i][1], results[i][2], results[i][1]))
--     print("    - saving " .. (#results[i][1] - 1) * (results[i][2] - 1) .. " bytes")
-- end

-- print(#src2, #replaced)

local s = "table.concat({"
for line in replaced:gmatch "([^\n]*)\n?" do
    s = s .. string.format("%q,\n", line)
end
s = s .. '}, "\\n")'
print(s)
print(#s, #src2)
