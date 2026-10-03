local cloneref=cloneref or clonereference or function(x)return x end
local function service(name)return cloneref(game:GetService(name))end
local Players=service("Players")
local UserInputService=service("UserInputService")
local TweenService=service("TweenService")
local RunService=service("RunService")
local HttpService=service("HttpService")
local CoreGui=service("CoreGui")
local Workspace=service("Workspace")
local GuiService=service("GuiService")
local LocalPlayer=Players.LocalPlayer

local requestFn=request or http_request or (syn and syn.request)
local clipFn=setclipboard or toclipboard
local assetFn=getcustomasset or getsynasset
local hasFiles=(writefile and readfile and isfile and isfolder and makefolder) and true or false
local isStudio=RunService:IsStudio()

local DirH,DirV=Enum.FillDirection.Horizontal,Enum.FillDirection.Vertical
local AlignL,AlignC,AlignR=Enum.HorizontalAlignment.Left,Enum.HorizontalAlignment.Center,Enum.HorizontalAlignment.Right
local AlignT,AlignM,AlignB=Enum.VerticalAlignment.Top,Enum.VerticalAlignment.Center,Enum.VerticalAlignment.Bottom
local AutoX,AutoY,AutoXY=Enum.AutomaticSize.X,Enum.AutomaticSize.Y,Enum.AutomaticSize.XY
local XLeft,XRight,XCenter=Enum.TextXAlignment.Left,Enum.TextXAlignment.Right,Enum.TextXAlignment.Center
local WReg,WMed,WSemi,WBold=Enum.FontWeight.Regular,Enum.FontWeight.Medium,Enum.FontWeight.SemiBold,Enum.FontWeight.Bold
local MouseBtn,TouchIn,MouseMove=Enum.UserInputType.MouseButton1,Enum.UserInputType.Touch,Enum.UserInputType.MouseMovement
local EaseBack,EaseQuad,EaseLinear,EaseSine=Enum.EasingStyle.Back,Enum.EasingStyle.Quad,Enum.EasingStyle.Linear,Enum.EasingStyle.Sine

local R_EL,R_WIN,R_SM=6,10,5
local FONT_FAMILY="rbxasset://fonts/families/GothamSSm.json"
local function font(weight)return Font.new(FONT_FAMILY,weight or WMed)end
local clamp=math.clamp

local Prism={Windows={},Version="1.0.0"}

local Themes={}
local function addTheme(name,t)
	local out={}
	for k,v in pairs(t)do
		out[k]=typeof(v)=="string" and Color3.fromHex(v) or v
	end
	out.Name=name
	Themes[name]=out
	return out
end

addTheme("Midnight",{Background="#0d0e13",Panel="#13151c",Element="#1a1d27",Hover="#242839",Stroke="#2b3042",Text="#eceef6",Sub="#8b92a9",Accent="#6c8dff",AccentText="#ffffff",Good="#3ecf8e",Warn="#f5b73b",Bad="#f0566a"})
addTheme("Light",{Background="#e9ecf2",Panel="#f6f7fa",Element="#ffffff",Hover="#e8ebf3",Stroke="#d5d9e4",Text="#15171e",Sub="#6a7186",Accent="#3b6cf6",AccentText="#ffffff",Good="#1fa971",Warn="#d98b0b",Bad="#d93c52"})
addTheme("Ember",{Background="#120b0a",Panel="#1a1110",Element="#251816",Hover="#33211e",Stroke="#41302c",Text="#f6ece8",Sub="#a8897f",Accent="#ff7a45",AccentText="#1a0d08",Good="#58d68d",Warn="#f7c548",Bad="#f0566a"})
addTheme("Forest",{Background="#0a110e",Panel="#101a15",Element="#16231c",Hover="#1f3028",Stroke="#2a3f35",Text="#e7f3ec",Sub="#84a392",Accent="#3ddc84",AccentText="#06150d",Good="#3ddc84",Warn="#f5b73b",Bad="#f0566a"})
addTheme("Orchid",{Background="#0f0b16",Panel="#17111f",Element="#201829",Hover="#2c2239",Stroke="#3a2e4b",Text="#f0e9f8",Sub="#9a89b0",Accent="#b57cff",AccentText="#ffffff",Good="#3ecf8e",Warn="#f5b73b",Bad="#f0566a"})
addTheme("Ocean",{Background="#071218",Panel="#0c1b23",Element="#12262f",Hover="#1b3642",Stroke="#25454f",Text="#e3f4fa",Sub="#7ba4b3",Accent="#22c1e6",AccentText="#041015",Good="#3ecf8e",Warn="#f5b73b",Bad="#f0566a"})
addTheme("Mono",{Background="#0b0b0b",Panel="#121212",Element="#1a1a1a",Hover="#262626",Stroke="#333333",Text="#f2f2f2",Sub="#8f8f8f",Accent="#f2f2f2",AccentText="#0b0b0b",Good="#3ecf8e",Warn="#f5b73b",Bad="#f0566a"})

local currentTheme=Themes.Midnight
local themeListeners={}
local bindings=setmetatable({},{__mode="k"})

local function tween(inst,time,props,style,dir)
	local t=TweenService:Create(inst,TweenInfo.new(time or 0.2,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
	t:Play()
	return t
end

local function bind(inst,prop,key)
	local b=bindings[inst]
	if not b then b={} bindings[inst]=b end
	b[prop]=key
	inst[prop]=currentTheme[key]
end

local function unbind(inst,prop)
	local b=bindings[inst]
	if b then b[prop]=nil end
end

local function paint(inst,prop,key,time)
	local b=bindings[inst]
	if not b then b={} bindings[inst]=b end
	b[prop]=key
	if time then tween(inst,time,{[prop]=currentTheme[key]}) else inst[prop]=currentTheme[key] end
end

local defaults={
	Frame={BorderSizePixel=0},
	ScrollingFrame={BorderSizePixel=0,BackgroundTransparency=1,ScrollBarThickness=0,ElasticBehavior=Enum.ElasticBehavior.Never,CanvasSize=UDim2.new()},
	TextLabel={BorderSizePixel=0,BackgroundTransparency=1,FontFace=font(WMed),TextSize=15,TextColor3=Color3.new(1,1,1)},
	TextButton={BorderSizePixel=0,AutoButtonColor=false,Text="",BackgroundColor3=Color3.new(1,1,1),FontFace=font(WMed),TextSize=15},
	TextBox={BorderSizePixel=0,BackgroundTransparency=1,FontFace=font(WMed),TextSize=15,ClearTextOnFocus=false,Text="",TextColor3=Color3.new(1,1,1)},
	ImageLabel={BorderSizePixel=0,BackgroundTransparency=1},
	ImageButton={BorderSizePixel=0,BackgroundTransparency=1,AutoButtonColor=false},
	UIListLayout={SortOrder=Enum.SortOrder.LayoutOrder},
}

local function create(class,props,children)
	local inst=Instance.new(class)
	local d=defaults[class]
	if d then for k,v in pairs(d)do inst[k]=v end end
	local parent
	if props then
		for k,v in pairs(props)do
			if k=="Theme" then
				for p,key in pairs(v)do bind(inst,p,key)end
			elseif k=="Parent" then
				parent=v
			else
				inst[k]=v
			end
		end
	end
	if children then
		for _,c in pairs(children)do
			if c then c.Parent=inst end
		end
	end
	if parent then inst.Parent=parent end
	return inst
end

local function corner(r)return create("UICorner",{CornerRadius=UDim.new(0,r)})end
local function pad(l,t,r,b)
	return create("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingTop=UDim.new(0,t or l),PaddingRight=UDim.new(0,r or l),PaddingBottom=UDim.new(0,b or t or l)})
end
local function stroke(key,thickness,transparency)
	return create("UIStroke",{Theme={Color=key},Thickness=thickness or 1,Transparency=transparency or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local function list(dir,padding,ha,va)
	return create("UIListLayout",{FillDirection=dir or DirV,Padding=UDim.new(0,padding or 0),HorizontalAlignment=ha or AlignL,VerticalAlignment=va or AlignT})
end
local function label(text,size,weight,key,props)
	local p={Text=text or "",TextSize=size or 15,FontFace=font(weight),TextXAlignment=XLeft,Theme={TextColor3=key or "Text"}}
	if props then for k,v in pairs(props)do p[k]=v end end
	return create("TextLabel",p)
end

local function safe(fn,...)
	if type(fn)~="function" then return end
	local ok,err=pcall(fn,...)
	if not ok then warn("[Prism] "..tostring(err)) end
end

local function toHex(c)
	return string.format("%02X%02X%02X",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5))
end

local function copyText(text)
	if not clipFn then return false end
	return (pcall(clipFn,text))
end

local function setThemeInternal(name)
	local t=Themes[name]
	if not t then return false end
	currentTheme=t
	for inst,b in pairs(bindings)do
		if inst:IsDescendantOf(game) then
			for p,key in pairs(b)do
				if t[key] then tween(inst,0.3,{[p]=t[key]}) end
			end
		else
			bindings[inst]=nil
		end
	end
	for _,fn in pairs(themeListeners)do safe(fn,name)end
	return true
end

local Glyphs={home="⌂",settings="⚙",user="☺",users="☻",star="★",heart="♥",sword="⚔",bolt="⚡",target="◎",eye="◉",info="ℹ",search="⌕",list="☰",grid="▦",play="▶",check="✓",close="✕",plus="+",minus="−",link="↗",copy="❐",folder="▤",code="‹›",globe="◍",shield="◈",crown="♛",gem="◆",flag="⚑",map="⌖",music="♪",sun="☀",moon="☾",cloud="☁",key="⚿",lock="⚷",bell="◔",mouse="⌖",cog="⚙",tool="⚒",chart="▥"}

local function isAsset(s)
	return type(s)=="string" and (s:sub(1,13)=="rbxassetid://" or s:sub(1,11)=="rbxthumb://")
end

local function iconNode(icon,size,key,tint)
	if icon==nil or icon=="" then return nil end
	if type(icon)=="number" then icon="rbxassetid://"..icon end
	if isAsset(icon) then
		local img=create("ImageLabel",{Size=UDim2.fromOffset(size,size),Image=icon})
		if tint then bind(img,"ImageColor3",key or "Sub") end
		return img,"ImageColor3"
	end
	local glyph=Glyphs[string.lower(icon)]
	if not glyph then
		local n=utf8.len(icon)
		if n and n<=2 then glyph=icon else glyph=string.upper(string.sub(icon,1,1)) end
	end
	local lab=create("TextLabel",{Size=UDim2.fromOffset(size,size),Text=glyph,TextSize=math.floor(size*0.9),FontFace=font(WBold),TextXAlignment=XCenter,Theme={TextColor3=key or "Sub"}})
	return lab,"TextColor3"
end

local function checkMark(parent,size)
	local s=size/20
	local holder=create("Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=parent})
	local function bar(cx,cy,len,rot)
		return create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(cx*s,cy*s),Size=UDim2.fromOffset(math.max(2,2*s),len*s),Rotation=rot,BackgroundTransparency=1,Theme={BackgroundColor3="AccentText"},Parent=holder},{corner(1)})
	end
	return holder,{bar(6.75,11.75,5.4,-45),bar(11.75,10,10.2,43)}
end

local gui,root,rootScale,layers
local uiScale=1
local notifHolder

local function viewport()
	local cam=Workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280,720)
end

local function applyScale(s)
	uiScale=s
	if rootScale then
		rootScale.Scale=s
		root.Size=UDim2.fromScale(1/s,1/s)
	end
end

local function guiParent()
	if gethui then
		local ok,res=pcall(gethui)
		if ok and res then return res end
	end
	if not isStudio then
		local ok=pcall(function()return CoreGui.Name end)
		if ok then return CoreGui end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function ensureGui()
	if gui and gui.Parent then return end
	notifHolder=nil
	gui=Instance.new("ScreenGui")
	gui.Name=HttpService:GenerateGUID(false)
	gui.ResetOnSpawn=false
	gui.IgnoreGuiInset=true
	gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder=2000
	pcall(function()
		if protectgui then protectgui(gui) elseif syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	gui.Parent=guiParent()
	rootScale=Instance.new("UIScale")
	root=create("Frame",{Name="Root",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=gui},{rootScale})
	layers={}
	for i,name in ipairs({"window","float","overlay","notif"})do
		layers[name]=create("Frame",{Name=name,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=i,Parent=root})
	end
	applyScale(uiScale)
end

local function pointerPos(input)
	local inset=GuiService:GetGuiInset()
	return Vector2.new(input.Position.X+inset.X,input.Position.Y+inset.Y)
end

local drags={}
local function startDrag(input,onMove,onStop)
	local d={input=input,move=onMove,stop=onStop}
	drags[d]=true
	return d
end

UserInputService.InputChanged:Connect(function(i)
	for d in pairs(drags)do
		if i==d.input or (i.UserInputType==MouseMove and d.input.UserInputType==MouseBtn) then
			d.move(i)
		end
	end
end)

UserInputService.InputEnded:Connect(function(i)
	for d in pairs(drags)do
		if i==d.input or (i.UserInputType==MouseBtn and d.input.UserInputType==MouseBtn) then
			drags[d]=nil
			if d.stop then d.stop() end
		end
	end
end)

local function hoverable(inst,prop,normalKey,hoverKey)
	inst.MouseEnter:Connect(function()paint(inst,prop,hoverKey,0.12)end)
	inst.MouseLeave:Connect(function()paint(inst,prop,normalKey,0.12)end)
end

local function makeDraggable(handle,target,onFinish,margin)
	margin=margin or 20
	handle.InputBegan:Connect(function(input)
		if input.UserInputType~=MouseBtn and input.UserInputType~=TouchIn then return end
		local startPointer=pointerPos(input)
		local center=(target.AbsolutePosition+target.AbsoluteSize*target.AnchorPoint)/uiScale
		local moved=false
		startDrag(input,function(i)
			local delta=(pointerPos(i)-startPointer)/uiScale
			if delta.Magnitude>5 then moved=true end
			if not moved then return end
			local vp=viewport()/uiScale
			target.Position=UDim2.fromOffset(clamp(center.X+delta.X,margin,vp.X-margin),clamp(center.Y+delta.Y,margin,vp.Y-margin))
		end,function()
			if onFinish then onFinish(moved) end
		end)
	end)
end

local function openPopup(anchor,width,height,build,onClose)
	ensureGui()
	local closed=false
	local catcher=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Parent=layers.overlay})
	local ap=anchor.AbsolutePosition/uiScale
	local as=anchor.AbsoluteSize/uiScale
	local vp=viewport()/uiScale
	local x=clamp(ap.X+as.X-width,8,math.max(8,vp.X-width-8))
	local below=ap.Y+as.Y+6
	local flip=below+height>vp.Y-8 and ap.Y-6-height>8
	if not flip then below=math.min(below,math.max(8,vp.Y-height-8)) end
	local box=create("Frame",{AnchorPoint=Vector2.new(0,flip and 1 or 0),Position=UDim2.fromOffset(x,flip and ap.Y-6 or below),Size=UDim2.fromOffset(width,0),ClipsDescendants=true,Active=true,Theme={BackgroundColor3="Panel"},Parent=layers.overlay},{corner(8),stroke("Stroke",1,0.1)})
	local inner=create("Frame",{BackgroundTransparency=1,Size=UDim2.fromOffset(width,height),AnchorPoint=Vector2.new(0,flip and 1 or 0),Position=UDim2.fromScale(0,flip and 1 or 0),Parent=box})
	tween(box,0.22,{Size=UDim2.fromOffset(width,height)})
	local api={Frame=inner}
	function api.Close()
		if closed then return end
		closed=true
		tween(box,0.15,{Size=UDim2.fromOffset(width,0)})
		task.delay(0.16,function()
			catcher:Destroy()
			box:Destroy()
		end)
		if onClose then safe(onClose) end
	end
	catcher.Activated:Connect(api.Close)
	build(inner,api)
	return api
end

local function smallButton(parent,text,variant,callback,size)
	variant=variant or "Secondary"
	local filled=variant=="Primary" or variant=="Danger"
	local bgKey=variant=="Primary" and "Accent" or variant=="Danger" and "Bad" or "Hover"
	local scale=create("UIScale",{Scale=1})
	local btn=create("TextButton",{Size=size or UDim2.fromOffset(100,34),Theme={BackgroundColor3=bgKey},Parent=parent},{corner(R_EL),scale})
	local lab=label(text,14,WSemi,filled and "AccentText" or "Text",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Parent=btn})
	btn.MouseEnter:Connect(function()
		if filled then tween(btn,0.12,{BackgroundTransparency=0.12}) else paint(btn,"BackgroundColor3","Stroke",0.12) end
	end)
	btn.MouseLeave:Connect(function()
		if filled then tween(btn,0.12,{BackgroundTransparency=0}) else paint(btn,"BackgroundColor3","Hover",0.12) end
	end)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType==MouseBtn or i.UserInputType==TouchIn then tween(scale,0.08,{Scale=0.95}) end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType==MouseBtn or i.UserInputType==TouchIn then tween(scale,0.2,{Scale=1},EaseBack) end
	end)
	btn.Activated:Connect(function()safe(callback)end)
	return btn,lab
