local addon = LibStub("AceAddon-3.0"):NewAddon("Telepath", "LibSink-2.0")

function addon:OnInitialize()
    local options = {
       type = "group",
       args = {
            catch = {
                type = "group",
                name = "Capture message",
                order = 1,
                args = {
                    channel = {
                        name = "Channel",
                        desc = "reacts only checked channel.",
                        order = 2,
                        type = "multiselect",
                        values = {
                            raid = "Raid/Instance",
                            party = "Party",
                            guild = "Guild",
                        },
                        set = function(info, k, v) addon.db.profile.channel[k] = v end, 
                        get = function(info, k) return addon.db.profile.channel[k] end,
                    },

                    nickname = {
                        order = 4,
                        name = "Nickname filter:",
                        type = "input",
                        multiline = true,
                        set = function(info, v)
                            addon.db.profile.nickname = v
                            addon.db.profile.nickname_list = {}
                            for nick in string.gmatch(v, "%S+") do
                                addon.db.profile.nickname_list[strlower(nick)] = true
                            end
                        end, 
                        get = function(info) return addon.db.profile.nickname end,
                    },
                    nickname_hint = {
                        order = 5,
                        name = "\nEmpty: reacts to every player message.\n\nIf you set, addon reacts only their message. (1 nickname 1 line)",
                        type = "description",
                    },
                }
            },
            output = {
                
            },
       }
    }
    
    options.args.output = self:GetSinkAce3OptionsDataTable()
    options.args.output.name = "Output style"
    options.args.output.order = 2

    self.db = LibStub("AceDB-3.0"):New(self.name .. "DB", {
        profile = {
            ["channel"] = {},
            ["nickname_list"] = {},
            ["sink20OutputSink"] = "RaidWarning",
        }
    })
    
    local config = LibStub("AceConfig-3.0")
    local dialog = LibStub("AceConfigDialog-3.0")
    config:RegisterOptionsTable(self.name, options)
    dialog:AddToBlizOptions(self.name)
    
    config:RegisterOptionsTable(self.name .. "Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    dialog:AddToBlizOptions(self.name .. "Profiles", "Profiles", self.name)
    
    self:SetSinkStorage(self.db.profile)
end

local latest = ""
local function displayMessage(...)
    local _, event, msg, _, _, _, name = ...
    
    local channels = {
        ["CHAT_MSG_SAY"] = "party", -- for debug
        
        ["CHAT_MSG_GUILD"] = "guild",
        ["CHAT_MSG_PARTY"] = "party",
        ["CHAT_MSG_PARTY_LEADER"] = "party",
        ["CHAT_MSG_RAID"] = "raid",
        ["CHAT_MSG_RAID_LEADER"] = "raid",
        ["CHAT_MSG_INSTANCE_CHAT"] = "raid",
        ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = "raid",
    }
    
    -- channel filter
    if not addon.db.profile.channel[ channels[event] ] then
        return
    end
    
    -- nickname filter
    if (next(addon.db.profile.nickname_list) and
        not addon.db.profile.nickname_list[ strlower(name) ]) then
        return
    end
    
    -- ignore same message
    local display = format("%s: %s", name, msg)
    if latest == display then
    	return
    else
    	latest = display
    end
    
    -- then fire
    addon:Pour(format("%s: %s", name, msg), 1, 1, 0, nil, 24, "OUTLINE", false)
end

function addon:OnEnable()
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", displayMessage) -- for debug
    
    ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", displayMessage) 
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", displayMessage)
end
