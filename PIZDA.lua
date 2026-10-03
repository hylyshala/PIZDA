--[[
    WindUI Plus  —  надстройка над WindUI (Footagesus, MIT)

    Что даёт:
      • новый внешний вид по умолчанию (скругления, Mac-кнопки, поиск, акцентная линия, тень)
      • 5 новых тем: Nebula (по умолчанию), Discord, Mocha, Sakura, Ocean
      • Tab:Discord{ Invite = "https://discord.gg/xxxx" }  — карточка сервера с аватаркой,
        названием, онлайном/участниками (берётся из Discord API), кнопками "Войти" и "Копировать"
      • Tab:Callout{ Type = "Info"|"Success"|"Warning"|"Error", Title, Desc } — цветные заметки
      • Tab:Link{ Title, Desc, Url } — карточка-ссылка с кнопкой копирования (сайт, YouTube, GitHub...)

    Использование: см. example.lua
    Если у вас свой билд WindUI — задайте перед загрузкой:
        getgenv().WindUI_SOURCE = "https://ваша-ссылка/main.lua"
]]

local cloneref = cloneref or clonereference or function(x) return x end
local HttpService = cloneref(game:GetService("HttpService"))

local SOURCE = (getgenv and getgenv().WindUI_SOURCE)
	or "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

local WindUI = loadstring(game:HttpGet(SOURCE))()
local Creator = WindUI.Creator
local New, Tween = Creator.New, Creator.Tween

local BLURPLE = Color3.fromHex("#5865F2")
local WHITE = Color3.new(1, 1, 1)

-- ════════════════════════════════════════════════════════════════
--  ТЕМЫ
-- ════════════════════════════════════════════════════════════════
local function theme(name, t)
	t.Name = name
	t.ElementBackgroundTransparency = 0
	WindUI:AddTheme(t)
end

theme("Nebula", {
	Accent = Color3.fromHex("#1b1535"), Dialog = Color3.fromHex("#150f2b"),
	Text = Color3.fromHex("#ede9fe"), Placeholder = Color3.fromHex("#8b7fc7"),
	Background = Color3.fromHex("#0d0a1f"), Button = Color3.fromHex("#7c5cff"),
	Primary = Color3.fromHex("#7c5cff"), Icon = Color3.fromHex("#a78bfa"),
	Toggle = Color3.fromHex("#22d3ee"), Slider = Color3.fromHex("#7c5cff"),
	Checkbox = Color3.fromHex("#7c5cff"), ElementBackground = Color3.fromHex("#1a1533"),
})

theme("Discord", {
	Accent = Color3.fromHex("#2b2d31"), Dialog = Color3.fromHex("#232428"),
	Text = Color3.fromHex("#f2f3f5"), Placeholder = Color3.fromHex("#949ba4"),
	Background = Color3.fromHex("#1e1f22"), Button = BLURPLE, Primary = BLURPLE,
	Icon = Color3.fromHex("#b5bac1"), Toggle = Color3.fromHex("#23a55a"),
	Slider = BLURPLE, Checkbox = BLURPLE, ElementBackground = Color3.fromHex("#2b2d31"),
})

theme("Mocha", {
	Accent = Color3.fromHex("#313244"), Dialog = Color3.fromHex("#1e1e2e"),
	Text = Color3.fromHex("#cdd6f4"), Placeholder = Color3.fromHex("#7f849c"),
	Background = Color3.fromHex("#181825"), Button = Color3.fromHex("#89b4fa"),
	Primary = Color3.fromHex("#89b4fa"), Icon = Color3.fromHex("#b4befe"),
	Toggle = Color3.fromHex("#a6e3a1"), Slider = Color3.fromHex("#89b4fa"),
	Checkbox = Color3.fromHex("#89b4fa"), ElementBackground = Color3.fromHex("#2a2b3c"),
})

theme("Sakura", {
	Accent = Color3.fromHex("#4a1d34"), Dialog = Color3.fromHex("#2d1220"),
	Text = Color3.fromHex("#fff0f6"), Placeholder = Color3.fromHex("#d98cb0"),
	Background = Color3.fromHex("#1a0a12"), Button = Color3.fromHex("#ff6fa5"),
	Primary = Color3.fromHex("#ff6fa5"), Icon = Color3.fromHex("#ff9ec4"),
	Toggle = Color3.fromHex("#ff6fa5"), Slider = Color3.fromHex("#ff6fa5"),
	Checkbox = Color3.fromHex("#ff6fa5"), ElementBackground = Color3.fromHex("#3a1b2b"),
})

