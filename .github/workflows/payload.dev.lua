#!/usr/bin/env lua
--[===[crc32 is garbage]===]
local args = {...}
if #args == 0 then return print(table.concat({
    "Hello there!",
    "",
    "You have in your possession the text of my Master's thesis.",
    "It is distributed as a polyglot file that's simultaneously",
    "a Lua script, a PDF document, and a ZIP archive.",
    "",
    "I trust you'll figure out what to do next.",
    "",
    "~ viluon",
}, "\n")) end

local path_to_self = debug.traceback():match "^.*\n%s*(.-):%d+: in main chunk\n"
if args[1] ~= "--shell" then
    print("hint: $ head -n 21 " .. path_to_self)
    return
end

local f = io.open(path_to_self, "rb")
if not f then error("I could not read itself from " .. tostring(path_to_self)) end
local self_zip = f:read "*a"
f:close()

local function portable_load(str, env)
    str = str:gsub("[$`|!&?@]", {
        ["$"] = "return ",
        ["`"] = "function",
        ["|"] = "local ",
        ["!"] = "end",
        ["&"] = " then ",
        ["?"] = "a.bit",
        ["@"] = "self.",
    })
    local f_env = setmetatable(env, { __index = _G })
    return setfenv
        and setfenv(loadstring(str), f_env)
        or load(str, "loaded", "t", f_env)
end

