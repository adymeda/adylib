ADYLIB = ADYLIB or {}
ADYLIB.Random = {}
local smalls = "abcdefghijklmnopqrstuvwxyz"
local capitals = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local numbers = "0123456789"
local symbols = "!@#$%^&*-_+="

---@class RandomStringParams
---@field capitals? boolean
---@field numbers? boolean
---@field smalls? boolean
---@field symbols? boolean

--- **[Server/Client]** Returns random string of specified length. Use `params` to customize the generation.
---@param length number
---@param params? RandomStringParams
---@return string
function ADYLIB.Random:GetRandomString(length, params)
    local chars
    if params then
        chars = ""
        if params.smalls then chars = chars .. smalls end
        if params.capitals then chars = chars .. capitals end
        if params.numbers then chars = chars .. numbers end
        if params.symbols then chars = chars .. symbols end
    end
    if #chars == 0 then
        chars = smalls .. capitals .. numbers
    end

    if #chars == 0 then return "" end
    local str = ""
    for i=1,length do
        local rand = math.random(1, #chars)
        str = str .. string.sub(chars, rand, rand)
    end
    return str
end

--- **[Server/Client]** Returns the length of any string counting cyrillic symbols as one instead of two.
function ADYLIB:CyrillicStringLength(str)
    return #(str:gsub('[\128-\191]',''))
end
function string.Length(str)
    return ADYLIB:CyrillicStringLength(str)
end
function ADYLIB:StringCharSplit(str)
    local chars = {}
    for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    return chars
end