theme("Ocean", {
	Accent = Color3.fromHex("#0c3a4a"), Dialog = Color3.fromHex("#082a36"),
	Text = Color3.fromHex("#e0f7ff"), Placeholder = Color3.fromHex("#5fa8c0"),
	Background = Color3.fromHex("#04161d"), Button = Color3.fromHex("#06b6d4"),
	Primary = Color3.fromHex("#06b6d4"), Icon = Color3.fromHex("#38bdf8"),
	Toggle = Color3.fromHex("#2dd4bf"), Slider = Color3.fromHex("#06b6d4"),
	Checkbox = Color3.fromHex("#06b6d4"), ElementBackground = Color3.fromHex("#0f2c38"),
})

-- ════════════════════════════════════════════════════════════════
--  ХЕЛПЕРЫ
-- ════════════════════════════════════════════════════════════════
local Plus = {}

local function Round(radius, shape, props, children, asButton)
	return Creator.NewRoundFrame(radius, shape, props or {}, children, asButton)
end

local function Icon(name, size, themed, color)
	local holder = Creator.Image(name, name, 0, "Temp", "Plus", themed == true)
	holder.Size = UDim2.fromOffset(size, size)
	if color then
		local img = holder:FindFirstChildWhichIsA("ImageLabel")
		if img then img.ImageColor3 = color end
	end
	return holder
end

local function Label(text, size, weight, transparency)
	return New("TextLabel", {
		Text = text or "", TextSize = size, FontFace = Font.new(Creator.Font, weight),
		TextTransparency = transparency, BackgroundTransparency = 1, RichText = false,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
		ThemeTag = { TextColor3 = "Text" },
	})
end

local function Notify(title, content, icon)
	pcall(function()
		WindUI:Notify({ Title = title, Content = content, Icon = icon, Duration = 3 })
	end)
end

local function CopyText(text)
	local fn = setclipboard or toclipboard
	if not fn then return false end
	return (pcall(fn, text))
end

local function Fmt(n)
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then out = out:sub(2) end
	return out
end

-- Кнопка: accent = цвет (залитая) или nil (полупрозрачная под тему)
local function Button(parent, text, iconName, accent, onClick, size)
	local primary = accent ~= nil
	local props = { Size = size, Parent = parent }
	if primary then
		props.ImageColor3 = accent
		props.ImageTransparency = 0
	else
		props.ThemeTag = { ImageColor3 = "Text" }
		props.ImageTransparency = 0.9
	end

	local scale = New("UIScale", { Scale = 1 })
	local ic = iconName and Icon(iconName, 18, not primary) or nil
	local lbl = New("TextLabel", {
		Text = text, TextSize = 16, FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY,
		TextColor3 = primary and WHITE or nil,
		ThemeTag = (not primary) and { TextColor3 = "Text" } or nil,
	})

	local btn = Round(12, "Squircle", props, {
		scale,
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
		ic, lbl,
	}, true)

	local idle, hover = primary and 0 or 0.9, primary and 0.12 or 0.82
	Creator.AddSignal(btn.MouseEnter, function() Tween(btn, 0.12, { ImageTransparency = hover }):Play() end)
	Creator.AddSignal(btn.MouseLeave, function() Tween(btn, 0.12, { ImageTransparency = idle }):Play() end)
	Creator.AddSignal(btn.MouseButton1Down, function() Tween(scale, 0.1, { Scale = 0.96 }):Play() end)
	Creator.AddSignal(btn.InputEnded, function() Tween(scale, 0.15, { Scale = 1 }):Play() end)
	Creator.AddSignal(btn.MouseButton1Click, function() Creator.SafeCallback(onClick) end)
	return btn, lbl
end

-- Обёртка элемента: добавляет вертикальные отступы и регистрирует элемент во вкладке
local function Wrap(tab, win)
	local pad = win.NewElements and 6 or 2
	return New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = tab.UIElements.ContainerFrame,
	}, {
		New("UIPadding", { PaddingTop = UDim.new(0, pad), PaddingBottom = UDim.new(0, pad) }),
	})
