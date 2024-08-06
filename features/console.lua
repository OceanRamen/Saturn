utf8 = require("utf8")
local nativefs = require("nativefs")

function Saturn:init_console()
    self.CONSOLE = {
        isOpen = false,
        isLocked = false,
        input = "",
        history = {},
        historyPos = 0,
        output = {},
        maxHistory = 100,
        size = 8,
        font = love.graphics.newFont(12),
        selectionStart = 1,
        selectionEnd = 1,
        isSelecting = false,
    }
    self.CONSOLE.height = (love.graphics.getHeight() / 6) * 1.05
    self.registry = CommandRegistry:new()
    self:register_commands()
end

function Saturn:log_console(log)
    table.insert(self.CONSOLE.output, tostring(log))
end

-------------------------------------------
-------------CLASS-DEFINITION--------------
-------------------------------------------

Command = {}
Command.__index = Command

function Command:new(name, description, execute)
    local cmd = {
        name = name,
        description = description,
        execute = execute,
    }
    setmetatable(cmd, Command)
    return cmd
end

function Command:execute(args)
    -- print(inspectDepth(args))
    if self.execute then
        self.execute(args)
    end
end

-- CommandRegistry class

CommandRegistry = {}
function CommandRegistry:new()
    local registry = {
        commands = {},
        sorted = {}
    }
    setmetatable(registry, { __index = CommandRegistry })
    return registry
end

