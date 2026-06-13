local color_text = color.new(200, 200, 200)
local color_title = color.new(0, 255, 100)
local color_selected = color.new(255, 255, 0)
local color_hint = color.new(100, 100, 100)

local root_folder = "ux0:data/FlashGames/"
local ruffle_dir = "ux0:data/ruffle/"
local profiles_dir = "ux0:data/ruffle/profiles/"

files.mkdir(root_folder)
files.mkdir(ruffle_dir)
files.mkdir(profiles_dir)

local current_dir = root_folder
local state = "browser"
local selected_game = ""

local cur_browser = 1
local cur_config = 1
local cur_key = 1

local key_db = {
    {name = "Space", code = 32}, {name = "Enter", code = 13}, {name = "Shift", code = 16}, {name = "Ctrl", code = 17},
    {name = "A", code = 65}, {name = "B", code = 66}, {name = "C", code = 67}, {name = "D", code = 68},
    {name = "E", code = 69}, {name = "F", code = 70}, {name = "G", code = 71}, {name = "H", code = 72},
    {name = "I", code = 73}, {name = "J", code = 74}, {name = "K", code = 75}, {name = "L", code = 76},
    {name = "M", code = 77}, {name = "N", code = 78}, {name = "O", code = 79}, {name = "P", code = 80},
    {name = "Q", code = 81}, {name = "R", code = 82}, {name = "S", code = 83}, {name = "T", code = 84},
    {name = "U", code = 85}, {name = "V", code = 86}, {name = "W", code = 87}, {name = "X", code = 88},
    {name = "Y", code = 89}, {name = "Z", code = 90},
    {name = "Up Arrow", code = 38}, {name = "Down Arrow", code = 40}, {name = "Left Arrow", code = 37}, {name = "Right Arrow", code = 39}
}

function get_filtered_list(dir)
    local raw_list = files.list(dir)
    local filtered = {}
    if raw_list then
        for i = 1, #raw_list do
            local ext = raw_list[i].ext and string.lower(raw_list[i].ext) or ""
            if raw_list[i].directory or ext == "swf" then
                table.insert(filtered, raw_list[i])
            end
        end
    end
    return filtered
end

local game_list = get_filtered_list(current_dir)
local map = {}

function load_game_profile(game_name)
    local default_map = {
        {id = "south", label = "Cross (Down)", key_name = "Space", code = 32},
        {id = "east",  label = "Circle (Right)", key_name = "A", code = 65},
        {id = "west",  label = "Square (Left)", key_name = "S", code = 83},
        {id = "north", label = "Triangle (Up)", key_name = "D", code = 68}
    }
    local safe_name = game_name:gsub("%.swf", ""):gsub("%.SWF", "")
    local path = profiles_dir .. safe_name .. ".txt"
    
    if files.exists(path) then
        local f = io.open(path, "r")
        if f then
            for i = 1, 4 do
                local line = f:read("*l")
                if line then
                    local name, code = line:match("([^,]+),([0-9]+)")
                    if name and code then
                        default_map[i].key_name = name
                        default_map[i].code = tonumber(code)
                    end
                end
            end
            f:close()
        end
    end
    return default_map
end

function execute_launch(game_path, game_name, current_map)
    local safe_name = game_name:gsub("%.swf", ""):gsub("%.SWF", "")
    local f = io.open(profiles_dir .. safe_name .. ".txt", "w")
    if f then
        for i = 1, 4 do 
            f:write(current_map[i].key_name .. "," .. current_map[i].code .. "\n") 
        end
        f:close()
    end

    files.delete(ruffle_dir .. "movie.swf")
    files.copy(game_path, ruffle_dir)
    files.rename(ruffle_dir .. files.nopath(game_path), "movie.swf")
    
    local ron = string.format([[Config(
    gamepad_config: {
        "dpad-up": 38, "dpad-down": 40, "dpad-left": 37, "dpad-right": 39,
        "south": %d, "east": %d, "west": %d, "north": %d,
    },
)]], current_map[1].code, current_map[2].code, current_map[3].code, current_map[4].code)
    
    local file = io.open(ruffle_dir .. "config.ron", "w")
    if file then 
        file:write(ron) 
        file:close() 
    end
    
    game.launch("RUFFLVITA")
end

