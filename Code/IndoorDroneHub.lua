local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

local function find_method(class_name, method_name)
  local class = _G[class_name]
  local method = class[method_name]
  if method then return method end
  for _, parent_class_name in ipairs(class.__parents) do
    method = find_method(parent_class_name, method_name)
    if method then return method end
  end
  return false
end

local function wrap_method(class_name, method_name, wrapper)
  local orig_method = find_method(class_name, method_name)
  _G[class_name][method_name] = function(self, ...)
    return wrapper(self, orig_method, ...)
  end
end

local function AddBuildingToTech (building_id, tech_id, hide_building)
  local requirements = BuildingTechRequirements[building_id] or {}
  BuildingTechRequirements[building_id] = requirements
  for _, requirement in ipairs(requirements) do
    if requirement.tech == tech_id then
      requirement.hide = hide_building
      return
    end
  end
  requirements[#requirements + 1] = { tech = tech_id, hide = hide_building }
end

AddBuildingToTech("Indoor_Drone_Hub", "DroneHub")

XTemplates.customIndoorDroneHub = XTemplates.customDroneHub

local lookup_other_building_id = {
  DroneHub = 'Indoor_Drone_Hub',
  Indoor_Drone_Hub = 'DroneHub',
}

wrap_method('City', 'AddPrefabs', function(self, orig_method, building_id, amount, refresh)
  local other_building_id = lookup_other_building_id[building_id]
  if other_building_id then
    orig_method(self, other_building_id, amount)
  end
  orig_method(self, building_id, amount, refresh)
end)

wrap_method('ConstructionSite', 'Complete', function(self, orig_method, ...)
  if self.prefab then
    if self.building_class == 'Indoor_Drone_Hub' then
      UICity:AddPrefabs("RechargeStation", 2)
      PlaceResourceStockpile_Delayed(self:GetPos(), 'Metals', 4000, self:GetAngle(), true)
    end
  end
  return orig_method(self, ...)
end)

function OnMsg.LoadGame()
  print(UICity.available_prefabs)
  UICity.available_prefabs['Indoor_Drone_Hub'] = UICity.available_prefabs['DroneHub']
end

DefineClass.IndoorDroneHub = {
  __parents = { "DroneHub" },
}

-- logically, the drone hub is centered on the dome, regardless of its actual position.
function IndoorDroneHub:GetPos()
  local dome = self.parent_dome
  if dome then
    return dome:GetPos()
  end
  local pos = CObject.GetPos(self)
  dome = GetDomeAtPoint(pos)
  if dome then
    return dome:GetPos()
  end
  return pos
end

-- we have no charging stations, so there's no attaches.
IndoorDroneHub.InitAttaches = empty_func

-- ordinarily, drones will try to park near their controller, and outside a dome, given that the controller is indoors, this doesn't work, and drones wander all over the map.

wrap_method('Drone', 'GoHome', function(self, orig_method, min, max, pos, ui_str_override)
  local command_center = self.command_center
  local dome = command_center.parent_dome
  if not dome then
    return orig_method(self, min, max, pos, ui_str_override)
  end

  min = min or 30 * guim
  max = max or 50 * guim
  self.override_ui_status = ui_str_override
  self:PushDestructor(function(self)
    self.override_ui_status = nil
  end)
  if SelectedObj == command_center and not HasSelectionArrow(self) then
    SelectionArrowAdd(self)
  end
  self:ExitHolder(command_center)
  pos = pos or command_center:GetPos()
  pos = self:GoToRandomPos(max, min, pos, IsBuildableZone)
  if not pos then
    self:GoToRandomPos(max, min, pos) --go in hollow rocks
    if not pos then --stuck drone
      Sleep(1000)
    end
  end
  self:PopAndCallDestructor()
end)

orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
