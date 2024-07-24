local lovely = require("lovely")
local nativefs = require("nativefs")

-- splitting the jokers into the different types
-- to add another joker just put it in its respective category

local joker_types = {
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

-- counter text and options for each type of counter
-- saves doing it manually

local type_table = {
    ['ERROR'] = {
        'ERROR',
    },
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
        'Chips / Mult',
    },
    ['obelisk'] = {
        'Most Played Hand',
    }
}

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck()
    if self.ability.set == 'Joker' and not self.st_counter then
        self:init_st_counter()
        self.st_ref_table = self.st_counter
        ben()
    end
    add_to_deck_ref(self)
end

-- saves the jokers current counter, like when you leave a run

local save_ref = Card.save
function Card:save()
    local ref_return = save_ref(self)
    if self.st_counter then
        self:init_st_counter(self.st_counter)
        ref_return['st_counter'] = self.st_counter
    end
    return ref_return
end

-- loading the jokers current counter, like when you resume a run

local load_ref = Card.load
function Card:load(cardTable, other_card)
    load_ref(self, cardTable, other_card)
    if cardTable['st_counter'] then
        self.st_ref_table = cardTable['st_counter']
        self:init_st_counter(self.st_ref_table)
    end
end

-- displays the counter when hovering over a joker

local hover_ref = Card.hover
function Card:hover()
    hover_ref(self)
    if self.ability.set == 'Joker' and self.config.h_popup and self.area == G.jokers then
        if not self.st_counter then
            self:init_st_counter(self.st_ref_table)
            self.st_ref_table = self.st_counter
        end
        if self.st_counter then
            ben('no')
            self:show_st_counter()
        end
    end
end

function ben(string)
    if string then
        print(string)
    else
        print('ben')
    end
end

-- hooks for calculating if a counter should be incremented

local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    local ref_return = calculate_joker_ref(self, context)
    self:calculate_st_counter(context)
    return ref_return
end

local calc_dollar_ref = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
    local ref_return = calc_dollar_ref(self)
    self:end_st_counter_bonus()
    return ref_return
end

-- function for initialising the counter

function Card:init_st_counter(args)
    local args = args or {}
    for k, v in pairs(joker_types) do
        for _k, _v in pairs(joker_types[k]) do
            if self.ability.name == _v then
                args.type = k
            end
        end
    end
    if not args.type then return end
    self.st_counter = {
        _type = args.type or 'ERROR',
        text = args.text or type_table[args.type][1] or 'ERROR',
        text_colour = G.C.UI.TEXT_LIGHT,
        text_size = args.text_size or 0.3,
        prefix = type_table[args.type][3] or '',
        value = args.value or 0,
        value_text = args.value_text or 'None',
        value_num = args.value_num or 1,
        value_colour = type_table[args.type][2] or G.C.UI.TEXT_LIGHT,
        value_size = args.value_size or 0.3,
        offset = 0.05,
        node_pos = nil,
        definition = {},
        config = {},
        UIBox = {},
        UI = nil,
    }
    self.st_ref_table = self.st_counter
end

-- generates a definition for the counter
-- part of the ui box