function CommandRegistry:register(command)
    self.commands[command.name] = command
    self.sorted[#self.sorted+1] = command.name
    table.sort(self.sorted)
end

function CommandRegistry:execute(commandName, args)
    -- print("cr:e"..inspectDepth(args))
    local command = self.commands[commandName]
    if command then
        command.execute(args)
    else
        S:log_console("unknown command: " .. commandName)
    end
end

-------------------------------------------
---------------KEY-HANDLING----------------
-------------------------------------------

function Saturn:handle_console(key)
    if key == "`" then
      if self.SETTINGS.modules.preferences.console.enabled then -- Toggle console with the ` key
        self.CONSOLE.isOpen = not  self.CONSOLE.isOpen
        return -- Ignore further processing of this key
      else
        self.CONSOLE.isOpen = false
      end
    end

    if self.CONSOLE.isOpen then
        if key == "return" then
            if  self.CONSOLE.input ~= "" then
                table.insert( self.CONSOLE.history,  self.CONSOLE.input)
                executeCommand( self.CONSOLE.input)
                self.CONSOLE.input = ""
                self.CONSOLE.selectionStart = 1
                self.CONSOLE.selectionEnd = 1
                self.CONSOLE.isSelecting = false
                self.CONSOLE.historyPos = # self.CONSOLE.history+1
            end

            -- Trim history if it exceeds maxHistory
            if # self.CONSOLE.history >  self.CONSOLE.maxHistory then
                table.remove( self.CONSOLE.history, 1)
            end
        elseif key == "backspace" then
            handleBackspace()
        elseif love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
            handleCtrlShortcuts(key)
        elseif key == 'up' or key == 'down' then
            handleArrowKey(key)
        else
            self.CONSOLE.isSelecting = false
        end
    end
end

function love.textinput(t)
    if S.CONSOLE and S.CONSOLE.isOpen then
        if t == "`" then
            return
        end -- Ignore backtick key input

        if S.CONSOLE.isSelecting and S.CONSOLE.selectionStart ~= S.CONSOLE.selectionEnd then
            local selectionStart = math.min(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            local selectionEnd = math.max(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            S.CONSOLE.input = S.CONSOLE.input:sub(1, selectionStart - 1) .. t .. S.CONSOLE.input:sub(selectionEnd)
            S.CONSOLE.selectionStart = selectionStart + #t
            S.CONSOLE.selectionEnd = S.CONSOLE.selectionStart
            S.CONSOLE.isSelecting = false
        else
            S.CONSOLE.input = S.CONSOLE.input .. t
            S.CONSOLE.selectionStart = #S.CONSOLE.input + 1
            S.CONSOLE.selectionEnd = #S.CONSOLE.input + 1
            S.CONSOLE.isSelecting = false
        end
    end
end

local love_draw_ref = love.draw
function love.draw()
    love_draw_ref(self)
    if S.CONSOLE and S.CONSOLE.isOpen then
        love.graphics.setFont(S.CONSOLE.font)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), S.CONSOLE.height)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("> " .. S.CONSOLE.input, 10, 10)

        -- Draw selection
        if S.CONSOLE.isSelecting and S.CONSOLE.selectionStart ~= S.CONSOLE.selectionEnd then
            local selectionStart = math.min(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            local selectionEnd = math.max(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            local preSelection = S.CONSOLE.input:sub(1, selectionStart - 1)
            local selectedText = S.CONSOLE.input:sub(selectionStart, selectionEnd - 1)

            local x = 10 + love.graphics.getFont():getWidth("> " .. preSelection)
            local y = 10
            local width = love.graphics.getFont():getWidth(selectedText)
            local height = love.graphics.getFont():getHeight()

            love.graphics.setColor(0, 40, 255, 0.26)
            love.graphics.rectangle("fill", x, y, width, height)
            love.graphics.setColor(255, 255, 255, 255)
        end

        -- Calculate the number of lines that can be displayed
        local lineHeight = love.graphics.getFont():getHeight()
        local maxLines = S.CONSOLE.size--math.floor((S.CONSOLE.height - 20) / lineHeight) -- Leave some padding at the top

        -- Get the lines to display
        local linesToDisplay = {}
        local startY = 30
        local outputLines = #S.CONSOLE.output
        local firstLine = math.max(1, outputLines - maxLines + 1)

        for i = firstLine, outputLines do
            table.insert(linesToDisplay, S.CONSOLE.output[i])
        end

        -- Draw the lines
        for i = #linesToDisplay, 1, -1 do
            love.graphics.print(linesToDisplay[i], 10, startY + (#linesToDisplay - i) * lineHeight)
        end
    end
end

function executeCommand(command)
    local args = {}
    -- Split the command string into words
    for word in string.gmatch(command, "%S+") do
        table.insert(args, word:lower())
    end

    -- Extract the command name and arguments
    local cmdName = args[1]
    table.remove(args, 1) -- Remove the command name from args

    -- Execute the command with arguments
    -- print(cmdName..inspectDepth(args))
    S.registry:execute(cmdName, args)
end


function handleBackspace()
    if S.CONSOLE.isSelecting and S.CONSOLE.selectionStart ~= S.CONSOLE.selectionEnd then
        local selectionStart = math.min(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
        local selectionEnd = math.max(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
        S.CONSOLE.input = S.CONSOLE.input:sub(1, selectionStart - 1) .. S.CONSOLE.input:sub(selectionEnd)
        S.CONSOLE.selectionStart = selectionStart
        S.CONSOLE.selectionEnd = selectionStart
        S.CONSOLE.isSelecting = false
    else
        local byteoffset = utf8.offset(S.CONSOLE.input, -1)
        if byteoffset then
            S.CONSOLE.input = string.sub(S.CONSOLE.input, 1, byteoffset - 1)
            S.CONSOLE.selectionStart = #S.CONSOLE.input + 1
            S.CONSOLE.selectionEnd = #S.CONSOLE.input + 1
            S.CONSOLE.isSelecting = false
        end
    end
end

function handleArrowKey(key)
    if key == 'down' then
        if S.CONSOLE.historyPos > 1 then
            S.CONSOLE.historyPos = S.CONSOLE.historyPos - 1
        end
    elseif key == 'up' then
        if S.CONSOLE.historyPos < #S.CONSOLE.history+1 then
            S.CONSOLE.historyPos = S.CONSOLE.historyPos + 1
        end
    end
    if S.CONSOLE.historyPos == #S.CONSOLE.history+1 then
        S.CONSOLE.input = ''
    elseif S.CONSOLE.historyPos <= #S.CONSOLE.history then
        S.CONSOLE.input = S.CONSOLE.history[S.CONSOLE.historyPos]
    end
end

function handleCtrlShortcuts(key)
    if key == "a" then -- Select all
        S.CONSOLE.selectionStart = 1
        S.CONSOLE.selectionEnd = #S.CONSOLE.input + 1
        S.CONSOLE.isSelecting = true
    elseif key == "c" then -- Copy
        if S.CONSOLE.isSelecting then
            love.system.setClipboardText(S.CONSOLE.input:sub(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd - 1))
        else
            love.system.setClipboardText(S.CONSOLE.input)
        end
    elseif key == "v" then -- Paste
        local clipboardText = love.system.getClipboardText()
        if S.CONSOLE.isSelecting and S.CONSOLE.selectionStart ~= S.CONSOLE.selectionEnd then
            local selectionStart = math.min(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            local selectionEnd = math.max(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            S.CONSOLE.input = S.CONSOLE.input:sub(1, selectionStart - 1) .. clipboardText .. S.CONSOLE.input:sub(selectionEnd)
            S.CONSOLE.selectionStart = selectionStart + #clipboardText
            S.CONSOLE.selectionEnd = S.CONSOLE.selectionStart
        else
            S.CONSOLE.input = S.CONSOLE.input .. clipboardText
            S.CONSOLE.selectionStart = #S.CONSOLE.input + 1
            S.CONSOLE.selectionEnd = #S.CONSOLE.input + 1
        end
        S.CONSOLE.isSelecting = false
    elseif key == "x" then -- Cut
        if S.CONSOLE.isSelecting then
            love.system.setClipboardText(S.CONSOLE.input:sub(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd - 1))
            local selectionStart = math.min(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            local selectionEnd = math.max(S.CONSOLE.selectionStart, S.CONSOLE.selectionEnd)
            S.CONSOLE.input = S.CONSOLE.input:sub(1, selectionStart - 1) .. S.CONSOLE.input:sub(selectionEnd)
            S.CONSOLE.selectionStart = selectionStart
            S.CONSOLE.selectionEnd = selectionStart
            S.CONSOLE.isSelecting = false
        else
            love.system.setClipboardText(S.CONSOLE.input)
            S.CONSOLE.input = ""
            S.CONSOLE.selectionStart = 1
            S.CONSOLE.selectionEnd = 1
            S.CONSOLE.isSelecting = false
        end
    end
end

-------------------------------------------
--------------SATURN-COMMANDS--------------
-------------------------------------------

-- Register built-in commands

function Saturn:register_commands()

    self.registry:register(Command:new("help", "shows available commands, usage: help <command>", function(args)
        args = args or {{''}}
        local specific_command = self.registry.commands[args[1]] or nil
        if specific_command then
            self:log_console(specific_command.name .. ', '..specific_command.description)
        else
            local commandsList = "available commands: "
            for i = 1, #self.registry.sorted do
                commandsList = commandsList .. self.registry.sorted[i] .. ", "
            end
            self:log_console(commandsList:sub(1, -3))
        end
    end))

    self.registry:register(Command:new("clear", "clears the console output, usage: clear", function(args)
        self.CONSOLE.output = {}
    end))

    self.registry:register(Command:new("cl", "clears the console output, usage: cl", function(args)
        self.CONSOLE.output = {}
    end))

    local function firstToUpper(str)
        return (str:gsub("^%l", string.upper))
    end

    self.registry:register(Command:new('list', 'lists the keys of a center type, usage: list <type> <pagenum> <num>', function(args)
        local _type = firstToUpper(args[1])
        local page_num = (args[2] and args[2]-1) or 0
        local max = args[3] or 15
        local key = nil
        if G.P_CENTER_POOLS[_type] and page_num*max <= #G.P_CENTER_POOLS[_type] and page_num > -1 and max > 0 then
            self.CONSOLE.output = {}
            for i = 1, max do
                if G.P_CENTER_POOLS[_type][i+(page_num*max)] then
                    key = G.P_CENTER_POOLS[_type][i+(page_num*max)]
                    self:log_console(tostring(key.key))
                end
            end
        end
        if not key then
            self:log_console('invalid argument')
        end
    end))

    self.registry:register(Command:new('debug', 'enables/disables debug mode, usage: debug', function(args)
        _RELEASE_MODE = not _RELEASE_MODE
    end))

    self.registry:register(Command:new('reroll', 'rerolls for a joker or stops, usage: reroll <joker> <edition>', function(args)
        local valid = false
        if args[1] then valid = true end
        if valid then
            if args[1] == 'stop' then return self:stop_reroll() end
            local joker = ''
            local edition = nil
            if args[#args] == 'negative' or args[#args] == 'holo' or args[#args] == 'polychrome' or args[#args] == 'foil' then
                edition = table.remove(args)
            end
            for i = 1, #args do
                joker = joker .. args[i]
                if i ~= #args then joker = joker .. ' ' end
            end
            if self:check_valid(joker) then
                self:start_reroll(joker, edition)
            else
                valid = false
            end
        end
        if not valid then
            self:log_console('invalid argument')
        end
    end))


    self.registry:register(Command:new('spawn', 'spawns a card, usage: spawn <center>', function(args)
        local center_key = nil
        local center_set = nil
        for k, v in pairs(G.P_CENTERS) do
            if tostring(k) == args[1] then
                center_key = tostring(k)
                center_set = tostring(v.set)
            end
        end
        if center_set == 'Joker' and G.STAGE == G.STAGES.RUN then
            G.GAME.joker_buffer = G.GAME.joker_buffer + 1
            local card = create_card('Joker', G.jokers, nil, nil, nil, nil, center_key, nil)
            card:add_to_deck()
            G.jokers:emplace(card)
            card:start_materialize()
            G.GAME.joker_buffer = 0
        elseif (center_set == 'Tarot' or center_set == 'Planet' or center_set == 'Spectral') and G.STAGE == G.STAGES.RUN then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            local card = create_card(center_set, G.consumables, nil, nil, nil, nil, center_key, nil)
            card:add_to_deck()
            G.consumeables:emplace(card)
            G.GAME.consumeable_buffer = 0
        else
            self:log_console('invalid argument')
        end
    end))

    self.registry:register(Command:new('redeem', 'redeems a voucher, usage: redeem <voucher>', function(args)
        local center_set = nil
        local center = args[1] or nil
        for k, v in pairs(G.P_CENTERS) do
            if tostring(k) == center then
                center = k
                center_set = tostring(v.set)
            end
        end
        if center_set == 'Voucher' and G.STAGE == G.STAGES.RUN then
            local card = Card(0, 0, 0, 0, G.P_CARDS.empty, G.P_CENTERS[center])
            card:apply_to_run()
            card:remove()
            G.GAME.used_vouchers[tostring(center)] = true
        else
            self:log_console('invalid argument')
        end
    end))

    self.registry:register(Command:new('version', 'displays current Saturn version, usage: version', function(args)
        self:log_console('Saturn VERSION: '..self.VERSION)
    end))

    self.registry:register(Command:new('new', 'starts a new run, usage: new <back>', function(args)
        local back = args[1] or nil
        if G.P_CENTERS[back] and G.P_CENTERS[back].set == 'Back' then
            G.GAME.selected_back = Back(G.P_CENTERS[back])
        end
        G:delete_run()
        G:start_run()
    end))

    self.registry:register(Command:new('menu', 'exits to menu, usaage: menu', function(args)
        G:delete_run()
        G:main_menu()
    end))

    self.registry:register(Command:new('quit', 'quits the game, usage: quit', function(args)
        G.FUNCS.quit()
    end))
    
    self.registry:register(Command:new('lines', 'changes number of lines displayed: lines <number>', function(args)
        if #args == 0 then
            self.CONSOLE.size = 8
        elseif tonumber(args[1]) > 0 and tonumber(args[1]) < 30 then
            self.CONSOLE.size = args[1]
        else
            self:log_console('invalid argument')
        end
    end))

    self.registry:register(Command:new('height', 'changes height of the console, usage: height <number>', function(args)
        if #args == 0 then
            self.CONSOLE.height = (love.graphics.getHeight() / 6) * 1.05
        elseif (tonumber(args[1])) > 6 or (tonumber(args[1])) < 1 then
            self:log_console('invalid argument')
            return
        else
            self.CONSOLE.height = (love.graphics.getHeight() / 6) * (tonumber(args[1]))
        end
    end))

end