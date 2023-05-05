function SelectClassAbilities()
    local rotationAbilities = {}
    local version, build, date, tocversion = GetBuildInfo()
    print("Version: " .. version)
    print("Build: " .. build)
    print("TOC Version: " .. tocversion)
    if version == '3.4.1' then 
        rotationAbilities = {
            Warrior = {},
            Mage = {
                ["fire"] = {"Fireball", "Pyroblast", "Combustion"},
                ["frost"] = {"Frostbolt", "Ice Lance", "Frozen Orb"},
                ["arcane"] = {"Arcane Blast", "Arcane Missiles", "Arcane Barrage"},
            },
            Druid = {
                ["balance"] = {"Moonfire", "Sunfire", "Starsurge"},
                ["feral"] = {"Ferocious Bite", "Rake", "Rip"},
                ["resto"] = {"Regrowth", "Wild Growth", "Swiftmend"},
                ["guardian"] = {"Wrath", "Starsurge", "Starfire"},
            },
            Paladin = {
                ["retribution"] = {"Crusader Strike", "Judgment", "Holy Shock"},
                ["prot"] = {"Shield of the Righteous", "Avenger's Shield", "Consecration"},
                ["holy"] = {"Flash of Light", "Holy Shock", "Light of Dawn"},
            },
            Warlock = {
                ["affliction"] = {"Shadow Bolt", "Haunt", "Drain Soul"},
                ["destruction"] = {"Chaos Bolt", "Conflagrate", "Immolate", "Incinerate"},
                ["demonology"] = {"Corruption", "Immolate", "Shadow Bolt", "Molten Core", "Incinerate", "Soul Fire"},
            },            
            Priest = {
                ["holy"] = {"Smite", "Holy Fire", "Penance"},
                ["shadow"] = {"Mind Blast", "Void Bolt", "Devouring Plague"},
                ["discipline"] = {"Heal", "Renew", "Prayer of Healing"},
            },
            DeathKnight = {
                ["frost"] = {"Obliterate", "Frost Strike", "Howling Blast"},
                ["unholy"] = {"Death Coil", "Scourge Strike", "Epidemic"},
                ["blood"] = {"Blood Boil", "Death and Decay", "Heart Strike"},
            },
            Rogue = {},
            Hunter = {},
        }
    end
    return rotationAbilities, select(2, UnitClass("player"))
end

function TalentSelected(talentName)
    for tabIndex = 1, GetNumTalentTabs() do
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, _, _, _, currentRank, maxRank = GetTalentInfo(tabIndex, talentIndex)
            if name and name == talentName and currentRank > 0 then
                return true
            end
        end
    end
    return false
end

function getClassSpecificRotation()
    local classAbilities, className = SelectClassAbilities()
    local selectedTalent = ""
    
    -- Check if Demonic Empowerment is selected for Demonology
    if TalentSelected("Demonic Empowerment") then
        selectedTalent = "demonology"
    -- Check if Haunt is selected for Affliction
    elseif TalentSelected("Haunt") then
        selectedTalent = "affliction"
    -- Check if Chaos Bolt is selected for Destruction
    elseif TalentSelected("Chaos Bolt") then
        selectedTalent = "destruction"
    end
    
    if className == "WARLOCK" then
        if classAbilities.Warlock ~= nil then
            if selectedTalent ~= "" and classAbilities.Warlock[selectedTalent] ~= nil then
                print("Abilities for " .. selectedTalent .. " specialization:")
                for i, ability in ipairs(classAbilities.Warlock[selectedTalent]) do
                    print(i, ability)
                end
            else
                print("No abilities found for Warlock " .. selectedTalent .. " specialization")
            end
        else
            print("No abilities found for Warlock")
        end
    else
        print("Class is not a Warlock")
    end
end