end

local function makeDialog(cfg)
	ensureGui()
	cfg=cfg or {}
	local vp=viewport()/uiScale
	local width=math.min(cfg.Width or 360,vp.X-32)
	local dim=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Active=true,Parent=layers.overlay})
	local scale=create("UIScale",{Scale=0.9})
	local card=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(width,0),AutomaticSize=AutoY,Active=true,Theme={BackgroundColor3="Panel"},Parent=dim},{corner(R_WIN),stroke("Stroke",1,0.1),pad(18),list(DirV,12),scale})
	local api={}
	local closed=false
	local head=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,LayoutOrder=1,Parent=card},{list(DirH,10,AlignL,AlignM)})
	local ic=iconNode(cfg.Icon,22,"Accent",true)
	if ic then ic.LayoutOrder=1 ic.Parent=head end
	label(cfg.Title or "Dialog",18,WBold,"Text",{Size=UDim2.new(1,ic and -32 or 0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Parent=head})
	if cfg.Content and cfg.Content~="" then
		label(cfg.Content,14,WMed,"Sub",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Parent=card})
	end
	local body=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,LayoutOrder=3,Parent=card},{list(DirV,10)})
	function api.Close()
		if closed then return end
		closed=true
		tween(dim,0.18,{BackgroundTransparency=1})
		tween(scale,0.18,{Scale=0.92})
		task.delay(0.2,function()dim:Destroy()end)
	end
	if cfg.Build then safe(cfg.Build,body,api) end
	local buttons=cfg.Buttons or {}
	if #buttons>0 then
		local row=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),LayoutOrder=4,Parent=card},{list(DirH,8)})
		local n=#buttons
		for i,b in ipairs(buttons)do
			local btn=smallButton(row,b.Title or "OK",b.Variant or (i==n and "Primary" or "Secondary"),function()
				local keep=false
				if b.Callback then
					local ok,res=pcall(b.Callback)
					keep=ok and res==false
				end
				if not keep then api.Close() end
			end,UDim2.new(1/n,-(8*(n-1)/n),1,0))
			btn.LayoutOrder=i
		end
	end
	if cfg.Dismissible then dim.Activated:Connect(api.Close) end
	tween(dim,0.22,{BackgroundTransparency=0.5})
	tween(scale,0.35,{Scale=1},EaseBack)
	api.Body=body
	return api
end

local function notifWidth()
	return (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 250 or 290
end

function Prism:Notify(cfg)
	ensureGui()
	cfg=cfg or {}
	local width=notifWidth()
	if not notifHolder or not notifHolder.Parent then
		notifHolder=create("Frame",{Name="Notifications",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,width,1,-28),Parent=layers.notif},{list(DirV,8,AlignR,AlignB)})
	end
	local kind=cfg.Type or "Info"
	local key=({Info="Accent",Success="Good",Warning="Warn",Error="Bad"})[kind] or "Accent"
	local duration=cfg.Duration or 4
	local wrap=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),Parent=notifHolder})
	local toast=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Position=UDim2.fromOffset(width+40,0),Theme={BackgroundColor3="Panel"},Parent=wrap},{corner(8),stroke("Stroke",1,0.15)})
	create("Frame",{Size=UDim2.new(0,3,1,-18),Position=UDim2.fromOffset(8,9),Theme={BackgroundColor3=key},Parent=toast},{corner(2)})
	local content=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=toast},{pad(22,12,34,14),list(DirV,3)})
	label(cfg.Title or "Notification",15,WBold,"Text",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=1,Parent=content})
	if cfg.Content and cfg.Content~="" then
		label(cfg.Content,13,WMed,"Sub",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Parent=content})
	end
	local bar=create("Frame",{Size=UDim2.new(1,-16,0,2),Position=UDim2.new(0,8,1,-4),Theme={BackgroundColor3=key},BackgroundTransparency=0.4,Parent=toast},{corner(1)})
	local closeBtn=create("TextButton",{Size=UDim2.fromOffset(26,26),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),BackgroundTransparency=1,Parent=toast})
	label("×",20,WBold,"Sub",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Parent=closeBtn})
	local closed=false
	local api={}
	function api.Close()
		if closed then return end
		closed=true
		tween(toast,0.3,{Position=UDim2.fromOffset(width+40,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
		task.delay(0.15,function()
			tween(wrap,0.25,{Size=UDim2.new(1,0,0,0)})
		end)
		task.delay(0.45,function()wrap:Destroy()end)
		safe(cfg.OnClose)
	end
	closeBtn.Activated:Connect(api.Close)
	task.spawn(function()
		task.wait()
		if closed then return end
		local h=toast.AbsoluteSize.Y/uiScale
		tween(wrap,0.3,{Size=UDim2.new(1,0,0,h)})
		tween(toast,0.5,{Position=UDim2.fromOffset(0,0)},EaseBack)
		if duration>0 then
			tween(bar,duration,{Size=UDim2.new(0,0,0,2)},EaseLinear)
			task.wait(duration)
			api.Close()
		end
	end)
	return api
end

function Prism:Popup(cfg)
	return makeDialog(cfg)
end

local function setRemoteImage(target,url,name)
	if not (requestFn and assetFn and hasFiles) then return end
	task.spawn(function()
		local folder="PrismCache"
		pcall(function()if not isfolder(folder)then makefolder(folder)end end)
		local path=folder.."/"..string.gsub(name,"[^%w_]","_")..".png"
		if not isfile(path) then
			local ok,res=pcall(requestFn,{Url=url,Method="GET"})
			if not ok or not res or res.StatusCode~=200 then return end
			pcall(writefile,path,res.Body)
		end
		local ok,asset=pcall(assetFn,path)
		if ok and target.Parent then target.Image=asset end
	end)
end

local Elements={}

local function newRow(ctx,cfg,opt)
	opt=opt or {}
	local rightW=opt.rightWidth or 0
	local row=create(opt.clickable and "TextButton" or "Frame",{Name="Row",Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Theme={BackgroundColor3="Element"}},{corner(R_EL),stroke("Stroke",1,0.45)})
	row.Parent=ctx.Content
	local inner=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=row},{pad(12,11)})
	if opt.column then inner:FindFirstChildOfClass("UIPadding").Parent=inner list(DirV,8).Parent=inner end
	local left=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,rightW>0 and -(rightW+12) or 0,0,0),AutomaticSize=AutoY,LayoutOrder=1,Parent=inner},{list(DirH,10,AlignL,AlignM)})
	local icon=iconNode(cfg.Icon,20,"Sub",true)
	if icon then icon.LayoutOrder=1 icon.Parent=left end
	local textCol=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,icon and -30 or 0,0,0),AutomaticSize=AutoY,LayoutOrder=2,Parent=left},{list(DirV,3)})
	local title=label(cfg.Title or "",15,WSemi,"Text",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=1,Visible=cfg.Title~=nil and cfg.Title~="",Parent=textCol})
	local desc=label(cfg.Desc or "",13,WMed,"Sub",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Visible=cfg.Desc~=nil and cfg.Desc~="",Parent=textCol})
	local right
	if rightW>0 then
		right=create("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(rightW,opt.rightHeight or 30),Parent=inner})
	end
	local el={Row=row,Inner=inner,Left=left,Right=right,TitleLabel=title,DescLabel=desc,Title=cfg.Title or "",Desc=cfg.Desc,Locked=false,Kind=opt.kind}
	local lockFrame
	function el:SetTitle(t)self.Title=t title.Text=t title.Visible=t~=nil and t~=""end
	function el:SetDesc(t)self.Desc=t desc.Text=t or "" desc.Visible=t~=nil and t~=""end
	function el:SetVisible(v)row.Visible=v end
	function el:Highlight()
		local s=row:FindFirstChildOfClass("UIStroke")
		if not s then return end
		s.Color=currentTheme.Accent
		s.Transparency=0
		s.Thickness=2
		task.delay(0.6,function()
			if not s.Parent then return end
			paint(s,"Color","Stroke",0.3)
			tween(s,0.3,{Transparency=0.45,Thickness=1})
		end)
	end
	function el:Lock(text)
		self.Locked=true
		if not lockFrame then
			lockFrame=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,ZIndex=5,Parent=row},{corner(R_EL)})
			label(text or "Locked",14,WSemi,"Text",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,TextTransparency=1,ZIndex=6,Parent=lockFrame})
		end
		lockFrame.Visible=true
		lockFrame.Active=true
		tween(lockFrame,0.2,{BackgroundTransparency=0.45})
		tween(lockFrame:FindFirstChildOfClass("TextLabel"),0.2,{TextTransparency=0.1})
		if text then lockFrame:FindFirstChildOfClass("TextLabel").Text=text end
	end
	function el:Unlock()
		self.Locked=false
		if lockFrame then
			lockFrame.Active=false
			tween(lockFrame,0.2,{BackgroundTransparency=1})
			tween(lockFrame:FindFirstChildOfClass("TextLabel"),0.2,{TextTransparency=1})
			task.delay(0.2,function()if lockFrame and not self.Locked then lockFrame.Visible=false end end)
		end
	end
	function el:Destroy()
		row:Destroy()
		if self.Container then
			local i=table.find(self.Container.Elements,self)
			if i then table.remove(self.Container.Elements,i) end
		end
	end
	if cfg.Locked then el:Lock(cfg.LockedTitle) end
	return el,row
end

local function plainElement(frame)
	local el={Row=frame}
	function el:SetVisible(v)frame.Visible=v end
	function el:Lock()end
	function el:Unlock()end
	function el:Destroy()
		frame:Destroy()
		if self.Container then
			local i=table.find(self.Container.Elements,self)
			if i then table.remove(self.Container.Elements,i) end
		end
	end
	return el
end