end

local function Register(tab, el, wrap)
	-- "Section" => библиотека считает элемент разделителем и не склеивает скругления соседей
	el.__type = "Section"
	el.ElementFrame = wrap
	tab.Elements[#tab.Elements + 1] = el
	function el.Destroy()
		local i = table.find(tab.Elements, el)
		if i then table.remove(tab.Elements, i) end
		wrap:Destroy()
	end
end

local function CardRadius(win)
	return (win.ElementConfig and win.ElementConfig.UICorner) or 16
end

-- ════════════════════════════════════════════════════════════════
--  DISCORD CARD
-- ════════════════════════════════════════════════════════════════
local function ParseInvite(raw)
	raw = tostring(raw or ""):gsub("%s+", "")
	local code = raw:match("discord%.gg/([%w%-_]+)")
		or raw:match("discord%.com/invite/([%w%-_]+)")
		or raw:match("discordapp%.com/invite/([%w%-_]+)")
		or raw:match("^([%w%-_]+)$")
	if not code or code == "" then return nil, nil end
	return code, "https://discord.gg/" .. code
end

local function FetchInvite(code)
	if not Creator.Request then return nil end
	local ok, res = pcall(Creator.Request, {
		Url = "https://discord.com/api/v10/invites/" .. code .. "?with_counts=true",
		Method = "GET",
	})
	if not ok or not res or res.StatusCode ~= 200 then return nil end
	local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
	if ok2 and type(data) == "table" then return data end
	return nil
end

-- Открывает окно приглашения в десктопном Discord через локальный RPC (порт 6463)
local function JoinViaRPC(code)
	if not Creator.Request then return false end
	local ok, res = pcall(Creator.Request, {
		Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST",
		Headers = { ["Content-Type"] = "application/json", Origin = "https://discord.com" },
		Body = HttpService:JSONEncode({
			cmd = "INVITE_BROWSER", args = { code = code },
			nonce = HttpService:GenerateGUID(false),
		}),
	})
	return ok and res ~= nil and (res.StatusCode == 200 or res.Success == true)
end

function Plus.Discord(tab, win, cfg)
	local accent = typeof(cfg.Color) == "Color3" and cfg.Color or BLURPLE
	local radius = CardRadius(win)
	local BANNER, PAD = 68, 16
	local wrap = Wrap(tab, win)

	local el = {
		Kind = "Discord", Title = cfg.Title, Desc = cfg.Desc,
		Invite = cfg.Invite or cfg.Link or cfg.Code or "", Code = nil, Link = nil, Data = nil,
	}

	local card = Round(radius, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = wrap,
		ThemeTag = { ImageColor3 = "ElementBackground", ImageTransparency = "ElementBackgroundTransparency" },
	})

	-- баннер
	Round(radius, "Squircle-TL-TR", {
		Size = UDim2.new(1, 0, 0, BANNER), ImageColor3 = WHITE, Parent = card,
	}, {
		New("UIGradient", {
			Color = ColorSequence.new(accent:Lerp(Color3.new(0, 0, 0), 0.45), accent:Lerp(WHITE, 0.1)),
			Rotation = 20,
		}),
		New("TextLabel", {
			Text = "DISCORD", TextSize = 12, FontFace = Font.new(Creator.Font, Enum.FontWeight.Bold),
			TextColor3 = WHITE, TextTransparency = 0.35, BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 14),
		}),
	})

	-- аватар (кольцо + круг)
	local placeholder = Icon("message-circle", 26, false)
	placeholder.AnchorPoint = Vector2.new(0.5, 0.5)
	placeholder.Position = UDim2.fromScale(0.5, 0.5)
	local avatar = Round(26, "Circle", {
		Size = UDim2.fromOffset(52, 52), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = accent,
	}, { placeholder })
	Round(32, "Circle", {
		Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(PAD, BANNER - 32),
		ZIndex = 5, Parent = card,
		ThemeTag = { ImageColor3 = "ElementBackground" },
	}, { avatar })

	-- тело карточки
	local body = New("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, BANNER),
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, 38), PaddingLeft = UDim.new(0, PAD),
			PaddingRight = UDim.new(0, PAD), PaddingBottom = UDim.new(0, PAD),
		}),
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) }),
	})

	local nameLabel = Label(cfg.Title or "Discord сервер", 21, Enum.FontWeight.SemiBold, 0)
	nameLabel.LayoutOrder = 1
	nameLabel.Parent = body
	local descLabel = Label(cfg.Desc or "Присоединяйся к нашему сообществу!", 15, Enum.FontWeight.Medium, 0.35)
	descLabel.LayoutOrder = 2
	descLabel.Parent = body

	-- статистика
	local statsRow = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 3,
		Visible = false, Parent = body,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 16),
		}),
	})
	local function Stat(color)
		local f = New("Frame", {
			BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, Visible = false, Parent = statsRow,
		}, {
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6),
			}),
			New("Frame", { Size = UDim2.fromOffset(8, 8), BackgroundColor3 = color }, {
				New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			}),
		})
		local t = New("TextLabel", {
			Text = "", TextSize = 14, FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			TextTransparency = 0.3, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY,
			ThemeTag = { TextColor3 = "Text" }, Parent = f,
		})
		return f, t
	end
	local onlineFrame, onlineText = Stat(Color3.fromHex("#23a55a"))
	local membersFrame, membersText = Stat(Color3.fromHex("#80848e"))

	-- плашка со ссылкой
	local linkText = New("TextLabel", {
		Text = "", TextSize = 16, FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		BackgroundTransparency = 1, RichText = false, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -26, 1, 0),
		ThemeTag = { TextColor3 = "Text" },
	})
	local pill = Round(10, "Squircle", {
		Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 4, Parent = body,
		ImageTransparency = 0.93, ThemeTag = { ImageColor3 = "Text" },
	}, {
		New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8),
		}),
		Icon("link", 16, true), linkText,
	}, true)

	-- кнопки
	local row = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 5, Parent = body,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local showJoin = cfg.ShowJoin ~= false
	local copyBtn, copyLabel
	local joinBtn

	function el.Copy()
		if not el.Link then
			Notify("Discord", "Ссылка-приглашение указана неверно", "triangle-alert")
			return false
		end
		local ok = CopyText(el.Link)
		copyLabel.Text = ok and "Скопировано!" or "Нет доступа к буферу"
		task.delay(1.6, function()
			if copyLabel.Parent then copyLabel.Text = "Копировать" end
		end)
		Notify("Discord", ok and "Ссылка скопирована в буфер обмена" or "Executor не поддерживает setclipboard",
			ok and "check" or "triangle-alert")
		Creator.SafeCallback(cfg.Callback, "copy", el.Link)
		return ok
	end

	function el.Join()
		if not el.Code then return end
		task.spawn(function()
			if JoinViaRPC(el.Code) then
				Notify("Discord", "Приглашение открыто в приложении Discord", "check")
			else
				CopyText(el.Link)
				Notify("Discord", "Discord не отвечает — ссылка скопирована, вставь её в браузер", "triangle-alert")
			end
			Creator.SafeCallback(cfg.Callback, "join", el.Link)
		end)
	end

	if showJoin then
		joinBtn = Button(row, "Войти", "log-in", accent, el.Join, UDim2.new(0.5, -4, 1, 0))
		joinBtn.LayoutOrder = 1
	end
	copyBtn, copyLabel = Button(row, "Копировать", "copy", nil, el.Copy,
		showJoin and UDim2.new(0.5, -4, 1, 0) or UDim2.new(1, 0, 1, 0))
	copyBtn.LayoutOrder = 2
	Creator.AddSignal(pill.MouseButton1Click, function() el.Copy() end)

	-- данные с сервера Discord
	local function Apply(data)
		if not data or not card.Parent then return end
		el.Data = data
		local g = data.guild or {}
		if not cfg.Title and g.name then nameLabel.Text = g.name end
		if not cfg.Desc and type(g.description) == "string" and g.description ~= "" then
			descLabel.Text = g.description
		end
		if cfg.ShowStats ~= false then
			local on, all = data.approximate_presence_count, data.approximate_member_count
			if on then onlineText.Text = Fmt(on) .. " в сети"; onlineFrame.Visible = true end
			if all then membersText.Text = Fmt(all) .. " участников"; membersFrame.Visible = true end
			statsRow.Visible = onlineFrame.Visible or membersFrame.Visible
		end
		if cfg.Avatar ~= false and g.id and g.icon then
			local url = ("https://cdn.discordapp.com/icons/%s/%s.png?size=128"):format(g.id, g.icon)
			local ok, img = pcall(Creator.Image, url, "dc_" .. g.id, 26, win.Folder, "Plus", false)
			if ok and img then
				img.Size = UDim2.fromScale(1, 1)
				img.ZIndex = 2
				img.Parent = avatar
			end
		end
	end

	function el.Refresh()
		if not el.Code then return end
		task.spawn(function() Apply(FetchInvite(el.Code)) end)
	end

	function el.SetInvite(_, raw)
		local code, link = ParseInvite(raw)
		el.Invite, el.Code, el.Link = raw, code, link
		linkText.Text = code and ("discord.gg/" .. code) or "Неверная ссылка-приглашение"
		el.Refresh()
	end
	function el.SetTitle(_, t) el.Title = t; nameLabel.Text = t end
	function el.SetDesc(_, t) el.Desc = t; descLabel.Text = t end

	el:SetInvite(el.Invite)
	Register(tab, el, wrap)
	return el
