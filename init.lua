require "preload"

hs.hotkey.alertDuration=0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

white = hs.drawing.color.white
black = hs.drawing.color.black
blue = hs.drawing.color.blue
osx_red = hs.drawing.color.osx_red
osx_green = hs.drawing.color.osx_green
osx_yellow = hs.drawing.color.osx_yellow
tomato = hs.drawing.color.x11.tomato
dodgerblue = hs.drawing.color.x11.dodgerblue
firebrick = hs.drawing.color.x11.firebrick
lawngreen = hs.drawing.color.x11.lawngreen
lightseagreen = hs.drawing.color.x11.lightseagreen
purple = hs.drawing.color.x11.purple
royalblue = hs.drawing.color.x11.royalblue
sandybrown = hs.drawing.color.x11.sandybrown
black50 = {red=0,blue=0,green=0,alpha=0.5}
darkblue = {red=24/255,blue=195/255,green=145/255,alpha=1}
gray = {red=246/255,blue=246/255,green=246/255,alpha=0.3}

mod0 =   {"cmd", "ctrl", "shift"}
appmod = {"cmd", "ctrl"}

privatepath = hs.fs.pathToAbsolute(hs.configdir..'/private')
if privatepath == nil then
    hs.fs.mkdir(hs.configdir..'/private')
end
privateconf = hs.fs.pathToAbsolute(hs.configdir..'/private/awesomeconfig.lua')
if privateconf ~= nil then
    require('private/awesomeconfig')
end