--[[
%    the bitop library below is licensed under MIT, copyright AlberTajuelo
%    repository here: https://github.com/AlberTajuelo/bitop-lua
%    thanks for your work, AlberTajuelo!
%]]
local bitop = (loadstring or load)(table.concat({
"|a={_TYPE='module',_NAME='bitop.funcs',_VERSION='1.0-0'}|b=math.floor",
"|c=2^32",
"|d=c-1",
"|` e(f)|g={}|h=setmetatable({},g)`",
"g:__index(i)|j=f(i)h[i]=j",
"$j !",
"$h !",
"|` k(h,l)|` m(n,o)|p,q=0,1",
"while n~=0 and o~=0 do |r,s=n%l,o%l",
"p=p+h[r][s]*q",
"n=(n-r)/l",
"o=(o-s)/l",
"q=q*l !",
"p=p+(n+o)*q",
"$p !",
"$m !",
"|` t(h)|u=k(h,2^1)|v=e(`(n)",
"$e(`(o)$u(n,o)!)!)$k(v,2^(h.n or 1))!",
"` a.tobit(w)$w%2^32 !",
"a.bxor=t{[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0},n=4}|x=a.bxor",
"` a.bnot(n)$d-n !",
"|y=a.bnot",
"` a.band(n,o)$(n+o-x(n,o))/2 !",
"|z=a.band",
"` a.bor(n,o)$d-z(d-n,d-o)!",
"|A=a.bor",
"|B,C",
"` a.rshift(n,D)if D<0&$B(n,-D)!",
"$b(n%2^32/2^D)!",
"C=a.rshift",
"` a.lshift(n,D)if D<0&$C(n,-D)!",
"$n*2^D%2^32 !",
"B=a.lshift",
"` a.tohex(w,E)E=E or 8",
"|F",
"if E<=0&if E==0&$''!",
"F=true",
"E=-E !",
"w=z(w,16^E-1)$('%0'..E..(F and'X'or'x')):format(w)!",
"|G=a.tohex",
"` a.extract(E,H,I)I=I or 1",
"$z(C(E,H),2^I-1)!",
"|J=a.extract",
"` a.replace(E,j,H,I)I=I or 1",
"|K=2^I-1",
"j=z(j,K)|L=y(B(K,H))$z(E,L)+B(j,H)!",
"|M=a.replace",
"` a.bswap(w)|n=z(w,0xff)w=C(w,8)local",
"o=z(w,0xff)w=C(w,8)|N=z(w,0xff)w=C(w,8)|O=z(w,0xff)$",
"B(B(B(n,8)+o,8)+N,8)+O !",
"|P=a.bswap",
"` a.rrotate(w,D)D=D%32",
"|Q=z(w,2^D-1)$C(w,D)+B(Q,32-D)!",
"|R=a.rrotate",
"` a.lrotate(w,D)$R(w,-D)!",
"|S=a.lrotate",
"a.rol=a.lrotate",
"a.ror=a.rrotate",
"` a.arshift(w,D)|T=C(w,D)if w>=0x80000000&T=T+B(2^D-1,32-D)!",
"$T !",
"|U=a.arshift",
"` a.btest(w,V)$z(w,V)~=0 !",
"?32={}|` W(w)$(-1-w)%c !",
"?32.bnot=W",
"|` X(n,o,N,...)|T",
"if o&n=n%c",
"o=o%c",
"T=x(n,o)if N&T=X(T,N,...)!",
"$T elseif n&$n%c else $0 ! !",
"?32.bxor=X",
"|` Y(n,o,N,...)|T",
"if o&n=n%c",
"o=o%c",
"T=(n+o-x(n,o))/2",
"if N&T=Y(T,N,...)!",
"$T elseif n&$n%c else $d ! !",
"?32.band=Y",
"|` Z(n,o,N,...)|T",
"if o&n=n%c",
"o=o%c",
"T=d-z(d-n,d-o)if N&T=Z(T,N,...)!",
"$T elseif n&$n%c else $0 ! !",
"?32.bor=Z",
"` ?32.btest(...)$Y(...)~=0 !",
"` ?32.lrotate(w,D)$S(w%c,D)!",
"` ?32.rrotate(w,D)$R(w%c,D)!",
"` ?32.lshift(w,D)if D>31 or D<-31&$0 !",
"$B(w%c,D)!",
"` ?32.rshift(w,D)if D>31 or D<-31&$0 !",
"$C(w%c,D)!",
"` ?32.arshift(w,D)w=w%c",
"if D>=0&if D>31&$w>=0x80000000 and d or 0 else |T=C(w,D)if",
"w>=0x80000000&T=T+B(2^D-1,32-D)!",
"$T ! else $B(w,-D)! !",
"` ?32.extract(w,H,...)|I=...or 1",
"if H<0 or H>31 or I<0 or H+I>32&error'out of range'!",
"w=w%c",
"$J(w,H,...)!",
"` ?32.replace(w,j,H,...)|I=...or 1",
"if H<0 or H>31 or I<0 or H+I>32&error'out of range'!",
"w=w%c",
"j=j%c",
"$M(w,j,H,...)!",
"?={}` ?.tobit(w)w=w%c",
"if w>=0x80000000&w=w-c !",
"$w !",
"|_=?.tobit",
"` ?.tohex(w,...)$G(w%c,...)!",
"` ?.bnot(w)$_(y(w%c))!",
"|` a0(n,o,N,...)if N&$",
"a0(a0(n,o),N,...)elseif o&$_(A(n%c,o%c))else $_(n)! !",
"?.bor=a0",
"|` a1(n,o,N,...)if N&$",
"a1(a1(n,o),N,...)elseif o&$_(z(n%c,o%c))else $_(n)! !",
"?.band=a1;|` a2(n,o,N,...)if N&",
"$a2(a2(n,o),N,...)elseif o&",
"$_(x(n%c,o%c))else $_(n)! !",
"?.bxor=a2",
"` ?.lshift(w,E)$_(B(w%c,E%32))!",
"` ?.rshift(w,E)$_(C(w%c,E%32))!",
"` ?.arshift(w,E)$_(U(w%c,E%32))!",
"` ?.rol(w,E)$_(S(w%c,E%32))!",
"` ?.ror(w,E)$_(R(w%c,E%32))!",
"` ?.bswap(w)$_(P(w%c))!",
"$a",
}, "\n"):gsub("[$`|!&?]", {
    ["$"] = "return ",
    ["`"] = "function",
    ["|"] = "local ",
    ["!"] = "end",
    ["&"] = " then ",
    ["?"] = "a.bit",
}))()

