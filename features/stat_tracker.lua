local lovely = require("lovely")
local nativefs = require("nativefs")

-- hook to right click queue to toggle
-- the counter of any jokers that are
-- right clicked

local r_click_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    if self.hovering.target.ability and self.hovering.target.ability.set == 'Joker' then
        self.hovering.target:counter_lock()
    end
    r_click_ref(self, x, y)
end

-- this one joker has caused me so much pain

local obelisk_scale_factor = 0.9

-- splitting the jokers into the different types
-- to add another joker just put it in its respective category

local joker_counter_types = {
    ['money gen'] = {
        'Delayed Gratification',
        'Business Card',
        'Faceless Joker',
        'Cloud 9',
        'Rocket',
        'Reserved Parking',
        'Mail-In Rebate',
        'Golden Joker',
        'Golden Ticket',
        'Rough Gem',
        'Matador',
        'Satellite',
        'To Do List',
    },
    ['value gen'] = {
        'Egg',
        'Gift Card',
    },
    ['card gen'] = {
        '8 Ball',
        'Sixth Sense',
        'Superposition',
        'Seance',
        'Vagabond',
        'Hallucination',
        'Cartomancer',
        'Perkeo'
    },
    ['jokers destroyed'] = {
        'Ceremonial Dagger',
    },
    ['cards added'] = {
        'Marble Joker',
        'DNA',
        'Certificate',
    },
    ['cards destroyed'] = {
        'Trading Card',
    },
    ['retriggers'] = {
        'Dusk',
        'Hack',
        'Mime',
        'Seltzer',
        'Sock and Buskin',
        'Hanging Chad',
    },
    ['hands upgraded'] = {
        'Burnt Joker',
        'Space Joker',
    },
    ['joker gen'] = {
        'Riff-raff',
    },
    ['cards chips'] = {
        'Hiker',
    },
    ['cards gold'] = {
        'Midas Mask',
    },
    ['blinds disabled'] = {
        'Chicot',
    },
    ['+ hands'] = {
        'Burglar',
    },
    ['+ chips'] = {
        'Sly Joker',
        'Wily Joker',
        'Clever Joker',
        'Devious Joker',
        'Crafty Joker',
        'Banner',
        'Scary Face',
        'Odd Todd',
        'Runner',
        'Ice Cream',
        'Blue Joker',
        'Square Joker',
        'Stone Joker',
        'Bull',
        'Castle',
        'Arrowhead',
        'Wee Joker',
        'Stuntman'
    },
    ['+ mult'] = {
        'Joker',
        'Greedy Joker',
        'Lusty Joker',
        'Wrathful Joker',
        'Gluttonous Joker',
        'Jolly Joker',
        'Zany Joker',
        'Mad Joker',
        'Crazy Joker',
        'Droll Joker',
        'Half Joker',
        'Mystic Summit',
        'Misprint',
        'Raised Fist',
        'Fibonacci',
        'Abstract Joker',
        'Gros Michel',
        'Even Steven',
        'Supernova',
        'Ride the Bus',
        'Green Joker',
        'Red Card',
        'Erosion',
        'Fortune Teller',
        'Flash Card',
        'Popcorn',
        'Spare Trousers',
        'Smiley Face',
        'Swashbuckler',
        'Onyx Agate',
        'Shoot the Moon',
        'Bootstraps',
    },
    ['x mult'] = {
        'Joker Stencil',
        'Loyalty Card',
        'Steel Joker',
        'Blackboard',
        'Constellation',
        'Cavendish',
        'Card Sharp',
        'Madness',
        'Vampire',
        'Hologram',
        'Baron',
        'Photograph',
        'Lucky Cat',
        'Baseball Card',
        'Ancient Joker',
        'Ramen',
        'Campfire',
        'Acrobat',
        'Throwback',
        'Bloodstone',
        'Glass Joker',
        'Flower Pot',
        'The Idol',
        'Seeing Double',
        'Hit the Road',
        'The Duo',
        'The Trio',
        'The Family',
        'The Order',
        'The Tribe',
        'Driver\'s License',
        'Caino',
        'Triboulet',
        'Yorick',
    },
    ['chips/mult'] = {
        'Scholar',
        'Walkie Talkie',
    },
    ['obelisk'] = {
        'Obelisk',
    },

}

local joker_highscore_types = {
    ['+ chips scale'] = {
        'Runner',
        'Stone Joker',
        'Bull',
        'Castle',
        'Wee Joker',
    },
    ['+ mult scale'] = {
        'Supernova',
        'Ride the Bus',
        'Green Joker',
        'Red Card',
        'Fortune Teller',
        'Flash Card',
        'Spare Trousers',
        'Bootstraps',
    },
    ['x mult scale'] = {
        'Steel Joker',
        'Constellation',
        'Madness',
        'Vampire',
        'Hologram',
        'Lucky Cat',
        'Campfire',
        'Throwback',
        'Glass Joker',
        'Hit the Road',
        'Caino',
        'Yorick',
    },
}

-- counter text and options for each type of counter
-- saves doing it manually

local counter_type_table = {
    ['money gen'] = {
        'Money Generated',
        G.C.MONEY,
        '$',
    },
    ['value gen'] = {
        'Value Generated',
        G.C.MONEY,
        '$',
    },
    ['card gen'] = {
        'Cards Generated',
        G.C.SECONDARY_SET.Tarot,
    },
    ['jokers destroyed'] = {
        'Jokers Destroyed',
        G.C.RED,
    },
    ['cards added'] = {
        'Cards Added',
        G.C.CHANCE,
    },
    ['cards destroyed'] = {
        'Cards Destroyed',
        G.C.RED,
    },
    ['retriggers'] = {
        'Cards Retriggered',
    },
    ['hands upgraded'] = {
        'Hands Upgraded:',
        G.C.HAND_LEVELS[6],
    },
    ['joker gen'] = {
        'Jokers Generated',
        G.C.RARITY[2],
    },
    ['cards chips'] = {
        'Bonus Chips',
        G.C.BLUE,
        '+',
    },
    ['cards gold'] = {
        'Cards Turned Gold',
        G.C.MONEY,
    },
    ['blinds disabled'] = {
        'Blind Disabled',
        G.C.RED
    },
    ['+ hands'] = {
        'Hands Given',
        G.C.BLUE,
        '+',
    },
    ['+ chips'] = {
        'Chips Given',
        G.C.BLUE,
        '+',
    },
    ['+ mult'] = {
        'Mult Given',
        G.C.RED,
        '+',
    },
    ['x mult'] = {
        'Mult Given',
    },
    ['chips/mult'] = {
        'Chips/Mult',
    },
    ['obelisk'] = {
        'Most Played Hand',
    }
}

