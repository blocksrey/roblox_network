local signal = _G.require("signal")
local event  = _G.require("event")

local replicatedstorage = game:GetService("ReplicatedStorage")

local remoteevent    = Instance.new("RemoteEvent", replicatedstorage)
local remotefunction = Instance.new("RemoteFunction", replicatedstorage)
local fireclient     = remoteevent.FireClient
local fireallclients = remoteevent.FireAllClients
local invokeclient   = remotefunction.InvokeClient

local network = {}
local runners = {}
local senders = {}

signal(remoteevent.OnServerEvent)(function(client, key, ...)
	local runner = runners[key]
	if runner then
		runner[1](client, ...)
	end
end)

function network.receive(key, func)
	if not runners[key] then
		runners[key] = {event()}
	end
	return runners[key][2](func)
end

function network.send(...)
	fireclient(remoteevent, ...)
end

function network.bounce(key, func)
	senders[key] = func
end

function network.fetch(...)
	return invokeclient(remotefunction, ...)
end

function remotefunction.OnServerInvoke(client, key, ...)
	local sender = senders[key]
	if sender then
		return sender(client, ...)
	else
		print("no sender: "..key)
	end
end

function network.share(...)
	fireallclients(remoteevent, ...)
end

return network