end

-- ════════════════════════════════════════════════════════════════
--  CALLOUT
-- ════════════════════════════════════════════════════════════════
local CalloutTypes = {
	Info = { Color = Color3.fromHex("#3b82f6"), Icon = "info" },
	Success = { Color = Color3.fromHex("#22c55e"), Icon = "circle-check" },
	Warning = { Color = Color3.fromHex("#f59e0b"), Icon = "triangle-alert" },
	Error = { Color = Color3.fromHex("#ef4444"), Icon = "circle-x" },
}

function Plus.Callout(tab, win, cfg)
	local radius = CardRadius(win)
	local wrap = Wrap(tab, win)
	local el = { Kind = "Callout", Title = cfg.Title or "", Desc = cfg.Desc, Type = cfg.Type or "Info" }

	local card = Round(radius, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = wrap,
		ImageTransparency = 0.88,
	})
	local border = Round(radius, "SquircleOutline", {
		Size = UDim2.new(1, 0, 1, 0), ImageTransparency = 0.6, Parent = card,
	})
	local content = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		}),
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local badge = Round(15, "Circle", { Size = UDim2.fromOffset(30, 30), ImageTransparency = 0.82, LayoutOrder = 1, Parent = content })
	local ic

	local title = Label(el.Title, 17, Enum.FontWeight.SemiBold, 0)
	local desc = Label(cfg.Desc or "", 15, Enum.FontWeight.Medium, 0.25)
	desc.Visible = cfg.Desc ~= nil and cfg.Desc ~= ""
	title.LayoutOrder, desc.LayoutOrder = 1, 2
	New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -42, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = content,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
		title, desc,
	})

	local function Paint()
		local kind = CalloutTypes[el.Type] or CalloutTypes.Info
		local color = typeof(cfg.Color) == "Color3" and cfg.Color or kind.Color
		card.ImageColor3, border.ImageColor3, badge.ImageColor3 = color, color, color
		if ic then ic:Destroy() end
		ic = Icon(cfg.Icon or kind.Icon, 18, false, color)
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Position = UDim2.fromScale(0.5, 0.5)
		ic.Parent = badge
	end
	Paint()

	function el.SetTitle(_, t) el.Title = t; title.Text = t end
	function el.SetDesc(_, t) el.Desc = t; desc.Text = t or ""; desc.Visible = t ~= nil and t ~= "" end
	function el.SetType(_, t) el.Type = t; Paint() end

	Register(tab, el, wrap)
	return el
