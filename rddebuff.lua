local mq = require('mq')
require("ImGui")

local guiOpen, guiOpenSelf = false, false
local running = true
local deBUG = false

local animSpell = mq.FindTextureAnimation('A_SpellIcons')
local animItem = mq.FindTextureAnimation('A_DragItem')
local iconSize = 16

local function getDuration(i)
    local remaining = mq.TLO.Target.Buff(i).Duration() or 0
    remaining = remaining / 1000
    remaining = remaining % 3600
    local m = math.floor(remaining / 60) or 0
    local s = remaining % 60
    return string.format("%02d:%02d", m, s)
end

local function DrawStatusIcon(iconID, type)
    animSpell:SetTextureCell(iconID or 0)
    animItem:SetTextureCell(iconID or 3996)
    if type == 'item' then
        ImGui.DrawTextureAnimation(animItem, iconSize, iconSize)
    elseif type == 'pwcs' then
        local animPWCS = mq.FindTextureAnimation(iconID)
        animPWCS:SetTextureCell(iconID)
        ImGui.DrawTextureAnimation(animPWCS, iconSize, iconSize)
    else
        ImGui.DrawTextureAnimation(animSpell, iconSize, iconSize)
    end
end

local function countMyDots(debuffCount)
    local DEBUFF = mq.TLO.Target.Buff
    local myDots = 0
    for i = 1, debuffCount do
        if DEBUFF(i) ~= nil and DEBUFF(i).Caster() == mq.TLO.Me.DisplayName() and not DEBUFF(i).Beneficial() then
            myDots = myDots + 1
        end
    end
    return myDots
end

local function checkSelfDebuffs()
    if deBUG or mq.TLO.Me.Poisoned() or mq.TLO.Me.Stunned() or mq.TLO.Me.Diseased() or 
       mq.TLO.Me.Dotted() or mq.TLO.Me.Cursed() or mq.TLO.Me.Corrupted() or 
       mq.TLO.Me.Rooted() or mq.TLO.Me.Mezzed() or mq.TLO.Me.Charmed() then
        return true
    end
    if mq.TLO.Me.Buff('Resurrection Sickness')() ~= nil then 
        return true 
    end
    return false
end

local function drawDebuffs(debuffCount)
    local DEBUFF = mq.TLO.Target.Buff
    for i = 1, debuffCount do
        if DEBUFF(i) ~= nil and DEBUFF(i).Caster() == mq.TLO.Me.DisplayName() and not DEBUFF(i).Beneficial() then
            local dur = getDuration(i)
            local durSeconds = DEBUFF(i).Duration.TotalSeconds() or 0
            local name = DEBUFF(i).Name() or "Unknown"
            local displayName = string.format("%s\t\t\t\t\t\t", name)
            ImGui.BeginGroup()
            if durSeconds <= 18 then
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0, 0, 1)
                ImGui.Text(displayName)
                ImGui.SameLine(ImGui.GetWindowWidth() - 55)
                ImGui.Text(dur)
                ImGui.PopStyleColor()
            else
                ImGui.Text(displayName)
                ImGui.SameLine(ImGui.GetWindowWidth() - 55)
                ImGui.Text(dur)
            end
            ImGui.EndGroup()
            if ImGui.IsItemHovered() and ImGui.IsMouseReleased(0) then
                mq.cmdf('/cast "%s"', name)
            end
        end
    end
end