function Card:generate_st_counter_defintion()
    if self.st_counter then
        if not S.SETTINGS.modules.stattrack.features.joker_tracking.groups.compact_view then
            self.st_counter.definition = {
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
                                            padding = 0.1,
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
                                                            text = self.st_counter.value_num > 1 and self.st_counter.text..'s' or self.st_counter.text,
                                                            scale = self.st_counter.text_size,
                                                            colour = self.st_counter.text_colour,
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
                                                            colour = G.C.CLEAR,
                                                        }, 
                                                        nodes = {
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    colour = G.C.CLEAR,
                                                                }, 
                                                                nodes = self.st_counter['_type'] == 'x mult' and {
                                                                    {
                                                                        n = G.UIT.C,
                                                                        config = {
                                                                            align = "cm",
                                                                            padding = 0.02,
                                                                            r = 0.1,
                                                                            colour = G.C.RED,
                                                                        },
                                                                        nodes = {
                                                                            {
                                                                                n = G.UIT.T,
                                                                                config = {
                                                                                    align = "cm",
                                                                                    scale = self.st_counter.value_size,
                                                                                    text = 'X'..self.st_counter.value,
                                                                                    colour = G.C.WHITE,
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                }
                                                                or self.st_counter['_type'] == 'chips/mult' and {
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
                                                                                    scale = self.st_counter.value_size,
                                                                                    text = '+'..(self.ability.name == 'Walkie Talkie' and (self.st_counter.value * 10) or self.ability.name == 'Scholar' and (self.st_counter.value * 20)),
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
                                                                                    scale = self.st_counter.value_size,
                                                                                    text = ' / ',
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
                                                                                    scale = self.st_counter.value_size,
                                                                                    text = '+'..self.st_counter.value*4,
                                                                                    colour = G.C.RED,
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
                                                                            scale = self.st_counter.value_size,
                                                                            text = self.ability.name == 'Obelisk' and self.st_counter.value_text or self.st_counter.prefix..self.st_counter.value,
                                                                            colour = self.st_counter.value_colour ~= G.C.UI.TEXT_LIGHT and self.st_counter.value_colour or G.C.UI.TEXT_DARK,
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
            self.st_counter.definition = {
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
                                            padding = 0.1,
                                        }, 
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    padding = 0.1,
                                                    r = 0.1,
                                                    text = self.st_counter.value_num > 1 and self.st_counter.text..'s:' or self.st_counter.text..':',
                                                    scale = self.st_counter.text_size,
                                                    colour = self.st_counter.text_colour,
                                                }
                                            },
                                            self.st_counter['_type'] == 'x mult' and {
                                                n = G.UIT.C,
                                                config = {
                                                    align = "cm",
                                                    minw = 1.5,
                                                    minh = 0.5,
                                                    r = 0.1,
                                                    padding = 0.05,
                                                    colour = G.C.RED,
                                                }, 
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = {
                                                            align = "cm",
                                                            scale = self.st_counter.value_size,
                                                            text = 'X'..self.st_counter.value,
                                                            colour = G.C.WHITE,
                                                        },
                                                    },
                                                },
                                            } 
                                            or self.st_counter['_type'] == 'chips/mult' and {
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
                                                            scale = self.st_counter.value_size,
                                                            text = '+'..(self.ability.name == 'Walkie Talkie' and (self.st_counter.value * 10) or self.ability.name == 'Scholar' and (self.st_counter.value * 20)),
                                                            colour = G.C.BLUE,
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
                                                                scale = self.st_counter.value_size,
                                                                text = ' ',
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
                                                                scale = self.st_counter.value_size,
                                                                text = '+'..self.st_counter.value*4,
                                                                colour = G.C.RED,
                                                            },
                                                        },
                                                    },
                                                }
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
                                                            scale = self.st_counter.value_size,
                                                            text = self.ability.name == 'Obelisk' and self.st_counter.value_text or self.st_counter.prefix..self.st_counter.value,
                                                            colour = self.st_counter.value_colour,
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
    end
end

-- generates the alignment for the counter
-- aligns it to the description pop up

function Card:generate_st_counter_align()
    local offset_below = (self.children.buy_button or (self.area and self.area.config.view_deck) or (self.area and self.area.config.type == 'shop')) and true or
                         (self.T.y < G.CARD_H*0.8) and true
    self.st_counter.config = {
        major = self.children.h_popup,
        parent = self.children.h_popup,
        xy_bond = 'Strong',
        r_bond = 'Weak',
        wh_bond = 'Weak',
        offset = {
            x = 0,
            y = offset_below and self.st_counter.offset or self.st_counter.offset * -1
        },  
        type = offset_below and 'bm' or 'tm'
    }
end

-- generates the ui box for the counter using the definition and alignment

function Card:generate_st_counter_UI()
    self.st_counter.UI = UIBox{
        definition = self.st_counter.definition,
        config = self.st_counter.config,
    }
end

-- function for showing the updated counter after a change in value, not needed as of now

function Card:update_st_counter()
    self:generate_st_counter_defintion()
    self:generate_st_counter_align()
    
    self:generate_st_counter_UI()
    if self.st_counter.shown then
        self:show_st_counter()
    end