Elements.Button=function(ctx,cfg)
	local primary=cfg.Variant=="Primary" or cfg.Color~=nil
	local el,row=newRow(ctx,cfg,{clickable=true,rightWidth=22,rightHeight=20,kind="Button"})
	local arrow=label(cfg.Arrow or ">",18,WBold,"Sub",{Size=UDim2.fromScale(1,1),TextXAlignment=XRight,Parent=el.Right})
	if primary then
		if typeof(cfg.Color)=="Color3" then
			unbind(row,"BackgroundColor3")
			row.BackgroundColor3=cfg.Color
			local lum=cfg.Color.R*0.299+cfg.Color.G*0.587+cfg.Color.B*0.114
			local tc=lum>0.6 and Color3.fromRGB(20,20,24) or Color3.new(1,1,1)
			for _,l in ipairs({el.TitleLabel,el.DescLabel,arrow})do unbind(l,"TextColor3") l.TextColor3=tc end
		else
			paint(row,"BackgroundColor3","Accent")
			for _,l in ipairs({el.TitleLabel,el.DescLabel,arrow})do paint(l,"TextColor3","AccentText")end
		end
		el.DescLabel.TextTransparency=0.25
		row.MouseEnter:Connect(function()tween(row,0.12,{BackgroundTransparency=0.12})end)
		row.MouseLeave:Connect(function()tween(row,0.12,{BackgroundTransparency=0})end)
	else
		hoverable(row,"BackgroundColor3","Element","Hover")
	end
	row.MouseEnter:Connect(function()tween(arrow,0.18,{Position=UDim2.fromOffset(4,0)})end)
	row.MouseLeave:Connect(function()tween(arrow,0.18,{Position=UDim2.fromOffset(0,0)})end)
	row.Activated:Connect(function()
		if el.Locked then return end
		tween(arrow,0.1,{Position=UDim2.fromOffset(8,0)})
		safe(cfg.Callback)
	end)
	return el
end

Elements.Toggle=function(ctx,cfg)
	local box=cfg.Type=="Checkbox"
	local el,row=newRow(ctx,cfg,{clickable=true,rightWidth=box and 22 or 44,rightHeight=box and 22 or 24,kind="Toggle"})
	el.Value=(cfg.Value==true) or (cfg.Default==true)
	hoverable(row,"BackgroundColor3","Element","Hover")
	local track=create("Frame",{Size=UDim2.fromScale(1,1),Theme={BackgroundColor3="Stroke"},Parent=el.Right},{corner(box and R_SM or 12)})
	local knob,bars
	if box then
		local _,b=checkMark(track,22)
		bars=b
	else
		knob=create("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1),Parent=track},{corner(9)})
	end
	local function render(animate)
		paint(track,"BackgroundColor3",el.Value and "Accent" or "Stroke",animate and 0.2 or nil)
		if knob then
			local pos=UDim2.fromOffset(el.Value and 23 or 3,3)
			if animate then tween(knob,0.3,{Position=pos},EaseBack) else knob.Position=pos end
		else
			for _,b in ipairs(bars)do
				local t=el.Value and 0 or 1
				if animate then tween(b,0.15,{BackgroundTransparency=t}) else b.BackgroundTransparency=t end
			end
		end
	end
	render(false)
	function el:Set(v,silent)
		v=v and true or false
		if self.Value==v then return end
		self.Value=v
		render(true)
		if not silent then safe(cfg.Callback,v) end
	end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	row.Activated:Connect(function()
		if el.Locked then return end
		el:Set(not el.Value)
	end)
	return el
end

Elements.Slider=function(ctx,cfg)
	local cv=type(cfg.Value)=="table" and cfg.Value or {}
	local min=cv.Min or cfg.Min or 0
	local max=cv.Max or cfg.Max or 100
	local step=cfg.Step or 1
	local rightW=ctx.Window.Compact and 170 or 230
	local el,row=newRow(ctx,cfg,{rightWidth=rightW,rightHeight=30,kind="Slider"})
	local showBox=cfg.IsTextbox~=false
	local boxW=showBox and 50 or 0
	local startValue=cv.Default or cfg.Default
	if startValue==nil and type(cfg.Value)=="number" then startValue=cfg.Value end
	el.Value=clamp(startValue or min,min,max)
	local hit=create("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,-(boxW+(showBox and 10 or 0)),1,0),Parent=el.Right})
	local bar=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,6),Theme={BackgroundColor3="Stroke"},Parent=hit},{corner(3)})
	local fill=create("Frame",{Size=UDim2.fromScale(0,1),Theme={BackgroundColor3="Accent"},Parent=bar},{corner(3)})
	local knob=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1),Parent=fill},{corner(7),stroke("Accent",2)})
	local box
	if showBox then
		box=create("TextBox",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.fromOffset(boxW,26),FontFace=font(WSemi),TextSize=13,BackgroundTransparency=0,Theme={TextColor3="Text",BackgroundColor3="Panel"},Parent=el.Right},{corner(R_SM)})
	end
	local function fmt(n)
		if step%1==0 then return tostring(math.floor(n+0.5)) end
		return tostring(tonumber(string.format("%.2f",n)))
	end
	local function snap(n)
		n=min+math.floor((n-min)/step+0.5)*step
		return clamp(n,min,max)
	end
	local function visual(animate)
		local f=(max==min) and 0 or (el.Value-min)/(max-min)
		if animate then tween(fill,0.08,{Size=UDim2.fromScale(f,1)},EaseQuad) else fill.Size=UDim2.fromScale(f,1) end
		if box then box.Text=fmt(el.Value) end
	end
	visual(false)
	function el:Set(v,silent)
		v=snap(tonumber(v) or self.Value)
		if v==self.Value then visual(false) return end
		self.Value=v
		visual(true)
		if not silent then safe(cfg.Callback,v) end
	end
	function el:SetRange(a,b)min=a max=b self:Set(self.Value,true) visual(false)end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	hit.InputBegan:Connect(function(input)
		if el.Locked then return end
		if input.UserInputType~=MouseBtn and input.UserInputType~=TouchIn then return end
		local scroller=row:FindFirstAncestorOfClass("ScrollingFrame")
		if scroller then scroller.ScrollingEnabled=false end
		local function update(i)
			local rel=clamp((pointerPos(i).X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
			el:Set(min+rel*(max-min))
		end
		update(input)
		tween(knob,0.12,{Size=UDim2.fromOffset(18,18)})
		startDrag(input,update,function()
			if scroller then scroller.ScrollingEnabled=true end
			tween(knob,0.18,{Size=UDim2.fromOffset(14,14)})
		end)
	end)
	if box then
		box.FocusLost:Connect(function()el:Set(box.Text)end)
	end
	return el
end

Elements.Dropdown=function(ctx,cfg)
	local compact=ctx.Window.Compact
	local el,row=newRow(ctx,cfg,{rightWidth=compact and 140 or 180,rightHeight=32,kind="Dropdown"})
	el.Multi=cfg.Multi==true
	el.Values=cfg.Values or {}
	local function nameOf(v)
		if type(v)=="table" then return tostring(v.Title or v.Name or v[1]) end
		return tostring(v)
	end
	local function sync(v)
		if el.Multi then
			local out={}
			if type(v)=="table" then
				for _,x in ipairs(v)do table.insert(out,nameOf(x))end
			elseif v~=nil then
				table.insert(out,nameOf(v))
			end
			return out
		end
		if type(v)=="number" then v=el.Values[v] end
		if v==nil then return nil end
		return nameOf(v)
	end
	el.Value=sync(cfg.Value)
	local btn=create("TextButton",{Size=UDim2.fromScale(1,1),Theme={BackgroundColor3="Panel"},Parent=el.Right},{corner(R_EL),stroke("Stroke",1,0.3)})
	local text=label("",14,WMed,"Text",{Size=UDim2.new(1,-30,1,0),Position=UDim2.fromOffset(10,0),TextTruncate=Enum.TextTruncate.AtEnd,Parent=btn})
	local chev=label(">",16,WBold,"Sub",{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Rotation=90,TextXAlignment=XCenter,Parent=btn})
	hoverable(btn,"BackgroundColor3","Panel","Hover")
	local function display()
		if el.Multi then
			text.Text=#el.Value>0 and table.concat(el.Value,", ") or "None"
		else
			text.Text=el.Value or "None"
		end
	end
	display()
	local function isSelected(name)
		if el.Multi then return table.find(el.Value,name)~=nil end
		return el.Value==name
	end
	local current
	local function open()
		if el.Locked or current then return end
		local items={}
		for _,v in ipairs(el.Values)do
			table.insert(items,{Name=nameOf(v),Locked=type(v)=="table" and v.Locked==true})
		end
		local search=cfg.SearchBarEnabled==true
		local listH=math.min(#items*36+8,compact and 170 or 230)
		local height=listH+(search and 44 or 0)
		local width=math.max(btn.AbsoluteSize.X/uiScale,compact and 150 or 190)
		tween(chev,0.2,{Rotation=270})
		current=openPopup(btn,width,height,function(inner,api)
			local sf=create("ScrollingFrame",{Size=UDim2.new(1,0,0,listH),Position=UDim2.fromOffset(0,search and 44 or 0),AutomaticCanvasSize=AutoY,Parent=inner},{pad(4),list(DirV,2)})
			local function visuals()
				for _,it in ipairs(items)do
					local sel=isSelected(it.Name)
					paint(it.Label,"TextColor3",sel and "Accent" or "Text",0.12)
					it.Dot.Visible=sel
				end
			end
			for i,it in ipairs(items)do
				local b=create("TextButton",{Size=UDim2.new(1,0,0,34),LayoutOrder=i,BackgroundTransparency=1,Theme={BackgroundColor3="Hover"},Parent=sf},{corner(R_SM)})
				it.Btn=b
				it.Label=label(it.Name,14,WMed,"Text",{Size=UDim2.new(1,-34,1,0),Position=UDim2.fromOffset(10,0),TextTruncate=Enum.TextTruncate.AtEnd,TextTransparency=it.Locked and 0.55 or 0,Parent=b})
				it.Dot=create("Frame",{Size=UDim2.fromOffset(6,6),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Theme={BackgroundColor3="Accent"},Parent=b},{corner(3)})
				b.MouseEnter:Connect(function()tween(b,0.1,{BackgroundTransparency=0.45})end)
				b.MouseLeave:Connect(function()tween(b,0.1,{BackgroundTransparency=1})end)
				b.Activated:Connect(function()
					if it.Locked then return end
					if el.Multi then
						local idx=table.find(el.Value,it.Name)
						if idx then
							if #el.Value>1 or cfg.AllowNone then table.remove(el.Value,idx) end
						else
							table.insert(el.Value,it.Name)
						end
						visuals()
						display()
						safe(cfg.Callback,table.clone(el.Value))
					else
						el.Value=it.Name
						display()
						safe(cfg.Callback,el.Value)
						api.Close()
					end
				end)
			end
			visuals()
			if search then
				local sb=create("Frame",{Size=UDim2.new(1,-16,0,32),Position=UDim2.fromOffset(8,6),Theme={BackgroundColor3="Element"},Parent=inner},{corner(R_SM)})
				local tb=create("TextBox",{Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(10,0),PlaceholderText="Search",TextSize=14,TextXAlignment=XLeft,Theme={TextColor3="Text",PlaceholderColor3="Sub"},Parent=sb})
				tb:GetPropertyChangedSignal("Text"):Connect(function()
					local q=string.lower(tb.Text)
					for _,it in ipairs(items)do
						it.Btn.Visible=q=="" or string.find(string.lower(it.Name),q,1,true)~=nil
					end
				end)
			end
		end,function()
			current=nil
			tween(chev,0.2,{Rotation=90})
		end)
	end
	btn.Activated:Connect(open)
	function el:Set(v,silent)
		self.Value=sync(v)
		display()
		if not silent then safe(cfg.Callback,self.Value) end
	end
	function el:Select(v)self:Set(v)end
	function el:Refresh(values)
		self.Values=values or {}
		self.Value=sync(self.Value)
		display()
	end
	function el:Open()open()end
	function el:Close()if current then current.Close() end end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	return el
end

Elements.Input=function(ctx,cfg)
	local area=cfg.Type=="Textarea"
	local el,row=newRow(ctx,cfg,{column=area,rightWidth=area and 0 or (ctx.Window.Compact and 150 or 190),rightHeight=32,kind="Input"})
	el.Value=cfg.Value or ""
	local holder=create("Frame",{Size=area and UDim2.new(1,0,0,110) or UDim2.fromScale(1,1),LayoutOrder=2,Theme={BackgroundColor3="Panel"},Parent=area and el.Inner or el.Right},{corner(R_EL)})
	local st=stroke("Stroke",1,0.3)
	st.Parent=holder
	local tb=create("TextBox",{Size=UDim2.new(1,-20,1,area and -16 or 0),Position=UDim2.fromOffset(10,area and 8 or 0),PlaceholderText=cfg.Placeholder or "Type here",Text=el.Value,TextSize=14,TextXAlignment=XLeft,TextYAlignment=area and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,MultiLine=area,TextWrapped=area,ClearTextOnFocus=cfg.ClearTextOnFocus==true,ClipsDescendants=true,Theme={TextColor3="Text",PlaceholderColor3="Sub"},Parent=holder})
	tb.Focused:Connect(function()paint(st,"Color","Accent",0.15)end)
	tb.FocusLost:Connect(function()
		paint(st,"Color","Stroke",0.15)
		if el.Locked then tb.Text=el.Value return end
		el.Value=tb.Text
		safe(cfg.Callback,el.Value)
	end)
	function el:Set(v,silent)
		self.Value=tostring(v or "")
		tb.Text=self.Value
		if not silent then safe(cfg.Callback,self.Value) end
	end
	function el:SetPlaceholder(t)tb.PlaceholderText=t end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	return el
end

Elements.Keybind=function(ctx,cfg)
	local el,row=newRow(ctx,cfg,{rightWidth=92,rightHeight=30,kind="Keybind"})
	local function keyName(v)
		if typeof(v)=="EnumItem" then return v.Name end
		return tostring(v or "None")
	end
	el.Value=keyName(cfg.Value or "F")
	local btn=create("TextButton",{Size=UDim2.fromScale(1,1),Text=el.Value,TextSize=13,FontFace=font(WSemi),Theme={BackgroundColor3="Panel",TextColor3="Text"},Parent=el.Right},{corner(R_EL),stroke("Stroke",1,0.3)})
	hoverable(btn,"BackgroundColor3","Panel","Hover")
	local picking=false
	local black={Escape=true}
	for _,b in ipairs(cfg.Blacklist or {})do black[keyName(b)]=true end
	btn.Activated:Connect(function()
		if el.Locked or cfg.CanChange==false or picking then return end
		picking=true
		btn.Text="..."
		paint(btn,"TextColor3","Accent",0.1)
	end)
	local conn=UserInputService.InputBegan:Connect(function(input,gp)
		local name
		if input.UserInputType==Enum.UserInputType.Keyboard then name=input.KeyCode.Name
		elseif input.UserInputType==MouseBtn then name="MouseLeft"
		elseif input.UserInputType==Enum.UserInputType.MouseButton2 then name="MouseRight" end
		if not name then return end
		if picking then
			if name=="MouseLeft" then return end
			picking=false
			paint(btn,"TextColor3","Text",0.1)
			if not black[name] then el.Value=name end
			btn.Text=el.Value
			return
		end
		if gp or el.Locked then return end
		if name==el.Value then safe(cfg.Callback,name) end
	end)
	row.Destroying:Connect(function()conn:Disconnect()end)
	function el:Set(v)
		self.Value=keyName(v)
		btn.Text=self.Value
	end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	return el
end

local function dragArea(frame,apply)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType~=MouseBtn and input.UserInputType~=TouchIn then return end
		local function upd(i)
			local p=pointerPos(i)
			apply(clamp((p.X-frame.AbsolutePosition.X)/math.max(frame.AbsoluteSize.X,1),0,1),clamp((p.Y-frame.AbsolutePosition.Y)/math.max(frame.AbsoluteSize.Y,1),0,1))
		end
		upd(input)
		startDrag(input,upd)
	end)
end

Elements.Colorpicker=function(ctx,cfg)
	local el,row=newRow(ctx,cfg,{clickable=true,rightWidth=38,rightHeight=22,kind="Colorpicker"})
	local hasAlpha=cfg.Transparency~=nil
	local color=cfg.Default or cfg.Value or Color3.fromRGB(255,255,255)
	local h,s,v=color:ToHSV()
	el.Value=color
	el.Transparency=cfg.Transparency or 0
	hoverable(row,"BackgroundColor3","Element","Hover")
	local swatch=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=color,BackgroundTransparency=el.Transparency,Parent=el.Right},{corner(R_SM),stroke("Stroke",1,0.2)})
	local refreshUI
	local function push(silent)
		el.Value=Color3.fromHSV(h,s,v)
		swatch.BackgroundColor3=el.Value
		swatch.BackgroundTransparency=el.Transparency
		if not silent then safe(cfg.Callback,el.Value,el.Transparency) end
	end
	local picker
	row.Activated:Connect(function()
		if el.Locked or picker then return end
		local height=212+(hasAlpha and 26 or 0)
		picker=openPopup(swatch,224,height,function(inner)
			local sv=create("Frame",{Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(200,130),BackgroundColor3=Color3.fromHSV(h,1,1),ClipsDescendants=true,Parent=inner},{corner(R_SM)})
			create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),Parent=sv},{create("UIGradient",{Transparency=NumberSequence.new(0,1)})})
			create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),Parent=sv},{create("UIGradient",{Transparency=NumberSequence.new(1,0),Rotation=90})})
			local cursor=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(12,12),BackgroundTransparency=1,Parent=sv},{corner(6),create("UIStroke",{Color=Color3.new(1,1,1),Thickness=2})})
			local hue=create("Frame",{Position=UDim2.fromOffset(12,152),Size=UDim2.fromOffset(200,14),BackgroundColor3=Color3.new(1,1,1),Parent=inner},{corner(7),create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(1/6,Color3.fromHSV(1/6,1,1)),ColorSequenceKeypoint.new(2/6,Color3.fromHSV(2/6,1,1)),ColorSequenceKeypoint.new(3/6,Color3.fromHSV(3/6,1,1)),ColorSequenceKeypoint.new(4/6,Color3.fromHSV(4/6,1,1)),ColorSequenceKeypoint.new(5/6,Color3.fromHSV(5/6,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))})})})
			local hueCur=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(6,20),BackgroundColor3=Color3.new(1,1,1),Parent=hue},{corner(3),create("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Transparency=0.5})})
			local alpha,alphaCur
			if hasAlpha then
				alpha=create("Frame",{Position=UDim2.fromOffset(12,178),Size=UDim2.fromOffset(200,14),BackgroundColor3=el.Value,Parent=inner},{corner(7),create("UIGradient",{Transparency=NumberSequence.new(0,1)})})
				alphaCur=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(6,20),BackgroundColor3=Color3.new(1,1,1),Parent=alpha},{corner(3),create("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Transparency=0.5})})
			end
			local hexBox=create("Frame",{Position=UDim2.fromOffset(12,hasAlpha and 204 or 178),Size=UDim2.fromOffset(200,28),Theme={BackgroundColor3="Element"},Parent=inner},{corner(R_SM)})
			local hexText=create("TextBox",{Size=UDim2.fromScale(1,1),TextSize=13,FontFace=font(WSemi),Theme={TextColor3="Text"},Parent=hexBox})
			refreshUI=function()
				sv.BackgroundColor3=Color3.fromHSV(h,1,1)
				cursor.Position=UDim2.fromScale(s,1-v)
				hueCur.Position=UDim2.fromScale(h,0.5)
				if alpha then
					alpha.BackgroundColor3=Color3.fromHSV(h,s,v)
					alphaCur.Position=UDim2.fromScale(1-el.Transparency,0.5)
				end
				hexText.Text="#"..toHex(Color3.fromHSV(h,s,v))
			end
			dragArea(sv,function(x,y)s=x v=1-y push() refreshUI()end)
			dragArea(hue,function(x)h=x push() refreshUI()end)
			if alpha then dragArea(alpha,function(x)el.Transparency=1-x push() refreshUI()end) end
			hexText.FocusLost:Connect(function()
				local ok,c=pcall(Color3.fromHex,hexText.Text)
				if ok and c then h,s,v=c:ToHSV() push() end
				refreshUI()
			end)
			refreshUI()
		end,function()picker=nil refreshUI=nil end)
	end)
	function el:Set(c,a)
		if typeof(c)=="Color3" then h,s,v=c:ToHSV() end
		if a then self.Transparency=a end
		push(true)
		if refreshUI then refreshUI() end
	end
	function el:Update(c,a)self:Set(c,a)end
	function el:Export()return {Color=toHex(self.Value),Transparency=self.Transparency}end
	function el:Import(d)
		if type(d)=="table" and d.Color then self:Set(Color3.fromHex(d.Color),d.Transparency) safe(cfg.Callback,self.Value,self.Transparency) end
	end
	return el
end

Elements.Paragraph=function(ctx,cfg)
	local el=newRow(ctx,cfg,{column=true,kind="Paragraph"})
	local buttons=cfg.Buttons or {}
	if #buttons>0 then
		local holder=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,LayoutOrder=2,Parent=el.Inner},{list(DirV,6)})
		for i,b in ipairs(buttons)do
			local btn=smallButton(holder,b.Title or "Button",b.Variant or "Secondary",b.Callback,UDim2.new(1,0,0,34))
			btn.LayoutOrder=i
		end
	end
	return el