local function GUI_debuffs()
    if mq.TLO.Me.Zoning() then return end

    if guiOpen then
        guiOpen = ImGui.Begin("Dots##" .. mq.TLO.Me.DisplayName(), guiOpen, 
            bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoDecoration))
        
        if guiOpen then
            local debuffCount = mq.TLO.Target.BuffCount() or 0
            if debuffCount > 0 then
                if countMyDots(debuffCount) > 0 then
                    drawDebuffs(debuffCount)
                end
            end
        end
        ImGui.End()
    end

    if guiOpenSelf then
        guiOpenSelf = ImGui.Begin("DotsSelf##" .. mq.TLO.Me.DisplayName(), guiOpenSelf, 
            bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoDecoration))
        
        if guiOpenSelf then
            ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.5, 0, 1)
            
            if checkSelfDebuffs() then
                ImGui.PushStyleColor(ImGuiCol.Separator, 0.9, 0.5, 0, 1)
                ImGui.SeparatorText('Self Debuff Status')
                ImGui.PopStyleColor()
                
                if deBUG or mq.TLO.Me.Poisoned() then
                    DrawStatusIcon(42, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('Poisoned')
                    ImGui.SameLine()
                    DrawStatusIcon(42, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Diseased() then
                    DrawStatusIcon(41, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('Diseased')
                    ImGui.SameLine()
                    DrawStatusIcon(41, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Dotted() and not mq.TLO.Me.Poisoned() and not mq.TLO.Me.Diseased() then
                    DrawStatusIcon(5987, 'item')
                    ImGui.SameLine()
                    ImGui.Text('Dotted')
                    ImGui.SameLine()
                    DrawStatusIcon(5987, 'item')
                end
                
                if deBUG or mq.TLO.Me.Cursed() then
                    DrawStatusIcon(5759, 'item')
                    ImGui.SameLine()
                    ImGui.Text('Cursed')
                    ImGui.SameLine()
                    DrawStatusIcon(5759, 'item')
                end
                
                if deBUG or mq.TLO.Me.Corrupted() then
                    DrawStatusIcon(5758, 'item')
                    ImGui.SameLine()
                    ImGui.Text('Corrupted')
                    ImGui.SameLine()
                    DrawStatusIcon(5758, 'item')
                end
                
                if deBUG or mq.TLO.Me.Rooted() then
                    DrawStatusIcon(117, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('ROOTED!!!')
                    ImGui.SameLine()
                    DrawStatusIcon(117, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Snared() then
                    DrawStatusIcon(5, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('SNARED!!!')
                    ImGui.SameLine()
                    DrawStatusIcon(5, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Stunned() then
                    DrawStatusIcon(25, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('STUNNED')
                    ImGui.SameLine()
                    DrawStatusIcon(25, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Mezzed() then
                    DrawStatusIcon(35, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('MEZZED!!')
                    ImGui.SameLine()
                    DrawStatusIcon(35, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Charmed() then
                    DrawStatusIcon(26, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('!!! CHARMED !!!')
                    ImGui.SameLine()
                    DrawStatusIcon(26, 'spell')
                end
                
                if deBUG or mq.TLO.Me.Buff('Resurrection Sickness')() ~= nil then
                    DrawStatusIcon(154, 'spell')
                    ImGui.SameLine()
                    ImGui.Text('REZ SICK :')
                    ImGui.SameLine()
                    ImGui.Text(tostring(mq.TLO.Me.Buff('Resurrection Sickness').Duration.TimeHMS() or '4:20'))
                    ImGui.SameLine()
                    DrawStatusIcon(154, 'spell')
                end
            end
            
            ImGui.PopStyleColor()
        end
        ImGui.End()
    end
end

local function mainLoop()
    while running do
        if mq.TLO.Target() ~= nil then
            local debuffCount = mq.TLO.Target.BuffCount() or 0
            if countMyDots(debuffCount) > 0 then
                guiOpen = true
            else
                guiOpen = false
            end
        else
            guiOpen = false
        end
        
        if checkSelfDebuffs() then
            guiOpenSelf = true
        else
            guiOpenSelf = false
        end
        
        mq.delay(100)
    end
end

print("\ay[Debuffs]\ax Starting standalone debuff monitor...")
print("\ay[Debuffs]\ax Target DOTs and Self Debuffs will be displayed automatically")
print("\ay[Debuffs]\ax Use \at/lua stop debuffs_standalone\ax to exit")

mq.imgui.init('Dots Status', GUI_debuffs)

mainLoop()

print("\ay[Debuffs]\ax Standalone debuff monitor stopped")
