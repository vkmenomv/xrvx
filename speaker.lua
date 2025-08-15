local player = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local env = getgenv()

local speakerModule = {
    api = env.API,

    enablePrioritySpeaker = function(self)
        local AudioFocusService = game:GetService("AudioFocusService")
        AudioFocusService:RegisterContextIdFromLua(100)
        task.wait()
        AudioFocusService:RequestFocus(100, 9999999)
    end,

    createNotification = function(self)
        if self.api then
            self.api:showNotification("SPEAKER", "Priority Speaker enabled", 5, "success")
        end
    end
}

speakerModule:enablePrioritySpeaker()
speakerModule:createNotification()
return speakerModule