end

-- function for displaying the counter, generates all the ui and 
-- sets it as a child of the description pop up

function Card:show_st_counter()
    if self.st_counter then
        local show_counter = false
        if (self.st_counter._type == 'money gen' or self.st_counter._type == 'value gen') and
        S.SETTINGS.modules.stattrack.features.joker_tracking.groups['money_generators'] then
            show_counter = true
        elseif (self.st_counter._type == 'card gen' or self.st_counter._type == 'cards added' or self.st_counter._type == 'joker gen') and
        S.SETTINGS.modules.stattrack.features.joker_tracking.groups['card_generators'] then
            show_counter = true
        elseif self.st_counter._type == '+ chips' and
        S.SETTINGS.modules.stattrack.features.joker_tracking.groups['chips_plus'] then
            show_counter = true
        elseif self.st_counter._type == '+ mult' and
        S.SETTINGS.modules.stattrack.features.joker_tracking.groups['mult_plus'] then
            show_counter = true
        elseif self.st_counter._type == 'x mult' and
        S.SETTINGS.modules.stattrack.features.joker_tracking.groups['mult_mult'] then
            show_counter = true
        elseif self.st_counter and S.SETTINGS.modules.stattrack.features.joker_tracking.groups['miscellaneous'] then
            show_counter = true
        end
        if show_counter then
            self:generate_st_counter_defintion()
            self:generate_st_counter_align()
            self:generate_st_counter_UI()
            self.children.h_popup.children.st_counter = self.st_counter.UI
        end
    end
end

-- function for hiding the counter, not needed as of now

function Card:hide_st_counter()
    if self.children.st_counter then
        self.children.st_counter = nil
    end
end

-- function for increasing the counter value

function Card:increment_st_counter(amt)
    self.st_counter.value = self.st_counter.value + amt
end

-- function for decreasing the counter value
  
function Card:decrement_st_counter(amt)
    self.st_counter.value = self.st_counter.value - amt
end

-- function for setting the counter value to 0
  
function Card:reset_st_counter()
    self.st_counter.value = 0
end

-- function for setting the counter value to a specific value
  
function Card:set_st_counter(amt)
    self.st_counter.value = amt
end

-- function for setting the counter text, as of now only needed for obelisk

