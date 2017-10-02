import { Ovale } from "./Ovale";

let _setmetatable = setmetatable;
let _tostring = tostring;
export class OvalePoolGC {
    name = "OvalePoolGC";
    size = 0;
    __index = OvalePoolGC;
    
    NewPool(name) {
        name = name || this.name;
        return _setmetatable({
            name: name
        }, this);
    }
    Get() {
        this.size = this.size + 1;
        return {
        };
    }
    Release(item) {
        this.Clean(item);
    }
    Clean(item) {
    }
    Drain() {
        this.size = 0;
    }
    DebuggingInfo() {
        Ovale.Print("Pool %s has size %d.", _tostring(this.name), this.size);
    }
}