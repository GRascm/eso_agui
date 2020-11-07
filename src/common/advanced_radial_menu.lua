--[[ Advanced Radial Menu

Inherits standart ZO_RadialMenu, with following improvements:

* Correct Clear if control hidden
* Fix scaling issues
* Remove limitation to one open radial menu

]]--

AGUI.RadialMenu = ZO_RadialMenu:Subclass()

function AGUI.RadialMenu:New(...)
    local object = ZO_RadialMenu.New(self, ...)
    object.clearing = false
    return object
end


function AGUI.RadialMenu:Clear()
    self.clearing = true
    ZO_RadialMenu.Clear(self)
    if self.control:IsHidden() then
        self:FinalizeClear()
    end
end

function AGUI.RadialMenu:FinalizeClear()
    if not self.clearing then return end
    ZO_RadialMenu.FinalizeClear(self)
    self.clearing = false
end

function AGUI.RadialMenu:PerformLayout()
    ZO_RadialMenu.PerformLayout(self)
    local width, height = self.control:GetDimensions()
    local step = math.pi * 2 / #self.entries
    for i, entry in ipairs(self.entries) do
        local x = math.sin(step*i)
        local y = math.cos(step*i)
        entry.control:SetAnchor(CENTER, nil, CENTER, x * width/2, y * height/2)
    end
end