end

Elements.Label=function(ctx,cfg)
	local el=newRow(ctx,cfg,{rightWidth=ctx.Window.Compact and 110 or 150,rightHeight=22,kind="Label"})
	local value=label(tostring(cfg.Value or ""),14,WSemi,"Accent",{Size=UDim2.fromScale(1,1),TextXAlignment=XRight,TextTruncate=Enum.TextTruncate.AtEnd,Parent=el.Right})
	el.Value=cfg.Value
	function el:Set(v)self.Value=v value.Text=tostring(v)end
	function el:SetValue(v)self:Set(v)end
	return el
end

Elements.Stepper=function(ctx,cfg)
	local el=newRow(ctx,cfg,{rightWidth=124,rightHeight=30,kind="Stepper"})
	local min,max,step=cfg.Min or 0,cfg.Max or 100,cfg.Step or 1
	el.Value=clamp(cfg.Value or cfg.Default or min,min,max)
	local display
	local function make(txt,x)
		local b=create("TextButton",{Size=UDim2.fromOffset(30,30),AnchorPoint=Vector2.new(x,0),Position=UDim2.new(x,0,0,0),Theme={BackgroundColor3="Panel"},Parent=el.Right},{corner(R_EL),stroke("Stroke",1,0.3)})
		label(txt,18,WBold,"Text",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Parent=b})
		hoverable(b,"BackgroundColor3","Panel","Hover")
		return b
	end
	local minus=make("-",0)
	local plus=make("+",1)
	display=label(tostring(el.Value),15,WSemi,"Text",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,0),Size=UDim2.new(1,-68,1,0),TextXAlignment=XCenter,Parent=el.Right})
	function el:Set(v,silent)
		v=clamp(tonumber(v) or self.Value,min,max)
		if v==self.Value then return end
		self.Value=v
		display.Text=tostring(tonumber(string.format("%.3f",v)))
		if not silent then safe(cfg.Callback,v) end
	end
	minus.Activated:Connect(function()if not el.Locked then el:Set(el.Value-step)end end)
	plus.Activated:Connect(function()if not el.Locked then el:Set(el.Value+step)end end)
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	return el
end

Elements.Segmented=function(ctx,cfg)
	local el=newRow(ctx,cfg,{column=true,kind="Segmented"})
	local options=cfg.Values or cfg.Options or {}
	local n=math.max(#options,1)
	el.Value=cfg.Value or options[1]
	local track=create("Frame",{Size=UDim2.new(1,0,0,34),LayoutOrder=2,Theme={BackgroundColor3="Panel"},Parent=el.Inner},{corner(R_EL),pad(3)})
	local pill=create("Frame",{Size=UDim2.new(1/n,0,1,0),Theme={BackgroundColor3="Accent"},Parent=track},{corner(R_SM)})
	local labels={}
	local function index()
		for i,o in ipairs(options)do if o==el.Value then return i end end
		return 1
	end
	local function render(animate)
		local i=index()
		local pos=UDim2.new((i-1)/n,0,0,0)
		if animate then tween(pill,0.28,{Position=pos},EaseBack) else pill.Position=pos end
		for j,l in ipairs(labels)do paint(l,"TextColor3",j==i and "AccentText" or "Sub",animate and 0.15 or nil)end
	end
	for i,o in ipairs(options)do
		local b=create("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1/n,0,1,0),Position=UDim2.new((i-1)/n,0,0,0),ZIndex=2,Parent=track})
		labels[i]=label(tostring(o),13,WSemi,"Sub",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,ZIndex=3,Parent=b})
		b.Activated:Connect(function()
			if el.Locked then return end
			el:Set(o)
		end)
	end
	render(false)
	function el:Set(v,silent)
		if self.Value==v then return end
		self.Value=v
		render(true)
		if not silent then safe(cfg.Callback,v) end
	end
	function el:Export()return self.Value end
	function el:Import(v)self:Set(v)end
	return el
end

Elements.ProgressBar=function(ctx,cfg)
	local cv=type(cfg.Value)=="table" and cfg.Value or {}
	local min=cv.Min or 0
	local max=cv.Max or 100
	local el=newRow(ctx,cfg,{rightWidth=ctx.Window.Compact and 150 or 210,rightHeight=20,kind="ProgressBar"})
	local bar=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,-46,0,6),ClipsDescendants=true,Theme={BackgroundColor3="Stroke"},Parent=el.Right},{corner(3)})
	local fill=create("Frame",{Size=UDim2.fromScale(0,1),Theme={BackgroundColor3="Accent"},Parent=bar},{corner(3)})
	local text=label("0%",13,WSemi,"Sub",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.fromOffset(40,20),TextXAlignment=XRight,Parent=el.Right})
	el.Value=clamp(cv.Default or (type(cfg.Value)=="number" and cfg.Value) or min,min,max)
	local function render(animate)
		local f=(max==min) and 0 or (el.Value-min)/(max-min)
		if animate then tween(fill,0.3,{Size=UDim2.fromScale(f,1)}) else fill.Size=UDim2.fromScale(f,1) end
		text.Text=math.floor(f*100+0.5).."%"
	end
	if cfg.Indeterminate then
		fill.Size=UDim2.fromScale(0.3,1)
		fill.Position=UDim2.fromScale(-0.3,0)
		text.Text=""
		TweenService:Create(fill,TweenInfo.new(1.2,EaseSine,Enum.EasingDirection.InOut,-1),{Position=UDim2.fromScale(1,0)}):Play()
	else
		render(false)
	end
	function el:Set(v)
		self.Value=clamp(tonumber(v) or self.Value,min,max)
		render(true)
	end
	function el:Get()return self.Value end
	return el