local highscore_type_table = {
    ['+ chips scale'] = {
        'Chips',
        G.C.BLUE,
        '+',
    },
    ['+ mult scale'] = {
        'Mult',
        G.C.RED,
        '+',
    },
    ['x mult scale'] = {
        'Mult',
    },
}

-- saves the jokers current counter, like when you leave a run

local save_ref = Card.save
function Card:save()
    local ref_return = save_ref(self)
    ref_return = self:save_counters(ref_return)
    return ref_return
end

-- loading the jokers current counter, like when you resume a run

local load_ref = Card.load
function Card:load(cardTable, other_card)
    load_ref(self, cardTable, other_card)
    self:load_counters(cardTable)
end

-- displays the counter when hovering over a joker

local hover_ref = Card.hover
function Card:hover()
    hover_ref(self)
    self:should_init()
    self:should_display(true)
end

-- displays any locked counters when you stop hovering

local stop_hover_ref = Card.stop_hover
function Card:stop_hover()
    stop_hover_ref(self)
    self:should_init()
    self:should_display()
end

-- hooks for calculating if a counter should be incremented

local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    self:should_init()
    local ref_return = calculate_joker_ref(self, context)
    self:calculate_counters(context)
    return ref_return
end

local calc_dollar_ref = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
    self:should_init()
    local ref_return = calc_dollar_ref(self)
    self:counter_bonus()
    return ref_return
end

local card_update_ref = Card.update
function Card:update(dt)
    self:should_init()
    card_update_ref(self, dt)
    if G.STAGE == G.STAGES.RUN and self:has_counter() then
        if self.ability.name == "Steel Joker" then 
            self:set_counter(nil, ((self.ability.steel_tally*0.2) + 1))
        end
        if self.ability.name == "Stone Joker" then 
            self:set_counter(nil, self.ability.stone_tally*25)
        end
        if self.ability.name == 'Bull' then
            self:set_counter(nil, self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))))
        end
        if self.ability.name == 'Bootstraps' then
            self:set_counter(nil, self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars))
        end
    end
    self:update_counter()
end

-- function for initialising the counter

function Card:init_counter(args)
    local args = args or {}
    args.counter_type = self:is_valid()
    args.highscore_type = self:is_scaling()
    if args.counter_type then
        self.counter = {
            counter_type = args.counter_type,
            counter_text = args.counter_text or counter_type_table[args.counter_type][1],
            counter_text_colour = G.C.UI.TEXT_LIGHT,
            counter_text_size = args.text_size or 0.3,
            counter_prefix = counter_type_table[args.counter_type][3] or '',
            counter_value = args.counter_value or 0,
            counter_old_value = args.counter_old_value or 0,
            counter_value_text = args.counter_value_text or {'None',},
            counter_old_value_text = args.counter_old_value_text or {'None',},
            counter_value_num = args.counter_value_num or 1,
            counter_value_colour = counter_type_table[args.counter_type][2] or G.C.UI.TEXT_LIGHT,
            counter_value_size = args.counter_value_size or 0.3,
            counter_offset = args.counter_offset or 0.05,

            highscore_type = args.highscore_type and args.highscore_type or nil,
            highscore_text = args.highscore_type and (args.highscore_text or highscore_type_table[args.highscore_type][1]),
            highscore_text_colour = args.highscore_type and G.C.UI.TEXT_LIGHT or nil,
            highscore_text_size = args.highscore_type and args.text_size or 0.3,
            highscore_prefix = (args.highscore_type and highscore_type_table[args.highscore_type][3]) or '',
            highscore_value = ((args.highscore_type and args.highscore_value) or (args.highscore_type == 'x_mult_scale' and 1)) or 0,
            highscore_old_value = ((args.highscore_type and args.highscore_old_value) or (args.highscore_type == 'x_mult_scale' and 1)) or 0,
            highscore_value_text = args.highscore_type and args.highscore_value_text or 'None',
            highscore_value_num = args.highscore_type and args.value_num or 1,
            highscore_value_colour = (args.highscore_type and highscore_type_table[args.highscore_type][2]) or G.C.UI.TEXT_LIGHT,
            highscore_value_size = args.highscore_type and args.highscore_value_size or 0.3,
            highscore_offset = args.highscore_type and args.highscore_offset or 0.05,

            locked = args.locked or false,
        }
    end
    self.counter_ref_table = self.counter
end

-- function for saving counter, hooked to card save

function Card:save_counters(saveTable)
    self:should_init()
    saveTable['saturn_counter'] = self.counter
    return saveTable
end

-- function for loading counters, hooked to card load

function Card:load_counters(cardTable)
    if cardTable['counter'] then
      local counter_value = cardTable['counter']
      self:init_counter()
      if self:has_counter() and counter_value ~= 0 then
        self:set_counter(counter_value)
        self:display_counter(false)
      end
    end
    if cardTable['saturn_counter'] then
        self.counter_ref_table = cardTable['saturn_counter']
        self:init_counter(self.counter_ref_table)
        if self:has_counter() then
            self:display_counter(false)
        end
    end
end

-- before doing anything counter related
-- this function is called to init a counter
-- if one doesnt exist, to prevent crashes
-- from trying to do stuff to a nil value

function Card:should_init()
    if self.ability and self.ability.set == 'Joker' and self.area == G.jokers then
        if not self:has_counter() then
            self:init_counter(self.counter_ref_table)
            self.counter_ref_table = self.counter
        end
    end
end

-- called to display any counters if they should be display
-- basically just checked if respective option is turned on
-- in the saturn menu

function Card:should_display(hover)
    if self:check_enabled() then
        self:display_counter(hover)
    end
end