end

-- ════════════════════════════════════════════════════════════════
--  LINK CARD
-- ════════════════════════════════════════════════════════════════
function Plus.Link(tab, win, cfg)
	local accent = typeof(cfg.Color) == "Color3" and cfg.Color or nil
	local radius = CardRadius(win)
	local wrap = Wrap(tab, win)
	local el = { Kind = "Link", Title = cfg.Title or "Ссылка", Desc = cfg.Desc, Url = cfg.Url or "" }

	local card = Round(radius, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = wrap,
		ThemeTag = { ImageColor3 = "ElementBackground", ImageTransparency = "ElementBackgroundTransparency" },
	})
	local content = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		}),
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local ic = Icon(cfg.Icon or "link", 18, accent == nil, accent)
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.fromScale(0.5, 0.5)
	local badgeProps = { Size = UDim2.fromOffset(38, 38), ImageTransparency = 0.85, LayoutOrder = 1, Parent = content }
	if accent then badgeProps.ImageColor3 = accent else badgeProps.ThemeTag = { ImageColor3 = "Text" } end
	Round(12, "Squircle", badgeProps, { ic })

	local title = Label(el.Title, 17, Enum.FontWeight.SemiBold, 0)
	local desc = Label(cfg.Desc or "", 14, Enum.FontWeight.Medium, 0.4)
	desc.Visible = cfg.Desc ~= nil and cfg.Desc ~= ""
	title.LayoutOrder, desc.LayoutOrder = 1, 2
	New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -168, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = content,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		title, desc,
	})

	local btn, lbl
	function el.Copy()
		local ok = CopyText(el.Url)
		lbl.Text = ok and "Готово!" or "Ошибка"
		task.delay(1.4, function() if lbl.Parent then lbl.Text = cfg.ButtonText or "Копировать" end end)
		Notify(el.Title, ok and "Ссылка скопирована" or "Executor не поддерживает setclipboard", ok and "check" or "triangle-alert")
		Creator.SafeCallback(cfg.Callback, el.Url)
	end
	btn, lbl = Button(content, cfg.ButtonText or "Копировать", "copy", accent, el.Copy, UDim2.fromOffset(110, 36))
	btn.LayoutOrder = 3

	function el.SetTitle(_, t) el.Title = t; title.Text = t end
	function el.SetDesc(_, t) el.Desc = t; desc.Text = t or ""; desc.Visible = t ~= nil and t ~= "" end
	function el.SetUrl(_, u) el.Url = u end

	Register(tab, el, wrap)
	return el
