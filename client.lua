local signal = _G.require("signal")
local event  = _G.require("event")

local replicatedstorage = game:GetService("ReplicatedStorage")

local remoteevent    = replicatedstorage:WaitForChild("RemoteEvent")
local remotefunction = replicatedstorage:WaitForChild("RemoteFunction")
local fireserver     = remoteevent.FireServer
local invokeserver   = remotefunction.InvokeServer

local network = {}
local runners = {}
local senders = {}

signal(remoteevent.OnClientEvent)(function(key, ...)
	local runner = runners[key]
	if runner then
		runner[1](...)
	end
end)

function network.receive(key, func)
	if not runners[key] then
		runners[key] = {event()}
	end
	return runners[key][2](func)
end

function network.send(...)
	fireserver(remoteevent, ...)
end

function network.bounce(key, func)
	senders[key] = func
end

function network.fetch(...)
	return invokeserver(remotefunction, ...)
end

function remotefunction.OnClientInvoke(key, ...)
	local sender = senders[key]
	if sender then
		return sender(...)
	else
		print("no sender: "..key)
	end
end

return network
