local function SetupMainMenuScene(sceneName)
    local scene = ZO_Scene:New(sceneName, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    scene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    return scene
end

local MENU_MAIN_ENTRIES =
{
    CROWN_STORE = 1,
    NOTIFICATIONS = 3,
    INVENTORY = 5,
    OPTIONS = 14,
}


AGUI.MainMenuSceneController = AGUI.SceneControllerBase:Subclass()

function AGUI.MainMenuSceneController:New(control, sceneName)
    local object = AGUI.SceneControllerBase.New(self, SetupMainMenuScene(sceneName))
    AGUI.MainMenuSceneController.Initialize(object, control)
    return object
end

function AGUI.MainMenuSceneController:Initialize(control)
    self.topLevelControl = control
    self.fragment = ZO_TranslateFromTopSceneFragment:New(self.topLevelControl, ALWAYS_ANIMATE)
    self.scene:AddFragment(self.fragment)

    self.mainMenuEntries = self:PrepareEntries()
    self.mainMenu = self:SetupRadialMenu("MainRadial")
    self.subMenu = self:SetupRadialMenu("SubRadial")
end

function AGUI.MainMenuSceneController:PrepareEntries()
    local entries = {}
    for i, entry in ipairs(ZO_MENU_ENTRIES) do
        if entry.id ~= MENU_MAIN_ENTRIES.NOTIFICATIONS then -- skip notifications, because it has been moved to KeybindButtonGroupDescriptor
            entries[#entries + 1] = entry.data
            if entry.id == MENU_MAIN_ENTRIES.CROWN_STORE or entry.id == MENU_MAIN_ENTRIES.INVENTORY or entry.id == MENU_MAIN_ENTRIES.OPTIONS then
                entries[#entries].proxyRequired = true
                if entry.subMenu then
                    entries[#entries].proxySubmenu = entry.subMenu
                else
                    entries[#entries].proxySubmenu = { [1] = entry }
                end
            end
        end
    end
    return entries
end

function AGUI.MainMenuSceneController:SetupRadialMenu(controlName)
    local control = self.topLevelControl:GetNamedChild(controlName)
    local menu = AGUI.RadialMenu:New(control, "AGUI.MainMenuEntryTemplate", nil, "SelectableItemRadialMenuEntryAnimation")

    local function SetupEntryControl(entryControl, data)
        entryControl.label:SetText(data.name)
        ZO_SetupSelectableItemRadialMenuEntryTemplate(entryControl)
    end
    menu:SetCustomControlSetUpFunction(SetupEntryControl)
    menu:Clear()
    return menu
end

function AGUI.MainMenuSceneController:PopulateMenu(menu, entries)
    menu.currentEntries = entries
    for i, entry in ipairs(entries) do
        if type(entry.name) ~= "function" then
            menu:AddEntry(entry.name, entry.icon, entry.icon, nil, {name = entry.name, slot = i})
        end
    end
end

function AGUI.MainMenuSceneController:ShowMenu(menu)
    self.activeMenu = menu
    self.activeEntries = menu.currentEntries
    if not menu:IsShown() then
        menu:Show()
    end
end

function AGUI.MainMenuSceneController:MakeKeybindButtonGroupDescriptor()
    return {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = GetString(SI_MAIN_MENU_GAMEPAD_VOICECHAT),
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function() SCENE_MANAGER:Push("gamepad_voice_chat") end,
            visible = IsConsoleUI,
        },
        {
            name = GetString(SI_GAMEPAD_TEXT_CHAT),
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function() SCENE_MANAGER:Push("gamepadChatMenu") end,
            visible = IsChatSystemAvailableForCurrentPlatform,
        },
        {
            name = GetString(SI_GAMEPAD_MAIN_MENU_NOTIFICATIONS),
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function() SCENE_MANAGER:Push("gamepad_notifications_root") end
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            order = -500,
            callback = function() self:ExecuteSelectedMenuEntry() end
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            visible = IsInGamepadPreferredMode,
            order = -1500,
            callback = function()
                if self.subMenu:IsShown() then
                    self.subMenu:Clear()
                    self:ShowMenu(self.mainMenu)
                else
                    SCENE_MANAGER:HideCurrentScene()
                end
            end,
        }
    }
end

function AGUI.MainMenuSceneController:ExecuteSelectedMenuEntry()
    local entry = self.activeMenu.selectedEntry
    if entry ~= nil then
        local menuEntryData = self.activeEntries[entry.data.slot]

        if menuEntryData.proxyRequired then
            self:ShowProxyDialog(menuEntryData)
            return
        end

        if menuEntryData.scene ~= nil then
            SCENE_MANAGER:Push(menuEntryData.scene)
            return
        end

        if menuEntryData.activatedCallback ~= nil then
            menuEntryData.activatedCallback()
            return
        end

        if menuEntryData.subMenu ~= nil then
            self:PopulateMenu(self.subMenu, menuEntryData.subMenu)
            self:ShowMenu(self.subMenu)
            return
        end

        SCENE_MANAGER:HideCurrentScene()
        d("Unknown menu entry")
    end
end

function AGUI.MainMenuSceneController:ShowProxyDialog(myEntry)
    MAIN_MENU_GAMEPAD.mainList:SetFirstIndexSelected()
    MAIN_MENU_GAMEPAD.mainList:GetTargetData().subMenu = myEntry.proxySubmenu
    MAIN_MENU_GAMEPAD:SwitchToSelectedScene(MAIN_MENU_GAMEPAD.mainList)
end

function AGUI.MainMenuSceneController:OnShowing()
    local prevActiveEntries = self.activeEntries

    self:PopulateMenu(self.mainMenu, self.mainMenuEntries)
    self:ShowMenu(self.mainMenu)

    if SCENE_MANAGER:GetPreviousSceneName() == "hud" then return end

    if prevActiveEntries ~= nil and prevActiveEntries ~= self.mainMenuEntries then
        self:PopulateMenu(self.subMenu, prevActiveEntries)
        self:ShowMenu(self.subMenu)
    end
end

function AGUI.MainMenuSceneController:OnShown()
end

function AGUI.MainMenuSceneController:OnHiding()
end

function AGUI.MainMenuSceneController:OnHidden()
    self.mainMenu:Clear()
    self.subMenu:Clear()
end
