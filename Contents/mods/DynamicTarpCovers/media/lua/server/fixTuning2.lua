if not ATATuning2Utils then ATATuning2Utils = {} end
if not ATATuning2 then ATATuning2 = {} end
if not ATATuning2.Create then ATATuning2.Create = {} end
if not ATATuning2.Init then ATATuning2.Init = {} end
if not ATATuning2.UninstallComplete then ATATuning2.UninstallComplete = {} end
if not ATATuning2.InstallComplete then ATATuning2.InstallComplete = {} end
if not ATATuning2.ContainerAccess then ATATuning2.ContainerAccess = {} end


local function localModelByModData(vehicle, part, item)
    -- print("ATATuning2Utils.ModelByModData")
    part:setAllModelsVisible(false)
    local vehicleName = vehicle:getScript():getName()
    local partName = part:getId()
    if not part:getItemType() or part:getItemType():isEmpty() then
        -- print("ATATuning2Utils.ModelByModData ERROR: не предусмотренное использование функции")
        part:setModelVisible("Default", true)
        part:setModelVisible("StaticPart", true)
    else
        if part:getModData().tuning2 then
            if part:getModData().tuning2.model then
                local modelName = part:getModData().tuning2.model
                if item then
                    part:setModelVisible(modelName, true)
                    if ATA2TuningTable[vehicleName] 
                            and ATA2TuningTable[vehicleName].parts[partName] 
                            and ATA2TuningTable[vehicleName].parts[partName][modelName] then 
                        local modelInfo = ATA2TuningTable[vehicleName].parts[partName][modelName]
                        
                        -- активируем вторую модель (пример использования - анимированная защита для окон)
                        if modelInfo.secondModel then
                            part:setModelVisible(modelInfo.secondModel, true)
                        end
                        
                        -- активируем другие модели
                        if modelInfo.modelList then
                            for _, newModelName in ipairs(modelInfo.modelList) do
                                part:setModelVisible(newModelName, true)
                            end
                        end
                        
                        -- активируем модели на всех защищаемых предметах (пример использования - цепи на колеса)
                        if modelInfo.protectionModel and type(modelInfo.protection) == "table" then
                            part:getModData().tuning2.setModelForAnotherPart = {}
                            for _, protectionPart in ipairs(modelInfo.protection) do
                                if vehicle:getPartById(protectionPart) then
                                    vehicle:getPartById(protectionPart):setModelVisible(modelName, true)
                                    part:getModData().tuning2.setModelForAnotherPart[protectionPart] = modelName
                                    vehicle:transmitPartModData(part)
                                end
                            end
                        end
                        
                        -- интерактивный багажник
                        if modelInfo.interactiveTrunk and part:getItemContainer() then
                            local fillingRate = part:getItemContainer():getContentsWeight() / part:getItemContainer():getCapacity()
                            if fillingRate > 0 then
                                if modelInfo.interactiveTrunk.filling then
                                    local tableSize = #modelInfo.interactiveTrunk.filling
                                    for num, itemTrunkModel in ipairs(modelInfo.interactiveTrunk.filling) do
                                        if num <= math.floor(fillingRate * tableSize + 1) then
                                            part:setModelVisible(itemTrunkModel, true)
                                        else
                                            break;
                                        end
                                    end
                                elseif modelInfo.interactiveTrunk.fillingOnlyOne then
                                    local tableSize = #modelInfo.interactiveTrunk.fillingOnlyOne
				    local activePos = math.floor(fillingRate * tableSize + 1)
				    if activePos > tableSize then activePos = tableSize end
                                    for num, itemTrunkModel in ipairs(modelInfo.interactiveTrunk.fillingOnlyOne) do
                                        if num == activePos then
                                            part:setModelVisible(itemTrunkModel, true)
                                        end
                                    end
                                end
                                if modelInfo.interactiveTrunk.items then
                                    for _, itemInfoTable in pairs(modelInfo.interactiveTrunk.items) do
                                        local itemcount = 0
                                        local maxItemCount = #itemInfoTable.modelNameByCount
                                        for _,itemNameNew in ipairs(itemInfoTable.itemTypes) do
                                            if itemcount < maxItemCount then
                                                itemcount = itemcount + part:getItemContainer():getCountType(itemNameNew)
                                            else
                                                break
                                            end
                                        end
                                        if itemcount > 0 then
                                            for num=1,itemcount do
                                                if num <= maxItemCount then
                                                    part:setModelVisible(itemInfoTable.modelNameByCount[num], true)
                                                else
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif part:getModData().tuning2.setModelForAnotherPart then
                -- отключаем модели с защищаемых деталей (параметр "protectionModel")
                for partName, modelName in pairs(part:getModData().tuning2.setModelForAnotherPart) do
                    if vehicle:getPartById(partName) then
                        vehicle:getPartById(partName):setModelVisible(modelName, false)
                    end
                end
                part:getModData().tuning2.setModelForAnotherPart = nil
                vehicle:transmitPartModData(part)
            elseif item then
                part:setInventoryItem(nil)
                vehicle:transmitPartItem(part)
            end
        end
    end
    vehicle:doDamageOverlay()
end


function ATATuning2.InstallComplete.RoofRack(vehicle, part)
	local cachedFunc = ATATuning2Utils.ModelByModData
	ATATuning2Utils.ModelByModData = localModelByModData

	ATATuning2.InstallComplete.Tuning(vehicle, part)

	ATATuning2Utils.ModelByModData = cachedFunc;
	--print("DRR: ATATuning2.InstallComplete");
end

function ATATuning2.UninstallComplete.RoofRack(vehicle, part, item)
	local cachedFunc = ATATuning2Utils.ModelByModData
	ATATuning2Utils.ModelByModData = localModelByModData

	ATATuning2.UninstallComplete.Tuning(vehicle, part, item)

	ATATuning2Utils.ModelByModData = cachedFunc;
	--print("DRR: ATATuning2.UninstallComplete");
end

function ATATuning2.ContainerAccess.RoofRack(vehicle, part, chr)
	local cachedFunc = ATATuning2Utils.ModelByModData
	ATATuning2Utils.ModelByModData = localModelByModData

	local result = ATATuning2.ContainerAccess.Tuning(vehicle, part, chr)

	ATATuning2Utils.ModelByModData = cachedFunc;
	--print("DRR: ATATuning2.ContainerAccess");
	return result
end

function ATATuning2.Create.RoofRack(vehicle, part)
	local cachedFunc = ATATuning2Utils.ModelByModData
	ATATuning2Utils.ModelByModData = localModelByModData

	ATATuning2.Create.Tuning(vehicle, part)

	ATATuning2Utils.ModelByModData = cachedFunc;
	--print("DRR: ATATuning2.Create");
end

function ATATuning2.Init.RoofRack(vehicle, part)
	local cachedFunc = ATATuning2Utils.ModelByModData
	ATATuning2Utils.ModelByModData = localModelByModData

	ATATuning2.Init.Tuning(vehicle, part)

	ATATuning2Utils.ModelByModData = cachedFunc;
	--print("DRR: ATATuning2.Init");
end