end

Elements.Code=function(ctx,cfg)
	local el=newRow(ctx,{Title=cfg.Title},{column=true,kind="Code"})
	el.Code=cfg.Code or ""
	local box=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,LayoutOrder=2,Theme={BackgroundColor3="Background"},Parent=el.Inner},{corner(R_EL),stroke("Stroke",1,0.3)})
	local scroller=create("ScrollingFrame",{Size=UDim2.new(1,0,0,30),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X,Parent=box})
	local text=create("TextLabel",{Text=el.Code,Font=Enum.Font.Code,TextSize=13,RichText=false,TextWrapped=false,TextXAlignment=XLeft,TextYAlignment=Enum.TextYAlignment.Top,AutomaticSize=AutoXY,Size=UDim2.new(0,0,0,0),Theme={TextColor3="Text"},Parent=scroller},{pad(12,10,44,10)})
	text:GetPropertyChangedSignal("TextBounds"):Connect(function()
		scroller.Size=UDim2.new(1,0,0,text.TextBounds.Y+20)
	end)
	scroller.Size=UDim2.new(1,0,0,text.TextBounds.Y+20)
	local copy=create("TextButton",{Size=UDim2.fromOffset(28,28),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Theme={BackgroundColor3="Hover"},Parent=box},{corner(R_SM)})
	local copyLabel=iconNode("copy",16,"Sub",true)
	copyLabel.AnchorPoint=Vector2.new(0.5,0.5)
	copyLabel.Position=UDim2.fromScale(0.5,0.5)
	copyLabel.Parent=copy
	copy.Activated:Connect(function()
		local ok=copyText(el.Code)
		Prism:Notify({Title=ok and "Copied" or "Unavailable",Content=ok and "Code copied to clipboard" or "Clipboard is not supported",Type=ok and "Success" or "Warning",Duration=2})
		safe(cfg.Callback,el.Code)
	end)
	function el:Set(code)self.Code=code text.Text=code end
	function el:SetCode(code)self:Set(code)end
	return el
end

Elements.Divider=function(ctx,cfg)
	local frame=create("Frame",{Name="Divider",BackgroundTransparency=1,Size=UDim2.new(1,0,0,cfg.Title and 22 or 10),Parent=ctx.Content})
	if cfg.Title then
		create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.new(0.5,-60,0,1),Theme={BackgroundColor3="Stroke"},Parent=frame})
		create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.new(0.5,-60,0,1),Theme={BackgroundColor3="Stroke"},Parent=frame})
		label(cfg.Title,12,WBold,"Sub",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(100,16),TextXAlignment=XCenter,Parent=frame})
	else
		create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,0,1),Theme={BackgroundColor3="Stroke"},Parent=frame})
	end
	return plainElement(frame)
end

Elements.Space=function(ctx,cfg)
	local frame=create("Frame",{Name="Space",BackgroundTransparency=1,Size=UDim2.new(1,0,0,cfg.Size or 8),Parent=ctx.Content})
	return plainElement(frame)
end

Elements.Image=function(ctx,cfg)
	local frame=create("Frame",{Name="Image",BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=ctx.Content})
	local img=create("ImageLabel",{Size=UDim2.new(1,0,0,0),ScaleType=Enum.ScaleType.Crop,Parent=frame},{corner(cfg.Radius or R_EL),create("UIAspectRatioConstraint",{AspectRatio=type(cfg.AspectRatio)=="number" and cfg.AspectRatio or 16/9,DominantAxis=Enum.DominantAxis.Width,AspectType=Enum.AspectType.ScaleWithParentSize})})
	if type(cfg.AspectRatio)=="string" then
		local a,b=string.match(cfg.AspectRatio,"(%d+):(%d+)")
		if a and b then img:FindFirstChildOfClass("UIAspectRatioConstraint").AspectRatio=tonumber(a)/tonumber(b) end
	end
	local source=cfg.Image or ""
	if type(source)=="number" then source="rbxassetid://"..source end
	if string.sub(source,1,4)=="http" then setRemoteImage(img,source,"img_"..#source) else img.Image=source end
	local el=plainElement(frame)
	function el:SetImage(i)
		if type(i)=="number" then i="rbxassetid://"..i end
		img.Image=i
	end
	return el
end

Elements.Viewport=function(ctx,cfg)
	local frame=create("Frame",{Name="Row",Size=UDim2.new(1,0,0,cfg.Height or 200),Theme={BackgroundColor3="Element"}},{corner(R_EL),stroke("Stroke",1,0.45)})
	frame.Parent=ctx.Content
	local vp=create("ViewportFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Parent=frame},{corner(R_EL)})
	local camera=Instance.new("Camera")
	vp.CurrentCamera=camera
	camera.Parent=vp
	local obj=cfg.Object
	local el=plainElement(frame)
	local yaw,pitch,dist,center=0.6,-0.25,10,Vector3.zero
	local function update()
		camera.CFrame=CFrame.new(center)*CFrame.Angles(0,yaw,0)*CFrame.Angles(pitch,0,0)*CFrame.new(0,0,dist)
	end
	function el:SetObject(o,clone)
		if obj then obj:Destroy() end
		obj=clone and o:Clone() or o
		obj.Parent=vp
		local cf,size
		if obj:IsA("Model") then cf,size=obj:GetBoundingBox() else cf,size=obj.CFrame,obj.Size end
		center=cf.Position
		dist=(size.Magnitude/2)/math.tan(math.rad(camera.FieldOfView/2))*1.15
		update()
	end
	if obj then el:SetObject(obj,cfg.Clone~=false) end
	if cfg.Interactive~=false then
		frame.InputBegan:Connect(function(input)
			if input.UserInputType~=MouseBtn and input.UserInputType~=TouchIn then return end
			local last=pointerPos(input)
			local scroller=frame:FindFirstAncestorOfClass("ScrollingFrame")
			if scroller then scroller.ScrollingEnabled=false end
			startDrag(input,function(i)
				local p=pointerPos(i)
				local d=p-last
				last=p
				yaw=yaw-d.X*0.01
				pitch=clamp(pitch-d.Y*0.01,-1.3,1.3)
				update()
			end,function()
				if scroller then scroller.ScrollingEnabled=true end
			end)
		end)
	end
	if cfg.AutoRotate then
		local conn=RunService.Heartbeat:Connect(function(dt)
			yaw=yaw+dt*0.6
			update()
		end)
		frame.Destroying:Connect(function()conn:Disconnect()end)
	end
	return el
end

Elements.Callout=function(ctx,cfg)
	local types={Info={Key="Accent",Icon="info"},Success={Key="Good",Icon="check"},Warning={Key="Warn",Icon="!"},Error={Key="Bad",Icon="x"}}
	local kind=types[cfg.Type or "Info"] or types.Info
	local card=create("Frame",{Name="Row",Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,BackgroundTransparency=0.88,Theme={BackgroundColor3=kind.Key},Parent=ctx.Content},{corner(R_EL),stroke(kind.Key,1,0.6)})
	card:SetAttribute("BaseT",0.88)
	local inner=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=card},{pad(12),list(DirH,12)})
	local badge=create("Frame",{Size=UDim2.fromOffset(28,28),BackgroundTransparency=0.7,LayoutOrder=1,Theme={BackgroundColor3=kind.Key},Parent=inner},{corner(14)})
	local glyph=cfg.Icon or kind.Icon
	local ic=iconNode(glyph,16,kind.Key,true)
	ic.AnchorPoint=Vector2.new(0.5,0.5)
	ic.Position=UDim2.fromScale(0.5,0.5)
	ic.Parent=badge
	local col=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-40,0,0),AutomaticSize=AutoY,LayoutOrder=2,Parent=inner},{list(DirV,3)})
	local title=label(cfg.Title or "",15,WBold,"Text",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=1,Parent=col})
	local desc=label(cfg.Desc or "",13,WMed,"Sub",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Visible=cfg.Desc~=nil and cfg.Desc~="",Parent=col})
	local el=plainElement(card)
	function el:SetTitle(t)title.Text=t end
	function el:SetDesc(t)desc.Text=t or "" desc.Visible=t~=nil and t~=""end
	return el
end

Elements.Link=function(ctx,cfg)
	local el,row=newRow(ctx,{Title=cfg.Title or "Link",Desc=cfg.Desc,Icon=cfg.Icon or "link"},{rightWidth=ctx.Window.Compact and 96 or 112,rightHeight=34,kind="Link"})
	el.Url=cfg.Url or ""
	local btn,lab=smallButton(el.Right,cfg.ButtonText or "Copy",cfg.Color and "Primary" or "Secondary",function()
		local ok=copyText(el.Url)
		lab.Text=ok and "Copied" or "Failed"
		task.delay(1.4,function()if lab.Parent then lab.Text=cfg.ButtonText or "Copy" end end)
		Prism:Notify({Title=el.Title,Content=ok and "Link copied to clipboard" or "Clipboard is not supported",Type=ok and "Success" or "Warning",Duration=2})
		safe(cfg.Callback,el.Url)
	end,UDim2.fromScale(1,1))
	if typeof(cfg.Color)=="Color3" then unbind(btn,"BackgroundColor3") btn.BackgroundColor3=cfg.Color end
	function el:SetUrl(u)self.Url=u end
	return el
end

local function userCard(parent,cfg,small)
	local height=small and 52 or 66
	local card=create("Frame",{Name="Row",Size=UDim2.new(1,0,0,height),Theme={BackgroundColor3="Element"},Parent=parent},{corner(R_EL),stroke("Stroke",1,0.45),create("UIGradient",{Transparency=NumberSequence.new(0.8,1)})})
	card:SetAttribute("BaseT",0)
	local accentStripe=create("Frame",{Size=UDim2.new(0,3,0,height-24),Position=UDim2.fromOffset(0,12),Theme={BackgroundColor3="Accent"},Parent=card},{corner(2)})
	local av=height-18
	local avatar=create("Frame",{Size=UDim2.fromOffset(av,av),Position=UDim2.fromOffset(14,9),Theme={BackgroundColor3="Hover"},Parent=card},{corner(av/2),stroke("Accent",2,0.2)})
	local ph=label("?",small and 16 or 20,WBold,"Sub",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Parent=avatar})
	local img=create("ImageLabel",{Size=UDim2.fromScale(1,1),Parent=avatar},{corner(av/2)})
	local dot=create("Frame",{Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,1,1,1),Theme={BackgroundColor3="Good"},Parent=avatar},{corner(5),stroke("Element",2)})
	local col=create("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(av+26,0),Size=UDim2.new(1,-(av+36),1,0),Parent=card},{list(DirV,2,AlignL,AlignM)})
	local nameLabel=label("",small and 14 or 16,WBold,"Text",{Size=UDim2.new(1,0,0,small and 16 or 19),TextTruncate=Enum.TextTruncate.AtEnd,LayoutOrder=1,Parent=col})
	local subLabel=label("",small and 11 or 12,WMed,"Sub",{Size=UDim2.new(1,0,0,small and 13 or 15),TextTruncate=Enum.TextTruncate.AtEnd,LayoutOrder=2,Parent=col})
	local api={Frame=card}
	local state={UserId=cfg.UserId or LocalPlayer.UserId,Anonymous=cfg.Anonymous==true}
	function api.Refresh()
		local uid=state.UserId
		if state.Anonymous then
			nameLabel.Text=cfg.Title or "Anonymous"
			subLabel.Text=cfg.Subtitle or "@hidden"
			img.Image=""
			ph.Visible=true
			return
		end
		local display,name=LocalPlayer.DisplayName,LocalPlayer.Name
		nameLabel.Text=cfg.Title or display
		subLabel.Text=cfg.Subtitle or ("@"..name)
		task.spawn(function()
			if uid~=LocalPlayer.UserId then
				local ok,n=pcall(Players.GetNameFromUserIdAsync,Players,uid)
				if ok and n then
					nameLabel.Text=cfg.Title or n
					subLabel.Text=cfg.Subtitle or ("@"..n)
				end
			end
			local ok,thumb=pcall(Players.GetUserThumbnailAsync,Players,uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
			if ok and thumb and img.Parent then
				img.Image=thumb
				ph.Visible=false
			end
		end)
	end
	function api.SetUser(_,uid)state.UserId=uid api.Refresh()end
	function api.SetAnonymous(_,v)state.Anonymous=v~=false api.Refresh()end
	if cfg.Callback then
		local click=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=3,Parent=card})
		click.Activated:Connect(function()safe(cfg.Callback,state.UserId)end)
		hoverable(card,"BackgroundColor3","Element","Hover")
	end
	api.Refresh()
	return api
end

Elements.User=function(ctx,cfg)
	local api=userCard(ctx.Content,cfg,false)
	local el=plainElement(api.Frame)
	el.SetUser=api.SetUser
	el.SetAnonymous=api.SetAnonymous
	el.Refresh=api.Refresh
	return el
end

local function parseInvite(raw)
	raw=string.gsub(tostring(raw or ""),"%s+","")
	local code=string.match(raw,"discord%.gg/([%w%-_]+)") or string.match(raw,"discord%.com/invite/([%w%-_]+)") or string.match(raw,"discordapp%.com/invite/([%w%-_]+)") or string.match(raw,"^([%w%-_]+)$")
	if not code or code=="" then return nil,nil end
	return code,"https://discord.gg/"..code