function Card:check_enabled()
    local show_counter = false
    local checked = false
    if self.ability.set == 'Joker' and self.area == G.jokers then
        self:should_init()
        if self:has_counter() and S.SETTINGS.modules.stattrack.enabled then
            if (self.counter.counter_type == 'money gen' or self.counter.counter_type == 'value gen') and not checked then
                if S.SETTINGS.modules.stattrack.features.joker_tracking.groups['money_generators'] then
                    show_counter = true
                end
                checked = true
            elseif (self.counter.counter_type == 'card gen' or self.counter.counter_type == 'cards added' or self.counter.counter_type == 'joker gen') and not checked then
                if S.SETTINGS.modules.stattrack.features.joker_tracking.groups['card_generators'] then
                    show_counter = true
                end
                checked = true
            elseif self.counter.counter_type == '+ chips' and not checked then
                if S.SETTINGS.modules.stattrack.features.joker_tracking.groups['chips_plus'] then
                    show_counter = true
                end
                checked = true
            elseif self.counter.counter_type == '+ mult' and not checked then
                if S.SETTINGS.modules.stattrack.features.joker_tracking.groups['mult_plus'] then
                    show_counter = true
                end
            elseif self.counter.counter_type == 'x mult' and not checked then
                if S.SETTINGS.modules.stattrack.features.joker_tracking.groups['mult_mult'] then
                    show_counter = true
                end
                checked = true
            elseif self.counter.counter_type and S.SETTINGS.modules.stattrack.features.joker_tracking.groups['miscellaneous'] and not checked then
                show_counter = true
            end
        end
    end
    return show_counter
end

-- function for locking the counter to always be displayed

function Card:counter_lock()
    self:should_init()
    if self:has_counter() and self:check_enabled() then
        self.counter.locked = not self.counter.locked
    end
end

-- checks if a joker should have a counter

function Card:is_valid()
    for k, v in pairs(joker_counter_types) do
        for _k, _v in pairs(joker_counter_types[k]) do
            if self.ability.name == _v then
                return k
            end
        end
    end
    return nil
end

-- checks if the jokers locked counter should be
-- a scaling one instead of the standard

function Card:is_scaling()
    for k, v in pairs(joker_highscore_types) do
        for _k, _v in pairs(joker_highscore_types[k]) do
            if self.ability.name == _v then
                return k
            end
        end
    end
    return nil
end

-- simply checks to see if a jokers counter exists

function Card:has_counter()
    if self and self.counter then
        return true
    else
        return false
    end
end

-- generates a definition for the counter
-- part of the ui box
-- kinda big because it returns 4 diff things
-- based on compact view or not
-- and if its locked

