

local function CleanUselessEntries()
    --local slotsToIgnore={["Private Parts"]=true}
    local removedCount = 0
    --Just in case, I've seen what you animals do with unfinished CC stuff.
    local dontKeep0VisualSlots={["Beard"]=true,["Hair"]=true}
    
    local CCAV = Ext.StaticData.GetAll("CharacterCreationAppearanceVisual")

    -- Table to store counts of VisualResource="00000000-0000-0000-0000-000000000000" per slot (we keep one)
    local zeroResourceCounts = {}

    for _, uuid in pairs(CCAV) do
        local selection = Ext.StaticData.Get(uuid, "CharacterCreationAppearanceVisual")

        if not Ext.Resource.Get(selection.VisualResource, "Visual") then
            local slotName = selection.SlotName
            local race = selection.RaceUUID
            local bodyShape=selection.BodyShape
            local bodyType=selection.BodyType
            --Todo use metatable
            -- Our set to keep at least 1 null visual for each slot
            zeroResourceCounts[slotName] = zeroResourceCounts[slotName] or {}
            zeroResourceCounts[slotName][race] = zeroResourceCounts[slotName][race] or {}
            zeroResourceCounts[slotName][race][bodyShape] = zeroResourceCounts[slotName][race][bodyShape] or {}
            zeroResourceCounts[slotName][race][bodyShape][bodyType]=zeroResourceCounts[slotName][race][bodyShape][bodyType] or 0

            if selection.VisualResource == "00000000-0000-0000-0000-000000000000" and not dontKeep0VisualSlots[selection.SlotName] then
                if zeroResourceCounts[slotName][race][bodyShape][bodyType] >= 1 then
                    selection.SlotName = "delete"
                    removedCount = removedCount + 1
                else
                    zeroResourceCounts[slotName][race][bodyShape][bodyType] = zeroResourceCounts[slotName][race][bodyShape][bodyType] + 1
                end
            else
                selection.SlotName = "delete"
                removedCount = removedCount + 1
            end
        end
    end
    BasicPrint("Removed : " .. removedCount .. " entries from the CC menu",_,_,_,true)
end

Ext.Events.StatsLoaded:Subscribe(CleanUselessEntries)

