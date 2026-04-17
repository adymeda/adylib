---@class AdyFrame: AdyPanel
local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)

    self.Titlebar = vgui.Create("AdyDraggable", self)
    self.Titlebar:Dock(TOP)
    self.Titlebar:SetTall(ADYLIB:ScaleUI(48))
    self.Titlebar:SetMoveTarget(self)
    function self.Titlebar:Paint(w, h)
        local pnl = self:GetParent()
        local r   = IsValid(pnl) and pnl:GetRoundRadius() or 0
        draw.RoundedBox(math.max(0, r), 0, 0, w, h, Color(26, 26, 26))
    end

    self.Titlebar.Buttons     = {}
    self.Titlebar.IconScale   = 0.5
    self.Titlebar.Icon        = nil
    self.Titlebar.IconColor   = nil
    self.Titlebar.TitleMargin = ADYLIB:ScaleUI(5)
    self.Titlebar.Text        = "Window"
    self.Titlebar.Font        = ADYLIB:CreateFont({
        font      = "Inter",
        extended  = true,
        size      = 26,
        weight    = 500,
        antialias = true,
    })

    -- Левый отступ (скругление)
    self.Titlebar.Marginer = vgui.Create("DPanel", self.Titlebar)
    self.Titlebar.Marginer:Dock(LEFT)
    self.Titlebar.Marginer:SetMouseInputEnabled(false)
    function self.Titlebar.Marginer:Paint() end

    -- Кнопка закрытия
    self.Titlebar.CloseButton = self:CreateButton("Close", Material("ady/cross.png"))
    self.Titlebar.CloseButton.HoverColor = Color(255, 77, 92)
    self.Titlebar.CloseButton:Dock(RIGHT)
    function self.Titlebar.CloseButton:DoClick()
        local titlebar = self:GetParent()
        if not IsValid(titlebar) then return end
        local pnl = titlebar:GetParent()
        if not IsValid(pnl) then return end
        pnl:Close()
    end

    self.Titlebar.Title = vgui.Create("DPanel", self.Titlebar)
    self.Titlebar.Title:SetTall(self.Titlebar:GetTall())
    self.Titlebar.Title:SetMouseInputEnabled(false)
    function self.Titlebar.Title:Paint(w, h)
        local titlebar = self:GetParent()
        if not IsValid(titlebar) then return end

        local iconSize = 0
        if titlebar.Icon then
            surface.SetFont(titlebar.Font)
            local _, th = surface.GetTextSize(titlebar.Text)
            iconSize = th
            surface.SetMaterial(titlebar.Icon)
            surface.SetDrawColor(titlebar.IconColor or color_white)
            surface.DrawTexturedRect(0, h / 2 - iconSize / 2, iconSize, iconSize)
            iconSize = iconSize + titlebar.TitleMargin
        end
        draw.SimpleText(
            titlebar.Text, titlebar.Font,
            iconSize, h / 2,
            color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
    end

    self:SetBackgroundColor(32, 32, 32, 254)
    self:SetRoundRadius(ADYLIB.UI:Scale(15))
    self:SetBlurIntensity(5)

    self:SetSize(800, 600)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
end

function PANEL:Close()
    if self.OnClose then self.OnClose() end
    self:Remove()
end

function PANEL:GetTitle() return self.Titlebar.Text end
function PANEL:SetTitle(title) self.Titlebar.Text = title end

function PANEL:GetTall()
    return self.BaseClass.GetTall(self)
end
function PANEL:GetViewTall()
    return self.BaseClass.GetTall(self) - self:GetTitlebarTall()
end
function PANEL:GetSize()
    return self:GetWide(), self:GetTall()
end

function PANEL:GetDraggable()
    return not self.Titlebar:IsBlocked()
end
function PANEL:SetDraggable(draggable)
    if draggable then self.Titlebar:Unblock()
    else               self.Titlebar:Block() end
end

function PANEL:IsIgnoringBounds()
    return self.Titlebar:IsIgnoringBounds()
end
function PANEL:IgnoreBounds(ignore)
    self.Titlebar:IgnoreBounds(ignore)
end

function PANEL:PerformLayout(w, h)
    local titlebarTall = self.Titlebar:GetTall()
    self.Titlebar:SetWide(w)

    for _, button in ipairs(self.Titlebar.Buttons) do
        button:SetSize(titlebarTall, titlebarTall)
    end

    self.Titlebar.Marginer:SetSize(self:GetRoundRadius() / 2, titlebarTall)

    surface.SetFont(self.Titlebar.Font)
    local titleW, titleH = surface.GetTextSize(self.Titlebar.Text)
    if self.Titlebar.Icon then
        titleW = titleW + titleH + self.Titlebar.TitleMargin
    end
    self.Titlebar.Title:SetSize(titleW, titlebarTall)

    if self.Titlebar.Title:GetDock() == NODOCK then
        self.Titlebar.Title:Center()
    else
        self.Titlebar.Title:DockMargin(
            self.Titlebar.TitleMargin, 0,
            self.Titlebar.TitleMargin, 0
        )
    end
end

function PANEL:IsTitlebarVisible() return self.Titlebar:IsVisible() end
function PANEL:SetTitlebarVisible(v) self.Titlebar:SetVisible(v) end
function PANEL:GetTitlebarTall() return self.Titlebar:GetTall() end
function PANEL:SetTitlebarTall(h) self.Titlebar:SetTall(h) end

function PANEL:GetTitlebarIcon()
    return self.Titlebar.Icon, self.Titlebar.IconColor
end
function PANEL:SetTitlebarIcon(material, r, g, b, a)
    if type(material) == "string" then material = Material(material) end
    self.Titlebar.Icon      = material
    self.Titlebar.IconColor = ADYLIB:ToGModColor(r, g, b, a)
end
function PANEL:SetTitlebarIconScale(v)
    self.Titlebar.IconScale = math.Clamp(v, 0, 1)
end
function PANEL:GetTitlebarIconScale()
    return self.Titlebar.IconScale
end

function PANEL:GetTitleDock()       return self.Titlebar.Title:GetDock() end
function PANEL:TitleDock(dock)      self.Titlebar.Title:Dock(dock) end
function PANEL:GetTitleDockMargin() return self.Titlebar.TitleMargin end
function PANEL:TitleDockMargin(m)   self.Titlebar.TitleMargin = m end

function PANEL:CreateButton(name, icon)
    local button = vgui.Create("DButton", self.Titlebar)
    button.Name = name
    button:SetText("")
    button:SetTooltip(name)
    if ADYLIB and ADYLIB.Translator and ADYLIB.Translator:HasTranslation(name) then
        t(name, { panel = button, method = "SetTooltip" })
    end
    function button:Paint(w, h)
        local titlebar = self:GetParent()
        local size = w * titlebar.IconScale
        local pos  = w / 2 - size / 2
        if self:IsHovered() then
            surface.SetDrawColor(self.HoverColor or color_white)
        elseif self.Color then
            surface.SetDrawColor(self.Color)
        else
            surface.SetDrawColor(Color(255, 255, 255, 180))
        end
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(pos, pos, size, size)
    end
    table.insert(self.Titlebar.Buttons, button)
    return button
end

vgui.Register("AdyFrame", PANEL, "AdyPanel")