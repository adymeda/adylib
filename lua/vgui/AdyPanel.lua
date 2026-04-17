---@class AdyPanel: DPanel
local PANEL = {}

function PANEL:Init()
    self:SetBlurIntensity(5)
    self:SetBackgroundColor(Color(0, 0, 0, 100))
    self:SetRoundRadius(10)
end

function PANEL:SetBlurIntensity(v)
    self.__BlurIntensity = math.Clamp(v, 0, 10)
end
function PANEL:GetBlurIntensity()
    return self.__BlurIntensity
end

---
---@param material IMaterial
---@param r Color|number|nil
---@param g number|nil
---@param b number|nil
---@param a number|nil
function PANEL:SetMaterialOverlay(material, r, g, b, a)
    print(material)
    self.__OverlayMaterial = material
    if r ~= nil then
        self.__OverlayColor = ADYLIB.Colors:ToGMColor(r,g,b,a)
    end
end

function PANEL:SetRoundRadius(r)
    self:SetRoundRadii(r,r,r,r)
end
function PANEL:GetRoundRadius()
    return self.__RoundRadius.top_left
end
function PANEL:SetRoundRadii(top_left, top_right, bottom_left, bottom_right)
    self.__RoundRadius = {
        top_left        = math.max(0, top_left or 0),
        top_right       = math.max(0, top_right or 0),
        bottom_left     = math.max(0, bottom_left or 0),
        bottom_right    = math.max(0, bottom_right or 0)
    }
end
function PANEL:GetRoundRadii(split)
    if split then
        return
            self.__RoundRadius.top_left,
            self.__RoundRadius.top_right,
            self.__RoundRadius.bottom_left,
            self.__RoundRadius.bottom_right
    end
    return self.__RoundRadius
end

function PANEL:SetBackgroundColor(r, g, b, a)
    self.__BackgroundColor = ADYLIB:ToGModColor(r, g, b, a)
end
function PANEL:GetBackgroundColor()
    return self.__BackgroundColor
end

function PANEL:Paint(w, h)
    local sx, sy = self:LocalToScreen(0, 0)
    local radii  = self:GetRoundRadii()

    if self.__BlurIntensity and self.__BlurIntensity > 0 then
        ADYLIB.UI:DrawBlur(self.__BlurIntensity, sx, sy, w, h, radii)
    end

    if self.__BackgroundColor then
        ADYLIB.UI:DrawRect(0, 0, w, h, {
            color = self.__BackgroundColor,
            round_radius = radii
        })
    end

    if self.__OverlayMaterial then
        ADYLIB.UI:DrawRect(0,0,w,h,{
            color = self.__OverlayColor or color_white,
            material = self.__OverlayMaterial,
            round_radius = radii
        })
    end
end

vgui.Register("AdyPanel", PANEL, "DPanel")