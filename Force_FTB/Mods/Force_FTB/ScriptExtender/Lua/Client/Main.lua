local DefaultPauseToggleHotkey = { ScanCode = "SPACE", Modifier = "LShift" }
local DefaultControllerPauseToggleHotkey = { "RightStick", "" }
local DefaultControllerPauseToggleHotkeyOverride = false

local PauseToggleHotkey = {
    ScanCode = DefaultPauseToggleHotkey.ScanCode,
    Modifier = DefaultPauseToggleHotkey.Modifier,
}
local ControllerPauseToggleHotkey = {
    DefaultControllerPauseToggleHotkey[1],
    DefaultControllerPauseToggleHotkey[2],
}
local ControllerPauseToggleHotkeyOverride = DefaultControllerPauseToggleHotkeyOverride

local IsControllerButtonPressed = {
    A = false,
    B = false,
    X = false,
    Y = false,
    DPadLeft = false,
    DPadRight = false,
    DPadUp = false,
    DPadDown = false,
    Back = false,
    Start = false,
    Touchpad = false,
    LeftStick = false,
    RightStick = false,
    LeftShoulder = false,
    RightShoulder = false,
    TriggerLeft = false,
    TriggerRight = false,
}

local function tableContains(tbl, element)
    if type(tbl) ~= "table" or element == nil then
        return false
    end
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

local KeybindingManager = {}

function KeybindingManager:IsActiveModifier(modifier)
    return tableContains({ "LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt" }, modifier)
end

function KeybindingManager:ExtractActiveModifiers(modifiers)
    local activeModifiers = {}
    for _, mod in ipairs(modifiers or {}) do
        if self:IsActiveModifier(mod) then
            activeModifiers[mod] = true
        end
    end
    return activeModifiers
end

function KeybindingManager:AreAllModifiersPresent(eventModifiers, activeModifiers)
    for _, mod in ipairs(eventModifiers or {}) do
        if self:IsActiveModifier(mod) and not activeModifiers[mod] then
            return false
        end
    end
    return true
end

function KeybindingManager:AreAllActiveModifiersPressed(eventActiveModifiers, activeModifiers)
    for mod, _ in pairs(activeModifiers) do
        if not eventActiveModifiers[mod] then
            return false
        end
    end
    return true
end

function KeybindingManager:IsModifierPressed(eventInput, modifiers)
    local modifiersTable = type(modifiers) == "table" and modifiers or { modifiers }
    local activeModifiers = self:ExtractActiveModifiers(modifiersTable)
    local eventActiveModifiers = self:ExtractActiveModifiers(eventInput.Modifiers)
    return self:AreAllModifiersPresent(eventInput.Modifiers, activeModifiers)
        and self:AreAllActiveModifiersPressed(eventActiveModifiers, activeModifiers)
end

local function isKeybindingPressed(eventInput, keybinding)
    if keybinding == nil or keybinding.ScanCode == nil or keybinding.ScanCode == "" then
        return false
    end
    if eventInput.Key ~= keybinding.ScanCode then
        return false
    end
    return KeybindingManager:IsModifierPressed(eventInput, keybinding.Modifier or "NONE")
end

local function isControllerKeybindingPressed(keybinding)
    if keybinding == nil or keybinding[1] == nil or keybinding[1] == "" then
        return false
    end
    if keybinding[2] == nil or keybinding[2] == "" then
        return IsControllerButtonPressed[keybinding[1]] == true
    end
    return IsControllerButtonPressed[keybinding[1]] == true
        and IsControllerButtonPressed[keybinding[2]] == true
end

local function loadSettingsFromMCM()
    if not MCM then
        return
    end

    local keyboardBinding = MCM.Get("pause_toggle_hotkey")
    if keyboardBinding ~= nil then
        PauseToggleHotkey = {
            ScanCode = keyboardBinding.ScanCode or DefaultPauseToggleHotkey.ScanCode,
            Modifier = keyboardBinding.Modifier or DefaultPauseToggleHotkey.Modifier,
        }
    end

    ControllerPauseToggleHotkey = {
        MCM.Get("controller_pause_toggle_hotkey") or DefaultControllerPauseToggleHotkey[1],
        MCM.Get("controller_pause_toggle_hotkey_2") or DefaultControllerPauseToggleHotkey[2],
    }
    ControllerPauseToggleHotkeyOverride =
        MCM.Get("controller_pause_toggle_hotkey_override") or DefaultControllerPauseToggleHotkeyOverride