function Card:set_st_text(text)
    local output_text = ''
    for k, v in pairs(text) do
        output_text = output_text..v
        if text[k] ~= text[#text] then
            output_text = output_text..'/'
        end
    end
    self.st_counter.value_text = output_text
    self.st_counter.value_num = #text
end

-- returns the counter value, not needed as of now

function Card:get_st_counter_value()
    return self.st_counter.value
end

-- function for incrementing the counter of money generating jokers that give money
-- at the end of the round

function Card:end_st_counter_bonus()
    if not self.st_counter then
        self:init_st_counter(self.st_ref_table)
        self.st_ref_table = self.st_counter
    end
    if self.debuff then return end
    if self.ability.set == "Joker" then
        if self.ability.name == 'Golden Joker' then
            self:increment_st_counter(self.ability.extra)
        end
        if self.ability.name == 'Cloud 9' and self.ability.nine_tally and self.ability.nine_tally > 0 then
            self:increment_st_counter(self.ability.extra*(self.ability.nine_tally))
        end
        if self.ability.name == 'Rocket' then
            self:increment_st_counter(self.ability.extra.dollars)
        end
        if self.ability.name == 'Satellite' then 
            local planets_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Planet' then planets_used = planets_used + 1 end
            end
            if planets_used == 0 then return end
            self:increment_st_counter(self.ability.extra*planets_used)
        end
        if self.ability.name == 'Delayed Gratification' and G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0 then
            self:increment_st_counter(G.GAME.current_round.discards_left*self.ability.extra)
        end
    end
end

-- mostly taken from the source code, increments counters when necessary
-- i took this route over using a bunch of patches because i hate patches

function Card:calculate_st_counter(context)
    if not self.st_counter then
        self:init_st_counter(self.st_ref_table)
        self.st_ref_table = self.st_counter
    end
    if context.ending_shop then
        if self.ability.name == 'Perkeo' then
            if G.consumeables.cards[1] then
                self:increment_st_counter(1)
            end
        end
    elseif context.first_hand_drawn then
        if self.ability.name == 'Certificate' then
            self:increment_st_counter(1)
        end
    elseif context.setting_blind and not self.getting_sliced then
        if self.ability.name == 'Chicot' and not context.blueprint
        and context.blind.boss and not self.getting_sliced then
            self:increment_st_counter(1)
        end
        if self.ability.name == 'Burglar' and not (context.blueprint_card or self).getting_sliced then
            self:increment_st_counter(self.ability.extra)
        end
        if self.ability.name == 'Cartomancer' and not (context.blueprint_card or self).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            self:increment_st_counter(1)
        end
        if self.ability.name == 'Marble Joker' and not (context.blueprint_card or self).getting_sliced  then
            self:increment_st_counter(1)
        end
    elseif context.destroying_card and not context.blueprint then
        if self.ability.name == 'Sixth Sense' and #context.full_hand == 1 and context.full_hand[1]:get_id() == 6 and G.GAME.current_round.hands_played == 0 then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                self:increment_st_counter(1)
            end
        end
    elseif context.debuffed_hand then 
        if self.ability.name == 'Matador' then
            if G.GAME.blind.triggered then 
                self:increment_st_counter(self.ability.extra)
            end
        end
    elseif context.pre_discard then
        if self.ability.name == 'Burnt Joker' and G.GAME.current_round.discards_used <= 0 and not context.hook then
            self:increment_st_counter(1)
        end
    elseif context.discard then
        if self.ability.name == 'Trading Card' and not context.blueprint and 
        G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
            self:increment_st_counter(1)
        end
        if self.ability.name == 'Mail-In Rebate' and
        not context.other_card.debuff and
        context.other_card:get_id() == G.GAME.current_round.mail_card.id then
            self:increment_st_counter(self.ability.extra)
        end
        if self.ability.name == 'Faceless Joker' and context.other_card == context.full_hand[#context.full_hand] then
            local face_cards = 0
            for k, v in ipairs(context.full_hand) do
                if v:is_face() then 
                    face_cards = face_cards + 1 
                end
            end
            if face_cards >= self.ability.extra.faces then
                self:increment_st_counter(self.ability.extra.dollars)
            end
        end
    elseif context.end_of_round then
        if context.repetition then
            if context.cardarea == G.hand then
                if self.ability.name == 'Mime' and
                (next(context.card_effects[1]) or #context.card_effects > 1) then
                    self:increment_st_counter(self.ability.extra)
                end
            end
        end
    elseif context.individual then
        if context.cardarea == G.play then
            if self.ability.name == 'Hiker' then
                self:increment_st_counter(self.ability.extra)
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
                    self:increment_st_counter(self.ability.extra)
                end
            end
            if self.ability.name == 'The Idol' and
            context.other_card:get_id() == G.GAME.current_round.idol_card.id and 
            context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Scary Face' and
            (context.other_card:is_face()) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Smiley Face' and (
            context.other_card:is_face()) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Golden Ticket' and
            context.other_card.ability.name == 'Gold Card' then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Scholar' and
            context.other_card:get_id() == 14 then
                self:increment_st_counter(1)
            end
            if self.ability.name == 'Walkie Talkie' and
            (context.other_card:get_id() == 10 or context.other_card:get_id() == 4) then
                self:increment_st_counter(1)
            end
            if self.ability.name == 'Fibonacci' and (
            context.other_card:get_id() == 2 or 
            context.other_card:get_id() == 3 or 
            context.other_card:get_id() == 5 or 
            context.other_card:get_id() == 8 or 
            context.other_card:get_id() == 14) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Even Steven' and
            context.other_card:get_id() <= 10 and 
            context.other_card:get_id() >= 0 and
            context.other_card:get_id()%2 == 0 then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Odd Todd' and
            ((context.other_card:get_id() <= 10 and 
            context.other_card:get_id() >= 0 and
            context.other_card:get_id()%2 == 1) or
            (context.other_card:get_id() == 14)) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.effect == 'Suit Mult' and
            context.other_card:is_suit(self.ability.extra.suit) then
                self:increment_st_counter(self.ability.extra.s_mult)
            end
            if self.ability.name == 'Rough Gem' and
            context.other_card:is_suit("Diamonds") then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Onyx Agate' and
            context.other_card:is_suit("Clubs") then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Arrowhead' and
            context.other_card:is_suit("Spades") then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Ancient Joker' and
            context.other_card:is_suit(G.GAME.current_round.ancient_card.suit) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Triboulet' and
            (context.other_card:get_id() == 12 or context.other_card:get_id() == 13) then
                self:increment_st_counter(self.ability.extra)
            end
        end
        if context.cardarea == G.hand then
            if self.ability.name == 'Shoot the Moon' and
            context.other_card:get_id() == 12 then
                if not context.other_card.debuff then
                    self:increment_st_counter(13)
                end
            end
            if self.ability.name == 'Baron' and
            context.other_card:get_id() == 13 then
                if not context.other_card.debuff then
                    self:increment_st_counter(self.ability.extra)
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
                        self:increment_st_counter(2*temp_Mult)
                    end
                end
            end
        end
    elseif context.repetition then
        if context.cardarea == G.play then
            if self.ability.name == 'Sock and Buskin' and (
            context.other_card:is_face()) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Hanging Chad' and (
            context.other_card == context.scoring_hand[1]) then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Dusk' and G.GAME.current_round.hands_left == 0 then
                self:increment_st_counter(self.ability.extra)
            end
            if self.ability.name == 'Seltzer' then
                self:increment_st_counter(1)
            end
            if self.ability.name == 'Hack' and (
            context.other_card:get_id() == 2 or 
            context.other_card:get_id() == 3 or 
            context.other_card:get_id() == 4 or 
            context.other_card:get_id() == 5) then
                self:increment_st_counter(self.ability.extra)
            end
        end
        if context.cardarea == G.hand then
            if self.ability.name == 'Mime' and
            (next(context.card_effects[1]) or #context.card_effects > 1) then
                self:increment_st_counter(self.ability.extra)
            end
        end
    elseif context.other_joker then
        if self.ability.name == 'Baseball Card' and context.other_joker.config.center.rarity == 2 and self ~= context.other_joker then
            self:increment_st_counter(self.ability.extra)
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
                        self:increment_st_counter(#faces)
                    end
                end
                if self.ability.name == 'To Do List' and context.scoring_name == self.ability.to_do_poker_hand then
                    self:increment_st_counter(self.ability.extra.dollars)
                end
                if self.ability.name == 'DNA' and G.GAME.current_round.hands_played == 0 then
                    if #context.full_hand == 1 then
                        self:increment_st_counter(1)
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
                    self:set_st_text(most_played_hands)
                end
                if self.ability.name == 'Loyalty Card' then
                    local loyalty_remaining = (self.ability.extra.every-1-(G.GAME.hands_played - self.ability.hands_played_at_create))%(self.ability.extra.every+1)
                    if loyalty_remaining == self.ability.extra.every then
                        self:increment_st_counter(self.ability.extra.Xmult)
                    end
                end
                if self.ability.name ~= 'Seeing Double' and self.ability.name ~= 'Obelisk' and self.ability.name ~= 'Lucky Cat' and
                self.ability.x_mult > 1 and (self.ability.type == '' or next(context.poker_hands[self.ability.type])) then
                    self:increment_st_counter(self.ability.x_mult)
                end
                if self.ability.t_mult > 0 and next(context.poker_hands[self.ability.type]) then
                    self:increment_st_counter(self.ability.t_mult)
                end
                if self.ability.t_chips > 0 and next(context.poker_hands[self.ability.type]) then
                    self:increment_st_counter(self.ability.t_chips)
                end
                if self.ability.name == 'Half Joker' and #context.full_hand <= self.ability.extra.size then
                    self:increment_st_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Abstract Joker' then
                    local x = 0
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i].ability.set == 'Joker' then
                            x = x + 1
                        end
                    end
                    self:increment_st_counter(x*self.ability.extra)
                end
                if self.ability.name == 'Acrobat' and G.GAME.current_round.hands_left == 0 then
                    self:increment_st_counter(self.ability.extra)
                end
                if self.ability.name == 'Mystic Summit' and G.GAME.current_round.discards_left == self.ability.extra.d_remaining then
                    self:increment_st_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Banner' and G.GAME.current_round.discards_left > 0 then
                    self:increment_st_counter(G.GAME.current_round.discards_left*self.ability.extra)
                end
                if self.ability.name == 'Stuntman' then
                    self:increment_st_counter(self.ability.extra.chip_mod)
                end
                if self.ability.name == 'Supernova' then
                    self:increment_st_counter(G.GAME.hands[context.scoring_name].played)
                end
                if self.ability.name == 'Vagabond' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    if G.GAME.dollars <= self.ability.extra then
                        self:increment_st_counter(1)
                    end
                end
                if self.ability.name == 'Superposition' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    local aces = 0
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i]:get_id() == 14 then aces = aces + 1 end
                    end
                    if aces >= 1 and next(context.poker_hands["Straight"]) then
                        self:increment_st_counter(1)
                    end
                end
                if self.ability.name == 'Seance' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    if next(context.poker_hands[self.ability.extra.poker_hand]) then
                        self:increment_st_counter(1)
                    end
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
                        self:increment_st_counter(self.ability.extra)
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
                        self:increment_st_counter(self.ability.extra)
                    end
                end
                if self.ability.name == 'Castle' and (self.ability.extra.chips > 0) then
                    self:increment_st_counter(self.ability.extra.chips)
                end
                if self.ability.name == 'Blue Joker' and #G.deck.cards > 0 then
                    self:increment_st_counter(self.ability.extra*#G.deck.cards)
                end
                if self.ability.name == 'Erosion' and (G.GAME.starting_deck_size - #G.playing_cards) > 0 then
                    self:increment_st_counter(self.ability.extra*(G.GAME.starting_deck_size - #G.playing_cards))
                end
                if self.ability.name == 'Square Joker' then
                    self:increment_st_counter(self.ability.extra.chips)
                end
                if self.ability.name == 'Runner' then
                    self:increment_st_counter(self.ability.extra.chips)
                end
                if self.ability.name == 'Ice Cream' then
                    self:increment_st_counter(self.ability.extra.chips)
                end
                if self.ability.name == 'Stone Joker' and self.ability.stone_tally > 0 then
                    self:increment_st_counter(self.ability.extra*self.ability.stone_tally)
                end
                if self.ability.name == 'Steel Joker' and self.ability.steel_tally > 0 then
                    self:increment_st_counter(1 + self.ability.extra*self.ability.steel_tally)
                end
                if self.ability.name == 'Bull' and (G.GAME.dollars + (G.GAME.dollar_buffer or 0)) > 0 then
                    self:increment_st_counter(self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))))
                end
                if self.ability.name == "Driver's License" then
                    if (self.ability.driver_tally or 0) >= 16 then 
                        self:increment_st_counter(self.ability.extra)
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
                        self:increment_st_counter(self.ability.extra)
                    end
                end
                if self.ability.name == 'Swashbuckler' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Joker' then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Spare Trousers' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Ride the Bus' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Flash Card' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Popcorn' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Green Joker' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Fortune Teller' and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot > 0 then
                    self:increment_st_counter(G.GAME.consumeable_usage_total.tarot)
                end
                if self.ability.name == 'Gros Michel' then
                    self:increment_st_counter(self.ability.extra.mult)
                end
                if self.ability.name == 'Cavendish' then
                    self:increment_st_counter(self.ability.extra.Xmult)
                end
                if self.ability.name == 'Red Card' and self.ability.mult > 0 then
                    self:increment_st_counter(self.ability.mult)
                end
                if self.ability.name == 'Card Sharp' and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round > 1 then
                    self:increment_st_counter(self.ability.extra.Xmult)
                end
                if self.ability.name == 'Bootstraps' and math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars) >= 1 then 
                    self:increment_st_counter(self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars))
                end
                if self.ability.name == 'Caino' and self.ability.caino_xmult > 1 then 
                    self:increment_st_counter(self.ability.caino_xmult)
                end
            end
        end
    end
end
