--[=[
    @class QuestService

    Questing
    (c) 2023 Bloxcode A/C Antcar
]=]

local require = require(script.parent.loader).load(script)

local Players = game:GetService("Players")

local PlayerDataStoreService = require("PlayerDataStoreService")

local Maid = require("Maid")
local ValueObject = require("ValueObject")

local QuestService = {}
QuestService.ServiceName = "QuestService"

function QuestService:Init(serviceBag)
    self._serviceBag = assert(serviceBag, "QuestService/ ServiceBag is nil")

    print("QuestService/ Initializing...")

    self._playerDataStoreService = self._serviceBag:GetService(PlayerDataStoreService)
    self._maid = Maid.new()

    self._quests = {}
    self._playerData = {}

    Players.PlayerAdded:Connect(function(player)
        self:_handlePlayer(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        print("QuestService/ PlayerRemoving: ", player)
        self._maid[player] = nil
    end)

    --Incase players are already in the game
    for _, player in pairs(Players:GetPlayers()) do
        self:_handlePlayer(player)
    end
    print('QuestService/ {self._serviceBag}')
    print("QuestService/ Initialized!")
end

function QuestService:_handlePlayer(player)
    local maid = Maid.new()
    self._playerData[player.UserId] = ValueObject.new({})

    maid:GivePromise(self._playerDataStoreService:PromiseDataStore(player)):Then(function(dataStore)
        maid:GivePromise(dataStore:Load("quest",{}))
            :Then(function(questData)
                self._playerData[player.UserId].Value = questData
                maid:GiveTask(dataStore:StoreOnValueChange("quest", self._playerData[player.UserId]))
            end)
    end)

    self._maid[player] = maid
end

function QuestService:GetQuestList()
    return self._quests
end

function QuestService:SetQuest(questData)
    assert(typeof(questData) == "table", "QuestService/ questData is not a table")
    self._quests = questData
end

function QuestService:GetQuest(player)
    return self._playerData[player.UserId].Value
end

function QuestService:DoQuest(player, questID)
    local questData = self._playerData[player.UserId].Value

    if questData[questID] == nil then
        print("QuestService/ Quest not found on player, creating new quest")
        questData[questID] = {}
        questData[questID].Done = 1
        questData[questID].Expire = os.time() + 86400
    elseif questData[questID].Expire < os.time() then
        questData[questID].Done = 1
        questData[questID].Expire = os.time() + 86400
    else
        questData[questID].Done = questData[questID].Done + 1
    end

    self._playerData[player.UserId].Value = questData

    return questData
end

function QuestService:Claim(player, questID)
    local questData = self._playerData[player.UserId].Value

    if questData[questID].Done == self._quests[questID].Requirement then
        self._quests[questID].Reward(player)
        questData[questID].Claimed = true
    end

    return questData
end

return QuestService
