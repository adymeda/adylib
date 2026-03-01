local PANEL = {}

function PANEL:Init()
    self:SetBlurIntensity(5)
    self:SetOverlayColor(Color(0, 0, 0, 100))
    self:SetCornerRadius(10)
end

function PANEL:SetBlurIntensity(v)
    self._blurIntensity = math.Clamp(v, 0, 10)
end
function PANEL:GetBlurIntensity()
    return self._blurIntensity
end

function PANEL:SetOverlayColor(r,g,b,a)
    self._overlayColor = ADYLIB:ToGModColor(r,g,b,a)
end
function PANEL:GetOverlayColor()
    return self._overlayColor
end

function PANEL:SetCornerRadius(r)
    self._cornerRadius = math.max(0, r)
end
function PANEL:GetCornerRadius()
    return self._cornerRadius
end

function PANEL:Paint(w, h)
    local sx, sy = self:LocalToScreen(0, 0)
    local r      = self._cornerRadius

    -- Blur: передаём экранные координаты в DrawBlur
    ady:DrawBlur(self._blurIntensity, sx, sy, w, h, r)

    -- Цветовой оверлей в локальных координатах панели
    draw.RoundedBox(r, 0, 0, w, h, self._overlayColor)

    return true
end

vgui.Register("AdyPanel", PANEL, "DPanel")