ADYLIB = ADYLIB or {}
ADYLIB.surface = ADYLIB.surface or {}

local blurMat = Material("pp/blurscreen")

-- RT занимает размер экрана и хранит смазанный кадр.
-- Создаётся один раз при загрузке файла.
local blurRT = GetRenderTargetEx(
    "BlurPanel_RT",
    ScrW(), ScrH(),
    RT_SIZE_LITERAL,
    MATERIAL_RT_DEPTH_NONE,
    bit.bor(4, 8),  -- TEXTUREFLAGS_CLAMPS | TEXTUREFLAGS_CLAMPT
    0,
    IMAGE_FORMAT_BGRA8888
)

-- UnlitGeneric для вывода RT как обычной текстуры через DrawPoly.
-- Именно через DrawPoly мы ограничиваем область рисования
-- формой rounded rect без артефактов по краям.
local blurRTMat = CreateMaterial("BlurPanel_RTMat", "UnlitGeneric", {
    ["$basetexture"] = blurRT:GetName(),
    ["$translucent"] = "1",
    ["$vertexcolor"] = "1",
    ["$vertexalpha"] = "1",
    ["$nofog"] = "1",
    ["$ignorez"] = "1",
})

-- ── Построение вершин rounded rect ───────────────────────────
-- x, y, w, h — экранные координаты (UV считаются от них же)
local function BuildPoly(x, y, w, h, tl, tr, br, bl)
    local scrW  = ScrW()
    local scrH  = ScrH()

    -- Ограничиваем радиусы, чтобы не вылезти за пределы прямоугольника
    local maxR  = math.min(w, h) * 0.5
    tl = math.min(tl, maxR)
    tr = math.min(tr, maxR)
    br = math.min(br, maxR)
    bl = math.min(bl, maxR)

    local verts = {}

    -- Вершина в экранных координатах; UV = экранная позиция / размер экрана
    local function addVert(sx, sy)
        verts[#verts + 1] = {
            x = sx - x,   -- DrawPoly рисует в локальных координатах панели,
            y = sy - y,   -- поэтому переводим обратно в локальные
            u = sx / scrW,
            v = sy / scrH,
        }
    end

    -- Четыре угла по часовой стрелке (Y направлен вниз):
    --   top-left     : дуга 180°→270°,  центр (x+tl,   y+tl  )
    --   top-right    : дуга 270°→360°,  центр (x+w-tr,  y+tr  )
    --   bottom-right : дуга   0°→90°,   центр (x+w-br,  y+h-br)
    --   bottom-left  : дуга  90°→180°,  центр (x+bl,   y+h-bl)
    local corners = {
        { x + tl,     y + tl,     tl, 180, 270 },
        { x + w - tr, y + tr,     tr, 270, 360 },
        { x + w - br, y + h - br, br,   0,  90 },
        { x + bl,     y + h - bl, bl,  90, 180 },
    }

    for _, c in ipairs(corners) do
        local cx, cy, r, a1, a2 = c[1], c[2], c[3], c[4], c[5]
        local steps = math.max(6, math.ceil(r * 0.5))
        for i = 0, steps do
            local a = math.rad(a1 + (a2 - a1) * i / steps)
            addVert(cx + math.cos(a) * r, cy + math.sin(a) * r)
        end
    end

    return verts
end

-- ── Рендер blur всего экрана в RT ─────────────────────────────
-- Три итерации с нарастающей силой размытия. После каждого
-- прохода результат копируется обратно в effect texture, чтобы
-- следующий проход размывал уже смазанную картинку.
local function RenderBlurToRT(intensity)
    local sw, sh = ScrW(), ScrH()

    render.UpdateScreenEffectTexture()  -- снимаем текущий кадр
    render.PushRenderTarget(blurRT)
    cam.Start2D()
        surface.SetMaterial(blurMat)
        surface.SetDrawColor(255, 255, 255, 255)
        for i = 1, 3 do
            blurMat:SetFloat("$blur", (i / 3) * intensity)
            blurMat:Recompute()
            surface.DrawTexturedRectUV(0, 0, sw, sh, 0, 0, 1, 1)
            render.UpdateScreenEffectTexture()
        end
    cam.End2D()
    render.PopRenderTarget()
end

-- ── Публичная функция ─────────────────────────────────────────
-- Перегрузка через количество аргументов:
--   6 аргументов : DrawBlur(intensity, x, y, w, h, r)          — единый радиус
--   9 аргументов : DrawBlur(intensity, x, y, w, h, tl, tr, br, bl) — каждый угол отдельно
function ADYLIB:DrawBlur(intensity, x, y, w, h, tl, tr, br, bl)
    if intensity <= 0 then return end

    -- Если передан один радиус — применяем ко всем углам
    if tr == nil then
        tl, tr, br, bl = tl, tl, tl, tl
    end

    tl = tl or 0
    tr = tr or 0
    br = br or 0
    bl = bl or 0

    RenderBlurToRT(intensity)

    local verts = BuildPoly(x, y, w, h, tl, tr, br, bl)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(blurRTMat)
    surface.DrawPoly(verts)
end