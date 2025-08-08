local core_mainmenu = require("core_mainmenu")

-- This seems to be the UI object. TObject for child UI at
-- (*(uint32_t *)0xa4d848) + 0x50
--local _DressingRoomControlObject = 0xA4D848

-- Seems like this is a stable pointer to the char data
local _DressingRoomCharDataPtr = 0xA4D7F8

local _HairBlue  = 0x00AE7780
local _HairGreen = 0x00AE7781
local _HairRed   = 0x00AE7782

local display = false

local function CurrentScene()
    return pso.read_u32(0xaab384)
end

local function GetDressingRoomObject()
    return pso.read_u32(0xA4D848)
end

local function GetDressingRoomCharData()
    return pso.read_u32(_DressingRoomCharDataPtr)
end

local function PresentHair()
    local char = GetDressingRoomCharData()

    local hairType    = pso.read_u16(char + 0x40)
    local hairRed     = pso.read_u16(char + 0x42)
    local hairGreen   = pso.read_u16(char + 0x44)
    local hairBlue    = pso.read_u16(char + 0x46)
    
    local s = string.format(
        "Hair type: %i\n" ..
        "Hair color (RGB): %-0.2i, %-0.2i, %-0.2i",
        hairType,
        hairRed,
        hairGreen,
        hairBlue)

    imgui.Text(s)
end

local function PresentProportions()
    local char = GetDressingRoomCharData()

    local width   = pso.read_f32(char + 0x48)
    local height  = pso.read_f32(char + 0x4c)

    local s = string.format("Proportions: %.2f, %.2f", width, height)
    imgui.Text(s)
end

local function PresentDressingRoomInfo()
    PresentHair()
    PresentProportions()
end

local function present()
    if not display then
        return
    end
    
    if CurrentScene() ~= 5 then
        return
    end

    if GetDressingRoomObject() == 0 then
        -- Never gets here
        return
    end

    if imgui.Begin("Dressing Room", nil, nil) then
        PresentDressingRoomInfo()
        imgui.End()
    end
end

-- TODO: Add actual options for window positioning. Or not.
local function init()
    local mainMenuButtonHandler = function()
        display = not display
    end

    core_mainmenu.add_button("Dressing Room", mainMenuButtonHandler)
    
    return 
    {
        name = 'Dressing Room',
        version = '0.0.1',
        author = 'Ender',
        present = present,
        toggleable = true,
    }
end

return 
{
    __addon = 
    {
        init = init,
    },
}