end

local function getDirectlyControlledCharacter()
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
        local userReservedFor = entity and entity.UserReservedFor
        local entityUuid = entity and entity.Uuid and entity.Uuid.EntityUuid
        if userReservedFor and userReservedFor.UserID == 1 and entityUuid ~= nil then
            return entityUuid
        end
    end
    return nil
end

local function isInFTB(uuid)
    if uuid == nil then
        return false
    end

    local entity = Ext.Entity.Get(uuid)
    return entity ~= nil
        and entity.FTBParticipant ~= nil
        and entity.FTBParticipant.field_18 ~= nil
end

local function postToggleFTB()
    local controlledCharacter = getDirectlyControlledCharacter()
    if controlledCharacter == nil then
        Ext.ClientNet.PostMessageToServer("ToggleFTB", "")
    elseif isInFTB(controlledCharacter) then
        Ext.ClientNet.PostMessageToServer("ExitFTB", "")
    else
        Ext.ClientNet.PostMessageToServer("EnterFTB", "")
    end
end

local function onKeyInput(eventInput)
    if eventInput.Repeat == false and eventInput.Event == "KeyDown" and isKeybindingPressed(eventInput, PauseToggleHotkey) then
        postToggleFTB()
        eventInput:PreventAction()
    end
end

local function onControllerButtonPressed(button)
    local override = false
    if isControllerKeybindingPressed(ControllerPauseToggleHotkey) then
        postToggleFTB()
        if ControllerPauseToggleHotkeyOverride then
            override = true
        end
    end
    return override
end

local function onControllerAxisInput(eventInput)
    local axis = tostring(eventInput.Axis)
    if axis == "TriggerLeft" or axis == "TriggerRight" then
        if IsControllerButtonPressed[axis] then
            if eventInput.Value == 0.0 then
                IsControllerButtonPressed[axis] = false
            end
        else
            IsControllerButtonPressed[axis] = true
            if onControllerButtonPressed(axis) then
                eventInput:PreventAction()
            end
        end
    end
end

local function onControllerButtonInput(eventInput)
    local button = tostring(eventInput.Button)
    IsControllerButtonPressed[button] = eventInput.Pressed
    if eventInput.Pressed and onControllerButtonPressed(button) then
        eventInput:PreventAction()
    end
end

local function onMCMSettingSaved(payload)
    if payload == nil or payload.modUUID ~= ModuleUUID or payload.settingId == nil then
        return
    end

    if payload.settingId == "pause_toggle_hotkey" then
        PauseToggleHotkey = {
            ScanCode = payload.value.ScanCode or DefaultPauseToggleHotkey.ScanCode,
            Modifier = payload.value.Modifier or DefaultPauseToggleHotkey.Modifier,
        }
    elseif payload.settingId == "controller_pause_toggle_hotkey" then
        ControllerPauseToggleHotkey[1] = payload.value or ""
    elseif payload.settingId == "controller_pause_toggle_hotkey_2" then
        ControllerPauseToggleHotkey[2] = payload.value or ""
    elseif payload.settingId == "controller_pause_toggle_hotkey_override" then
        ControllerPauseToggleHotkeyOverride = payload.value == true
    end
end

local function onSessionLoaded()
    Ext.Events.KeyInput:Subscribe(onKeyInput)
    Ext.Events.ControllerButtonInput:Subscribe(onControllerButtonInput)
    Ext.Events.ControllerAxisInput:Subscribe(onControllerAxisInput)
end

loadSettingsFromMCM()

Ext.Events.SessionLoaded:Subscribe(onSessionLoaded)

if MCM then
    Ext.ModEvents.BG3MCM["MCM_Setting_Saved"]:Subscribe(onMCMSettingSaved)
end
