function AGUI.MainMenuEntryTemplate_OnInitialized(control)
    control.label = control:GetNamedChild("Label")
    ZO_SelectableItemRadialMenuEntryTemplate_OnInitialized(control)
    ZO_CreateSparkleAnimation(control)
end

function AGUI.MainMenuTopLevel_Initialize(control)
    AGUI.mainMenuSceneController = AGUI.MainMenuSceneController:New(control, "mainMenuGamepad")
end
