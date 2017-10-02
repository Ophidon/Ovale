import { L } from "./Localization";
import { OvaleDebug } from "./Debug";
import { OvaleProfiler } from "./Profiler";
import { OvaleSpellBook } from "./SpellBook";
import { Ovale } from "./Ovale";
let OvaleActionBarBase = Ovale.NewModule("OvaleActionBar", "AceEvent-3.0", "AceTimer-3.0");
let gsub = string.gsub;
let strlen = string.len;
let strmatch = string.match;
let strupper = string.upper;
let tconcat = table.concat;
let _tonumber = tonumber;
let tsort = table.sort;
const tinsert = table.insert;
let _wipe = wipe;
let API_GetActionInfo = GetActionInfo;
let API_GetActionText = GetActionText;
let API_GetBindingKey = GetBindingKey;
let API_GetBonusBarIndex = GetBonusBarIndex;
let API_GetMacroItem = GetMacroItem;
let API_GetMacroSpell = GetMacroSpell;

class OvaleActionBarClass extends OvaleProfiler.RegisterProfiling(OvaleDebug.RegisterDebugging(OvaleActionBarBase)) {
    debugOptions = {
        actionbar: {
            name: L["Action bar"],
            type: "group",
            args: {
                spellbook: {
                    name: L["Action bar"],
                    type: "input",
                    multiline: 25,
                    width: "full",
                    get: (info) => {
                        return this.DebugActions();
                    }
                }
            }
        }
    }
    
    constructor(){
        super();
        for (const [k, v] of pairs(this.debugOptions)) {
            OvaleDebug.options.args[k] = v;
        }
    }
    action = {}
    keybind = {}
    spell = {}
    macro = {}

    item = {}
    GetKeyBinding(slot) {
        let name;
        if (Bartender4) {
            name = "CLICK BT4Button" + slot + ":LeftButton";
        } else {
            if (slot <= 24 || slot > 72) {
                name = "ACTIONBUTTON" + (((slot - 1) % 12) + 1);
            } else if (slot <= 36) {
                name = "MULTIACTIONBAR3BUTTON" + (slot - 24);
            } else if (slot <= 48) {
                name = "MULTIACTIONBAR4BUTTON" + (slot - 36);
            } else if (slot <= 60) {
                name = "MULTIACTIONBAR2BUTTON" + (slot - 48);
            } else {
                name = "MULTIACTIONBAR1BUTTON" + (slot - 60);
            }
        }
        let key = name && API_GetBindingKey(name);
        if (key && strlen(key) > 4) {
            key = strupper(key);
            key = gsub(key, "%s+", "");
            key = gsub(key, "ALT%-", "A");
            key = gsub(key, "CTRL%-", "C");
            key = gsub(key, "SHIFT%-", "S");
            key = gsub(key, "NUMPAD", "N");
            key = gsub(key, "PLUS", "+");
            key = gsub(key, "MINUS", "-");
            key = gsub(key, "MULTIPLY", "*");
            key = gsub(key, "DIVIDE", "/");
        }
        return key;
    }