local inflate_src = table.concat({"|a={}|bit=bit32 or bit",
"a.band=bit.band",
"a.rshift=bit.rshift",
"` ?stream_init(b)|c={file=b,buf=nil,len=nil,pos=1,b=0,n=0}`",
"c:flushb(d)@n=@n-d",
"@b=bit.rshift(@b,d)!",
"` c:next_byte()if @pos>@len&",
"@buf=@file:read(4096)@len=@buf:len()@pos=1 !",
"|e=@pos",
"@pos=e+1",
"$@buf:byte(e)!",
"` c:peekb(d)while",
"@n<d do @b=@b+bit.lshift(self:next_byte(),@n)@n=@n+8 !",
"$bit.band(@b,bit.lshift(1,d)-1)!",
"` c:getb(d)|f=c:peekb(d)@n=@n-d",
"@b=bit.rshift(@b,d)$f !",
"` c:getv(g,d)|h=g[c:peekb(d)]local",
"i=bit.band(h,15)|f=bit.rshift(h,4)@n=@n-i",
"@b=bit.rshift(@b,i)$f !",
"` c:close()if @file&@file:close()! !",
"if type(b)==\"string\"&c.file=nil",
"c.buf=b else c.buf=b:read(4096)!",
"c.len=c.buf:len()$c !",
"|` j(k)|l=#k",
"|m=1",
"|n={}|o={}for p=1,l do |q=k[p]if q>m&m=q !",
"n[q]=(n[q]or 0)+1 !",
"|table={}|r=0",
"n[0]=0",
"for p=1,m do r=(r+(n[p-1]or 0))*2",
"o[p]=r !",
"for p=1,l do |i=k[p]or 0",
"if i>0&|h=(p-1)*16+i",
"|r=o[i]|s=0",
"for t=1,i do s=s+bit.lshift(bit.band(1,bit.rshift(r,t-1)),i-t)!",
"for t=0,2^m-1,2^i do table[t+s]=h !",
"o[i]=o[i]+1 ! !",
"$table,m !",
"|` u(v,c,w,x,y,z)|A",
"repeat A=c:getv(y,w)if A<256&table.insert(v,A)elseif A>256&|m=0",
"|B=3",
"|C=1",
"if A<265&B=B+A-257 elseif A<285&",
"m=bit.rshift(A-261,2)B=B+bit.lshift(bit.band(A-261,3)+4,m)else B=258 !",
"if m>0&B=B+c:getb(m)!",
"|D=c:getv(z,x)if D<4&C=C+D else",
"m=bit.rshift(D-2,1)C=C+bit.lshift(bit.band(D,1)+2,m)C=C+c:getb(m)!",
"|E=#v-C+1",
"while B>0 do table.insert(v,v[E])E=E+1",
"B=B-1 ! ! until A==256 !",
"|` F(v,c)|G={17,18,19,1,9,8,10,7,11,6,12,5,13,4,14,3,15,2,16}local",
"H=257+c:getb(5)|I=1+c:getb(5)|J=4+c:getb(4)|k={}for p=1,J do",
"|D=c:getb(3)k[G[p]]=D !",
"for p=J+1,19 do k[G[p]]=0 !",
"|K,L=j(k)|p=1",
"while p<=H+I do |D=c:getv(K,L)if D<16&k[p]=D",
"p=p+1 elseif D<19&|M={2,3,7}|N=M[D-15]|O=0",
"|d=3+c:getb(N)if D==16&O=k[p-1]elseif D==18&d=d+8 !",
"for t=1,d do k[p]=O",
"p=p+1 ! else",
"error(\"wrong entry in depth table for literal/length alphabet: \"..D)! !",
"|P={}for p=1,H do table.insert(P,k[p])!",
"|y,w=j(P)|Q={}for p=H+1,#k do table.insert(Q,k[p])!",
"|z,x=j(Q)u(v,c,w,x,y,z)!",
"|` R(v,c)|S={144,112,24,8}|T={8,9,7,8}|k={}for p=1,4 do",
"|q=T[p]for",
"t=1,S[p]do table.insert(k,q)! !",
"|y,w=j(k)k={}for p=1,32 do k[p]=5 !",
"|z,x=j(k)u(v,c,w,x,y,z)!",
"|` U(v,c)c:flushb(bit.band(c.n,7))|i=c:getb(16)if c.n>0&",
"error(\"Unexpected.. should be zero remaining bits in buffer.\")!",
"|L=c:getb(16)if bit.bxor(i,L)~=65535&error(\"LEN and NLEN don't match\")!",
"for p=1,i do table.insert(v,c:next_byte())! !",
"` a.main(c)|V,type",
"|W={}repeat |X",
"V=c:getb(1)type=c:getb(2)if type==0&U(W,c)elseif type==1&",
"R(W,c)elseif type==2&",
"F(W,c)else error(\"unsupported block type\")! until V==1",
"c:flushb(bit.band(c.n,7))$W !",
"|Y",
"` a.crc32(Z,_)if not Y&Y={}for p=0,255 do |a0=p",
"for t=1,8 do",
"a0=bit.bxor(bit.rshift(a0,1),bit.band(0xedb88320,bit.bnot(bit.band(a0,1)-1)))!",
"Y[p]=a0 ! !",
"_=bit.bnot(_ or 0)for p=1,#Z do",
"|O=Z:byte(p)_=bit.bxor(Y[bit.bxor(O,bit.band(_,0xff))],bit.rshift(_,8))!",
"_=bit.bnot(_)if _<0&_=_+4294967296 !",
"$_ !",
"$a",
}, "\n")

