NoResearchDupes = {}
NoResearchDupes.addonName = "NoResearchDupes"

-- local traitTypeNameMap = {
--   [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "divines",
--   [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "impenetrable",
--   [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "infused",
--   [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = "intricate",
--   [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "nirnhoned",
--   [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = "ornate",
--   [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "prosperous",
--   [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "reinforced",
--   [ITEM_TRAIT_TYPE_ARMOR_STURDY] = "sturdy",
--   [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "training",
--   [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "well_fitted",
--   [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "arcane",
--   [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "bloodthirsty",
--   [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "harmony",
--   [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "healthy",
--   [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "infused",
--   [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = "intricate",
--   [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = "ornate",
--   [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "protective",
--   [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "robust",
--   [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "swift",
--   [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "triune",
--   [ITEM_TRAIT_TYPE_NONE] = "none",
--   [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "charged",
--   [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "decisive",
--   [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "defending",
--   [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "infused",
--   [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = "intricate",
--   [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "nirnhoned",
--   [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = "ornate",
--   [ITEM_TRAIT_TYPE_WEAPON_POWERED] = "powered",
--   [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "precise",
--   [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "sharpened",
--   [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "training",
-- }

local function isBagAvailableForResearch(bagId)
  return bagId == BAG_BACKPACK or bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK
end

local equipmentClassStep = ITEM_TRAIT_TYPE_MAX_VALUE + 1
local function packTraitId(traitType, equipmentClass)
  return equipmentClass*equipmentClassStep + traitType
end
local function unpackTraitId(traitId)
  local equipmentClass = math.floor(traitId / equipmentClassStep)
  local traitType = traitId - equipmentClass*equipmentClassStep
  return traitType, equipmentClass
end

local function isTraitCraftingMaterial(slotData)
  -- Jade etc.
  return slotData.itemType == ITEMTYPE_WEAPON_TRAIT or slotData.itemType == ITEMTYPE_ARMOR_TRAIT or slotData.itemType == ITEMTYPE_JEWELRY_TRAIT
end
local function augmentSlotData(slotData)
  if slotData.nrdTraitType == nil then
    slotData.nrdTraitType = GetItemTrait(slotData.bagId, slotData.slotIndex)
    if slotData.nrdTraitType ~= ITEM_TRAIT_TYPE_NONE and not isTraitCraftingMaterial(slotData) then
      slotData.nrdEquipmentClass = NoResearchDupes.EquipmentClass.forSlotData(slotData)
      slotData.nrdTraitId = packTraitId(slotData.nrdTraitType, slotData.nrdEquipmentClass)
    end
  end
end

local function isFirstPreferredOverSecond(slotData1, slotData2)
  -- TODO: what actually is the difference between functional and display quality?
  if slotData1.functionalQuality ~= slotData2.functionalQuality then
    return slotData1.functionalQuality < slotData2.functionalQuality
  elseif slotData1.displayQuality ~= slotData2.displayQuality then
    return slotData1.displayQuality < slotData2.displayQuality
  else
    return slotData1.sellPrice < slotData2.sellPrice
  end
end

local sortedItemsByTrait = {}
local function ensureIndexed(slotData)
  if sortedItemsByTrait[slotData.nrdTraitId] == nil then
    sortedItemsByTrait[slotData.nrdTraitId] = {}
  end
  local insertBeforeIndex = nil
  for index, existingSlotData in ipairs(sortedItemsByTrait[slotData.nrdTraitId]) do
    if existingSlotData.bagId == slotData.bagId and existingSlotData.slotIndex == slotData.slotIndex then
      return -- Already exists.
    end
    if insertBeforeIndex == nil and isFirstPreferredOverSecond(slotData, existingSlotData) then
      insertBeforeIndex = index
    end
  end
  if insertBeforeIndex ~= nil then
    table.insert(sortedItemsByTrait[slotData.nrdTraitId], insertBeforeIndex, slotData)
  else
    table.insert(sortedItemsByTrait[slotData.nrdTraitId], slotData)
  end
end
local function ensureNotIndexed(slotData)
  if sortedItemsByTrait[slotData.nrdTraitId] == nil then
    return
  end
  local indexToRemove = nil
  for index, existingSlotData in ipairs(sortedItemsByTrait[slotData.nrdTraitId]) do
    if existingSlotData.bagId == slotData.bagId and existingSlotData.slotIndex == slotData.slotIndex then
      indexToRemove = index
      break
    end
  end
  if indexToRemove ~= nil then
    table.remove(sortedItemsByTrait[slotData.nrdTraitId], indexToRemove)
  end
end

local function onSlotAddedOrUpdated(bagId, slotIndex, slotData)
  augmentSlotData(slotData)
  if slotData.nrdTraitId ~= nil then
    if isBagAvailableForResearch(bagId) and slotData.traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
      ensureIndexed(slotData)
    else
      ensureNotIndexed(slotData)
    end
  end
end
local function onSlotRemoved(bagId, slotIndex, slotData)
  augmentSlotData(slotData)
  if slotData.nrdTraitId ~= nil then
    ensureNotIndexed(slotData)
  end
end

local function isBestResearchableItem(slotData)
  if slotData.nrdTraitId == nil then
    error("supposedly unreachable: slotData.nrdTraitId == nil")
  end
  local items = sortedItemsByTrait[slotData.nrdTraitId]
  if #items == 0 then
    error("supposedly unreachable: #items == 0")
  end
  local bestItem = items[1]
  return slotData.bagId == bestItem.bagId and slotData.slotIndex == bestItem.slotIndex
end
local function updateTraitIconColourInInventoryRow(rowControl, slotData)
  local traitIcon = rowControl:GetNamedChild("TraitInfo")
  if slotData.traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED and not isBestResearchableItem(slotData) then
    traitIcon:SetColor(0.3, 0.3, 0.3, 1)
  else
    traitIcon:SetColor(1, 1, 1, 1)
  end
end


local function sortInventoryViewByModifiedTraitInformation(inventory)
  local scrollData = ZO_ScrollList_GetDataList(inventory.list)
  table.sort(scrollData, function(entry1, entry2)
    if entry1.typeId ~= entry2.typeId then
      return entry1.typeId < entry2.typeId
    end
    local slot1 = entry1.data
    local slot2 = entry2.data
    if slot1.traitInformationSortOrder ~= slot2.traitInformationSortOrder then
      return slot1.traitInformationSortOrder < slot2.traitInformationSortOrder
    end
    if slot1.traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
      local isBest1 = isBestResearchableItem(slot1)
      local isBest2 = isBestResearchableItem(slot2)
      if isBest1 ~= isBest2 then
        return isBest2
      end
    end
    return slot1.name < slot2.name
  end)
end
local function sortInventoryView(inventory)
  if inventory.sortKey == "traitInformationSortOrder" then
    sortInventoryViewByModifiedTraitInformation(inventory)
    return true
  else
    return false -- Fall back to stock implementation.
  end
end

local function initialize()
  SHARED_INVENTORY:RegisterCallback("SlotAdded", onSlotAddedOrUpdated)
  SHARED_INVENTORY:RegisterCallback("SlotUpdated", onSlotAddedOrUpdated)
  SHARED_INVENTORY:RegisterCallback("SlotRemoved", onSlotRemoved)
  SecurePostHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", updateTraitIconColourInInventoryRow)
  ZO_PreHook(SMITHING.deconstructionPanel.inventory, "SortData", sortInventoryView)
end

EVENT_MANAGER:RegisterForEvent(NoResearchDupes.addonName, EVENT_ADD_ON_LOADED, initialize)
