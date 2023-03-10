--[=[
    @class QuestScreen

    Questing Screeneeen!
    (c) Bloxcode 2023
]=]

local require = require(script.Parent.loader).load(script)

local BasicPane = require("BasicPane")
local Blend = require("Blend")
local SpringObject = require("SpringObject")--Should be using BaseWindow not BasicPane!!!!!
local BaseWindow = require("BaseWindow")
local TimerPill = require("TimerPill")
local BasicPaneUtils = require("BasicPaneUtils")

local QuestScreen = setmetatable({}, BaseWindow)
QuestScreen.__index = QuestScreen
QuestScreen.ClassName = "QuestScreen"

function QuestScreen.new(obj)--HMM
    local self = setmetatable(BaseWindow.new(obj), QuestScreen)

    --Doing this later
    self:SetDisplayName("Quests!")

    self._timerPill = TimerPill.new()

    self._maid:GiveTask(self._timerPill)

    self._maid:GiveTask(BasicPaneUtils.observeVisible(self):Subscribe(function(isVisible)
        self._timerPill:SetVisible(isVisible)
    end))

    self._maid:GiveTask(self:_render():Subscribe(function(gui)
        self.Gui = gui
    end))

    return self
end

function QuestScreen:_render()
    return self:_renderBase({
        }, {
            [Blend.Children] = self._timerPill.Gui
        })
end

return QuestScreen

