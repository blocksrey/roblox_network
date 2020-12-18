local Signal = _G.require("Signal")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent    = Instance.new("RemoteEvent", ReplicatedStorage)
local RemoteFunction = Instance.new("RemoteFunction", ReplicatedStorage)

local runners = {}
local senders = {}

RemoteEvent.OnServerEvent:Connect(function(plr, key, ...)
	if runners[key] then
		runners[key]:Fire(plr, ...)
	else
		print("no runner: "..key)
	end
end)

function RemoteFunction.OnServerInvoke(plr, key, ...)
	if senders[key] then
		senders[key]:Fire(plr, ...)
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
	RemoteEvent:FireClient(...)
end

function Network.fetch(...)
	return RemoteFunction:InvokeClient(...)
end

function Network.share(...)
	RemoteEvent:FireAllClients(...)
end

return Network
