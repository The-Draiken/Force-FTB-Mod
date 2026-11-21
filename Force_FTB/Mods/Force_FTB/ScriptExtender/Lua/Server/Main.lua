local function forEachPartyMember(callback)
    for _, member in pairs(Osi.DB_PartyMembers:Get(nil)) do
        if member and member[1] then
            local uuid = Osi.GetUUID(member[1])
            if uuid ~= nil then
                callback(uuid)
            end
        end
    end
end

local function setPartyForceTurnBased(enabled)
    forEachPartyMember(function(uuid)
        Osi.ForceTurnBasedMode(uuid, enabled and 1 or 0)
    end)
end

local function isPartyInForceTurnBasedMode()
    local isInForceTurnBasedMode = false
    forEachPartyMember(function(uuid)
        if Osi.IsInForceTurnBasedMode(uuid) == 1 then
            isInForceTurnBasedMode = true
        end
    end)
    return isInForceTurnBasedMode
end

local function enterFTB()
    setPartyForceTurnBased(true)
end

local function exitFTB()
    setPartyForceTurnBased(false)
end

local function toggleFTB()
    setPartyForceTurnBased(not isPartyInForceTurnBasedMode())
end

local function onNetMessage(data)
    if data == nil or data.Channel == nil then
        return
    end

    if data.Channel == "ToggleFTB" then
        toggleFTB()
    elseif data.Channel == "EnterFTB" then
        enterFTB()
    elseif data.Channel == "ExitFTB" then
        exitFTB()
    end
end

local function onSessionLoaded()
    Ext.Events.NetMessage:Subscribe(onNetMessage)
end

Ext.Events.SessionLoaded:Subscribe(onSessionLoaded)
