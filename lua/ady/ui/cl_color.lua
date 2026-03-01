ADYLIB = ADYLIB or {}

local Colors = ADYLIB.Colors or {}

local function ColorInvert(c)
    return Color(255-c.r,255-c.g,255-c.b,c.a)
end

--- **[Client]** Transforms any RGB color format to Garry's Mod Color class.
--- It is allowed to pass either existing color or R,G,B values as separate arguments.
---@param r number|table
---@param g? number
---@param b? number
---@param a? number
---@return Color
function Colors:ToGMColor(r,g,b,a)
    if type(r) ~= "number" then
        if r == nil then
            r = 0
        else
            if type(r) ~= "table" then
                r = {}
            end
            if r.r == nil then r.r = 0 end
            if r.g == nil then r.g = 0 end
            if r.b == nil then r.b = 0 end
            if r.a == nil then r.a = 255 end
            return r
        end
    end
    if g == nil or type(g) ~= "number" then g = 0 end
    if b == nil or type(b) ~= "number" then b = 0 end
    if a == nil or type(a) ~= "number" then a = 255 end
    return Color(r,g,b,a)
end

--- **[Client]** Returns a smoothly transitioning rainbow color based on the current time.
--- Useful for generating animated color effect when called every frame.
---@param speed? number
---@return Color
function Colors:GetRainbowColor(speed)
    if speed == nil or type(speed) == "number" and speed <= 0 then
        speed = 1
    end
	local time = CurTime()
	local r = math.sin(time * speed + 0) * 127 + 128
	local g = math.sin(time * speed + 2) * 127 + 128
	local b = math.sin(time * speed + 4) * 127 + 128
	return Color(r,g,b)
end

--- Inverts the color. This method does not change alpha channel during transformation.
--- 
--- No need to use `ADYLIB:ToGmodColor(...)` as this method automatically validates the color.
---@param r table|number
---@param g? number
---@param b? number
---@param a? number
---@return Color
function Colors:InvertColor(r,g,b,a)
    return ColorInvert(self:ToGModColor(r,g,b,a))
end

--- **[Client]** TBD
---@param r integer
---@param g? integer
---@param b? integer
---@param a? integer
---@return Color
function Colors:LightenColor(r,g,b,a)
    local color = self:ToGModColor(r,g,b,a)
    local diff = math.min(255 - color.r, 255 - color.g, 255 - color.b)
    return Color(color.r + diff, color.g + diff, color.b + diff, color.a)
end

function Colors:DarkenColor(r,g,b,a)
    local color = self:ToGModColor(r,g,b,a)
    local diff = math.max(color.r, color.g, color.b)
    return Color(color.r - diff, color.b - diff, color.b - diff, color.a)
end

ADYLIB.Colors = Colors