end

local function formatNumber(n)
	local s=tostring(math.floor(n))
	local out=string.gsub(string.reverse(s),"(%d%d%d)","%1,")
	out=string.reverse(out)
	if string.sub(out,1,1)=="," then out=string.sub(out,2) end
	return out
end

Elements.Discord=function(ctx,cfg)
	local accent=typeof(cfg.Color)=="Color3" and cfg.Color or Color3.fromHex("#5865F2")
	local card=create("Frame",{Name="Row",Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Theme={BackgroundColor3="Element"},Parent=ctx.Content},{corner(R_EL),stroke("Stroke",1,0.45)})
	create("Frame",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,0,58),BackgroundColor3=Color3.new(1,1,1),Parent=card},{corner(R_SM),create("UIGradient",{Color=ColorSequence.new(accent:Lerp(Color3.new(0,0,0),0.55),accent),Rotation=12})})
	local ring=create("Frame",{Position=UDim2.fromOffset(16,34),Size=UDim2.fromOffset(60,60),ZIndex=3,Theme={BackgroundColor3="Element"},Parent=card},{corner(30)})
	local avatar=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(52,52),BackgroundColor3=accent,Parent=ring},{corner(26)})
	label("D",22,WBold,"Text",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,TextColor3=Color3.new(1,1,1),Theme={},Parent=avatar})
	local img=create("ImageLabel",{Size=UDim2.fromScale(1,1),ZIndex=2,Parent=avatar},{corner(26)})
	local body=create("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,64),Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=card},{pad(16,34,16,16),list(DirV,10)})
	local nameLabel=label(cfg.Title or "Discord server",19,WBold,"Text",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=1,Parent=body})
	local descLabel=label(cfg.Desc or "Join our community",13,WMed,"Sub",{Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,TextWrapped=true,LayoutOrder=2,Parent=body})
	local stats=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),LayoutOrder=3,Visible=false,Parent=body},{list(DirH,16,AlignL,AlignM)})
	local function stat(color)
		local f=create("Frame",{BackgroundTransparency=1,AutomaticSize=AutoXY,Visible=false,Parent=stats},{list(DirH,6,AlignL,AlignM)})
		create("Frame",{Size=UDim2.fromOffset(8,8),BackgroundColor3=color,LayoutOrder=1,Parent=f},{corner(4)})
		local t=label("",13,WMed,"Sub",{AutomaticSize=AutoXY,Size=UDim2.new(),LayoutOrder=2,Parent=f})
		return f,t
	end
	local onlineFrame,onlineText=stat(Color3.fromHex("#23a55a"))
	local memberFrame,memberText=stat(Color3.fromHex("#80848e"))
	local pill=create("TextButton",{Size=UDim2.new(1,0,0,36),LayoutOrder=4,Theme={BackgroundColor3="Panel"},Parent=body},{corner(R_EL),stroke("Stroke",1,0.3)})
	local linkText=label("",14,WMed,"Text",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(12,0),TextTruncate=Enum.TextTruncate.AtEnd,Parent=pill})
	hoverable(pill,"BackgroundColor3","Panel","Hover")
	local row=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),LayoutOrder=5,Parent=body},{list(DirH,8)})
	local el=plainElement(card)
	el.Invite=cfg.Invite or cfg.Link or cfg.Code or ""
	local copyLab
	function el:Copy()
		if not self.Link then
			Prism:Notify({Title="Discord",Content="Invalid invite link",Type="Warning",Duration=3})
			return false
		end
		local ok=copyText(self.Link)
		copyLab.Text=ok and "Copied" or "Failed"
		task.delay(1.5,function()if copyLab.Parent then copyLab.Text="Copy" end end)
		Prism:Notify({Title="Discord",Content=ok and "Invite copied to clipboard" or "Clipboard is not supported",Type=ok and "Success" or "Warning",Duration=2})
		safe(cfg.Callback,"copy",self.Link)
		return ok
	end
	function el:Join()
		if not self.Code then return end
		task.spawn(function()
			local opened=false
			if requestFn then
				local ok,res=pcall(requestFn,{Url="http://127.0.0.1:6463/rpc?v=1",Method="POST",Headers={["Content-Type"]="application/json",Origin="https://discord.com"},Body=HttpService:JSONEncode({cmd="INVITE_BROWSER",args={code=self.Code},nonce=HttpService:GenerateGUID(false)})})
				opened=ok and res~=nil and (res.StatusCode==200 or res.Success==true)
			end
			if opened then
				Prism:Notify({Title="Discord",Content="Invite opened in the Discord app",Type="Success",Duration=3})
			else
				copyText(self.Link)
				Prism:Notify({Title="Discord",Content="Discord did not respond. The link was copied instead",Type="Warning",Duration=4})
			end
			safe(cfg.Callback,"join",self.Link)
		end)
	end
	local showJoin=cfg.ShowJoin~=false
	if showJoin then
		local jb=smallButton(row,"Join","Primary",function()el:Join()end,UDim2.new(0.5,-4,1,0))
		unbind(jb,"BackgroundColor3")
		jb.BackgroundColor3=accent
		jb.LayoutOrder=1
	end
	local cb
	cb,copyLab=smallButton(row,"Copy","Secondary",function()el:Copy()end,showJoin and UDim2.new(0.5,-4,1,0) or UDim2.fromScale(1,1))
	cb.LayoutOrder=2
	pill.Activated:Connect(function()el:Copy()end)
	function el:Refresh()
		if not self.Code or not requestFn then return end
		task.spawn(function()
			local ok,res=pcall(requestFn,{Url="https://discord.com/api/v10/invites/"..self.Code.."?with_counts=true",Method="GET"})
			if not ok or not res or res.StatusCode~=200 then return end
			local ok2,data=pcall(function()return HttpService:JSONDecode(res.Body)end)
			if not ok2 or type(data)~="table" or not card.Parent then return end
			local g=data.guild or {}
			if not cfg.Title and g.name then nameLabel.Text=g.name end
			if not cfg.Desc and type(g.description)=="string" and g.description~="" then descLabel.Text=g.description end
			if cfg.ShowStats~=false then
				if data.approximate_presence_count then onlineText.Text=formatNumber(data.approximate_presence_count).." online" onlineFrame.Visible=true end
				if data.approximate_member_count then memberText.Text=formatNumber(data.approximate_member_count).." members" memberFrame.Visible=true end
				stats.Visible=onlineFrame.Visible or memberFrame.Visible
			end
			if g.id and g.icon and cfg.Avatar~=false then
				setRemoteImage(img,("https://cdn.discordapp.com/icons/%s/%s.png?size=128"):format(g.id,g.icon),"dc_"..g.id.."_"..g.icon)
			end
		end)
	end
	function el:SetInvite(raw)
		local code,link=parseInvite(raw)
		self.Invite,self.Code,self.Link=raw,code,link
		linkText.Text=code and ("discord.gg/"..code) or "Invalid invite link"
		self:Refresh()
	end
	function el:SetTitle(t)nameLabel.Text=t end
	function el:SetDesc(t)descLabel.Text=t end
	el:SetInvite(el.Invite)
	return el
end

Elements.Section=function(ctx,cfg)
	local headerH=40
	local wrapper=create("Frame",{Name="Row",Size=UDim2.new(1,0,0,headerH),ClipsDescendants=true,Theme={BackgroundColor3="Element"},Parent=ctx.Content},{corner(R_EL),stroke("Stroke",1,0.45)})
	local header=create("TextButton",{Size=UDim2.new(1,0,0,headerH),BackgroundTransparency=1,Parent=wrapper})
	local ic=iconNode(cfg.Icon,18,"Accent",true)
	local titleX=14
	if ic then ic.AnchorPoint=Vector2.new(0,0.5) ic.Position=UDim2.new(0,14,0.5,0) ic.Parent=header titleX=40 end
	local title=label(cfg.Title or "Section",14,WBold,"Text",{Position=UDim2.new(0,titleX,0,0),Size=UDim2.new(1,-titleX-40,1,0),TextTruncate=Enum.TextTruncate.AtEnd,Parent=header})
	local chev=label(">",16,WBold,"Sub",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0.5,0),Size=UDim2.fromOffset(16,16),TextXAlignment=XCenter,Rotation=90,Parent=header})
	local content=create("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,headerH),Size=UDim2.new(1,0,0,0),Parent=wrapper},{pad(10,0,10,10)})
	local layout=list(DirV,8)
	layout.Parent=content
	local opened=cfg.Opened~=false
	local animating=false
	local function target()
		if not opened then return headerH end
		return headerH+layout.AbsoluteContentSize.Y/uiScale+10
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if opened and not animating then wrapper.Size=UDim2.new(1,0,0,target()) end
	end)
	chev.Rotation=opened and 270 or 90
	header.Activated:Connect(function()
		opened=not opened
		animating=true
		tween(wrapper,0.3,{Size=UDim2.new(1,0,0,target())})
		tween(chev,0.25,{Rotation=opened and 270 or 90})
		task.delay(0.32,function()animating=false end)
	end)
	local section=plainElement(wrapper)
	section.Content=content
	section.Window=ctx.Window
	section.Elements={}
	section.Compact=ctx.Compact
	function section:SetTitle(t)title.Text=t end
	function section:Open()if not opened then opened=true tween(wrapper,0.3,{Size=UDim2.new(1,0,0,target())}) end end
	function section:Close()if opened then opened=false tween(wrapper,0.3,{Size=UDim2.new(1,0,0,headerH)}) end end
	task.defer(function()if opened then wrapper.Size=UDim2.new(1,0,0,target()) end end)
	section.__container=true
	return section
end

Elements.Group=function(ctx,cfg)
	local gap=6
	local frame=create("Frame",{Name="Group",BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=ctx.Content},{list(DirH,gap,AlignL,AlignT)})
	local group=plainElement(frame)
	group.Content=frame
	group.Window=ctx.Window
	group.Elements={}
	group.Narrow=true
	group.__container=true
	function group:OnAdd()
		local n=#self.Elements
		for _,e in ipairs(self.Elements)do
			if e.Row then
				e.Row.Size=UDim2.new(1/n,-(gap*(n-1)/n),0,0)
			end
		end
	end
	return group
end

local function register(container,el,cfg)
	el.Container=container
	table.insert(container.Elements,el)
	if cfg.Flag and container.Window and container.Window.Flags then
		container.Window.Flags[cfg.Flag]=el
	end
	if container.OnAdd then container:OnAdd(el) end
end

local function attach(container)
	for name,builder in pairs(Elements)do
		container[name]=function(self,cfg)
			cfg=cfg or {}
			local el=builder(self,cfg)
			if el then
				if el.__container then
					el.Container=self
					table.insert(self.Elements,el)
					attach(el)
					if self.OnAdd then self:OnAdd(el) end
				else
					register(self,el,cfg)
				end
			end
			return el
		end
	end
	function container:LockAll()for _,e in ipairs(self.Elements)do if e.Lock then e:Lock()end end end
	function container:UnlockAll()for _,e in ipairs(self.Elements)do if e.Unlock then e:Unlock()end end end
end

local function newConfigManager(win,folderName)
	local mgr={Configs={}}
	local dir=folderName.."/configs"
	local function ensure()
		if not hasFiles then return end
		pcall(function()
			if not isfolder(folderName) then makefolder(folderName) end
			if not isfolder(dir) then makefolder(dir) end
		end)
	end
	function mgr:CreateConfig(name)
		local config={Name=name,Path=dir.."/"..name..".json"}
		function config:Save()
			local data={}
			for flag,el in pairs(win.Flags)do
				if el.Export then
					local ok,v=pcall(el.Export,el)
					if ok then data[flag]=v end
				end
			end
			if hasFiles then
				ensure()
				pcall(writefile,self.Path,HttpService:JSONEncode(data))
			end
			return data
		end
		function config:Load()
			if not hasFiles or not isfile(self.Path) then return false,"missing" end
			local ok,data=pcall(function()return HttpService:JSONDecode(readfile(self.Path))end)
			if not ok or type(data)~="table" then return false,"invalid" end
			for flag,v in pairs(data)do
				local el=win.Flags[flag]
				if el and el.Import then pcall(el.Import,el,v) end
			end
			return true
		end
		function config:Delete()
			if hasFiles and delfile and isfile(self.Path) then
				pcall(delfile,self.Path)
				mgr.Configs[name]=nil
				return true
			end
			return false
		end
		mgr.Configs[name]=config
		return config
	end
	function mgr:GetConfig(name)return self.Configs[name]end
	function mgr:AllConfigs()
		local out={}
		if hasFiles and listfiles then
			ensure()
			local ok,files=pcall(listfiles,dir)
			if ok then
				for _,p in ipairs(files)do
					local n=string.match(p,"([^/\\]+)%.json$")
					if n then table.insert(out,n) end
				end
			end
		end
		return out
	end
	return mgr
end

