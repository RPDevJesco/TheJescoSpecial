local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializePosition(PetActionBarFrame, petBarDB, defaultFramePoint)
        PetActionBarFrame:SetMovable(true)
        PetActionBarFrame:SetUserPlaced(true)
        PetActionBarFrame:EnableMouse(true)

        PetActionBarFrame:SetScript("OnMouseDown", function()
            PetActionBarFrame:StartMoving()
        end)

        PetActionBarFrame:SetScript("OnMouseUp", function()
            PetActionBarFrame:StopMovingOrSizing()
        end)
    elseif event == "PLAYER_LOGOUT" then
        petBarDB = SavePosition(PetActionBarFrame)
    end
end)
