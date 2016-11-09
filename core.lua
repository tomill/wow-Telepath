local addon = LibStub("AceAddon-3.0"):NewAddon("Telepath", "LibSink-2.0")

local option_catch = {
    type = "group",
    name = "Hook message",
    args = {
        channel = {
            order = 1,
            type = "multiselect",
            name = "Source channel",
            desc = "reacts only checked channel.",
            values = {
                raid = "Raid/Instance",
                party = "Party",
                guild = "Guild",
                say = "Say (for your test)",
                ch1 = "/1 General",
                ch2 = "/2 Trade",
                ch3 = "/3 LocalDefense",
                ch4 = "/4 usually LfG",
                chx = "Custom channels",
            },
            set = function(info, k, v) addon.db.profile.channel[k] = v end,
            get = function(info, k) return addon.db.profile.channel[k] end,
        },

        nickname = {
            order = 4,
            type = "input",
            name = "Nickname always highlight",
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
            type = "description",
            name = [[
Tip: Set your raid leader name or no-VC player name.
(1 nickname 1 line)
]],
            fontSize = "medium",
        },
        
        keyword = {
            order = 7,
            type = "input",
            name = "Keyword list (optional)",
            multiline = true,
            set = function(info, v)
                addon.db.profile.keyword = v
                addon.db.profile.keyword_list = {}
                for word in string.gmatch(v, "%S+") do
                    addon.db.profile.keyword_list[strlower(word)] = true
                end
            end, 
            get = function(info) return addon.db.profile.keyword end,
        },
        keyword_hint = {
            order = 8,
            type = "description",
            name = [[
Tip: set "inc" or "help" or your name. 
(1 keyword 1 line)
            ]],
            fontSize = "medium",
        },
    }
}

function addon:OnInitialize()
    local options = {
        type = "group",
        args = {
            catch = {},
            output = {},
        }
    }
    
    options.args.catch = option_catch
    options.args.catch.order = 1

    options.args.output = self:GetSinkAce3OptionsDataTable()
    options.args.output.name = "Output style"
    options.args.output.order = 2

    self.db = LibStub("AceDB-3.0"):New(self.name .. "DB", {
        profile = {
            ["channel"] = {["raid"] = true},
            ["nickname"] = "",
            ["nickname_list"] = {},
            ["keyword"] = "inc\nincoming\nhelp\nsafe",
            ["keyword_list"] = {["inc"] = true, ["help"] = true},
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
    
    self.latest = ""
end

local function displayMessage(...)
    local self, event, msg, fullname, _, _,name, _, _, ch_no = ...
    
    -- channel check 
    local channels = {
        ["CHAT_MSG_CHANNEL"] = "chx",
        ["CHAT_MSG_SAY"] = "say",
        ["CHAT_MSG_GUILD"] = "guild",
        ["CHAT_MSG_PARTY"] = "party",
        ["CHAT_MSG_PARTY_LEADER"] = "party",
        ["CHAT_MSG_RAID"] = "raid",
        ["CHAT_MSG_RAID_LEADER"] = "raid",
        ["CHAT_MSG_INSTANCE_CHAT"] = "raid",
        ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = "raid",
    }
    
    local ch_key = channels[event]
    if event == "CHAT_MSG_CHANNEL" and ch_no < 5 then
        ch_key = "ch" .. ch_no
    end
    
    if not addon.db.profile.channel[ ch_key ] then
        return
    end
    
    -- nickname filter
    local nickname_filter = addon.db.profile.keyword == ""
    if (addon.db.profile.nickname ~= "") then
        if (addon.db.profile.nickname_list[ strlower(name) ]) then
            nickname_filter = true
        else
            nickname_filter = false
        end
    end
    
    -- keyword filter
    local keyword_filter = addon.db.profile.nickname == ""
    if (addon.db.profile.keyword ~= "") then
        keyword_filter = false
        local msg_lc = strlower(msg)
        for word in pairs(addon.db.profile.keyword_list) do
            if msg_lc:find(strlower(word), 1, true) then
                keyword_filter = true
                break
            end
        end
    end
    
    -- condition "OR"
    if (not nickname_filter and not keyword_filter) then
        return
    end
    
    -- ignore same message
    local display = format("%s: %s", name, msg)
    if addon.latest == display then
        return
    else
        addon.latest = display
    end
    
    -- then fire
    addon:Pour(display, 1, 1, 0, nil, 24, "OUTLINE", false)
end

function addon:OnEnable()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", displayMessage) -- for debug
    ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", displayMessage) 
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", displayMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", displayMessage)
end
