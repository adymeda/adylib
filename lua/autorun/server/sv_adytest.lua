util.AddNetworkString("AdyLibTest")

hook.Add("PlayerSay", "AdyLibTestCommand", function(ply, text)
    print(text)
    if text == "!adytest" then
        net.Start("AdyLibTest")
        net.Send(ply)
    elseif text == "!tableflow" then
        local bigTable = {}
        for i = 1,10000 do
            bigTable["key_" .. i] = i .. "_some_very_RANDOM_value_" .. string.rep("xx", 20)
        end

        tableflow:Start("TableflowTest")
        tableflow:WriteTable(bigTable)
        tableflow:Send(ply)
    else return end
    return ""
end)