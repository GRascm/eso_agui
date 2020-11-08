AGUI.SceneControllerBase = ZO_Object:Subclass()

function AGUI.SceneControllerBase:New(...)
    local object = ZO_Object.New(self)
    AGUI.SceneControllerBase.Initialize(object, ...)
    return object
end

function AGUI.SceneControllerBase:Initialize(scene)
    scene:RegisterCallback("StateChange", function (...) self:OnStateChanged(...) end)
    self.scene = scene
    self.keybindButtonGroupDescriptor = self:MakeKeybindButtonGroupDescriptor()
end

function AGUI.SceneControllerBase:OnStateChanged(oldState, newState)
    if newState == SCENE_SHOWING or newState == SCENE_GROUP_SHOWING then
        return self:ProcessShowing()
    end

    if newState == SCENE_SHOWN or newState == SCENE_GROUP_SHOWN then
        return self:ProcessShown()
    end

    if newState == SCENE_HIDING then
        return self:ProcessHiding()
    end

    if newState == SCENE_HIDDEN or newState == SCENE_GROUP_HIDDEN then
        return self:ProcessHidden()
    end
end

function AGUI.SceneControllerBase:ProcessShowing()
    if self.keybindButtonGroupDescriptor then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindButtonGroupDescriptor)
    end

    self:OnShowing()
end

function AGUI.SceneControllerBase:ProcessShown()
    self:OnShown()
end

function AGUI.SceneControllerBase:ProcessHiding()
    if self.keybindButtonGroupDescriptor then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindButtonGroupDescriptor)
    end

    self:OnHiding()
end

function AGUI.SceneControllerBase:ProcessHidden()
    if self.keybindButtonGroupDescriptor then -- No SCENE_GROUP_HIDING, so need to unregister here (multiple unregistring is not an error)
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindButtonGroupDescriptor)
    end

    self:OnHidden()
end

-- override
function AGUI.SceneControllerBase:MakeKeybindButtonGroupDescriptor()
end

function AGUI.SceneControllerBase:OnShowing()
end

function AGUI.SceneControllerBase:OnShown()
end

function AGUI.SceneControllerBase:OnHiding()
end

function AGUI.SceneControllerBase:OnHidden()
end
