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
---@field inst EntityScript
---@field enabled boolean
---@field shown boolean
---@field focus boolean
---@field focus_target boolean
---@field focus_flow table
---@field focus_flow_args table
---
---@field SetCenterAlignment function
---@field StartUpdating function
---@field StopUpdating function
---@field SetPosition function
---@field GetPosition function
---@field SetVAnchor function
---@field SetHAnchor function
---@field Show function
---@field Hide function
---@field OnRawKey function
---@field OnControl function
---@field OnMouseButton fun(self,button:integer, down:boolean, x:number, y:number):boolean
---@field GetDeepestFocus function
---@field SetScale function
---@field SetFocus fun(self)
---@field OnGainFocus fun(self)
---@field OnLoseFocus fun(self)
---@field Kill fun(self)
---@field IsEnabled fun():boolean
---@field GetLocalPosition fun():Vector3
---@field SetVAlign fun(self,integer)
---@field SetHAlign fun(self,integer)
---@field Enable fun(self)
---@field Disable fun(self)
---@field MoveToBack fun(self)
---@field MoveToFront fun(self)
Widget = {}

---@generic T
---@param child T
---@return T child
function Widget:AddChild(child) end

---@class UITransform
---@field SetScale function
---@field SetVAnchor function
---@field GetRotation function
---@field GetLocalPosition function
---@field SetPosition function
---@field SetMaxPropUpscale function
---@field SetScaleMode function
---@field UpdateTransform function
---@field SetHAnchor function
---@field SetRotation function
---@field GetScale function
---@field GetWorldPosition function

---@class TextWidget
---@field EnableWordWrap function
---@field SetVAnchor function
---@field SetColour function
---@field SetFont function
---@field SetHAnchor function
---@field GetString function
---@field GetRegionSize function
---@field SetString function
---@field SetSize function
---@field SetRegionSize function
---@field ShowEditCursor function
---@field SetHorizontalSqueeze function

---@class TextEditWidget
---@field SetAllowClipboardPaste fun(self,enable:boolean)
---@field SetPassword fun(self,enable:boolean)
---@field ShowEditCursor fun(self,enable:boolean)
---@field GetString fun(self):string
---@field SetString fun(self,str:string)
---@field OnKeyDown fun(self,key:integer)
---@field OnKeyUp fun(self,key:integer)
---@field OnTextInput fun(self,text:string)

---@class ImageWidget
---@field GetSize function
---@field SetBlendMode function
---@field SetVAnchor function
---@field SetTexture function
---@field SetTextureHandle function
---@field SetHAnchor function
---@field SetAlphaRange function
---@field SetTint function
---@field SetEffect function
---@field SetSize function
---@field SetEffectParams function
---@field SetUVScale function
---@field EnableEffectParams function

--#endregion

--#region components

---@class container
---@field GiveItem fun(self, item:Item, slot:integer, src_pos, drop_on_fail, skipsound)

--#endregion

--#region entity

---创建实体
---@return EntityScript
function CreateEntity() end

---@class entity
---@field GetGUID fun(self):integer
---@field GetCanSleep function
---@field AddRoadManager function
---@field AddMiniMap function
---@field AddMiniMapEntity function
---@field AddFollower function
---@field AddAnimState function
---@field AddFlooding function
---@field GetParent function
---@field RemoveTag function
---@field Show function
---@field SetParent function
---@field AddEnvelopeManager function
---@field SetClickable function
---@field AddStaticShadow function
---@field GetDebugString function
---@field AddSoundEmitter function
---@field AddLabel function
---@field AddPhysics function
---@field Retire function
---@field SetPrefabName function
---@field WorldToLocalSpace function
---@field IsValid function
---@field SetCanSleep function
---@field AddLight function
---@field LocalToWorldSpaceIncParen function
---@field GetPrefabName function
---@field AddTextEditWidget function
---@field SetSelected function
---@field AddTextWidget function
---@field AddPostProcessor function
---@field AddTag function
---@field AddInteriorManager function
---@field AddWaveComponent function
---@field Hide function
---@field LocalToWorldSpace function
---@field AddSplatManager function
---@field AddBroadcastingOptions function
---@field SetName function
---@field AddDebugRender function
---@field HasTag function
---@field AddLightWatcher function
---@field AddFloodingBlockerEntity function
---@field AddUITransform function
---@field AddFloodingEntity function
---@field AddGroundCreepEntity function
---@field AddGroundCreep function
---@field MoveToFront function
---@field SetAABB function
---@field CallPrefabConstructionCom function
---@field AddShadowManager function
---@field AddDynamicShadow function
---@field AddGraphicsOptions function
---@field AddCloudComponent function
---@field AddFontManager function
---@field AddParticleEmitter function
---@field MoveToBack function
---@field AddVideoWidget function
---@field GetName function
---@field AddImageWidget function
---@field AddMapGenSim function
---@field AddTransform function
---@field AddMapLayerManager function
---@field AddMap function
---@field AddPathfinder function
---@field IsAwake function
---@field IsVisible function
---@field __index table

