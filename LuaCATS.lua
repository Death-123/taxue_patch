---@meta

---@class Class
---@field _ctor fun(self, ...)
---@field _base Class

--#region Widget
---@class Widget:Class
---@field _ctor fun(self, name)
---@field children table[]
---@field callbacks table[]
---@field name string
---@field inst entity
---@field enabled boolean
---@field shown boolean
---@field focus boolean
---@field focus_target boolean
---@field focus_flow table
---@field focus_flow_args table
---
---@field SetCenterAlignment function
---@field StartUpdating function
---@field SetPosition function
---@field GetPosition function
---@field SetVAnchor function
---@field SetHAnchor function
---@field Show function
---@field Hide function
---@field OnRawKey function
---@field OnControl function
---@field OnMouseButton function
---@field GetDeepestFocus function
---@field SetScale function
---@field MoveToFront function
Widget = {}

---@generic T
---@param child T
---@return T child
function Widget:AddChild(child) end

--#endregion

--#region entity

---创建实体
---@return entity
function CreateEntity() end

---@class entity
---@field name string
---
---@field ImageWidget table
---@field UITransform table
---
---@field IsValid fun(self):boolean
---@field Remove fun(self)
---@field AddComponent fun(self, component:string)
---@field RemoveComponent fun(self, component:string)
---@field HasTag fun(self, component:string):boolean
---@field RemoveTag fun(self, component:string)

---@class entityPrefab:entity
---@field GUID integer
---@field Transform table
---@field inlimbo boolean
---@field parent entityPrefab
---@field AnimState table
---@field prefab string
---@field ininterior boolean
---@field persists boolean
---@field name string
---@field Physics table
---@field age number
---@field MiniMapEntity table
---@field event_listeners table[]
---@field SoundEmitter table
---@field origspawnedFrom table
---@field spawntime number
---@field addcolourdata table
---@field components table<string, table>
---@field pendingtasks table
---
---@field taxue_coin_value number|nil
---@field equip_value number|nil
---@field MAX_EQUIP_VALUE number|nil
---@field loaded_item_list table|nil
---@field advance_list table|nil
---
---@field EMCvalue number|nil
---@field noneexchangeable boolean
--#endregion

--#region Vector3
---@class Vector3
---@overload fun(x?:number,y?:number,z?:number):Vector3
---@operator add(Vector3):Vector3
---@operator sub(Vector3):Vector3
---@operator mul(Vector3):Vector3
---@operator div(Vector3):Vector3
---@field Dot fun(other:Vector3):number
---@field Corss fun(other:Vector3):Vector3
---@field __tostring fun(self):string
---@field __eq fun(other:Vector3):boolean
---@field Get fun(self): x:number,y:number,z:number
---@field DistSq fun(self,other:Vector3):number
---@field Dist fun(self,other:Vector3):number
---@field LengthSq fun(self):number
---@field Length fun(self):number
---@field Normalize fun(self):self
---@field GetNormalized fun(self):Vector3
---@field Invert fun(self):self
---@field GetInverse fun(self):Vector3
---@field IsVector3 fun(self):boolean
Vector3 = {}

---@param obj Vector3|number|number[]
---@param y number
---@param z number
---@return Vector3|nil
function ToVector3(obj,y,z) end
--#endregion

---@class TheSim
---@field GetPosition fun():x:integer, y:integer
---@field GetScreenPos fun(self,x:number,y:number,z:number):x:integer, y:integer
---@field FindEntities fun(self,x:number,y:number,z:number,radius:number,tags:string[],notags:string[]):entityPrefab[]
TheSim = {}

---@class Input
---@field GetScreenPosition fun():Vector3
---@field GetWorldEntityUnderMouse fun(self):entityPrefab
TheInput = {}
