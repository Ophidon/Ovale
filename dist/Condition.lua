local OVALE, Ovale = ...
local OvaleCondition = Ovale:NewModule("OvaleCondition")
Ovale.OvaleCondition = OvaleCondition
local OvaleState = nil
local _type = type
local _wipe = wipe
local INFINITY = math.huge
local self_condition = {}
local self_spellBookCondition = {}
do
    self_spellBookCondition["spell"] = true
end
OvaleCondition.Compare = nil
OvaleCondition.ParseCondition = nil
OvaleCondition.ParseRuneCondition = nil
OvaleCondition.TestBoolean = nil
OvaleCondition.TestValue = nil
OvaleCondition.COMPARATOR = {
    atLeast = true,
    atMost = true,
    equal = true,
    less = true,
    more = true
}
local OvaleCondition = __class()
function OvaleCondition:OnInitialize()
    OvaleState = Ovale.OvaleState
end
function OvaleCondition:OnEnable()
    OvaleState:RegisterState(self, self.statePrototype)
end
function OvaleCondition:OnDisable()
    OvaleState:UnregisterState(self)
end
function OvaleCondition:RegisterCondition(name, isSpellBookCondition, func, arg)
    if arg then
        if _type(func) == "string" then
            func = arg[func]
        end
        self_condition[name] = function(...)
            func(arg, ...)
        end
    else
        self_condition[name] = func
    end
    if isSpellBookCondition then
        self_spellBookCondition[name] = true
    end
end
function OvaleCondition:UnregisterCondition(name)
    self_condition[name] = nil
end
function OvaleCondition:IsCondition(name)
    return (self_condition[name] ~= nil)
end
function OvaleCondition:IsSpellBookCondition(name)
    return (self_spellBookCondition[name] ~= nil)
end
function OvaleCondition:EvaluateCondition(name, positionalParams, namedParams, state, atTime)
    return self_condition[name](positionalParams, namedParams, state, atTime)
end
OvaleCondition.ParseCondition = function(positionalParams, namedParams, state, defaultTarget)
    local target = namedParams.target or defaultTarget or "player"
    namedParams.target = namedParams.target or target
    if target == "target" then
        target = state.defaultTarget
    end
    local filter
    if namedParams.filter then
        if namedParams.filter == "debuff" then
            filter = "HARMFUL"
        elseif namedParams.filter == "buff" then
            filter = "HELPFUL"
        end
    end
    local mine = true
    if namedParams.any and namedParams.any == 1 then
        mine = false
    else
        if  not namedParams.any and namedParams.mine and namedParams.mine ~= 1 then
            mine = false
        end
    end
    return target, filter, mine
end
OvaleCondition.TestBoolean = function(a, yesno)
    if  not yesno or yesno == "yes" then
        if a then
            return 0, INFINITY
        end
    else
        if  not a then
            return 0, INFINITY
        end
    end
    return nil
end
OvaleCondition.TestValue = function(start, ending, value, origin, rate, comparator, limit)
    if  not value or  not origin or  not rate then
        return nil
    end
    start = start or 0
    ending = ending or INFINITY
    if  not comparator then
        if start < ending then
            return start, ending, value, origin, rate
        else
            return 0, INFINITY, 0, 0, 0
        end
    elseif  not OvaleCondition.COMPARATOR[comparator] then
        OvaleCondition:Error("unknown comparator %s", comparator)
    elseif  not limit then
        OvaleCondition:Error("comparator %s missing limit", comparator)
    elseif rate == 0 then
        if (comparator == "less" and value < limit) or (comparator == "atMost" and value <= limit) or (comparator == "equal" and value == limit) or (comparator == "atLeast" and value >= limit) or (comparator == "more" and value > limit) then
            return start, ending
        end
    elseif (comparator == "less" and rate > 0) or (comparator == "atMost" and rate > 0) or (comparator == "atLeast" and rate < 0) or (comparator == "more" and rate < 0) then
        local t = (limit - value) / rate + origin
        ending = (ending < t) and ending or t
        return start, ending
    elseif (comparator == "less" and rate < 0) or (comparator == "atMost" and rate < 0) or (comparator == "atLeast" and rate > 0) or (comparator == "more" and rate > 0) then
        local t = (limit - value) / rate + origin
        start = (start > t) and start or t
        return start, INFINITY
    end
    return nil
end
OvaleCondition.Compare = function(value, comparator, limit)
    return OvaleCondition:TestValue(0, INFINITY, value, 0, 0, comparator, limit)
end
OvaleCondition.statePrototype = {}
local statePrototype = OvaleCondition.statePrototype
statePrototype.defaultTarget = nil
local OvaleCondition = __class()
function OvaleCondition:InitializeState(state)
    state.defaultTarget = "target"
end
function OvaleCondition:CleanState(state)
    state.defaultTarget = nil
end