---@class EntityScript
---@field entity entity
---@field name string|nil
---@field GUID integer
---@field components table
---@field spawntime integer
---@field age integer
---@field persists boolean
---@field inlimbo boolean
---@field data nil|table
---@field listeners nil|table
---@field updatecomponents nil|table
---@field inherentactions nil|table
---@field event_listeners nil|table
---@field event_listening nil|table
---@field pendingtasks nil|table
---@field children nil|table
---@field ininterior nil|boolean
---
---@field UITransform UITransform
---@field ImageWidget ImageWidget
---@field TextWidget TextWidget
---@field TextEditWidget TextEditWidget
---
---@field IsValid fun(self):boolean
---@field Remove fun(self)
---@field AddComponent fun(self, component:string)
---@field RemoveComponent fun(self, component:string)
---@field AddTag fun(self, tag:string)
---@field HasTag fun(self, tag:string):boolean
---@field RemoveTag fun(self, tag:string)
---@field ListenForEvent fun(self,envent:string,fn:fun(ent:EntityScript,data?:any),source?:table)
---@field PushEvent fun(self,event:string,data?:any)
---@field RemoveEventCallback fun(self,envent:string,fn:fun(ent:EntityScript,data?:any),source?:table)
---@field RemoveAllEventCallbacks fun(self)
---@field OnSave fun(self, data:table)
---@field OnLoad fun(self, data:table)
---@field _ctor function
---@field __tostring function
---@field is_a function
---
---@field IsActionValid function
---@field GetIsOnWater function
---@field SetPanelLongDescription function
---@field GetIsOnLand function
---@field GetSaveRecord function
---@field GetPanelLongDescription function
---@field LoadPostPass function
---@field IsPosSurroundedByLand function
---@field AddComponentAtRuntime function
---@field GetIsFlooded function
---@field StartThread function
---@field Teleport function
---@field CanDoAction function
---@field SetBrain function
---@field GetDistanceSqToPoint function
---@field RemoveFromScene function
---@field ResumeTask function
---@field GetHorzDistanceSqToInst function
---@field SetProfile function
---@field GetDebugString function
---@field CancelAllPendingTasks function
---@field GetIsWet function
---@field IsInLimbo function
---@field GetPanelDescriptions function
---@field SetPanelDescription function
---@field SetAddColour function
---@field GetPhysicsRadius function
---@field SetPrefabName function
---@field SetInherentSceneAltAction function
---@field GetIsInInterior function
---@field SetInherentSceneAction function
---@field IsPosSurroundedByTileType function
---@field GetAngleToPoint function
---@field SetPersistData function
---@field StartWallUpdatingComponent function
---@field FaceAwayFromPoint function
---@field ForceFacePoint function
---@field GetCurrentTileType function
---@field GetIsOnTileType function
---@field IsNear function
---@field TimeRemainingInTask function
---@field ReturnToScene function
---@field IsOnValidGround function
---@field SinkIfOnWater function
---@field SetPrefabNameOverride function
---@field AddInherentAction function
---@field GetRotation function
---@field OnUsedAsItem function
---@field CanInteractWith function
---@field RemoveChild function
---@field ClearStateGraph function
---@field PushBufferedAction function
---@field GetBufferedAction function
---@field InterruptBufferedAction function
---@field Hide function
---@field PerformBufferedAction function
---@field StartUpdatingComponent function
---@field OnBuilt function
---@field GetIsOnLandOutside function
---@field GetTaskInfo function
---@field GetTimeAlive function
---@field DoTaskInTime function
---@field DoPeriodicTask function
---@field GetPersistData function
---@field AddChild function
---@field KillTasks function
---@field StopUpdatingComponent function
---@field RemoveComponentAtRuntime function
---@field GetBrainString function
---@field GetDistanceSqToInst function
---@field GetGrandParent function
---@field FacePoint function
---@field GetAdjective function
---@field LongUpdate function
---@field ClearBufferedAction function
---@field GetDisplayName function
---@field GetComponentName function
---@field GetInheritedMoisture function
---@field OnProgress function
---@field IsPosSurroundedByWater function
---@field Show function
---@field ApplyInheritedMoisture function
---@field RunScript function
---@field IsAsleep function
---@field SetStateGraph function
---@field StopUpdatingComponent_Deferred function
---@field UpdateIsInInterior function
---@field HasChildPrefab function
---@field RemoveInherentAction function
---@field StopBrain function
---@field StopWallUpdatingComponent function
---@field GetPosition function
---@field CheckIsInInterior function
---@field RestartBrain function
---@field SpawnChild function