function Card:generate_counter_defintion()
    local definition = nil
    local is_obelisk = self.ability.name == 'Obelisk' -- this joker i swear
    if not S.SETTINGS.modules.preferences.compact_view.enabled then
        if self:is_scaling() and self.counter.locked then
            definition = {
                n = G.UIT.ROOT,
                config = {
                    align = 'cm',
                    colour = G.C.CLEAR,
                    padding = 0.02,
                }, 
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    colour = lighten(G.C.JOKER_GREY, 0.5),
                                    r = 0.1,
                                    padding = 0.05,
                                    emboss = 0.05,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            colour = adjust_alpha(G.C.SET.Joker, 0.8),
                                            r = 0.1,
                                            padding = 0.12,
                                        }, 
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    minh = 0,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            padding = 0.1,
                                                            r = 0.1,
                                                            text = self.counter.highscore_text,
                                                            scale = self.counter.highscore_text_size,
                                                            colour = self.counter.highscore_text_colour,
                                                        }
                                                    },
                                                },
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    minw = 1.5,
                                                    minh = 0.5,
                                                    r = 0.1,
                                                    padding = 0.05,
                                                    colour = G.C.WHITE,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.03,
                                                        }, 
                                                        nodes = {
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                }, 
                                                                nodes = self.counter.highscore_type == 'x mult scale' and {
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            r = 0.1,
                                                                            padding = 0,
                                                                            colour = G.C.RED,
                                                                            outline_colour = G.C.RED,
                                                                            outline = 1.05,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.counter.highscore_value_size,
                                                                                    text = 'X'..self.counter.highscore_value,
                                                                                    colour = G.C.WHITE,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                }
                                                                or {
                                                                    {
                                                                        n = G.UIT.T,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.1,
                                                                            r = 0.1,
                                                                            scale = self.counter.highscore_value_size,
                                                                            text = self.counter.highscore_prefix..self.counter.highscore_value,
                                                                            colour = self.counter.highscore_value_colour ~= G.C.UI.TEXT_LIGHT and self.counter.highscore_value_colour or G.C.UI.TEXT_DARK,
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    }
                },
            }
        else
            definition = {
                n = G.UIT.ROOT,
                config = {
                    align = 'cm',
                    colour = G.C.CLEAR,
                    padding = 0.02,
                }, 
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            colour = G.C.CLEAR,
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    colour = lighten(G.C.JOKER_GREY, 0.5),
                                    r = 0.1,
                                    padding = 0.05,
                                    emboss = 0.05,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            colour = adjust_alpha(G.C.SET.Joker, 0.8),
                                            r = 0.1,
                                            padding = 0.12,
                                        }, 
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    minh = 0.36,
                                                    colour = G.C.CLEAR,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            padding = 0.1,
                                                            r = 0.1,
                                                            text = self.counter.counter_value_num > 1 and self.counter.counter_text..'s' or self.counter.counter_text,
                                                            scale = self.counter.counter_text_size,
                                                            colour = self.counter.counter_text_colour,
                                                        }
                                                    },
                                                },
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    minw = 1.5,
                                                    minh = 0.5,
                                                    r = 0.1,
                                                    padding = 0.05,
                                                    colour = G.C.WHITE,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.03,
                                                            id = 'counter_row',
                                                            colour = G.C.CLEAR,
                                                        }, 
                                                        nodes = {
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    colour = G.C.CLEAR,
                                                                    
                                                                }, 
                                                                nodes = self.counter.counter_type == 'x mult' and {
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            r = 0.1,
                                                                            padding = 0,
                                                                            colour = G.C.RED,
                                                                            outline_colour = G.C.RED,
                                                                            outline = 1.05,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.counter.counter_value_size,
                                                                                    text = 'X'..self.counter.counter_value,
                                                                                    colour = G.C.WHITE,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                }
                                                                or self.counter.counter_type == 'chips/mult' and {
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.02,
                                                                            colour = G.C.CLEAR,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.counter.counter_value_size,
                                                                                    text = '+'..(self.ability.name == 'Walkie Talkie' and (self.counter.counter_value * 10) or self.ability.name == 'Scholar' and (self.counter.counter_value * 20)),
                                                                                    colour = G.C.BLUE,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.02,
                                                                            colour = G.C.CLEAR,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.counter.counter_value_size,
                                                                                    text = '/',
                                                                                    colour = G.C.L_BLACK,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.02,
                                                                            colour = G.C.CLEAR,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.counter.counter_value_size,
                                                                                    text = '+'..self.counter.counter_value*4,
                                                                                    colour = G.C.RED,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                }
                                                                or not is_obelisk and {
                                                                    {
                                                                        n = G.UIT.T,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.1,
                                                                            r = 0.1,
                                                                            scale = self.counter.counter_value_size,
                                                                            text =self.counter.counter_prefix..self.counter.counter_value,
                                                                            colour = self.counter.counter_value_colour ~= G.C.UI.TEXT_LIGHT and self.counter.counter_value_colour or G.C.UI.TEXT_DARK,
                                                                        },
                                                                    },
                                                                } or nil,
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    }
                },
            }
        end
    else
        if self:is_scaling() and self.counter.locked then
            definition = {
                n = G.UIT.ROOT,
                config = {
                    align = 'cm',
                    colour = G.C.CLEAR,
                    padding = 0.02,
                }, 
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            colour = G.C.CLEAR,
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    colour = lighten(G.C.JOKER_GREY, 0.5),
                                    r = 0.1,
                                    padding = 0.05,
                                    emboss = 0.05,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            colour = adjust_alpha(G.C.SET.Joker, 0.8),
                                            r = 0.1,
                                            padding = 0.12,
                                        }, 
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    text = self.counter.highscore_text..':',
                                                    scale = self.counter.highscore_text_size,
                                                    colour = self.counter.highscore_text_colour,
                                                }
                                            },
                                            self.counter.highscore_type == 'x mult scale' and {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    r = 0.1,
                                                    padding = 0.01,
                                                    colour = G.C.RED,
                                                    outline_colour = G.C.RED,
                                                    outline = 1.05,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            align = "cm",
                                                            scale = self.counter.highscore_value_size,
                                                            text = 'X'..self.counter.highscore_value,
                                                            colour = G.C.WHITE,
                                                        },
                                                    },
                                                },
                                            } 
                                            or {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    padding = 0.02,
                                                    colour = G.C.CLEAR,
                                                },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1,
                                                            r = 0.1,
                                                            scale = self.counter.highscore_value_size,
                                                            text = self.counter.highscore_prefix..self.counter.highscore_value,
                                                            colour = self.counter.highscore_value_colour,
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    }
                },
            }
        else
            definition = {
                n = G.UIT.ROOT,
                config = {
                    align = 'cm',
                    colour = G.C.CLEAR,
                    padding = 0.02,
                }, 
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            colour = G.C.CLEAR,
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    colour = lighten(G.C.JOKER_GREY, 0.5),
                                    r = 0.1,
                                    padding = 0.05,
                                    emboss = 0.05,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            colour = adjust_alpha(G.C.SET.Joker, 0.8),
                                            r = 0.1,
                                            padding = 0.12,
                                        }, 
                                        nodes = self.counter.counter_type == 'x mult' and {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    text = self.counter.counter_text..':',
                                                    scale = self.counter.counter_text_size,
                                                    colour = self.counter.counter_text_colour,
                                                }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    r = 0.1,
                                                    padding = 0.01,
                                                    colour = G.C.RED,
                                                    outline_colour = G.C.RED,
                                                    outline = 1.05,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            align = "cm",
                                                            scale = self.counter.counter_value_size,
                                                            text = 'X'..self.counter.counter_value,
                                                            colour = G.C.WHITE,
                                                        },
                                                    },
                                                },
                                            }
                                        }
                                        or self.counter.counter_type == 'chips/mult' and {
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    colour = G.C.CLEAR,
                                                    r = 0.1,
                                                    padding = 0,
                                                },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            padding = 0,
                                                            r = 0.1,
                                                            text = self.counter.counter_text..':',
                                                            scale = self.counter.counter_text_size,
                                                            colour = self.counter.counter_text_colour,
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.C,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.02,
                                                            colour = G.C.CLEAR,
                                                        },
                                                        nodes = {
                                                            {
                                                                n = G.UIT.T,
                                                                config = {
                                                                    align = "cm",
                                                                    scale = self.counter.counter_value_size,
                                                                    text = '+'..(self.ability.name == 'Walkie Talkie' and (self.counter.counter_value * 10) or self.ability.name == 'Scholar' and (self.counter.counter_value * 20)),
                                                                    colour = G.C.BLUE,
                                                                },
                                                            },
                                                        },
                                                    },
                                                    {
                                                        n = G.UIT.C,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.02,
                                                            colour = G.C.CLEAR,
                                                        },
                                                        nodes = {
                                                            {
                                                                n = G.UIT.T,
                                                                config = {
                                                                    align = "cm",
                                                                    scale = self.counter.counter_value_size,
                                                                    text = '/',
                                                                    colour = G.C.UI.TEXT_LIGHT,
                                                                },
                                                            },
                                                        },
                                                    },
                                                    {
                                                        n = G.UIT.C,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.02,
                                                            colour = G.C.CLEAR,
                                                        },
                                                        nodes = {
                                                            {
                                                                n = G.UIT.T,
                                                                config = {
                                                                    align = "cm",
                                                                    scale = self.counter.counter_value_size,
                                                                    text = '+'..self.counter.counter_value*4,
                                                                    colour = G.C.RED,
                                                                },
                                                            },
                                                        },
                                                    }
                                                }
                                            }
                                        }
                                        or not is_obelisk and {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    text = self.counter.counter_text..':',
                                                    scale = self.counter.counter_text_size,
                                                    colour = self.counter.counter_text_colour,
                                                }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    padding = 0.02,
                                                    colour = G.C.CLEAR,
                                                },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1,
                                                            r = 0.1,
                                                            scale = self.counter.counter_value_size,
                                                            text = self.counter.counter_prefix..self.counter.counter_value,
                                                            colour = self.counter.counter_value_colour,
                                                        },
                                                    },
                                                },
                                            }
                                        }
                                    },
                                },
                            },
                        },
                    }
                },
            }
        end
    end
    if is_obelisk then -- oh boy
        if not S.SETTINGS.modules.preferences.compact_view.enabled then
            definition.nodes[1].nodes[1].nodes[1].nodes[2].nodes = {}
            for i = 1, #self.counter.counter_value_text do
                table.insert(definition.nodes[1].nodes[1].nodes[1].nodes[2].nodes, {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        colour = G.C.CLEAR,
                    }, 
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                align = "cm",
                                padding = 0.1,
                                r = 0.1,
                                scale = self.counter.counter_value_size,
                                text = self.counter.counter_value_text[i],
                                colour = self.counter.counter_value_colour ~= G.C.UI.TEXT_LIGHT and self.counter.counter_value_colour or G.C.UI.TEXT_DARK,
                            },
                        }
                    },
                })
            end
        else
            definition.nodes[1].nodes[1].nodes[1].nodes = {
                {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        colour = G.C.CLEAR,
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                padding = 0.1,
                                r = 0.1,
                                text = self.counter.counter_value_num > 1 and self.counter.counter_text..'s:' or self.counter.counter_text..':',
                                scale = self.counter.counter_text_size*(1-((1-obelisk_scale_factor)*(#self.counter.counter_value_text-1))),
                                colour = self.counter.counter_text_colour,
                            }
                        },
                    }
                }
            }
            for i = 1, #self.counter.counter_value_text do
                table.insert(definition.nodes[1].nodes[1].nodes[1].nodes, {
                    n = G.UIT.R,
                    config = {
                        align = "cm",
                        colour = G.C.CLEAR,
                    }, 
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                align = "cm",
                                padding = 0.1,
                                r = 0.1,
                                scale = self.counter.counter_value_size*(1-((1-obelisk_scale_factor)*(#self.counter.counter_value_text-1))),
                                text = self.counter.counter_value_text[i],
                                colour = self.counter.counter_value_colour,
                            },
                        }
                    },
                })
            end
        end
    end
    return definition
