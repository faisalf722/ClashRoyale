local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PlayCard = ReplicatedStorage:WaitForChild("PlayCard")
local UpdateElixir = ReplicatedStorage:WaitForChild("UpdateElixir")
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

-- Folder to hold all spawned troops
local troopsFolder = Workspace:FindFirstChild("Troops")
if not troopsFolder then
	troopsFolder = Instance.new("Folder")
	troopsFolder.Name = "Troops"
	troopsFolder.Parent = Workspace
end

local TROOP_CONFIGS = {
	Giant = {
		Color = Color3.fromRGB(215, 120, 30),
		Size = Vector3.new(4, 7, 4),
		Shape = Enum.PartType.Block,
	},
	Knight = {
		Color = Color3.fromRGB(45, 125, 210),
		Size = Vector3.new(2.5, 5, 2.5),
		Shape = Enum.PartType.Block,
	},
	Archer = {
		Color = Color3.fromRGB(40, 165, 85),
		Size = Vector3.new(2, 4, 2),
		Shape = Enum.PartType.Cylinder,
	},
}

local function spawnTroop(player, cardName, targetPosition)
	local data = CardData[cardName]
	local visual = TROOP_CONFIGS[cardName]
	if not data or not visual then return end

	-- Create Troop Model
	local troopModel = Instance.new("Model")
	troopModel.Name = string.format("%s_%s", cardName, player.Name)
	troopModel:SetAttribute("Owner", player.Name)
	troopModel:SetAttribute("CardName", cardName)
	troopModel:SetAttribute("Damage", data.Damage)
	troopModel:SetAttribute("AttackRange", data.AttackRange)

	-- Root / Body Part
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = visual.Size
	rootPart.Position = targetPosition + Vector3.new(0, visual.Size.Y / 2, 0)
	rootPart.Color = visual.Color
	rootPart.Material = Enum.Material.SmoothPlastic
	rootPart.Anchored = false
	rootPart.CanCollide = true
	rootPart.Parent = troopModel

	troopModel.PrimaryPart = rootPart

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = data.Health
	humanoid.Health = data.Health
	humanoid.WalkSpeed = data.Speed
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = troopModel

	-- Overhead BillboardGui for Health & Name
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OverheadGui"
	billboard.Size = UDim2.new(0, 120, 0, 40)
	billboard.StudsOffset = Vector3.new(0, visual.Size.Y / 2 + 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = rootPart
	billboard.Parent = troopModel

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 13
	nameLabel.Text = string.format("%s (%s)", cardName, player.DisplayName)
	nameLabel.Parent = billboard

	local healthBg = Instance.new("Frame")
	healthBg.Size = UDim2.new(1, 0, 0.35, 0)
	healthBg.Position = UDim2.new(0, 0, 0.55, 0)
	healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	healthBg.BorderSizePixel = 0
	healthBg.Parent = billboard

	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = visual.Color
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBg

	humanoid.HealthChanged:Connect(function(health)
		local ratio = math.clamp(health / humanoid.MaxHealth, 0, 1)
		healthBar.Size = UDim2.new(ratio, 0, 1, 0)
		if health <= 0 then
			task.wait(0.5)
			troopModel:Destroy()
		end
	end)

	troopModel.Parent = troopsFolder
	return troopModel
end

PlayCard.OnServerEvent:Connect(function(player, cardName, targetPosition)
	if typeof(cardName) ~= "string" or typeof(targetPosition) ~= "Vector3" then
		return
	end

	local card = CardData[cardName]
	if not card then return end

	local elixirVal = player:FindFirstChild("Elixir")
	if not elixirVal then return end

	-- Check if player has enough elixir
	if elixirVal.Value >= card.Cost then
		-- Deduct elixir
		elixirVal.Value = elixirVal.Value - card.Cost
		UpdateElixir:FireClient(player, elixirVal.Value)

		-- Spawn troop
		spawnTroop(player, cardName, targetPosition)
	end
end)
