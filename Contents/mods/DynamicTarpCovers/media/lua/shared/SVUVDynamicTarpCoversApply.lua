require "SVUV_TuningTable"
require "SVUVDynamicTarpCoversList"

local DoVehicleParam = function(vehicle, param, module)
	module = module or "Base"
	local vehicleScript = ScriptManager.instance:getVehicle(module .. "." .. vehicle)
	if not vehicleScript then return end
	vehicleScript:Load(vehicle, "{" .. param .. "}")
end

local SetTemplate = function(vehicle, armor, module)
	module = module or "Base"
	DoVehicleParam(vehicle, "template! = " .. armor .. ",", module)
    	DoVehicleParam(vehicle, "template! = DRR_PatchTsarLib,", module) -- Когда Царь починит свой код - удалить эту строчку чтобы убрать наш костыль.
end

local SetRoofRackDynamic = function(vehicleName, module)
	module = module or "Base"
	if (ATA2TuningTable[vehicleName]) then
		if (ATA2TuningTable[vehicleName].parts["ATA2InteractiveTrunkRoofRack"]) then
			local modelInfo = ATA2TuningTable[vehicleName].parts["ATA2InteractiveTrunkRoofRack"]["Default"]
			if modelInfo then
				modelInfo.interactiveTrunk = {}
				modelInfo.interactiveTrunk.fillingOnlyOne = {"Empty","Fill25","Fill50","Fill75","Full" }
			end
		end
	end
end

for key, val in pairs(DynamicTarpCovers.list) do
    SetTemplate(key, val)
end

local function SVUV_PatchRoofRacks()
    for key, val in pairs(DynamicTarpCovers.list) do
        SetRoofRackDynamic(key)
    end
end
Events.OnInitGlobalModData.Add(SVUV_PatchRoofRacks)