---@class entityPrefab:EntityScript
---@field Transform Transform
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

---@class Item:entityPrefab
---@field prevcontainer? container
---@field prevslot? integer

---@class Taxue:entityPrefab
---@field EXP_PER number
---@field EXP_ONE number
---@field level number
---@field bank_value number
---@field badluck_num number
---@field exp number
---@field combat_capacity number
---@field charm_value number
---@field exp_extra number
---@field charm_value_extra number
---@field has_ticket? boolean
---@field gamble_multiple? integer
---@field loot_multiple? integer
---@field substitute_item? string
---@field faceblack number
---@field golden number
---@field lockpick_chance number
---@field variation_chance number
---@field thieves_chance number
---@field lollipop_chance number
---@field colourful_windmill_chance number
---@field loaded_dice_chance number
---@field has_surprised_sword boolean

---@return Taxue
function GetPlayer() end

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
function ToVector3(obj, y, z) end

--#endregion

---@class Transform
---@field SetPosition fun(self,x:number,y:number,z:number)
---@field SetScale fun(self,x:number,y:number,z:number)
---@field GetWorldPosition fun(self):x:number,y:number,z:number
---@field GetRotation fun(self):x:number,y:number,z:number
Transform = {}

---@class TheSim
---@field GetPosition fun():x:integer, y:integer
---@field GetScreenPos fun(self,x:number,y:number,z:number):x:integer, y:integer
---@field FindEntities fun(self,x:number,y:number,z:number,radius:number,tags?:string[],notags?:string[]):entityPrefab[]
---@field GetScreenSize fun(self):w:integer,h:integer
---@field ProfilerPush fun(self,profile:string)
---@field ProfilerPop fun(self)
---@field GetPersistentString fun(self,filepath:string,fn:fun(load_success:boolean,str:string))
---@field SetPersistentString fun(self,name:string,data:string,encode:boolean,callback?:function,local_save?:boolean)
TheSim = {}

---@class Input:Class
---@field GetScreenPosition fun(self):Vector3
---@field GetWorldPosition fun(self):Vector3
---@field GetWorldEntityUnderMouse fun(self):entityPrefab
---@field GetControllerID fun(self):string
---@field GetLocalizedControl fun(self,id:string,key:integer):string
---@field pickConditions table
---@field hoverinst EntityScript
---@field entitiesundermouse EntityScript
---@field useController boolean
---@field enabledebugtoggle boolean
---@field mouse_enabled boolean
---@field position table
---@field onkey table
---@field onkeyup table
---@field onkeydown table
---@field ongesture table
---@field oncontrol table
---@field onmousedown table
---@field onmouseup {events:table<string|integer,table[]>}
---@field ontextinput table
---
---@field GetInputDevices function
---@field OnText function
---@field AddGestureHandler function
---@field OnMouseMove function
---@field EnableAllControllers function
---@field OnUpdate fun(self)
---@field GetControlIsMouseWheel function
---@field EnableDebugToggle function
---@field AddControlMappingHandler function
---@field ControllerConnected function
---@field OnMouseButton function
---@field UpdatePosition function
---@field AddPickCondition function
---@field IsControlPressed function
---@field IsDebugToggleEnabled function
---@field UpdateEntitiesUnderMouse function
---@field AddMoveHandler function
---@field ControllerAttached function
---@field AddGeneralControlHandler function
---@field GetAnalogControlValue function
---@field IsKeyDown function
---@field OnRawKey function
---@field GetHUDEntityUnderMouse function
---@field IsMouseDown function
---@field AddControlHandler function
---@field GetAllEntitiesUnderMouse function
---@field AddTextInputHandler function
---@field RemovePickCondition function
---@field OnControlMapped function
---@field OnFrameStart function
---@field AddMouseButtonHandler function
---@field EnableMouse function
---@field OnGesture function
---@field DisableAllControllers function
---@field AddKeyHandler function
---@field AddKeyUpHandler function
---@field OnControl function
---@field AddKeyDownHandler function
TheInput = {}
