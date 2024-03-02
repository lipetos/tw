--[[
    Input Controller
    lpz
    idk
]]

--// Services & Modules
local uis = game:GetService("UserInputService")
local replicated_storage = game:GetService("ReplicatedStorage")

local knit = require(replicated_storage.Packages.Knit)

--// Controller
local InputController = knit.CreateController({
    Name = "InputController"
})

function InputController:KnitInit()
    self.input_binds = {}
end

function InputController:KnitStart()

end

function InputController:BindKeyboard(key: string, event_type: string, f: () -> (), should_check_gpe: boolean?)
    if not self.input_binds[key] then
        self.input_binds[key] = {
            binds = {}
        }
    end

    table.insert(self.input_binds[key].binds, uis[event_type]:Connect(function(input, gpe)
        if gpe == should_check_gpe then return end

        if input.KeyCode == Enum.KeyCode[key] then
            f()
        end
    end))
end

return InputController