local function runKeySystem(cfg)
	local ks=cfg.KeySystem
	local folderName=cfg.Folder or cfg.Title or "Prism"
	local path=folderName.."/key.txt"
	local function valid(k)
		if ks.KeyValidator then
			local ok,res=pcall(ks.KeyValidator,k)
			return ok and res and true or false
		end
		if type(ks.Key)=="table" then return table.find(ks.Key,k)~=nil end
		return tostring(ks.Key)==k
	end
	if ks.SaveKey and hasFiles then
		local ok,saved=pcall(function()if isfile(path)then return readfile(path)end end)
		if ok and saved and valid(saved) then return true end
	end
	local done,passed=false,false
	local input=""
	local buttons={
		{Title="Exit",Variant="Secondary",Callback=function()done=true passed=false end},
	}
	if ks.URL then
		table.insert(buttons,{Title="Get key",Variant="Secondary",Callback=function()
			local ok=copyText(ks.URL)
			Prism:Notify({Title="Key system",Content=ok and "Key link copied to clipboard" or "Clipboard is not supported",Type=ok and "Success" or "Warning"})
			return false
		end})
	end
	table.insert(buttons,{Title="Submit",Variant="Primary",Callback=function()
		if valid(input) then
			if ks.SaveKey and hasFiles then
				pcall(function()
					if not isfolder(folderName) then makefolder(folderName) end
					writefile(path,input)
				end)
			end
			passed=true
			done=true
			return true
		end
		Prism:Notify({Title="Key system",Content="Invalid key",Type="Error",Duration=3})
		return false
	end})
	makeDialog({Title=ks.Title or cfg.Title or "Key system",Icon="key",Content=ks.Note,Buttons=buttons,Build=function(body)
		local holder=create("Frame",{Size=UDim2.new(1,0,0,38),Theme={BackgroundColor3="Element"},Parent=body},{corner(R_EL)})
		local st=stroke("Stroke",1,0.3)
		st.Parent=holder
		local tb=create("TextBox",{Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(10,0),PlaceholderText="Enter key",TextSize=14,TextXAlignment=XLeft,Theme={TextColor3="Text",PlaceholderColor3="Sub"},Parent=holder})
		tb.Focused:Connect(function()paint(st,"Color","Accent",0.15)end)
		tb.FocusLost:Connect(function()paint(st,"Color","Stroke",0.15) input=tb.Text end)
		tb:GetPropertyChangedSignal("Text"):Connect(function()input=tb.Text end)
	end})
	repeat task.wait() until done
	return passed
end

local function setTabActive(tab,on)
	local item=tab.Item
	tween(item,0.2,{BackgroundTransparency=on and 0.88 or 1})
	tween(tab.Bar,0.25,{Size=UDim2.new(0,3,0,on and 18 or 0)},EaseBack)
	paint(tab.TitleLabel,"TextColor3",on and "Text" or "Sub",0.2)
	if tab.IconNode then
		local prop=tab.IconNode:IsA("ImageLabel") and "ImageColor3" or "TextColor3"
		if on or bindings[tab.IconNode] then paint(tab.IconNode,prop,on and "Accent" or "Sub",0.2) end
	end
end

local function selectTab(win,tab)
	if tab.Locked or win.CurrentTab==tab then return end
	local old=win.CurrentTab
	win.CurrentTab=tab
	if old then
		setTabActive(old,false)
		old.Page.Visible=false
	end
	setTabActive(tab,true)
	tab.Page.Visible=true
	tab.Page.Position=UDim2.fromOffset(0,18)
	tween(tab.Page,0.35,{Position=UDim2.fromOffset(0,0)})
	win.HeaderTitle.Text=tab.Title
	win.HeaderTitle.Position=UDim2.fromOffset(26,0)
	win.HeaderTitle.TextTransparency=1
	tween(win.HeaderTitle,0.3,{Position=UDim2.fromOffset(16,0),TextTransparency=0})
	win.HeaderDesc.Text=tab.Desc or ""
	local n=0
	for _,child in ipairs(tab.Page:GetChildren())do
		if child.Name=="Row" and n<14 then
			n=n+1
			local base=child:GetAttribute("BaseT") or 0
			child.BackgroundTransparency=1
			task.delay((n-1)*0.035,function()
				if child.Parent then tween(child,0.35,{BackgroundTransparency=base}) end
			end)
		end
	end
end

local function createTab(win,cfg,parentList)
	cfg=cfg or {}
	local compact=win.Compact
	local tab={Title=cfg.Title or "Tab",Desc=cfg.Desc,Elements={},Window=win,Locked=cfg.Locked==true,Compact=compact}
	local item=create("TextButton",{Name="Tab",Size=UDim2.new(1,0,0,compact and 38 or 40),BackgroundTransparency=1,Theme={BackgroundColor3="Accent"},Parent=parentList},{corner(R_EL)})
	local bar=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(0,3,0,0),Theme={BackgroundColor3="Accent"},Parent=item},{corner(2)})
	local inner=create("Frame",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=item},{pad(12,0),list(DirH,10,AlignL,AlignM)})
	local icon=iconNode(cfg.Icon,18,"Sub",true)
	if icon then icon.LayoutOrder=1 icon.Parent=inner end
	local titleLabel=label(tab.Title,14,WSemi,"Sub",{Size=UDim2.new(1,icon and -28 or 0,1,0),TextTruncate=Enum.TextTruncate.AtEnd,LayoutOrder=2,TextTransparency=tab.Locked and 0.5 or 0,Parent=inner})
	tab.Item=item
	tab.Bar=bar
	tab.TitleLabel=titleLabel
	tab.IconNode=icon
	local page=create("ScrollingFrame",{Name="Page",Size=UDim2.fromScale(1,1),Visible=false,AutomaticCanvasSize=AutoY,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=compact and 0 or 3,ScrollBarImageTransparency=0.5,Theme={ScrollBarImageColor3="Accent"},Parent=win.Pages},{pad(compact and 10 or 14,compact and 10 or 14,compact and 10 or 14,16),list(DirV,8)})
	tab.Page=page
	tab.Content=page
	local empty=label("Nothing here yet",14,WMed,"Sub",{Size=UDim2.new(1,0,0,70),TextXAlignment=XCenter,Parent=page})
	tab.EmptyLabel=empty
	function tab:OnAdd()
		if self.EmptyLabel then self.EmptyLabel:Destroy() self.EmptyLabel=nil end
	end
	attach(tab)
	item.MouseEnter:Connect(function()
		if win.CurrentTab~=tab and not tab.Locked then tween(item,0.12,{BackgroundTransparency=0.94}) end
	end)
	item.MouseLeave:Connect(function()
		if win.CurrentTab~=tab then tween(item,0.12,{BackgroundTransparency=1}) end
	end)
	item.Activated:Connect(function()selectTab(win,tab)end)
	function tab:Select()selectTab(win,self)end
	function tab:Lock()self.Locked=true tween(titleLabel,0.2,{TextTransparency=0.5})end
	function tab:Unlock()self.Locked=false tween(titleLabel,0.2,{TextTransparency=0})end
	function tab:SetTitle(t)self.Title=t titleLabel.Text=t if win.CurrentTab==self then win.HeaderTitle.Text=t end end
	function tab:Destroy()
		item:Destroy()
		page:Destroy()
		local i=table.find(win.Tabs,self)
		if i then table.remove(win.Tabs,i) end
		if win.CurrentTab==self then
			win.CurrentTab=nil
			if win.Tabs[1] then selectTab(win,win.Tabs[1]) end
		end
	end
	table.insert(win.Tabs,tab)
	if not win.CurrentTab and not tab.Locked then selectTab(win,tab) end
	return tab
end

