ItemParts = {}

function DetectItems()
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local itemId = GetContainerItemID(bag, slot)
      local _, itemCount = GetContainerItemInfo(bag, slot)
      local classId = select(12, GetItemInfo(itemId))
      local itemType = select(6, GetItemInfo(itemId))

      local itemPart = {
        typeName = itemType,
        items = {}
      }
      if ItemParts[classId] ~= nil then
        itemPart = ItemParts[classId]
      end
      
      if itemPart.items[itemId] ~= nil then
        itemPart.items[itemId].count = itemPart.items[itemId].count + itemCount
      else
        itemPart.items[itemId] = {
          count = itemCount
        }
      end

      ItemParts[classId] = itemPart
    end
  end

	EventHandler:FireEvent("ITEMS_CHANGE");
  
  return ItemParts
end