while true do
    buttons.read()

    if state == "browser" then
        screen.print(20, 20, "--- GAME BROWSER ---", 1, color_title)
        screen.print(20, 50, "Path: " .. current_dir, 1, color_hint)

        if not game_list or #game_list == 0 then
            screen.print(20, 90, "[ Empty Folder ]", 1, color_text)
        else
            local start_idx = math.max(1, cur_browser - 8)
            local end_idx = math.min(#game_list, start_idx + 16)
            if end_idx - start_idx < 16 then 
                start_idx = math.max(1, end_idx - 16) 
            end

            local pos_y = 90
            for i = start_idx, end_idx do
                local current_color = color_text
                if i == cur_browser then
                    current_color = color_selected
                    screen.print(5, pos_y, ">", 1, current_color)
                end
                
                local prefix = game_list[i].directory and "[DIR] " or "      "
                screen.print(25, pos_y, prefix .. game_list[i].name, 1, current_color)
                pos_y = pos_y + 22
            end
        end

        screen.print(20, 500, "[X] Configure    [SQUARE] Quick Launch    [O] Back    [START] Exit", 1, color_hint)

        if buttons.up and cur_browser > 1 then 
            cur_browser = cur_browser - 1 
        end
        
        if buttons.down and game_list and cur_browser < #game_list then 
            cur_browser = cur_browser + 1 
        end
        
        if buttons.cross and game_list and #game_list > 0 then
            local target = game_list[cur_browser]
            if target.directory then
                current_dir = target.path .. "/"
                game_list = get_filtered_list(current_dir)
                cur_browser = 1
            else
                selected_game = target.path
                map = load_game_profile(target.name)
                state = "config"
            end
        end

        if buttons.square and game_list and #game_list > 0 then
            local target = game_list[cur_browser]
            if not target.directory then
                local temp_map = load_game_profile(target.name)
                execute_launch(target.path, target.name, temp_map)
            end
        end

        if buttons.circle and current_dir ~= root_folder then
            local stripped = current_dir:sub(1, #current_dir - 1)
            local pivot = stripped:match("^.*()/")
            if pivot then
                current_dir = stripped:sub(1, pivot)
                game_list = get_filtered_list(current_dir)
                cur_browser = 1
            end
        end

        if buttons.start then 
            os.exit() 
        end

    elseif state == "config" then
        screen.print(20, 20, "--- CONTROL CONFIGURATION ---", 1, color_title)
        screen.print(20, 50, "Game: " .. files.nopath(selected_game), 1, color_text)
        screen.print(20, 80, "Select a console button to remap:", 1, color_hint)
        
        local pos_y = 120
        for i = 1, #map do
            local current_color = color_text
            if i == cur_config then
                current_color = color_selected
                screen.print(5, pos_y, ">", 1, current_color)
            end
            screen.print(25, pos_y, map[i].label .. "   ====>   " .. map[i].key_name, 1, current_color)
            pos_y = pos_y + 30
        end

        screen.print(20, 480, "[X] Remap Key   [O] Back to List", 1, color_hint)
        screen.print(20, 500, "[START] SAVE PROFILE AND PLAY", 1, color_title)

        if buttons.up and cur_config > 1 then 
            cur_config = cur_config - 1 
        end
        
        if buttons.down and cur_config < #map then 
            cur_config = cur_config + 1 
        end
        
        if buttons.circle then 
            state = "browser" 
        end
        
        if buttons.cross then 
            cur_key = 1 
            state = "assign" 
        end

        if buttons.start then
            execute_launch(selected_game, files.nopath(selected_game), map)
        end

    elseif state == "assign" then
        screen.print(20, 20, "--- ASSIGN KEYBOARD KEY ---", 1, color_title)
        screen.print(20, 50, "Selected button: " .. map[cur_config].label, 1, color_text)
        
        local start_idx = math.max(1, cur_key - 8)
        local end_idx = math.min(#key_db, start_idx + 16)
        if end_idx - start_idx < 16 then 
            start_idx = math.max(1, end_idx - 16) 
        end

        local pos_y = 90
        for i = start_idx, end_idx do
            local current_color = color_text
            if i == cur_key then
                current_color = color_selected
                screen.print(5, pos_y, ">", 1, current_color)
            end
            screen.print(25, pos_y, key_db[i].name .. " (Code: " .. key_db[i].code .. ")", 1, current_color)
            pos_y = pos_y + 22
        end

        screen.print(20, 500, "Up/Down: Navigate   [X] Confirm   [O] Cancel", 1, color_hint)

        if buttons.up and cur_key > 1 then 
            cur_key = cur_key - 1 
        end
        
        if buttons.down and cur_key < #key_db then 
            cur_key = cur_key + 1 
        end
        
        if buttons.circle then 
            state = "config" 
        end
        
        if buttons.cross then
            map[cur_config].key_name = key_db[cur_key].name
            map[cur_config].code = key_db[cur_key].code
            state = "config"
        end
    end

    screen.flip()
end