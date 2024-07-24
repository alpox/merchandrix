local ADDON, Addon = ...;

Addon.WEAPON_ID = 2
Addon.ARMOR_ID = 4

function __genOrderedIndex(t)
   local orderedIndex = {}
   for key in pairs(t) do
      table.insert(orderedIndex, key)
   end
   table.sort(orderedIndex)
   return orderedIndex
end

function orderedNext(t, state)
   -- Equivalent of the next function, but returns the keys in the alphabetic
   -- order. We use a temporary ordered key table that is stored in the
   -- table being iterated.

   local key = nil
   --print("orderedNext: state = "..tostring(state) )
   if state == nil then
      -- the first time, generate the index
      t.__orderedIndex = __genOrderedIndex(t)
      key = t.__orderedIndex[1]
   else
      -- fetch the next value
      for i = 1, table.getn(t.__orderedIndex) do
         if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i + 1]
         end
      end
   end

   if key then
      return key, t[key]
   end

   -- no more value to return, cleanup
   t.__orderedIndex = nil
   return
end

function orderedPairs(t)
   -- Equivalent of the pairs() function on tables. Allows to iterate
   -- in order
   return orderedNext, t, nil
end

--[[ Utility Functions ]]
                          --

function idoublepair(t)
   local function dbit(t, i)
      local v = t[i + 1];
      local w = t[i + 2];

      i = i + 2;

      if w ~= nil then
         return i, v, w;
      else
         return nil;
      end
   end

   return dbit, t, 0;
end

function sortBase(t, cond)
   local ts = {};
   local it = nil;

   if t[1] then
      it = ipairs;
   else
      it = pairs;
   end

   for k, v in it(t) do
      local inserted = nil;
      local size = table.getn(ts);

      for idx, v2 in ipairs(ts) do
         local c = cond(v, v2);

         if c == true then
            table.insert(ts, idx, v);
            inserted = true;
            break;
         elseif c == 0 then
            for q = idx, size do
               if q == size or cond(v, ts[q + 1]) ~= 0 then
                  table.insert(ts, q + 1, v);
                  inserted = true;
                  break;
               end
            end
            break;
         end
      end

      if not inserted then
         table.insert(ts, size + 1, v);
      end
   end

   return ts;
end

function sortItemInfoByFn(t, fn, desc)
   return sortBase(t, function(s1, s2)
      local v1 = fn(s1)
      local v2 = fn(s2)

      if v1 == v2 then
         return 0;
      elseif v1 and v2 then
         if desc then
            return v1 > v2;
         else
            return v1 < v2;
         end
      end
   end);
end

function sortItemInfo(t, classId, desc)
   return sortItemInfoByFn(t, function(item)
      return select(classId, GetItemInfo(item.itemId))
   end, desc)
end

function levelSort(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetCurrentItemLevel(item.location)
   end)
end

function levelSortDesc(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetCurrentItemLevel(item.location)
   end, true)
end

function qualitySort(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetItemQuality(item.location)
   end)
end

function qualitySortDesc(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetItemQuality(item.location)
   end, true)
end

function itemSubTypeSort(t)
   return sortItemInfo(t, 13)
end

function stackCountSort(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetStackCount(item.location)
   end)
end

function stackCountSortDesc(t)
   return sortItemInfoByFn(t, function(item)
      return C_Item.GetStackCount(item.location)
   end, true)
end

function itemSubTypeSortDesc(t)
   return sortItemInfo(t, 13, true)
end

function itemInvTypeSort(t)
   return sortItemInfo(t, 9)
end

function itemNameSort(t)
   return sortItemInfo(t, 1)
end

function sortedArmor(t)
   local ts = qualitySortDesc(levelSortDesc(itemSubTypeSortDesc(itemNameSort(t))));

   local function s(ts, i)
      i = i + 1;
      local v = ts[i];

      if v ~= nil then
         return i, v;
      else
         return nil;
      end
   end

   return s, ts, 0;
end

function sortedOther(t)
   local ts = itemSubTypeSortDesc(stackCountSortDesc(levelSortDesc(itemNameSort(t))));

   local function s(ts, i)
      i = i + 1;
      local v = ts[i];

      if v ~= nil then
         return i, v;
      else
         return nil;
      end
   end

   return s, ts, 0;
end

function choose(arg)
   local f = {
      from = function(self, tbl)
         for _, case in ipairs(tbl) do
            local funCase = case[1];
            if type(funCase) == "table" then
               case[1] = function()
                  return unpack(funCase);
               end
            end
         end
         return map(arg):to(tbl);
      end
   };
   return f;
end

function map(arg)
   local f = {
      to = function(self, tbl)
         local default = nil;
         for _, case in ipairs(tbl) do
            if type(case) == "function" then
               default = case;
            else
               for idx, input in ipairs { select(2, unpack(case)) } do
                  local func = case[1];
                  if type(func) == "function" and input == arg then
                     return case[1]();
                  end
               end
            end
         end
         if default then default() end
      end
   };
   return f;
end

local waitTable = {};
local waitFrame = nil;

function Vendorix_wait(delay, func, ...)
   if (type(delay) ~= "number" or type(func) ~= "function") then
      return false;
   end
   if (waitFrame == nil) then
      waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
      waitFrame:SetScript("onUpdate", function(self, elapse)
         local count = #waitTable;
         local i = 1;
         while (i <= count) do
            local waitRecord = tremove(waitTable, i);
            local d = tremove(waitRecord, 1);
            local f = tremove(waitRecord, 1);
            local p = tremove(waitRecord, 1);
            if (d > elapse) then
               tinsert(waitTable, i, { d - elapse, f, p });
               i = i + 1;
            else
               count = count - 1;
               f(unpack(p));
            end
         end
      end);
   end
   tinsert(waitTable, { delay, func, { ... } });
   return true;
end