local inflate = portable_load(inflate_src, { bit32 = bitop.bit32 })()

local zzlib_src = table.concat({"|unpack=table.unpack or unpack",
"|a=inflate",
"|b=tonumber(_VERSION:match(\"^Lua (.*)\"))",
"|c={}|` d(e)|f={}|g=#e",
"|h=1",
"|i=1",
"while g>0 do |j=g>=2048 and 2048 or g",
"|k=string.char(unpack(e,h,h+j-1))h=h+j",
"g=g-j",
"|l=1",
"while f[l]do k=f[l]..k",
"f[l]=nil",
"l=l+1 !",
"if l>i&i=l !",
"f[l]=k !",
"|m=\"\"for l=1,i do if f[l]&m=f[l]..m ! !",
"$m !",
"|` n(o)|p,q,r,s=o.buf:byte(1,4)if p~=31 or q~=139&",
"error(\"invalid gzip header\")!",
"if r~=8&error(\"only deflate format is supported\")!",
"o.pos=11",
"if a.band(s,4)~=0&|t,u=o.buf.byte(o.pos,o.pos+1)|v=u*256+t",
"o.pos=o.pos+v+2 !",
"if a.band(s,8)~=0&|h=o.buf:find(\"\000\",o.pos)o.pos=h+1 !",
"if a.band(s,16)~=0&|h=o.buf:find(\"\000\",o.pos)o.pos=h+1 !",
"if a.band(s,2)~=0&o.pos=o.pos+2 !",
"|w=d(a.main(o))local",
"x=o:getb(8)+256*(o:getb(8)+256*(o:getb(8)+256*o:getb(8)))o:close()if",
"x~=a.crc32(w)&error(\"checksum verification failed\")!",
"$w !",
"|` y(k)|z=1",
"|A=0",
"for l=1,#k do |B=k:byte(l)z=(z+B)%65521",
"A=(A+z)%65521 !",
"$A*65536+z !",
"|` C(o)|D=o.buf:byte(1)|s=o.buf:byte(2)if(D*256+s)%31~=0&",
"error(\"zlib header check bits are incorrect\")!",
"if a.band(D,15)~=8&error(\"only deflate format is supported\")!",
"if a.rshift(D,4)~=7&error(\"unsupported window size\")!",
"if a.band(s,32)~=0&error(\"preset dictionary not implemented\")!",
"o.pos=3",
"|w=d(a.main(o))local",
"E=((o:getb(8)*256+o:getb(8))*256+o:getb(8))*256+o:getb(8)o:close()if",
"E~=y(w)&error(\"checksum verification failed\")!",
"$w !",
"|` F(G,H,x)|o=?stream_init(G)o.pos=H",
"|w=d(a.main(o))if x and x~=a.crc32(w)&error(\"checksum verification failed\")!",
"$w !",
"` c.gunzipf(I)|J,K=io.open(I,\"rb\")if not J&$nil,K !",
"$n(?stream_init(J))!",
"` c.gunzip(m)$n(?stream_init(m))!",
"` c.inflate(m)$C(?stream_init(m))!",
"|` L(m,h)|M,N=m:byte(h,h+1)$N*256+M !",
"|` O(m,h)|M,N,B,P=m:byte(h,h+3)$((P*256+B)*256+N)*256+M !",
"|` Q(G,R)if O(G,R)~=0x02014b50&$!",
"|S=L(G,R+10)~=0",
"|x=O(G,R+16)|T=L(G,R+28)|U=G:sub(R+46,R+45+T)|H=O(G,R+42)+1",
"R=R+46+T+L(G,R+30)+L(G,R+32)if O(G,H)~=0x04034b50&",
"error(\"invalid |header signature\")!",
"|g=O(G,H+18)|V=L(G,H+28)H=H+30+T+V",
"$R,U,H,g,S,x !",
"` c.files(G)",
"for off=0,math.min(#G-22,65535) do",
"|R=#G-21-off",
"if O(G,R)==0x06054b50&",
"|W=O(G,R+16)+1",
"$Q,G,W",
"!",
"!",
"error\"invalid ZIP file\"",
"!",
"` c.unzip(G,X,Y)if type(X)==\"number\"&$F(G,X,Y)!",
"|I=X",
"for Z,U,H,g,S,x in c.files(G)do if U==I&|w",
"if not S&w=G:sub(H,H+g-1)else w=F(G,H,x)!",
"$w ! !",
"error(\"file '\"..I..\"' not found in ZIP archive\")!",
"$c",
}, "\n")

