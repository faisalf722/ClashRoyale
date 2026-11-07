local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local UpdateElixir = ReplicatedStorage:WaitForChild("UpdateElixir")
local PlayCard = ReplicatedStorage:WaitForChild("PlayCard")
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local screenGui = script.Parent
local deckFrame = screenGui:WaitForChild("DeckFrame")
local elixirLabel = deckFrame:WaitForChild("ElixirLabel")

local cardButtons = {
	Giant = deckFrame:WaitForChild("GiantButton"),
	Knight = deckFrame:WaitForChild("KnightButton"),
	Archer = deckFrame:WaitForChild("ArcherButton"),
}

local currentElixir = 5
local selectedCard = nil

-- Listen for elixir updates from server
UpdateElixir.OnClientEvent:Connect(function(elixir)
	currentElixir = elixir
	elixirLabel.Text = string.format("Elixir\n%d/10", currentElixir)

	-- Update button visuals based on cost affordability
	for cardName, button in pairs(cardButtons) do
		local data = CardData[cardName]
		if data and currentElixir < data.Cost then
			button.BackgroundTransparency = 0.5
		else
			button.BackgroundTransparency = 0
		end
	end
end)

local function selectCard(cardName)
	if selectedCard == cardName then
		-- Deselect if clicked again
		selectedCard = nil
	else
		selectedCard = cardName
	end

	for name, btn in pairs(cardButtons) do
		local stroke = btn:FindFirstChild("SelectionStroke")
		if stroke then
			if name == selectedCard then
				stroke.Thickness = 3
				stroke.Color = Color3.fromRGB(255, 230, 0)
			else
				stroke.Thickness = 0
			end
		end
	end
end

for cardName, button in pairs(cardButtons) do
	button.MouseButton1Click:Connect(function()
		selectCard(cardName)
	end)
end

-- Cancel selection on right click
mouse.Button2Down:Connect(function()
	if selectedCard then
		selectCard(nil)
	end
end)

-- Click in world to play selected card
mouse.Button1Down:Connect(function()
	if not selectedCard then return end

	-- Ensure user did not click on UI
	local mousePos = UserInputService:GetMouseLocation()
	local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
	for _, gui in ipairs(guiObjects) do
		if gui:IsDescendantOf(deckFrame) then
			return
		end
	end

	local targetRay = mouse.UnitRay
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	if player.Character then
		raycastParams.FilterDescendantsInstances = {player.Character}
	end

	local rayResult = workspace:Raycast(targetRay.Origin, targetRay.Direction * 1000, raycastParams)
	if rayResult then
		local spawnPosition = rayResult.Position
		local cardToPlay = selectedCard

		-- Deselect card
		selectCard(nil)

		-- Fire remote to server
		PlayCard:FireServer(cardToPlay, spawnPosition)
	end
end)