end

-- generates the config for the counter
-- aligns it to the description pop up
-- or joker itself if the counter is locked

function Card:generate_counter_config()
    local config = nil
    local offset_below = (self.children.buy_button or (self.area and self.area.config.view_deck) or (self.area and self.area.config.type == 'shop')) and true or (self.T.y < G.CARD_H*0.8) and true
    if not self.counter.locked then
        config = {
            major = self.children.h_popup,
            parent = self.children.h_popup,
            xy_bond = 'Strong',
            r_bond = 'Weak',
            wh_bond = 'Weak',
            offset = {
                x = 0,
                y = offset_below and self.counter.counter_offset or self.counter.counter_offset + 0.03 * -1
            },  
            type = offset_below and 'bm' or 'tm'
        }
    else
        if self:is_scaling() then
            config = {
                major = self,
                parent = self,
                xy_bond = 'Strong',
                r_bond = 'Weak',
                wh_bond = 'Weak',
                offset = {
                    x = 0,
                    y = offset_below and self.counter.highscore_offset or self.counter.highscore_offset * -1
                },  
                type = 'bm'
            }
        else
            config = {
                major = self,
                parent = self,
                xy_bond = 'Strong',
                r_bond = 'Weak',
                wh_bond = 'Weak',
                offset = {
                    x = 0,
                    y = offset_below and self.counter.counter_offset or self.counter.counter_offset * -1
                },  
                type = 'bm'
            }
        end
    end
    return config
end

-- generates the ui box for the counter using the definition and config
-- also i hate obelisk

function Card:generate_counter_UI()
   return UIBox{
        definition = self:generate_counter_defintion(),
        config = self:generate_counter_config(),
    }
end

-- function for showing the updated counter after a change in value

function Card:update_counter(force)
    self:should_init()
    if self:has_counter() then
        if not self:check_enabled() and self.counter.locked then
            self.counter.locked = false
            if self.children.counter then
                self.children.counter = nil
            end
        end
        if self.counter.counter_value ~= self.counter.counter_old_value then
            self.counter.counter_old_value = self.counter.counter_value
            self:should_display(false)
        end
        if self.counter.highscore_value ~= self.counter.highscore_old_value then
            self.counter.highscore_old_value = self.counter.highscore_value
            self:should_display(false)
        end
        if self.counter.counter_value_text ~= self.counter.counter_old_value_text then
            self.counter.counter_old_value_text = self.counter.counter_value_text
            self:should_display(false)
        end
        if force then
            self:should_display()
        end
    end
end

-- updates all counters, useful for one saturn settings are changed
-- like compact view turned on/off, all counters need to be updated
-- to fit new settings

function update_all_counters(force)
    if not (G.jokers and G.jokers.cards) then return end
    for k, v in pairs(G.jokers.cards) do
        if v.ability and v.ability.set == 'Joker' then
            v:update_counter(force)
        end
    end
end

-- function for displaying the counter, generates all the ui and 
-- sets it as a child of the description pop up or joker
-- if the joker is being hovered over then itll display like normal
-- when a joker is no longer being hovered over then itll
-- display and locked counters

function Card:display_counter(hover)
    if self.facing == 'front' then
        if hover then
            local locked = false
            if self.counter.locked then
                self.counter.locked = false
                locked = true
            end
            self.children.counter = nil
            self.children.h_popup.children.counter = self:generate_counter_UI()
            if locked then
                self.counter.locked = true
            end
        else
            if self.counter.locked then
                self.children.counter = self:generate_counter_UI()
            end
        end
    end
end

-- function for increasing the counter value

function Card:increment_counter(counter, highscore)
    if not counter then counter = 0 end
    if not highscore then highscore = 0 end
    self:should_init()
    if self:has_counter() then
        self.counter.counter_value = self.counter.counter_value + counter
        self.counter.highscore_value = self.counter.highscore_value + highscore
    end
end

-- function for decreasing the counter value
  
function Card:decrement_counter(counter, highscore)
    if not counter then counter = 0 end
    if not highscore then highscore = 0 end
    self:should_init()
    if self:has_counter() then
        self.counter.counter_value = self.counter.counter_value - counter
        self.counter.highscore_value = self.counter.highscore_value - highscore
    end
end

-- function for setting the counter value to 0
  
function Card:reset_counter()
    self:should_init()
    if self:has_counter() then
        self.counter.counter_value = 0
        self.counter.highscore_value = 0
    end
end

-- function for setting the counter value to a specific value
  
function Card:set_counter(counter, highscore)
    if self then
        self:should_init()
        if self:has_counter() then
            if not counter then counter = self.counter.counter_value end
            if not highscore then highscore = self.counter.highscore_value end
            self.counter.counter_value = counter
            self.counter.highscore_value = highscore
        end
    end
end

-- function for setting the counter text, as of now only needed for obelisk

function Card:set_counter_text(text)
    self:should_init()
    if self:has_counter() then
        self.counter.counter_value_text = text
        self.counter.counter_value_num = #text
    end
end

-- returns the counter value, not needed as of now

function Card:get_counter_value()
    if self:has_counter() then
        return self.counter.counter_value, self.counter.highscore_value
    end
end

-- function for incrementing the counter of money generating jokers that give money
-- at the end of the round

