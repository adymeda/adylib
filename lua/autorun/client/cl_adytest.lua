local Window

function AdyLibTest()
    if IsValid(Window) then return end
    Window = vgui.Create("AdyFrame")
    Window:SetTitle("AdyLibTest")
    Window:SetSize(1280,720)
    Window:MakePopup()
    Window:Center()
    Window:SetRoundRadius(15)
    Window:SetBackgroundColor(0,0,0,200)
    Window:SetKeyboardInputEnabled(false)

    


    local scrollable = vgui.Create("AdyScrollable", Window)
    scrollable:SetSize(Window:GetWide(), Window:GetTall() - 48)
    -- local scrollable = vgui.Create("DScrollPanel", Window)
    -- scrollable:SetSize(Window:GetWide(), 128)
    scrollable:SetY(48)
    -- scrollable:SetScrollPower(100)

    local tb = vgui.Create("DButton", scrollable)
    tb:SetText("Very test button")
    tb:SetSize(256,64)

    local testL = vgui.Create("DLabel", scrollable)
    testL:SetPos(1550,250)
    testL:SetText("ABOBA")
    testL:SetTextColor(color_black)

    -- local vx, vy = scrollable:GetViewportSize()
    -- local grid = vgui.Create("AdyGrid", scrollable)
    -- grid:SetSize(vx,512)
    -- grid:SetMargin(10)
    -- grid:SetColumns(5)
    -- grid:SetRowHeight(72)
    -- function grid:Paint(w,h)
    --     surface.SetDrawColor(Color(0,255,0))
    --     surface.DrawRect(0,0,w,h)
    -- end
    -- for k=1,100 do
    --     vgui.Create("DButton", grid)
    -- end

    for i=1,50 do
        local model = vgui.Create("DModelPanel", scrollable)
        model:SetModel(LocalPlayer():GetModel())
        model:SetSize(256,256)
        -- model:SetPos((i-1)*256 ,64)
        model:SetPos(0,(i-1)*256 + 64)
    end






    -- local pp = vgui.Create("AdyPagePanel", Window)
    -- pp:SetSize(Window:GetWide()/2, Window:GetTall()/2)
    -- pp:Center()
    -- pp:SetCycled(true)

    -- local page = vgui.Create("DPanel")
    -- page:SetSize(128,128)
    -- function page:Paint(w, h)
    --     --draw.RoundedBox(15, 0, 0, w, h, Color(0, 0, 255))
    --     draw.RoundedBox(15,0,0,w,h,ADYLIB:RainbowColor())
    -- end
    -- pp:AddPage(page)

    -- local btn = vgui.Create("DButton")
    -- btn:SetSize(200, 64)
    -- btn:SetText("Test button")
    -- pp:AddPage(btn)

    -- local block = vgui.Create("DPanel")
    -- block:SetSize(256,128)
    -- function block:Paint(w, h)
    --     draw.RoundedBox(0,0,0,w,h,Color(0,0,0))
    -- end
    -- pp:AddPage(block)


    -- local prev = vgui.Create("DButton", Window)
    -- prev:Dock(TOP)
    -- prev:SetText("<")
    -- function prev:DoClick()
    --     pp:PreviousPage()
    -- end
    -- local next = vgui.Create("DButton", Window)
    -- next:Dock(TOP)
    -- next:SetText(">")
    -- function next:DoClick()
    --     pp:NextPage()
    -- end

    -- local label = vgui.Create("DLabel", Window)
    -- label:SetText("1/" .. #pp:GetPages())
    -- --label:SetFont("CloseCaption_Bold")
    -- label:Center()
    -- label:AlignBottom(15)

    -- pp:OnPageChange(function(cur, total)
    --     label:SetText(cur .. "/" .. total)
    -- end)
end


net.Receive("AdyLibTest", AdyLibTest)


tableflow:Receive("TableflowTest", function(tbl, chunkSize)
    print("[tableflow] Received big table with " .. table.Count(tbl) .. " keys within " .. chunkSize .. " chunks")

    -- Проверим несколько значений
    print("Sample key: key_1 = ", tbl["key_1"])
    print("Sample key: key_5000 = ", tbl["key_5000"])
    print("Sample key: key_10000 = ", tbl["key_10000"])
end)