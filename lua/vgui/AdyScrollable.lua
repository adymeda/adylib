local PANEL_CLASS = "AdyScrollable"
---@class AdyScrollable: Panel
local PANEL = {}

function PANEL:Init()

    self.Canvas = vgui.Create("DPanel", self)
    self.Canvas:SetPaintBackground(false)
    function self.Canvas:OnMouseWheeled(delta)
        local parent = self:GetParent()
        if not IsValid(parent) or not parent.OnMouseWheeled then return end
        parent:OnMouseWheeled(delta)
    end

    -- Scrolling
    self.IsXScrollAllowed = true
    self.IsYScrollAllowed = true

    self.TargetOffset = {
        x = 0,
        y = 0
    }

    self.ScrollPower = 50
    self.ScrollSpeed = 5
    self.MaxOverscroll = 120

    self._CanvasW = 0
    self._CanvasH = 0

    self.VerticalScrollbar = vgui.Create("AdyScrollbar")
    self.VerticalScrollbar:SetWide(8)
    self.VerticalScrollbar:SetParent(self)
    self.HorizontalScrollbar = vgui.Create("AdyScrollbar")
    self.HorizontalScrollbar:SetTall(8)
    self.HorizontalScrollbar:SetParent(self)
    self.HorizontalScrollbar:SetVertical(false)
    -- Scrolling

    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:OnMouseWheeled(delta)
    if self.VerticalScrollbar and self.VerticalScrollbar.Dragging then return end
    if self.HorizontalScrollbar and self.HorizontalScrollbar.Dragging then return end
    -- if not self:IsHovered() then return end

    if self.IsYScrollAllowed and --[[self.VerticalOverflow]] self.VerticalScrollbar:IsVisible() and not self.HorizontalScrollbar:IsHovered() then
        self.TargetOffset.y = self.TargetOffset.y - delta * self.ScrollPower
    elseif self.IsXScrollAllowed and --[[self.HorizontalOverflow]] self.HorizontalScrollbar:IsVisible() and not self.VerticalScrollbar:IsHovered() then
        self.TargetOffset.x = self.TargetOffset.x - delta * self.ScrollPower
    end
end

local function NormalizeTargetOffset(target, min, max, overscroll)
    if target < min then
        target = Lerp(FrameTime() * 8, target, min)
    elseif target > max then
        target = Lerp(FrameTime() * 8, target, max)
    end
    return math.Clamp(target, -overscroll, max + overscroll)
end

function PANEL:Think()
    local ft = FrameTime()
    local canvasX, canvasY = self.Canvas:GetPos()

    local targetCanvasX = -self.TargetOffset.x
    local targetCanvasY = -self.TargetOffset.y

    local newX, newY = canvasX, canvasY

    if canvasY ~= targetCanvasY then
        local dy = math.abs(canvasY - targetCanvasY)
        local boost = 1 + 50 / (dy + 1)
        newY = Lerp(ft * self.ScrollSpeed * boost, canvasY, targetCanvasY)
    end
    if canvasX ~= targetCanvasX then
        local dx = math.abs(canvasX - targetCanvasX)
        local boost = 1 + 50 / (dx + 1)
        newX = Lerp(ft * self.ScrollSpeed * boost, canvasX, targetCanvasX)
    end

    newX, newY = math.Round(newX), math.Round(newY)
    if newX ~= canvasX or newY ~= canvasY then
        self.Canvas:SetPos(newX, newY)
        self:OnScrolled(-newX, -newY)
    end

    -- Normalize TargetOffset
    local canvasW, canvasH = self.Canvas:GetSize()
    local selfW, selfH = self:GetSize()
    local maxOffsetX = math.max(0, canvasW - selfW)
    local maxOffsetY = math.max(0, canvasH - selfH)
    self.TargetOffset.x = NormalizeTargetOffset(self.TargetOffset.x, 0, maxOffsetX, self.MaxOverscroll)
    self.TargetOffset.y = NormalizeTargetOffset(self.TargetOffset.y, 0, maxOffsetY, self.MaxOverscroll)

    self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
    self:LayoutChildren()
    self:LayoutScrollbars(w, h)
end

