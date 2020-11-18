local Signal = _G.require("Signal")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent    = ReplicatedStorage:WaitForChild("RemoteEvent")
local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")

local runners = {}
local senders = {}

RemoteEvent.OnClientEvent:Connect(function(key, ...)
	if runners[key] then
		runners[key]:Fire(...)
	else
		print("no runner: "..key)
	end
end)

function RemoteFunction.OnClientInvoke(key, ...)
	if senders[key] then
		senders[key]:Fire(...)
	else
		print("no sender: "..key)
	end
end

local Network = {}

function Network.receive(key)
	if not runners[key] then
		runners[key] = Signal.new()
	end
	return runners[key]
end

function Network.bounce(key, func)
	senders[key] = func
end

function Network.send(...)
	RemoteEvent:FireServer(...)
end

function Network.fetch(...)
	return RemoteFunction:InvokeServer(...)
end

return Network