end

-- ════════════════════════════════════════════════════════════════
--  ПОДКЛЮЧЕНИЕ К ОКНУ
-- ════════════════════════════════════════════════════════════════
local function Enhance(tab, win)
	if not tab or tab.__plus then return tab end
	tab.__plus = true
	function tab:Discord(cfg) return Plus.Discord(tab, win, cfg or {}) end
	function tab:Callout(cfg) return Plus.Callout(tab, win, cfg or {}) end
	function tab:Link(cfg) return Plus.Link(tab, win, cfg or {}) end
	return tab
end

local function Decorate(win)
	pcall(function()
		local main = win.UIElements.Main.Main
		local h = (win.Topbar and win.Topbar.Height) or 48
		New("Frame", {
			Name = "PlusAccent", Size = UDim2.new(1, -28, 0, 2), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, h - 1), ZIndex = 50, Parent = main,
			ThemeTag = { BackgroundColor3 = "Primary" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			New("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0.1),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		})
	end)
end

local originalCreateWindow = WindUI.CreateWindow

function WindUI:CreateWindow(cfg)
	cfg = cfg or {}
	-- новые значения по умолчанию (всё можно переопределить в своём конфиге)
	cfg.Theme = cfg.Theme or "Nebula"
	cfg.Radius = cfg.Radius or 22
	if cfg.NewElements == nil then cfg.NewElements = true end
	if cfg.HideSearchBar == nil then cfg.HideSearchBar = false end
	cfg.Topbar = cfg.Topbar or { Height = 48, ButtonsType = "Mac" }
	cfg.SideBarWidth = cfg.SideBarWidth or 215
	cfg.Size = cfg.Size or UDim2.fromOffset(640, 480)
	cfg.ShadowTransparency = cfg.ShadowTransparency or 0.45

	local win = originalCreateWindow(self, cfg)
	if not win then return win end

	local originalTab = win.Tab
	function win:Tab(tabCfg)
		return Enhance(originalTab(self, tabCfg), win)
	end

	local originalSection = win.Section
	function win:Section(secCfg)
		local section = originalSection(self, secCfg)
		local originalSectionTab = section.Tab
		function section:Tab(tabCfg)
			return Enhance(originalSectionTab(self, tabCfg), win)
		end
		return section
	end

	Decorate(win)
	return win
end

WindUI.Plus = Plus
return WindUI