function PANEL:LayoutScrollbars(w, h)
    local vsb = self.VerticalScrollbar
    local hsb = self.HorizontalScrollbar

    -- Vertical scrollbar
    local vsbTallMargin = vsb.Margin
    if IsValid(hsb) and hsb:IsVisible() then
        vsbTallMargin = vsbTallMargin + hsb:GetTall()
    end
    vsb:SetPos(w - vsb:GetWide(), vsb.Margin)
    vsb:SetTall(h - vsbTallMargin - vsb.Margin)

    -- Horizontal scrollbar
    local hsbWidthMargin = hsb.Margin
    if IsValid(vsb) and vsb:IsVisible() then
        hsbWidthMargin = vsb:GetWide()
    end
    hsb:SetPos(hsb.Margin, h - hsb:GetTall())
    hsb:SetWide(w - hsbWidthMargin - hsb.Margin)
end

function PANEL:LayoutChildren()
    local maxX, maxY = 0, 0
    for _, child in ipairs(self.Canvas:GetChildren()) do
        if IsValid(child) then
            local x, y = child:GetPos()
            maxX = math.max(maxX, x + child:GetWide())
            maxY = math.max(maxY, y + child:GetTall())
            local dock = child:GetDock()
            if dock == FILL or dock == TOP or dock == BOTTOM then
                maxX = self:GetViewportWide()
            end
        end
    end

    if maxX ~= self._CanvasW or maxY ~= self._CanvasH then
        self._CanvasW = maxX
        self._CanvasH = maxY
        self.Canvas:SetSize(maxX, maxY)
    end

    local selfW, selfT = self:GetSize()
    self.VerticalScrollbar:SetVisible(selfT < maxY)
    self.HorizontalScrollbar:SetVisible(selfW < maxX)
end

function PANEL:OnChildAdded(child)
    if child == self.Canvas then return end
    if child == self.VerticalScrollbar then return end
    if child == self.HorizontalScrollbar then return end
    timer.Simple(0, function()
        if not IsValid(child) or not IsValid(self) then return end
        if child:GetParent() ~= self then return end

        child:SetParent(self.Canvas)
        self:LayoutChildren()
    end)
end

function PANEL:OnScrolled(...)
    -- stub: override to receive scroll position changes (x, y)
end


-- API
function PANEL:GetScrollSpeed()
    return self.ScrollSpeed - 3
end
function PANEL:SetScrollSpeed(speed)
    if type(speed) ~= "number" or speed <= 0 then speed = 1 end
    self.ScrollSpeed = 3 + speed
end

function PANEL:GetScrollPower()
    return self.ScrollPower
end
function PANEL:SetScrollPower(power)
    if type(power) ~= "number" or power < 10 then power = 10 end
    self.ScrollPower = power
end

function PANEL:IsHorizontalScrollEnabled()
    return self.IsXScrollAllowed
end
function PANEL:EnableHorizontalScroll()
    self.IsXScrollAllowed = true
end
function PANEL:DisableHorizontalScroll()
    self.IsXScrollAllowed = false
end
function PANEL:IsVerticalScrollEnabled()
    return self.IsYScrollAllowed
end
function PANEL:EnableVerticalScroll()
    self.IsYScrollAllowed = true
end
function PANEL:DisableVerticalScroll()
    self.IsYScrollAllowed = false
end
function PANEL:GetViewportWide()
    local w = self:GetWide()
    if IsValid(self.VerticalScrollbar) and self.VerticalScrollbar:IsVisible() then
        w = w - self.VerticalScrollbar:GetWide()
    end
    return w
end
function PANEL:GetViewportTall()
    local h = self:GetTall()
    if IsValid(self.HorizontalScrollbar) and self.HorizontalScrollbar:IsVisible() then
        h = h - self.HorizontalScrollbar:GetTall()
    end
    return h
end
function PANEL:GetViewportSize()
    return self:GetViewportWide(), self:GetViewportTall()
end
function PANEL:GetScrollbarsMargin()
    return self.VerticalScrollbar.Margin, self.HorizontalScrollbar.Margin
end
function PANEL:SetScrollbarsMargin(margin)
    self.VerticalScrollbar.Margin = margin
    self.HorizontalScrollbar.Margin = margin
end
function PANEL:GetScrollOffset()
    return self.TargetOffset.x, self.TargetOffset.y
end
function PANEL:ScrollToX(x, force)
    if force then
        self.Canvas:SetX(-x)
    end
    self.TargetOffset.x = x
end
function PANEL:ScrollToY(y, force)
    if force then
        self.Canvas:SetY(-y)
    end
    self.TargetOffset.y = y
end
function PANEL:ScrollTo(x, y, force)
    self:ScrollToX(x, force)
    self:ScrollToY(y, force)
end

vgui.Register(PANEL_CLASS, PANEL, "Panel")