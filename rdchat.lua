local mq = require('mq')
local ImGui = require('ImGui')

local WINDOW_TITLE = 'Chat Broadcast'
local running = true
local ui_open = true
local input_text = ''

local function seed_rng()
    local meID = mq.TLO.Me and mq.TLO.Me.ID() or 0
    math.randomseed(os.time() + (meID or 0))
    math.random(); math.random(); math.random()
end

seed_rng()

local function trim(s)
    return (s or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function parse_args(arg)
    arg = arg or ''
    local zone = arg:match('zone=([%w_%-%s]+)')
    if zone then
        local prefix = 'zone=' .. zone
        local start_pos, end_pos = arg:find(prefix, 1, true)
        if start_pos == 1 then
            arg = arg:sub((end_pos or 0) + 1)
        else
            arg = (arg:sub(1, start_pos - 1) .. arg:sub((end_pos or 0) + 1))
        end
    end
    local text = trim(arg)
    return zone and trim(zone) or nil, text
end

local function humanized_say(text)
    text = trim(text)
    if text == '' then return end
    local delay_s = math.random(1, 10)
    mq.cmdf('/echo [chat] Saying in %ds: %s', delay_s, text)
    mq.delay(delay_s * 1000)
    mq.cmdf('/say %s', text)
end

mq.bind('/chatsay', function(arg)
    local expect_zone, message = parse_args(arg)
    if trim(message) == '' then return end
    local my_zone = mq.TLO.Zone.ShortName() or ''
    if expect_zone and expect_zone ~= '' and expect_zone ~= my_zone then
        return
    end
    humanized_say(message)
end)

mq.imgui.init('chat_ui', function()
    if not ui_open then return end
    local openRet, drawRet = ImGui.Begin(WINDOW_TITLE, ui_open)
    if drawRet == nil then
        drawRet = openRet
    else
        ui_open = openRet
    end
    if drawRet then
        ImGui.Text('Type a line to /say on all toons in zone:')
        ImGui.SetNextItemWidth(300)
        local r1, r2 = ImGui.InputTextWithHint('##saytext', 'Enter text to /say', input_text, 256)
        local changed, new_val
        if type(r1) == 'boolean' then
            changed, new_val = r1, r2
        else
            new_val, changed = r1, (r2 == true)
        end
        if type(new_val) == 'string' and new_val ~= input_text then
            input_text = new_val
        end
        ImGui.SameLine()
        if ImGui.Button('Send') then
            local text = trim(input_text)
            if text ~= '' then
                local zoneShort = tostring(mq.TLO.Zone.ShortName() or '')
                local hasDanNet = mq.TLO.DanNet ~= nil
                local me = tostring(mq.TLO.Me.Name() or '')
                local count = 0
                if hasDanNet then
                    local peers_raw = tostring(mq.TLO.DanNet.Peers() or '')
                    local seenSelf = false
                    local function iter_peers(s)
                        s = s:gsub(',', '|')
                        for token in s:gmatch('[^|]+') do
                            local name = trim(token)
                            if name ~= '' then
                                coroutine.yield(name)
                            end
                        end
                    end
                    local co = coroutine.create(function() iter_peers(peers_raw) end)
                    while true do
                        local ok, name = coroutine.resume(co)
                        if not ok or name == nil then break end
                        if name == me then seenSelf = true end
                        local delay_s = math.random(1, 10)
                        local frames = delay_s * 10
                        local safe_text = tostring(text):gsub('"', '\\"')
                        mq.cmdf('/dex %s /timed %d /say "%s"', name, frames, safe_text)
                        mq.cmdf('/echo [chat] queued %s in %ds', name, delay_s)
                        count = count + 1
                    end
                    if not seenSelf then
                        local delay_s = math.random(1, 10)
                        local frames = delay_s * 10
                        local safe_text = tostring(text):gsub('"', '\\"')
                        mq.cmdf('/timed %d /say "%s"', frames, safe_text)
                        mq.cmdf('/echo [chat] queued %s in %ds (self)', me, delay_s)
                        count = count + 1
                    end
                    mq.cmdf('/echo [chat] Broadcast scheduled for %d toons.', count)
                else
                    local delay_s = math.random(1, 10)
                    local frames = delay_s * 10
                    mq.cmdf('/echo [chat] DanNet not detected. Local say in %ds.', delay_s)
                    mq.cmdf('/timed %d /say "%s"', frames, text)
                end
            else
                mq.cmd('/echo [chat] No text to send.')
            end
        end
    end
    ImGui.End()
end)

while running do
    if not ui_open then running = false end
    mq.delay(100)
end

mq.cmd('/echo [chat] Closed.')