local function isCompact()
	local vp=viewport()
	return (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X<760
end

function Prism:CreateWindow(cfg)
	cfg=cfg or {}
	ensureGui()
	if cfg.Theme and Themes[cfg.Theme] then setThemeInternal(cfg.Theme) end
	if cfg.KeySystem then
		if not runKeySystem(cfg) then return nil end
	end
	local compact=isCompact()
	local win={Tabs={},Flags={},Closed=false,Destroyed=false,Compact=compact,Title=cfg.Title or "Prism",Folder=cfg.Folder or cfg.Title or "Prism"}
	local W=(cfg.Size and cfg.Size.X.Offset) or (compact and 620 or 720)
	local H=(cfg.Size and cfg.Size.Y.Offset) or (compact and 400 or 500)
	local minSize=cfg.MinSize or Vector2.new(520,340)
	local maxSize=cfg.MaxSize or Vector2.new(1100,760)
	local sideW=cfg.SideBarWidth or (compact and 150 or 200)
	local TOPBAR=compact and 46 or 52
	local conns={}

	local function fitScale()
		if cfg.UIScale then applyScale(cfg.UIScale) return end
		local vp=viewport()
		local w=win.Holder and win.Holder.Size.X.Offset or W
		local h=win.Holder and win.Holder.Size.Y.Offset or H
		applyScale(clamp(math.min((vp.X-20)/w,(vp.Y-20)/h),0.5,1))
	end
	applyScale(1)
	do
		local vp=viewport()
		applyScale(cfg.UIScale or clamp(math.min((vp.X-20)/W,(vp.Y-20)/H),0.5,1))
	end

	local holder=create("Frame",{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),Position=cfg.Position or UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1,Active=true,Parent=layers.window})
	win.Holder=holder
	local anim=create("UIScale",{Scale=0.9,Parent=holder})
	if not compact then
		create("ImageLabel",{Name="Shadow",Image="rbxassetid://6014261993",ImageColor3=Color3.new(0,0,0),ImageTransparency=0.55,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),Size=UDim2.new(1,56,1,56),Position=UDim2.fromOffset(-28,-20),ZIndex=0,Parent=holder})
	end
	local body=create("Frame",{Name="Body",Size=UDim2.fromScale(1,1),ClipsDescendants=true,Theme={BackgroundColor3="Background"},Parent=holder},{corner(R_WIN),stroke("Stroke",1,0.2)})
	if cfg.Background then
		create("ImageLabel",{Size=UDim2.fromScale(1,1),Image=type(cfg.Background)=="number" and ("rbxassetid://"..cfg.Background) or cfg.Background,ImageTransparency=cfg.BackgroundImageTransparency or 0.85,ScaleType=Enum.ScaleType.Crop,Parent=body},{corner(R_WIN)})
	end

	local topbar=create("Frame",{Name="Topbar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,TOPBAR),Parent=body})
	local titleBox=create("Frame",{BackgroundTransparency=1,AutomaticSize=AutoXY,Position=UDim2.fromOffset(16,0),Size=UDim2.new(0,0,1,0),Parent=topbar},{list(DirH,10,AlignL,AlignM)})
	local topIcon=iconNode(cfg.Icon,22,"Accent",true)
	if topIcon then topIcon.LayoutOrder=1 topIcon.Parent=titleBox end
	local titleCol=create("Frame",{BackgroundTransparency=1,AutomaticSize=AutoXY,LayoutOrder=2,Parent=titleBox},{list(DirV,0,AlignL,AlignM)})
	local titleLabel=label(win.Title,17,WBold,"Text",{AutomaticSize=AutoXY,Size=UDim2.new(),LayoutOrder=1,Parent=titleCol})
	local authorLabel=label(cfg.Author or "",12,WMed,"Sub",{AutomaticSize=AutoXY,Size=UDim2.new(),LayoutOrder=2,Visible=cfg.Author~=nil and cfg.Author~="",Parent=titleCol})

	local buttonsBox=create("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),AutomaticSize=AutoXY,Size=UDim2.new(),Parent=topbar},{list(DirH,4,AlignR,AlignM)})
	local function topButton(order,build,hoverKey,onClick)
		local b=create("TextButton",{Size=UDim2.fromOffset(compact and 34 or 32,compact and 34 or 32),LayoutOrder=order,BackgroundTransparency=1,Theme={BackgroundColor3=hoverKey or "Hover"},Parent=buttonsBox},{corner(R_EL)})
		build(b)
		b.MouseEnter:Connect(function()tween(b,0.12,{BackgroundTransparency=0})end)
		b.MouseLeave:Connect(function()tween(b,0.12,{BackgroundTransparency=1})end)
		b.Activated:Connect(function()safe(onClick)end)
		return b
	end

	local tagBox=create("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-(compact and 120 or 124),0.5,0),AutomaticSize=AutoXY,Size=UDim2.new(),Parent=topbar},{list(DirH,6,AlignR,AlignM)})
	function win:Tag(tc)
		tc=tc or {}
		local keyOrColor=tc.Color
		local tag=create("Frame",{AutomaticSize=AutoXY,Size=UDim2.new(),Parent=tagBox},{corner(10),pad(10,4),list(DirH,5,AlignL,AlignM)})
		if typeof(keyOrColor)=="Color3" then tag.BackgroundColor3=keyOrColor else bind(tag,"BackgroundColor3",keyOrColor or "Accent") end
		local tl=create("TextLabel",{Text=tc.Title or "Tag",TextSize=12,FontFace=font(WBold),AutomaticSize=AutoXY,Size=UDim2.new(),Theme={TextColor3="AccentText"},Parent=tag})
		local api={}
		function api:SetTitle(t)tl.Text=t end
		function api:SetColor(c)unbind(tag,"BackgroundColor3") tag.BackgroundColor3=c end
		function api:Destroy()tag:Destroy()end
		return api
	end

	local minBtn=topButton(1,function(b)
		create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(12,2),Theme={BackgroundColor3="Sub"},Parent=b},{corner(1)})
	end,"Hover",function()win:Close()end)
	local maxBtn=topButton(2,function(b)
		create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(11,11),BackgroundTransparency=1,Parent=b},{corner(2),stroke("Sub",2)})
	end,"Hover",function()win:ToggleFullscreen()end)
	local closeBtn=topButton(3,function(b)
		label("×",24,WBold,"Sub",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Parent=b})
	end,"Bad",function()
		if cfg.IgnoreAlerts then win:Destroy() return end
		makeDialog({Title="Close window",Content="Do you want to close this window? You will need to run the script again to open it.",Icon="!",Buttons={{Title="Cancel",Variant="Secondary"},{Title="Close",Variant="Danger",Callback=function()win:Destroy()end}}})
	end)

	local accentLine=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0,TOPBAR),Size=UDim2.new(1,-28,0,2),Theme={BackgroundColor3="Accent"},Parent=body},{corner(1)})
	local lineGrad=create("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0.1),NumberSequenceKeypoint.new(1,1)}),Offset=Vector2.new(-0.45,0),Parent=accentLine})
	TweenService:Create(lineGrad,TweenInfo.new(2.6,EaseSine,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(0.45,0)}):Play()

	makeDraggable(topbar,holder)

	local sidebar=create("Frame",{Name="Sidebar",BackgroundTransparency=1,Position=UDim2.fromOffset(0,TOPBAR),Size=UDim2.new(0,sideW,1,-TOPBAR),Parent=body})
	local userHeight=(cfg.User and cfg.User.Enabled~=false) and 62 or 0
	local searchHeight=(cfg.HideSearchBar==false or (cfg.HideSearchBar==nil and not compact)) and 44 or 0
	if searchHeight>0 then
		local sb=create("Frame",{Position=UDim2.fromOffset(10,8),Size=UDim2.new(1,-20,0,32),Theme={BackgroundColor3="Panel"},Parent=sidebar},{corner(R_EL),stroke("Stroke",1,0.3)})
		local sIcon=iconNode("search",16,"Sub",true)
		sIcon.AnchorPoint=Vector2.new(0,0.5)
		sIcon.Position=UDim2.new(0,8,0.5,0)
		sIcon.Parent=sb
		local tb=create("TextBox",{Position=UDim2.fromOffset(30,0),Size=UDim2.new(1,-38,1,0),PlaceholderText="Search",TextSize=14,TextXAlignment=XLeft,Theme={TextColor3="Text",PlaceholderColor3="Sub"},Parent=sb})
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			local q=string.lower(tb.Text)
			for _,t in ipairs(win.Tabs)do
				t.Item.Visible=q=="" or string.find(string.lower(t.Title),q,1,true)~=nil
			end
		end)
	end
	win.SideList=create("ScrollingFrame",{Position=UDim2.fromOffset(0,searchHeight),Size=UDim2.new(1,0,1,-(searchHeight+userHeight)),AutomaticCanvasSize=AutoY,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=sidebar},{pad(10,6,10,6),list(DirV,4)})
	if userHeight>0 then
		local holderUser=create("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,userHeight),Parent=sidebar},{pad(10,0,10,8)})
		local uc=cfg.User
		userCard(holderUser,{UserId=uc.UserId,Anonymous=uc.Anonymous,Callback=uc.Callback,Title=uc.Title,Subtitle=uc.Subtitle},true)
	end

	local panel=create("Frame",{Name="Panel",Position=UDim2.fromOffset(sideW,TOPBAR+2),Size=UDim2.new(1,-sideW-10,1,-TOPBAR-12),ClipsDescendants=true,Theme={BackgroundColor3="Panel"},Parent=body},{corner(8),stroke("Stroke",1,0.35)})
	local header=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,46),Parent=panel})
	win.HeaderTitle=label("",20,WBold,"Text",{Position=UDim2.fromOffset(16,0),Size=UDim2.new(0.6,0,0,30),Parent=header})
	win.HeaderDesc=label("",12,WMed,"Sub",{Position=UDim2.fromOffset(16,26),Size=UDim2.new(1,-32,0,16),TextTruncate=Enum.TextTruncate.AtEnd,Visible=false,Parent=header})
	win.HeaderTitle.Position=UDim2.fromOffset(16,0)
	win.HeaderTitle.Size=UDim2.new(1,-32,1,0)
	create("Frame",{Position=UDim2.new(0,12,1,-1),Size=UDim2.new(1,-24,0,1),Theme={BackgroundColor3="Stroke"},BackgroundTransparency=0.4,Parent=header})
	win.Pages=create("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,46),Size=UDim2.new(1,0,1,-46),ClipsDescendants=true,Parent=panel})

	if cfg.Resizable~=false then
		local grip=create("TextButton",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-3,1,-3),Size=UDim2.fromOffset(compact and 26 or 20,compact and 26 or 20),BackgroundTransparency=1,ZIndex=20,Parent=body})
		local gripDot=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(8,8),BackgroundTransparency=0.4,Theme={BackgroundColor3="Sub"},Parent=grip},{corner(4)})
		grip.MouseEnter:Connect(function()tween(gripDot,0.15,{Size=UDim2.fromOffset(12,12),BackgroundTransparency=0})end)
		grip.MouseLeave:Connect(function()tween(gripDot,0.15,{Size=UDim2.fromOffset(8,8),BackgroundTransparency=0.4})end)
		grip.InputBegan:Connect(function(input)
			if input.UserInputType~=MouseBtn and input.UserInputType~=TouchIn then return end
			if win.Fullscreen then return end
			local startPointer=pointerPos(input)
			local startSize=Vector2.new(holder.Size.X.Offset,holder.Size.Y.Offset)
			local startCenter=(holder.AbsolutePosition+holder.AbsoluteSize*holder.AnchorPoint)/uiScale
			startDrag(input,function(i)
				local delta=(pointerPos(i)-startPointer)/uiScale
				local ns=Vector2.new(clamp(startSize.X+delta.X,minSize.X,maxSize.X),clamp(startSize.Y+delta.Y,minSize.Y,maxSize.Y))
				local shift=(ns-startSize)/2
				holder.Size=UDim2.fromOffset(ns.X,ns.Y)
				holder.Position=UDim2.fromOffset(startCenter.X+shift.X,startCenter.Y+shift.Y)
			end,function()
				if not cfg.UIScale then fitScale() end
			end)
		end)
	end

	local tbCfg=cfg.ToggleButton or {}
	local tbSize=compact and 54 or 48
	local toggle=create("TextButton",{Name="ToggleButton",AnchorPoint=Vector2.new(0.5,0.5),Position=tbCfg.Position or UDim2.new(0.5,0,0,compact and 36 or 34),Size=UDim2.fromOffset(tbSize,tbSize),Theme={BackgroundColor3="Accent"},Visible=tbCfg.Visible~=false,Parent=layers.float},{corner(tbSize/2),create("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=0.55}),create("UIGradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(190,190,190)),Rotation=45})})
	local tbScale=create("UIScale",{Scale=1,Parent=toggle})
	local letter=label(string.upper(tbCfg.Letter or string.sub(win.Title,1,1)),compact and 24 or 22,WBold,"AccentText",{Size=UDim2.fromScale(1,1),TextXAlignment=XCenter,Rotation=0,Parent=toggle})
	toggle.MouseEnter:Connect(function()tween(tbScale,0.15,{Scale=1.1})end)
	toggle.MouseLeave:Connect(function()tween(tbScale,0.15,{Scale=1})end)
	toggle.InputBegan:Connect(function(i)
		if i.UserInputType==MouseBtn or i.UserInputType==TouchIn then tween(tbScale,0.08,{Scale=0.9}) end
	end)
	toggle.InputEnded:Connect(function(i)
		if i.UserInputType==MouseBtn or i.UserInputType==TouchIn then tween(tbScale,0.25,{Scale=1},EaseBack) end
	end)
	makeDraggable(toggle,toggle,function(moved)
		if not moved then win:Toggle() end
	end,tbSize/2)
	win.ToggleButton=toggle

	function win:Open()
		if self.Destroyed or not self.Closed then return end
		self.Closed=false
		holder.Visible=true
		anim.Scale=0.88
		tween(anim,0.4,{Scale=1},EaseBack)
		tween(letter,0.4,{Rotation=360},EaseBack)
		task.delay(0.42,function()letter.Rotation=0 end)
		safe(self.OnOpenCallback)
	end
	function win:Close()
		if self.Destroyed or self.Closed then return end
		self.Closed=true
		tween(anim,0.22,{Scale=0.88},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
		task.delay(0.22,function()if self.Closed then holder.Visible=false end end)
		safe(self.OnCloseCallback)
	end
	function win:Toggle()if self.Closed then self:Open() else self:Close() end end
	function win:OnOpen(fn)self.OnOpenCallback=fn end
	function win:OnClose(fn)self.OnCloseCallback=fn end
	function win:OnDestroy(fn)self.OnDestroyCallback=fn end
	function win:SetToggleKey(k)cfg.ToggleKey=k end
	function win:SetTitle(t)self.Title=t titleLabel.Text=t end
	function win:SetAuthor(t)authorLabel.Text=t authorLabel.Visible=t~=nil and t~=""end
	function win:SetSize(s)
		if typeof(s)=="UDim2" then
			holder.Size=UDim2.fromOffset(clamp(s.X.Offset,minSize.X,maxSize.X),clamp(s.Y.Offset,minSize.Y,maxSize.Y))
			if not cfg.UIScale then fitScale() end
		end
	end
	function win:SetUIScale(s)cfg.UIScale=s applyScale(s)end
	function win:SetTheme(name)return setThemeInternal(name)end
	function win:SetToCenter()tween(holder,0.4,{Position=UDim2.fromScale(0.5,0.5)})end
	function win:EditToggleButton(c)
		c=c or {}
		if c.Letter then letter.Text=string.upper(c.Letter) end
		if c.Visible~=nil then toggle.Visible=c.Visible end
		if c.Position then toggle.Position=c.Position end
	end
	win.EditOpenButton=win.EditToggleButton
	function win:Dialog(c)return makeDialog(c)end
	function win:Notify(c)return Prism:Notify(c)end
	function win:LockAll()for _,e in pairs(self.Flags)do if e.Lock then e:Lock()end end for _,t in ipairs(self.Tabs)do t:LockAll()end end
	function win:UnlockAll()for _,e in pairs(self.Flags)do if e.Unlock then e:Unlock()end end for _,t in ipairs(self.Tabs)do t:UnlockAll()end end
	function win:SelectTab(t)
		if type(t)=="number" then t=self.Tabs[t] end
		if t then selectTab(self,t) end
	end
	function win:Tab(c)return createTab(self,c,self.SideList)end
	function win:Divider()
		create("Frame",{Size=UDim2.new(1,0,0,9),BackgroundTransparency=1,Parent=self.SideList},{create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,0,1),Theme={BackgroundColor3="Stroke"}})})
	end
	function win:Section(c)
		c=c or {}
		local sec={}
		local box=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=AutoY,Parent=self.SideList},{list(DirV,4)})
		label(string.upper(c.Title or "Section"),11,WBold,"Sub",{Size=UDim2.new(1,0,0,22),TextTransparency=0.15,LayoutOrder=0,Parent=box},nil)
		create("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingTop=UDim.new(0,4),Parent=box:FindFirstChildOfClass("TextLabel")})
		function sec:Tab(tc)
			return createTab(win,tc,box)
		end
		function sec:Destroy()box:Destroy()end
		return sec
	end
	function win:ToggleFullscreen()
		if not self.Fullscreen then
			self.Fullscreen=true
			self.Restore={Size=holder.Size,Position=holder.Position}
			local vp=viewport()/uiScale
			tween(holder,0.4,{Size=UDim2.fromOffset(vp.X-20,vp.Y-20),Position=UDim2.fromOffset(vp.X/2,vp.Y/2)})
		else
			self.Fullscreen=false
			tween(holder,0.4,{Size=self.Restore.Size,Position=self.Restore.Position})
		end
	end
	function win:Destroy()
		if self.Destroyed then return end
		self.Destroyed=true
		safe(self.OnDestroyCallback)
		tween(anim,0.25,{Scale=0.85},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
		task.delay(0.26,function()
			holder:Destroy()
			toggle:Destroy()
			for _,c in ipairs(conns)do c:Disconnect()end
			local i=table.find(Prism.Windows,self)
			if i then table.remove(Prism.Windows,i) end
			if #Prism.Windows==0 and gui then
				gui:Destroy()
				gui=nil
				notifHolder=nil
			end
		end)
	end

	win.ConfigManager=newConfigManager(win,win.Folder)

	table.insert(conns,UserInputService.InputBegan:Connect(function(input,gp)
		if gp or not cfg.ToggleKey then return end
		local key=cfg.ToggleKey
		if typeof(key)=="EnumItem" then
			if input.KeyCode==key then win:Toggle() end
		elseif type(key)=="string" and input.KeyCode.Name==key then
			win:Toggle()
		end
	end))
	local cam=Workspace.CurrentCamera
	if cam then
		table.insert(conns,cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if not cfg.UIScale and not win.Fullscreen then fitScale() end
		end))
	end

	table.insert(Prism.Windows,win)
	win.Closed=true
	holder.Visible=false
	win:Open()
	return win
end

function Prism:AddTheme(t)
	if type(t)~="table" or not t.Name then return nil end
	local base={}
	for k,v in pairs(Themes.Midnight)do base[k]=v end
	for k,v in pairs(t)do base[k]=v end
	return addTheme(t.Name,base)
end

function Prism:SetTheme(name)return setThemeInternal(name)end
function Prism:GetThemes()return Themes end
function Prism:GetCurrentTheme()return currentTheme.Name end
function Prism:OnThemeChange(fn)
	local id=HttpService:GenerateGUID(false)
	themeListeners[id]=fn
	return {Disconnect=function()themeListeners[id]=nil end}
end

function Prism:Destroy()
	for _,w in ipairs(table.clone(Prism.Windows))do w:Destroy() end
	if gui then gui:Destroy() gui=nil end
	notifHolder=nil
end

return Prism
