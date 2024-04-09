local dur = tick()

local prefix = "a."
local commands, aliases = { }, { }

local replicatedStorage = game:GetService("ReplicatedStorage")
local textChat = game:GetService("TextChatService")
local players = game:GetService("Players")
local teleport = game:GetService("TeleportService")

local host = 120166026
local player = players:GetPlayerByUserId(host)

local localPlayer = players.LocalPlayer

local unc = {
    ["on_queue"] = queue_on_teleport
}

local add = function(aliases, functions)
    for _,name in ipairs(aliases) do
        if (type(name)) == "string" then
            if not (commands[name]) and not (aliases[name]) then
                commands[name] = {
                    functions = functions,
                    aliases = aliases
                }
            else
                aliases[name] = {
                    functions = functions,
                    aliases = aliases
                }
            end
        else
            print("Improper alias type: " .. type(name))
        end
    end
end

local message = function(res)
    local chatType = textChat.ChatVersion

    if (chatType) == Enum.ChatVersion.TextChatService then
        local textChannels = textChat:FindFirstChild("TextChannels")
        local RBX = textChannels:FindFirstChild("RBXGeneral")

        if (RBX) then
            RBX:SendAsync(tostring(res))
        end
    else
        local defaultChatSystemChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local messageRequest = defaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

        messageRequest:FireServer(tostring(res), "All")
    end
end

if (player) then
    add({ "ex", "example", "debug" }, function()
        local dur = tick()
        message("Identified in " .. string.format("%.2f", tick() - dur) .. " seconds.")
    end)

    add({ "rejoin", "rj", "rej", "reconnect" }, function()
        unc.on_queue("loadstring(game:HttpGet(''))()")

        local gameId = game.PlaceId
        local jobId = game.JobId

        localPlayer:Kick("Rejoining session ...")

        teleport:TeleportToPlaceInstance(gameId, jobId, localPlayer)
    end)

    player.Chatted:Connect(function(input: string)
        local command = string.sub(input, #prefix + 1)
        local args = { }

        for arg in string.gmatch(command, "%S+") do
            table.insert(args, arg)
        end

        local functions = commands[args[1]]
        if (functions) then
            functions.functions(unpack(args))
        end
    end)

    message("Account Manager loaded in " .. string.format("%.2f", tick() - dur) .. " seconds.")
else
    message("Host not found, cannot use Account Manager.")
end
