AGUI = {}
AGUI.name = "AdvancedGamepadUI"


function AGUI.OnAddOnLoaded(event, addonName)
    if addonName ~= AGUI.name then return end
end

EVENT_MANAGER:RegisterForEvent(AGUI.name, EVENT_ADD_ON_LOADED, AGUI.OnAddOnLoaded)