function Card:counter_bonus()
    self:should_init()
    if self.debuff then return end
    if self.ability.set == "Joker" then
        if self.ability.name == 'Golden Joker' then
            self:increment_counter(self.ability.extra)
        end
        if self.ability.name == 'Cloud 9' and self.ability.nine_tally and self.ability.nine_tally > 0 then
            self:increment_counter(self.ability.extra*(self.ability.nine_tally))
        end
        if self.ability.name == 'Rocket' then
            self:increment_counter(self.ability.extra.dollars)
        end
        if self.ability.name == 'Satellite' then 
            local planets_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Planet' then planets_used = planets_used + 1 end
            end
            if planets_used == 0 then return end
            self:increment_counter(self.ability.extra*planets_used)
        end
        if self.ability.name == 'Delayed Gratification' and G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0 then
            self:increment_counter(G.GAME.current_round.discards_left*self.ability.extra)
        end
    end
end

-- mostly taken from the source code, increments counters when necessary
-- i took this route over using a bunch of patches because i hate patches

function Card:calculate_counters(context)
    self:should_init()
    if context.ending_shop then
        if self.ability.name == 'Perkeo' then
            if G.consumeables.cards[1] then
                self:increment_counter(1)
            end
        end
    elseif context.selling_card then
        if self.ability.name == 'Campfire' and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.reroll_shop then
        if self.ability.name == 'Flash Card' and not context.blueprint then
            self:set_counter(nil, self.ability.mult)
        end
    elseif context.skipping_booster then
        if self.ability.name == 'Red Card' and not context.blueprint then
            self:set_counter(nil, self.ability.mult)
        end
    elseif context.skip_blind then
        if self.ability.name == 'Throwback' and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.first_hand_drawn then
        if self.ability.name == 'Certificate' then
            self:increment_counter(1)
        end
    elseif context.playing_card_added and not self.getting_sliced then
        if self.ability.name == 'Hologram' and (not context.blueprint)
        and context.cards and context.cards[1] then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.setting_blind and not self.getting_sliced then
        if self.ability.name == 'Chicot' and not context.blueprint
        and context.blind.boss and not self.getting_sliced then
            self:increment_counter(1)
        end
        if self.ability.name == 'Madness' and not context.blueprint and not context.blind.boss then
            self:set_counter(nil, self.ability.x_mult)
        end
        if self.ability.name == 'Burglar' and not (context.blueprint_card or self).getting_sliced then
            self:increment_counter(self.ability.extra)
        end
        if self.ability.name == 'Marble Joker' and not (context.blueprint_card or self).getting_sliced  then
            self:increment_counter(1)
        end
    elseif context.debuffed_hand then 
        if self.ability.name == 'Matador' then
            if G.GAME.blind.triggered then 
                self:increment_counter(self.ability.extra)
            end
        end
    elseif context.cards_destroyed then
        if self.ability.name == 'Caino' and not context.blueprint then
            self:set_counter(nil, self.ability.caino_xmult)
        end
        if self.ability.name == 'Glass Joker' and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.remove_playing_cards then
        if self.ability.name == 'Caino' and not context.blueprint then
            self:set_counter(nil, self.ability.caino_xmult)
        end
        if self.ability.name == 'Glass Joker' and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.using_consumeable then
        if self.ability.name == 'Glass Joker' and not context.blueprint and context.consumeable.ability.name == 'The Hanged Man'  then
            self:set_counter(nil, self.ability.x_mult)
        end
        if self.ability.name == 'Fortune Teller' and not context.blueprint and (context.consumeable.ability.set == "Tarot") then
            self:set_counter(nil, G.GAME.consumeable_usage_total.tarot)
        end
        if self.ability.name == 'Constellation' and not context.blueprint and context.consumeable.ability.set == 'Planet' then
            self:set_counter(nil, self.ability.x_mult)
        end
    elseif context.pre_discard then
        if self.ability.name == 'Burnt Joker' and G.GAME.current_round.discards_used <= 0 and not context.hook then
            self:increment_counter(1)
        end
    elseif context.discard then
        if self.ability.name == 'Yorick' and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
        if self.ability.name == 'Castle' and
        not context.other_card.debuff and
        context.other_card:is_suit(G.GAME.current_round.castle_card.suit) and not context.blueprint then
            self:set_counter(nil, self.ability.extra.chips)
        end
        if self.ability.name == 'Trading Card' and not context.blueprint and 
        G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
            self:increment_counter(1)
        end
        if self.ability.name == 'Hit the Road' and
        not context.other_card.debuff and
        context.other_card:get_id() == 11 and not context.blueprint then
            self:set_counter(nil, self.ability.x_mult)
        end
        if self.ability.name == 'Green Joker' and not context.blueprint and context.other_card == context.full_hand[#context.full_hand] then
            self:set_counter(nil, self.ability.mult)
        end
        if self.ability.name == 'Mail-In Rebate' and
        not context.other_card.debuff and
        context.other_card:get_id() == G.GAME.current_round.mail_card.id then
            self:increment_counter(self.ability.extra)
        end
        if self.ability.name == 'Faceless Joker' and context.other_card == context.full_hand[#context.full_hand] then
            local face_cards = 0
            for k, v in ipairs(context.full_hand) do
                if v:is_face() then 
                    face_cards = face_cards + 1 
                end
            end
            if face_cards >= self.ability.extra.faces then
                self:increment_counter(self.ability.extra.dollars)
            end
        end
    elseif context.end_of_round then
        if context.repetition then
            if context.cardarea == G.hand then
                if self.ability.name == 'Mime' and
                (next(context.card_effects[1]) or #context.card_effects > 1) then
                    self:increment_counter(self.ability.extra)
                end
            end
        elseif not context.blueprint then
            if self.ability.name == 'Campfire' and G.GAME.blind.boss then
                self:set_counter(nil, self.ability.x_mult)
            end
            if self.ability.name == 'Hit the Road' then
                self:set_counter(nil, self.ability.x_mult)
            end
        end
    elseif context.individual then
        if context.cardarea == G.play then
            if self.ability.name == 'Hiker' then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Photograph' then
                local first_face = nil
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:is_face() then
                        first_face = context.scoring_hand[i]
                        break
                    end
                end
                if context.other_card == first_face then
                    self:increment_counter(self.ability.extra)
                end
            end
            if self.ability.name == 'The Idol' and
            context.other_card:get_id() == G.GAME.current_round.idol_card.id and 
            context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Scary Face' and
            (context.other_card:is_face()) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Smiley Face' and (
            context.other_card:is_face()) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Golden Ticket' and
            context.other_card.ability.name == 'Gold Card' then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Scholar' and
            context.other_card:get_id() == 14 then
                self:increment_counter(1)
            end
            if self.ability.name == 'Walkie Talkie' and
            (context.other_card:get_id() == 10 or context.other_card:get_id() == 4) then
                self:increment_counter(1)
            end
            if self.ability.name == 'Fibonacci' and (
            context.other_card:get_id() == 2 or 
            context.other_card:get_id() == 3 or 
            context.other_card:get_id() == 5 or 
            context.other_card:get_id() == 8 or 
            context.other_card:get_id() == 14) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Even Steven' and
            context.other_card:get_id() <= 10 and 
            context.other_card:get_id() >= 0 and
            context.other_card:get_id()%2 == 0 then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Odd Todd' and
            ((context.other_card:get_id() <= 10 and 
            context.other_card:get_id() >= 0 and
            context.other_card:get_id()%2 == 1) or
            (context.other_card:get_id() == 14)) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.effect == 'Suit Mult' and
            context.other_card:is_suit(self.ability.extra.suit) then
                self:increment_counter(self.ability.extra.s_mult)
            end
            if self.ability.name == 'Rough Gem' and
            context.other_card:is_suit("Diamonds") then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Onyx Agate' and
            context.other_card:is_suit("Clubs") then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Arrowhead' and
            context.other_card:is_suit("Spades") then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Ancient Joker' and
            context.other_card:is_suit(G.GAME.current_round.ancient_card.suit) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Triboulet' and
            (context.other_card:get_id() == 12 or context.other_card:get_id() == 13) then
                self:increment_counter(self.ability.extra)
            end
        end
        if context.cardarea == G.hand then
            if self.ability.name == 'Shoot the Moon' and
            context.other_card:get_id() == 12 then
                if not context.other_card.debuff then
                    self:increment_counter(13)
                end
            end
            if self.ability.name == 'Baron' and
            context.other_card:get_id() == 13 then
                if not context.other_card.debuff then
                    self:increment_counter(self.ability.extra)
                end
            end
            if self.ability.name == 'Raised Fist' then
                local temp_Mult, temp_ID = 15, 15
                local raised_card = nil
                for i=1, #G.hand.cards do
                    if temp_ID >= G.hand.cards[i].base.id and G.hand.cards[i].ability.effect ~= 'Stone Card' then 
                        temp_Mult = G.hand.cards[i].base.nominal
                        temp_ID = G.hand.cards[i].base.id
                        raised_card = G.hand.cards[i] 
                    end
                end
                if raised_card == context.other_card then 
                    if not context.other_card.debuff then
                        self:increment_counter(2*temp_Mult)
                    end
                end
            end
        end
    elseif context.repetition then
        if context.cardarea == G.play then
            if self.ability.name == 'Sock and Buskin' and (
            context.other_card:is_face()) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Hanging Chad' and (
            context.other_card == context.scoring_hand[1]) then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Dusk' and G.GAME.current_round.hands_left == 0 then
                self:increment_counter(self.ability.extra)
            end
            if self.ability.name == 'Seltzer' then
                self:increment_counter(1)
            end
            if self.ability.name == 'Hack' and (
            context.other_card:get_id() == 2 or 
            context.other_card:get_id() == 3 or 
            context.other_card:get_id() == 4 or 
            context.other_card:get_id() == 5) then
                self:increment_counter(self.ability.extra)
            end
        end
        if context.cardarea == G.hand then
            if self.ability.name == 'Mime' and
            (next(context.card_effects[1]) or #context.card_effects > 1) then
                self:increment_counter(self.ability.extra)
            end
        end
    elseif context.other_joker then
        if self.ability.name == 'Baseball Card' and context.other_joker.config.center.rarity == 2 and self ~= context.other_joker then
            self:increment_counter(self.ability.extra)
        end
    else
        if context.cardarea == G.jokers then
            if context.before then
                if self.ability.name == 'Midas Mask' and not context.blueprint then
                    local faces = {}
                    for k, v in ipairs(context.scoring_hand) do
                        if v:is_face() then 
                            faces[#faces+1] = v
                        end
                    end
                    if #faces > 0 then 
                        self:increment_counter(#faces)
                    end
                end
                if self.ability.name == 'To Do List' and context.scoring_name == self.ability.to_do_poker_hand then
                    self:increment_counter(self.ability.extra.dollars)
                end
                if self.ability.name == 'DNA' and G.GAME.current_round.hands_played == 0 then
                    if #context.full_hand == 1 then
                        self:increment_counter(1)
                    end
                end
                if self.ability.name == 'Obelisk' and not context.blueprint then
                    local most_played_num = 0
                    local most_played_hands = {}
                    for k, v in pairs(G.GAME.hands) do
                        if v.played >= most_played_num then
                            most_played_num = v.played
                        end
                    end
                    for k, v in pairs(G.GAME.hands) do
                        if v.played >= most_played_num then
                            most_played_hands[#most_played_hands + 1] = k
                        end
                    end
                    self:set_counter_text(most_played_hands)
                end
                if self.ability.name == 'Loyalty Card' then
                    local loyalty_remaining = (self.ability.extra.every-1-(G.GAME.hands_played - self.ability.hands_played_at_create))%(self.ability.extra.every+1)
                    if loyalty_remaining == self.ability.extra.every then
                        self:increment_counter(self.ability.extra.Xmult)
                    end
                end
                if self.ability.name ~= 'Seeing Double' and self.ability.name ~= 'Obelisk' and -- Lucky Cat maybe
                self.ability.x_mult > 1 and (self.ability.type == '' or next(context.poker_hands[self.ability.type])) then
                    self:increment_counter(self.ability.x_mult)
                    if self.ability.x_mult > 1 and self.ability.type == '' then
                        self:set_counter(nil, self.ability.x_mult)
                    end
                end
                if self.ability.t_mult > 0 and next(context.poker_hands[self.ability.type]) then
                    self:increment_counter(self.ability.t_mult)
                end
                if self.ability.t_chips > 0 and next(context.poker_hands[self.ability.type]) then
                    self:increment_counter(self.ability.t_chips)
                end
                if self.ability.name == 'Half Joker' and #context.full_hand <= self.ability.extra.size then
                    self:increment_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Abstract Joker' then
                    local x = 0
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i].ability.set == 'Joker' then
                            x = x + 1
                        end
                    end
                    self:increment_counter(x*self.ability.extra)
                end
                if self.ability.name == 'Acrobat' and G.GAME.current_round.hands_left == 0 then
                    self:increment_counter(self.ability.extra)
                end
                if self.ability.name == 'Mystic Summit' and G.GAME.current_round.discards_left == self.ability.extra.d_remaining then
                    self:increment_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Banner' and G.GAME.current_round.discards_left > 0 then
                    self:increment_counter(G.GAME.current_round.discards_left*self.ability.extra)
                end
                if self.ability.name == 'Stuntman' then
                    self:increment_counter(self.ability.extra.chip_mod)
                end
                if self.ability.name == 'Supernova' then
                    self:increment_counter(G.GAME.hands[context.scoring_name].played)
                    self:set_counter(nil, G.GAME.hands[context.scoring_name].played)
                end
                if self.ability.name == 'Flower Pot' then
                    local suits = {
                        ['Hearts'] = 0,
                        ['Diamonds'] = 0,
                        ['Spades'] = 0,
                        ['Clubs'] = 0
                    }
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                            if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                            elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                            elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                            elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                        end
                    end
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name == 'Wild Card' then
                            if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                            elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                            elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                            elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                        end
                    end
                    if suits["Hearts"] > 0 and
                    suits["Diamonds"] > 0 and
                    suits["Spades"] > 0 and
                    suits["Clubs"] > 0 then
                        self:increment_counter(self.ability.extra)
                    end
                end
                if self.ability.name == 'Seeing Double' then
                    local suits = {
                        ['Hearts'] = 0,
                        ['Diamonds'] = 0,
                        ['Spades'] = 0,
                        ['Clubs'] = 0
                    }
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                            if context.scoring_hand[i]:is_suit('Hearts') then suits["Hearts"] = suits["Hearts"] + 1 end
                            if context.scoring_hand[i]:is_suit('Diamonds') then suits["Diamonds"] = suits["Diamonds"] + 1 end
                            if context.scoring_hand[i]:is_suit('Spades') then suits["Spades"] = suits["Spades"] + 1 end
                            if context.scoring_hand[i]:is_suit('Clubs') then suits["Clubs"] = suits["Clubs"] + 1 end
                        end
                    end
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name == 'Wild Card' then
                            if context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then suits["Clubs"] = suits["Clubs"] + 1
                            elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                            elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                            elseif context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0  then suits["Hearts"] = suits["Hearts"] + 1 end
                        end
                    end
                    if (suits["Hearts"] > 0 or
                    suits["Diamonds"] > 0 or
                    suits["Spades"] > 0) and
                    suits["Clubs"] > 0 then
                        self:increment_counter(self.ability.extra)
                    end
                end
                if self.ability.name == 'Castle' and (self.ability.extra.chips > 0) then
                    self:increment_counter(self.ability.extra.chips)
                    self:set_counter(nil, self.ability.extra.chips)
                end
                if self.ability.name == 'Blue Joker' and #G.deck.cards > 0 then
                    self:increment_counter(self.ability.extra*#G.deck.cards)
                end
                if self.ability.name == 'Erosion' and (G.GAME.starting_deck_size - #G.playing_cards) > 0 then
                    self:increment_counter(self.ability.extra*(G.GAME.starting_deck_size - #G.playing_cards))
                end
                if self.ability.name == 'Square Joker' then
                    self:increment_counter(self.ability.extra.chips)
                    self:set_counter(nil, self.ability.extra.chips)
                end
                if self.ability.name == 'Runner' then
                    self:increment_counter(self.ability.extra.chips)
                    self:set_counter(nil, self.ability.extra.chips)
                end
                if self.ability.name == 'Ice Cream' then
                    self:increment_counter(self.ability.extra.chips)
                end
                if self.ability.name == 'Stone Joker' and self.ability.stone_tally > 0 then
                    self:increment_counter(self.ability.extra*self.ability.stone_tally)
                    self:set_counter(nil, self.ability.extra*self.ability.stone_tally)
                end
                if self.ability.name == 'Steel Joker' and self.ability.steel_tally > 0 then
                    self:increment_counter(1 + self.ability.extra*self.ability.steel_tally)
                    self:set_counter(nil, 1 + self.ability.extra*self.ability.steel_tally)
                end
                if self.ability.name == 'Bull' and (G.GAME.dollars + (G.GAME.dollar_buffer or 0)) > 0 then
                    self:increment_counter(self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))))
                    self:set_counter(nil, self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))))
                end
                if self.ability.name == "Driver's License" then
                    if (self.ability.driver_tally or 0) >= 16 then 
                        self:increment_counter(self.ability.extra)
                    end
                end
                if self.ability.name == "Blackboard" then
                    local black_suits, all_cards = 0, 0
                    for k, v in ipairs(G.hand.cards) do
                        all_cards = all_cards + 1
                        if v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true) then
                            black_suits = black_suits + 1
                        end
                    end
                    if black_suits == all_cards then 
                        self:increment_counter(self.ability.extra)
                    end
                end
                if self.ability.name == 'Swashbuckler' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                end
                if self.ability.name == 'Joker' then
                    self:increment_counter(self.ability.mult)
                end
                if self.ability.name == 'Spare Trousers' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                    self:set_counter(nil, self.ability.mult)
                end
                if self.ability.name == 'Ride the Bus' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                    self:set_counter(nil, self.ability.mult)
                end
                if self.ability.name == 'Flash Card' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                    self:set_counter(nil, self.ability.mult)
                end
                if self.ability.name == 'Popcorn' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                end
                if self.ability.name == 'Green Joker' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                    self:set_counter(nil, self.ability.mult)
                end
                if self.ability.name == 'Fortune Teller' and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot > 0 then
                    self:increment_counter(G.GAME.consumeable_usage_total.tarot)
                end
                if self.ability.name == 'Gros Michel' then
                    self:increment_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Cavendish' then
                    self:increment_counter(self.ability.extra.Xmult)
                end
                if self.ability.name == 'Red Card' and self.ability.mult > 0 then
                    self:increment_counter(self.ability.mult)
                    self:set_counter(nil, self.ability.mult)
                end
                if self.ability.name == 'Card Sharp' and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round > 1 then
                    self:increment_counter(self.ability.extra.Xmult)
                end
                if self.ability.name == 'Bootstraps' and math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars) >= 1 then 
                    self:increment_counter(self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars))
                    self:set_counter(nil, self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars))
                end
                if self.ability.name == 'Caino' and self.ability.caino_xmult > 1 then 
                    self:increment_counter(self.ability.caino_xmult)
                    self:set_counter(nil, self.ability.caino_xmult)
                end
            end
        end
    end
end