    ParseHyperlink(hyperlink) {
        let [color, linkType, linkData, text] = strmatch(hyperlink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
        return [color, linkType, linkData, text];
    }

    OnEnable() {
        this.RegisterEvent("ACTIONBAR_SLOT_CHANGED");
        this.RegisterEvent("PLAYER_ENTERING_WORLD", this.UpdateActionSlots);
        this.RegisterEvent("UPDATE_BINDINGS");
        this.RegisterEvent("UPDATE_BONUS_ACTIONBAR", this.UpdateActionSlots);
        this.RegisterMessage("Ovale_StanceChanged", this.UpdateActionSlots);
        this.RegisterMessage("Ovale_TalentsChanged", this.UpdateActionSlots);
    }

    OnDisable() {
        this.UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
        this.UnregisterEvent("PLAYER_ENTERING_WORLD");
        this.UnregisterEvent("UPDATE_BINDINGS");
        this.UnregisterEvent("UPDATE_BONUS_ACTIONBAR");
        this.UnregisterMessage("Ovale_StanceChanged");
        this.UnregisterMessage("Ovale_TalentsChanged");
    }

    ACTIONBAR_SLOT_CHANGED(event, slot) {
        slot = _tonumber(slot);
        if (slot == 0) {
            this.UpdateActionSlots(event);
        } else if (slot) {
            let bonus = _tonumber(API_GetBonusBarIndex()) * 12;
            let bonusStart = (bonus > 0) && (bonus - 11) || 1;
            let isBonus = slot >= bonusStart && slot < bonusStart + 12;
            if (isBonus || slot > 12 && slot < 73) {
                this.UpdateActionSlot(slot);
            }
        }
    }
    UPDATE_BINDINGS(event) {
        this.Debug("%s: Updating key bindings.", event);
        this.UpdateKeyBindings();
    }
    TimerUpdateActionSlots() {
        this.UpdateActionSlots("TimerUpdateActionSlots");
    }
    UpdateActionSlots(event) {
        this.StartProfiling("OvaleActionBar_UpdateActionSlots");
        this.Debug("%s: Updating all action slot mappings.", event);
        _wipe(this.action);
        _wipe(this.item);
        _wipe(this.macro);
        _wipe(this.spell);
        let start = 1;
        let bonus = _tonumber(API_GetBonusBarIndex()) * 12;
        if (bonus > 0) {
            start = 13;
            for (let slot = bonus - 11; slot <= bonus; slot += 1) {
                this.UpdateActionSlot(slot);
            }
        }
        for (let slot = start; slot <= 72; slot += 1) {
            this.UpdateActionSlot(slot);
        }
        if (event != "TimerUpdateActionSlots") {
            this.ScheduleTimer("TimerUpdateActionSlots", 1);
        }
        this.StopProfiling("OvaleActionBar_UpdateActionSlots");
    }
    UpdateActionSlot(slot) {
        this.StartProfiling("OvaleActionBar_UpdateActionSlot");
        let action = this.action[slot];
        if (this.spell[action] == slot) {
            this.spell[action] = undefined;
        } else if (this.item[action] == slot) {
            this.item[action] = undefined;
        } else if (this.macro[action] == slot) {
            this.macro[action] = undefined;
        }
        this.action[slot] = undefined;
        let [actionType, actionId, subType] = API_GetActionInfo(slot);
        if (actionType == "spell") {
            const id = _tonumber(actionId);
            if (id) {
                if (!this.spell[id] || slot < this.spell[id]) {
                    this.spell[id] = slot;
                }
                this.action[slot] = id;
            }
        } else if (actionType == "item") {
            const id = _tonumber(actionId);
            if (id) {
                if (!this.item[id] || slot < this.item[id]) {
                    this.item[id] = slot;
                }
                this.action[slot] = id;
            }
        } else if (actionType == "macro") {
            const id = _tonumber(actionId);
            if (id) {
                let actionText = API_GetActionText(slot);
                if (actionText) {
                    if (!this.macro[actionText] || slot < this.macro[actionText]) {
                        this.macro[actionText] = slot;
                    }
                    let [_, __, spellId] = API_GetMacroSpell(id);
                    if (spellId) {
                        if (!this.spell[spellId] || slot < this.spell[spellId]) {
                            this.spell[spellId] = slot;
                        }
                        this.action[slot] = spellId;
                    } else {
                        let [_, hyperlink] = API_GetMacroItem(id);
                        if (hyperlink) {
                            let [_, __, linkData] = this.ParseHyperlink(hyperlink);
                            let itemIdText = gsub(linkData, ":.*", "");
                            const itemId = _tonumber(itemIdText);
                            if (itemId) {
                                if (!this.item[itemId] || slot < this.item[itemId]) {
                                    this.item[itemId] = slot;
                                }
                                this.action[slot] = itemId;
                            }
                        }
                    }
                    if (!this.action[slot]) {
                        this.action[slot] = actionText;
                    }
                }
            }
        }
        if (this.action[slot]) {
            this.Debug("Mapping button %s to %s.", slot, this.action[slot]);
        } else {
            this.Debug("Clearing mapping for button %s.", slot);
        }
        this.keybind[slot] = this.GetKeyBinding(slot);
        this.StopProfiling("OvaleActionBar_UpdateActionSlot");
    }
    UpdateKeyBindings() {
        this.StartProfiling("OvaleActionBar_UpdateKeyBindings");
        for (let slot = 1; slot <= 120; slot += 1) {
            this.keybind[slot] = this.GetKeyBinding(slot);
        }
        this.StopProfiling("OvaleActionBar_UpdateKeyBindings");
    }
    GetForSpell(spellId) {
        return this.spell[spellId];
    }
    GetForMacro(macroName) {
        return this.macro[macroName];
    }
    GetForItem(itemId) {
        return this.item[itemId];
    }
    GetBinding(slot) {
        return this.keybind[slot];
    }

    output = {}
    OutputTableValues(output, tbl) {}

    DebugActions() {
        _wipe(this.output);
        let array = {
        }
        for (const [k, v] of pairs(this.spell)) {
            tinsert(array, tostring(this.GetKeyBinding(v)) + ": " + tostring(k) + " " + tostring(OvaleSpellBook.GetSpellName(k)));
        }
        tsort(array);
        for (const [_, v] of ipairs(array)) {
            this.output[lualength(this.output) + 1] = v;
        }
        let total = 0;
        for (const [_] of pairs(this.spell)) {
            total = total + 1;
        }
        this.output[lualength(this.output) + 1] = "Total spells: " + total;
        return tconcat(this.output, "\n");
    }
}

export const OvaleActionBar = new OvaleActionBarClass();