hsreload_keys = hsreload_keys or {mod0, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

if modalmgr == nil then
    showtime_lkeys = showtime_lkeys or {mod0, "T"}
    if string.len(showtime_lkeys[2]) > 0 then
        hs.hotkey.bind(showtime_lkeys[1], showtime_lkeys[2], 'Show Digital Clock', function() show_time() end)
    end

    show_screen_numbers_lkeys = show_screen_numbers_lkeys or {mod0, "Q"}
    if string.len(show_screen_numbers_lkeys[2]) > 0 then
        hs.hotkey.bind(show_screen_numbers_lkeys[1], show_screen_numbers_lkeys[2], 'Show Screen Numbers', function() show_screen_numbers() end)
    end
end

showhotkey_keys = showhotkey_keys or {mod0, "space"}
if string.len(showhotkey_keys[2]) > 0 then
    hs.hotkey.bind(showhotkey_keys[1], showhotkey_keys[2], "Toggle Hotkeys Cheatsheet", function() showavailableHotkey() end)
end

times = {}

function destroy_time(idx)
    local time = times[idx]
    if time then
        if time.draw then
            time.draw:delete()
            time.draw = nil
        end
        times[idx] = nil
    end
end

function show_time()
    for i=1,#hs.screen.allScreens() do
        local screen = hs.screen.allScreens()[i]
        if not times[screen:id()] then
            local time = {}
            times[screen:id()] = time
            local mainRes = screen:fullFrame()
            local localMainRes = screen:absoluteToLocal(mainRes)
            local time_str = hs.styledtext.new(os.date("%H:%M"),{font={name="Impact",size=120},color=darkblue,paragraphStyle={alignment="center"}})
            local timeframe = hs.geometry.rect(screen:localToAbsolute((localMainRes.w-300)/2,(localMainRes.h-200)/2,300,150))
            time.draw = hs.drawing.text(timeframe,time_str)
            time.draw:setLevel(hs.drawing.windowLevels.overlay)
            time.draw:show()
            if time.ttimer == nil then
                time.ttimer = hs.timer.doAfter(1, function() destroy_time(screen:id()) end)
            else
                time.ttimer:start()
            end
        else
            local time = times[screen:id()]
            if time.ttimer then
                time.ttimer:stop()
            end
            destroy_time(screen:id())
        end
    end
end

screen_numbers = {}

function destroy_screen_number(idx)
    local screen_number = screen_numbers[idx]
    if screen_number then
        if screen_number.draw then
            screen_number.draw:delete()
            screen_number.draw = nil
        end
        screen_numbers[idx] = nil
    end
end

function show_screen_numbers()
    for i=1,#hs.screen.allScreens() do
        local screen = hs.screen.allScreens()[i]
        if not screen_numbers[screen:id()] then
            screen_number = {}
            screen_numbers[screen:id()] = screen_number
            local mainRes = screen:fullFrame()
            local localMainRes = screen:absoluteToLocal(mainRes)
            local number_str = hs.styledtext.new(i,{font={name="Impact",size=160},color=lawngreen,paragraphStyle={alignment="center"}})
            local numberframe = hs.geometry.rect(screen:localToAbsolute((localMainRes.w-300)/2,(localMainRes.h-240)/2,300,200))
            screen_number.draw = hs.drawing.text(numberframe,number_str)
            screen_number.draw:setLevel(hs.drawing.windowLevels.overlay)
            screen_number.draw:show()
            if screen_number.ttimer == nil then
                screen_number.ttimer = hs.timer.doAfter(1, function() destroy_screen_number(screen:id()) end)
            else
                screen_number.ttimer:start()
            end
        else
            screen_number = screen_numbers[screen:id()]
            if screen_number.ttimer then
                screen_number.ttimer:stop()
            end
            destroy_screen_number(screen:id())
        end
    end
end

function showavailableHotkey()
    if not hotkeytext then
        local hotkey_list=hs.hotkey.getHotkeys()
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local localMainRes = mainScreen:absoluteToLocal(mainRes)
        local width = math.min(864, localMainRes.w * 3 / 5)
        local height = math.min(540, localMainRes.h * 3 / 5)
        local hkbgrect = hs.geometry.rect(mainScreen:localToAbsolute((localMainRes.w-width)/2,(localMainRes.h-height)/2,width,height))
        hotkeybg = hs.drawing.rectangle(hkbgrect)
        -- hotkeybg:setStroke(false)
        if not hotkey_tips_bg then hotkey_tips_bg = "light" end
        if hotkey_tips_bg == "light" then
            hotkeybg:setFillColor({red=238/255,blue=238/255,green=238/255,alpha=0.95})
        elseif hotkey_tips_bg == "dark" then
            hotkeybg:setFillColor({red=0,blue=0,green=0,alpha=0.95})
        end
        hotkeybg:setRoundedRectRadii(10,10)
        hotkeybg:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeybg:behavior(hs.drawing.windowBehaviors.stationary)
        local hktextrect = hs.geometry.rect(hkbgrect.x+40,hkbgrect.y+30,hkbgrect.w-80,hkbgrect.h-60)
        hotkeytext = hs.drawing.text(hktextrect,"")
        hotkeytext:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeytext:behavior(hs.drawing.windowBehaviors.stationary)
        hotkeytext:setClickCallback(nil,function() hotkeytext:delete() hotkeytext=nil hotkeybg:delete() hotkeybg=nil end)
        hotkey_filtered = {}
        for i=1,#hotkey_list do
            if hotkey_list[i].idx ~= hotkey_list[i].msg then
                table.insert(hotkey_filtered,hotkey_list[i])
            end
        end
        local availablelen = 80
        local hkstr = ''
        for i=2,#hotkey_filtered,2 do
            local tmpstr = hotkey_filtered[i-1].msg .. hotkey_filtered[i].msg
            if string.len(tmpstr)<= availablelen then
                local tofilllen = availablelen-string.len(hotkey_filtered[i-1].msg)
                hkstr = hkstr .. string.format('%-80s', hotkey_filtered[i-1].msg) .. string.format('%'..tofilllen..'s',hotkey_filtered[i].msg) .. '\n'
            else
                hkstr = hkstr .. hotkey_filtered[i-1].msg .. '\n' .. hotkey_filtered[i].msg .. '\n'
            end
        end
        if math.fmod(#hotkey_filtered,2) == 1 then hkstr = hkstr .. hotkey_filtered[#hotkey_filtered].msg end
        local hkstr_styled = hs.styledtext.new(hkstr, {font={name="Courier-Bold",size=16}, color=dodgerblue, paragraphStyle={lineSpacing=12.0,lineBreak='truncateMiddle'}, shadow={offset={h=0,w=0},blurRadius=0.5,color=darkblue}})
        hotkeytext:setStyledText(hkstr_styled)
        hotkeybg:show()
        hotkeytext:show()
    else
        hotkeytext:delete()
        hotkeytext=nil
        hotkeybg:delete()
        hotkeybg=nil
    end
end

modal_list = {}

function modal_stat(color,alpha)
    if not modal_tray then
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local localMainRes = mainScreen:absoluteToLocal(mainRes)
        modal_tray = hs.canvas.new(mainScreen:localToAbsolute({x=localMainRes.w-40,y=localMainRes.h-40,w=20,h=20}))
        modal_tray[1] = {action="fill",type="circle",fillColor=white}
        modal_tray[1].fillColor.alpha=0.7
        modal_tray[2] = {action="fill",type="circle",fillColor=white,radius="40%"}
        modal_tray:level(hs.canvas.windowLevels.status)
        modal_tray:clickActivating(false)
        modal_tray:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.stationary)
        modal_tray._default.trackMouseDown = true
    end
    modal_tray:show()
    modal_tray[2].fillColor = color
    modal_tray[2].fillColor.alpha = alpha
end

activeModals = {}
function exit_others(excepts)
    function isInExcepts(value,tbl)
        for i=1,#tbl do
           if tbl[i] == value then
               return true
           end
        end
        return false
    end
    if excepts == nil then excepts = {} end
    for i = 1, #activeModals do
        if not isInExcepts(activeModals[i].id, excepts) then
            activeModals[i].modal:exit()
        end
    end
end

function move_win(direction)
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local screens = hs.screen.allScreens()
    if win then
        if direction == 'up' then win:moveOneScreenNorth() end
        if direction == 'down' then win:moveOneScreenSouth() end
        if direction == 'left' then win:moveOneScreenWest() end
        if direction == 'right' then win:moveOneScreenEast() end
        if direction == 'next' then win:moveToScreen(screen:next()) end
        if direction == 'first' then win:moveToScreen(screens[1]) end
        if direction == 'second' then win:moveToScreen(screens[2]) end
        if direction == 'third' then win:moveToScreen(screens[3]) end
        if direction == 'fourth' then win:moveToScreen(screens[4]) end
    end
end

function resize_win(direction)
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local localf = screen:absoluteToLocal(f)
        local max = screen:fullFrame()
        local stepw = max.w/30
        local steph = max.h/30
        if direction == "right" then
            localf.w = localf.w+stepw
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "left" then
            localf.w = localf.w-stepw
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "up" then
            localf.h = localf.h-steph
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "down" then
            localf.h = localf.h+steph
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "halfright" then
            localf.x = max.w/2 localf.y = 0 localf.w = max.w/2 localf.h = max.h
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "halfleft" then
            localf.x = 0 localf.y = 0 localf.w = max.w/2 localf.h = max.h
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "halfup" then
            localf.x = 0 localf.y = 0 localf.w = max.w localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "halfdown" then
            localf.x = 0 localf.y = max.h/2 localf.w = max.w localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "cornerNE" then
            localf.x = max.w/2 localf.y = 0 localf.w = max.w/2 localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "cornerSE" then
            localf.x = max.w/2 localf.y = max.h/2 localf.w = max.w/2 localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "cornerNW" then
            localf.x = 0 localf.y = 0 localf.w = max.w/2 localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "cornerSW" then
            localf.x = 0 localf.y = max.h/2 localf.w = max.w/2 localf.h = max.h/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "center" then
            localf.x = (max.w-localf.w)/2 localf.y = (max.h-localf.h)/2
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "fcenter" then
            localf.x = stepw*5 localf.y = steph*5 localf.w = stepw*20 localf.h = steph*20
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "fullscreen" then
            win:toggleFullScreen()
        end
        if direction == "maximize" then
            localf.x = 0 localf.y = 0 localf.w = max.w localf.h = max.h
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "shrink" then
            localf.x = localf.x+stepw localf.y = localf.y+steph localf.w = localf.w-(stepw*2) localf.h = localf.h-(steph*2)
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "expand" then
            localf.x = localf.x-stepw localf.y = localf.y-steph localf.w = localf.w+(stepw*2) localf.h = localf.h+(steph*2)
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "mright" then
            localf.x = localf.x+stepw
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "mleft" then
            localf.x = localf.x-stepw
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "mup" then
            localf.y = localf.y-steph
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "mdown" then
            localf.y = localf.y+steph
            local absolutef = screen:localToAbsolute(localf)
            win:setFrame(absolutef)
        end
        if direction == "ccursor" then
            localf.x = localf.x+localf.w/2 localf.y = localf.y+localf.h/2
            hs.mouse.setRelativePosition({x=localf.x,y=localf.y},screen)
        end
    else
        hs.alert.show("No focused window!")
    end
end

function highlightActiveWin()
    if fw() then
        local rect = hs.drawing.rectangle(fw():frame())
        rect:setStrokeColor({["red"]=1,  ["blue"]=0, ["green"]=1, ["alpha"]=1})
        rect:setStrokeWidth(5)
        rect:setFill(false)
        rect:show()
        hs.timer.doAfter(0.3, function() rect:delete() end)
    end
end

-- Fetch next index but cycle back when at the end
--
-- > getNextIndex({1,2,3}, 3)
-- 1
-- > getNextIndex({1}, 1)
-- 1
-- @return int
local function getNextIndex(table, currentIndex)
  nextIndex = currentIndex + 1
  if nextIndex > #table then
    nextIndex = 1
  end

  return nextIndex
end

local function getNextWindow(windows, window)
  if type(windows) == "string" then
    windows = hs.application.find(windows):allWindows()
  end

  windows = hs.fnutils.filter(windows, function(win)
    return win:isStandard() and win:isVisible()
  end)

  -- need to sort by ID, since the default order of the window
  -- isn't usable when we change the mainWindow
  -- since mainWindow is always the first of the windows
  -- hence we would always get the window succeeding mainWindow
  table.sort(windows, function(w1, w2)
    return w1:id() > w2:id()
  end)

  lastIndex = hs.fnutils.indexOf(windows, window)
  if not lastIndex then return window end

  return windows[getNextIndex(windows, lastIndex)]
end

-- Needed to enable cycling of application windows
lastToggledApplication = ''

function launchOrCycleFocus(applicationName)
  return function()
    local nextWindow = nil
    local targetWindow = nil
    local focusedWindow          = hs.window.focusedWindow()
    local lastToggledApplication = focusedWindow and focusedWindow:application():name()

    if not focusedWindow then return nil end
    if lastToggledApplication == applicationName then
      nextWindow = getNextWindow(applicationName, focusedWindow)
      -- Becoming main means
      -- * gain focus (although docs say differently?)
      -- * next call to launchOrFocus will focus the main window <- important
      -- * when fetching allWindows() from an application mainWindow will be the first one
      --
      -- If we have two applications, each with multiple windows
      -- i.e:
      --
      -- Google Chrome: {window1} {window2}
      -- Firefox:       {window1} {window2} {window3}
      --
      -- and we want to move between Google Chrome {window2} and Firefox {window3}
      -- when pressing the hotkeys for those applications, then using becomeMain
      -- we cycle until those windows (i.e press hotkey twice for Chrome) have focus
      -- and then the launchOrFocus will trigger that specific window.
      nextWindow:becomeMain()
      nextWindow:focus()
    else
      hs.application.launchOrFocus(applicationName)
    end

    if nextWindow then
      targetWindow = nextWindow
    else
      targetWindow = hs.window.focusedWindow()
    end

    if not targetWindow then
      return nil
    end
  end
end

function activateApp(appname)
    launchOrCycleFocus(appname)()
    local app = hs.application.find(appname)
    if app then
        app:activate()
        hs.timer.doAfter(0.1, highlightActiveWin)
        app:unhide()
    end
end

resize_win_bindings = {
    { key = {mod0, "left"},  dir = "halfleft", tip = "Lefthalf of Screen" },
    { key = {mod0, "right"}, dir = "halfright", tip = "Righthalf of Screen" },
    { key = {mod0, "up"},    dir = "halfup", tip = "Uphalf of Screen" },
    { key = {mod0, "down"},  dir = "halfdown", tip = "Downhalf of Screen" },
    { key = {mod0, "O"},     dir = "cornerNE", tip = "NorthEast Corner" },
    { key = {mod0, "Y"},     dir = "cornerNW", tip = "NorthWest Corner" },
    { key = {mod0, "U"},     dir = "cornerSW", tip = "SouthWest Corner" },
    { key = {mod0, "I"},     dir = "cornerSE", tip = "SouthEast Corner" },
    { key = {mod0, "C"},     dir = "center", tip = "Center Window" },
    { key = {mod0, "M"},     dir = "maximize", tip = "Maximize Window" },
    { key = {mod0, "F"},     dir = "fullscreen", tip = "Fullscreen Window" },
}

move_win_bindings = {
    { key = {mod0, "n"}, dir = "next", tip = "Move to next screen" },
    { key = {mod0, "1"}, dir = "first", tip = "Move to first screen" },
    { key = {mod0, "2"}, dir = "second", tip = "Move to second screen" },
    { key = {mod0, "3"}, dir = "third", tip = "Move to third screen" },
    { key = {mod0, "4"}, dir = "fourth", tip = "Move to fourth screen" },
}

applist = {
    {shortcut = 'c', appname = 'Google Chrome'},
    {shortcut = 'e', appname = 'Microsoft Excel'},
    {shortcut = 'f', appname = 'Finder'},
    {shortcut = 'i', appname = 'Amazon Chime'},
    {shortcut = 'j', appname = 'IntelliJ IDEA'},
    {shortcut = 'm', appname = 'NeteaseMusic'},
    {shortcut = 'o', appname = 'Microsoft Outlook'},
    {shortcut = 'p', appname = 'Microsoft PowerPoint'},
    {shortcut = 'r', appname = 'Firefox'},
    {shortcut = 't', appname = 'iTerm2'},
    {shortcut = 'w', appname = 'Microsoft Word'},
    {shortcut = 'x', appname = 'WeChat'},
}

hs.fnutils.each(resize_win_bindings, function(item)
    hs.hotkey.bind(item.key[1], item.key[2], item.tip, function() resize_win(item.dir) end)
end)

hs.fnutils.each(move_win_bindings, function(item)
    hs.hotkey.bind(item.key[1], item.key[2], item.tip, function() move_win(item.dir) end)
end)

hs.fnutils.each(applist, function(item)
    hs.hotkey.bind(appmod, item.shortcut, item.appname, function() activateApp(item.appname) end)
end)

if not module_list then
    module_list = {
        "widgets/caffeine",
        "widgets/netspeed",
        "widgets/calendar",
        "widgets/hcalendar",
        "widgets/analogclock",
        "widgets/timelapsed",
        "widgets/aria2",
        "modes/basicmode",
        "modes/indicator",
        "modes/clipshow",
        "modes/cheatsheet",
        "modes/hsearch",
        "misc/bingdaily",
    }
end

hs.fnutils.each(module_list, function(module)
    require(module)
end)

if #modal_list > 0 then require("modalmgr") end

globalGC = hs.timer.doEvery(180, collectgarbage)
globalScreenWatcher = hs.screen.watcher.newWithActiveScreen(function(activeChanged)
    if activeChanged then
        exit_others()
        clipshowclear()
        if modal_tray then modal_tray:delete() modal_tray = nil end
        if hotkeytext then hotkeytext:delete() hotkeytext = nil end
        if hotkeybg then hotkeybg:delete() hotkeybg = nil end
        for i=1,#hs.screen.allScreens() do
            local screen = hs.screen.allScreens()[i]
            destroy_time(screen:id())
            destroy_screen_number(screen:id())
        end
        if cheatsheet_view then cheatsheet_view:delete() cheatsheet_view = nil end
    end
end):start()

hs.alert.show("Config Loaded")