local zzlib = portable_load(zzlib_src, { inflate = inflate })()

local function normalize_path(path)
    local result = {}
    for segment in path:gmatch "([^/]*)/?" do
        if segment == ".." then
            if #result > 0 then table.remove(result) end
        elseif segment ~= "" and segment ~= "." then
            table.insert(result, segment)
        end
    end

    return table.concat(result, "/")
end

local function combine(a, b)
    return normalize_path(
        b:sub(1, 1) == "/" and b or a .. "/" .. b
    )
end

local cwd = ""
local commands
commands = setmetatable({
    help = function()
        print("available commands:")
        for cmd in pairs(commands) do
            print("  " .. cmd)
        end
    end;
    ls = function(path)
        local wd = combine(cwd, path)
        local slashed = wd .. "/"

        print(string.format("%10s %7s %8s %s", "size", "method", "crc32", "name"))
        for _, name, offset, size, packed, crc in zzlib.files(self_zip) do
            local is_in_subtree = wd == "" or slashed == name:sub(1, #slashed)
            local suffix = wd == "" and name or name:sub(#slashed + 1)

            if is_in_subtree and suffix ~= "" and not suffix:sub(1, #suffix - 1):find "/" then
                local method = packed and "Deflate" or "Store"
                print(string.format("%10d %7s %08x %s", size, method, crc, suffix))
            end
        end
    end;
    cat = function(path)
        local loc = combine(cwd, path)
        for _, name in zzlib.files(self_zip) do
            if loc == "" or loc == name or loc .. "/" == name then
                if loc == "" or name:sub(-1, -1) == "/" then
                    print("cat: " .. path .. ": Is a directory")
                    return
                end

                print(zzlib.unzip(self_zip, name))
                return
            end
        end

        print("cat: " .. path .. ": No such file or directory")
    end;
    cd = function(path)
        local loc = combine(cwd, path)
        for _, name in zzlib.files(self_zip) do
            if loc == "" or name == loc .. "/" then
                cwd = loc
                return
            end
        end
    end;
    about = function()
        print(table.concat({
            "My work on P4 began with an internship at Intel. I joined",
            "the XFG team to work on the p4c compiler back in spring",
            "of 2022. I was looking for possible topics for a Master's",
            "thesis ahead of my final year. My manager at the time,",
            "Viktor Puš, got in touch with a team developing the P4",
            "Insight product, led by Adam Reynolds. The P4I people were",
            "very interested in the Language Server Protocol, but didn't",
            "have the resources to actually start developing a P4 server.",
        }, "\n"))
        if not io.read() then return end
        print(table.concat({
            "I talked to Adam Reynolds and Tim Roberts of the P4I team.",
            "We quickly decided to join forces on the project. Certain",
            "key points were laid out from the very start: it had to be",
            "open source to gain any market share and it was to be",
            "developed in Rust to support a WebAssembly target (as well",
            "as attract more open source contributors.)",
        }, "\n"))
    end;
    copyright = function()
        print(table.concat({
            "this executable thesis uses code by:",
            "- Sam Hocevar & François Galea (https://github.com/zerkman/zzlib)",
            "   (c) under the terms of the WTFPL",
            "- AlberTajuelo (https://github.com/AlberTajuelo/bitop-lua)",
            "   (c) under the terms of the MIT license",
            "",
            "thanks to these authors and other contributors",
            "for making open source even better.",
        }, "\n"))
    end;
    whoami = function()
        print "dearreader"
    end;
    pwd = function()
        print("/" .. cwd)
    end;
}, {
    __index = function(t, k)
        print("unknown command:", k)
        return function() end
    end;
})

commands.h = commands.help
commands["?"] = commands.help

print "welcome to the zip shell, have a look around!\n"

while true do
    io.write(cwd .. "> ")
    local ok, cmd = pcall(io.read)
    if not ok or type(cmd) ~= "string" then break end
    local cmd, args = cmd:match "^(%S+)%s*(.-)$"
    if cmd then commands[cmd](args) end
end

print()
