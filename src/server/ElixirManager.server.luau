local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateElixir = ReplicatedStorage:WaitForChild("UpdateElixir")

local MAX_ELIXIR = 10
local INITIAL_ELIXIR = 5
local REGEN_INTERVAL = 2 -- seconds

local function onPlayerAdded(player)
	local elixir = Instance.new("IntValue")
	elixir.Name = "Elixir"
	elixir.Value = INITIAL_ELIXIR
	elixir.Parent = player

	-- Initial sync
	UpdateElixir:FireClient(player, elixir.Value)

	-- Elixir generation loop for this player
	task.spawn(function()
		while player.Parent do
			task.wait(REGEN_INTERVAL)
			if not player.Parent then break end

			if elixir.Value < MAX_ELIXIR then
				elixir.Value = math.min(MAX_ELIXIR, elixir.Value + 1)
				UpdateElixir:FireClient(player, elixir.Value)
			end
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
