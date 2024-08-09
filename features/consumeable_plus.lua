consumeable = {
  in_use = false,
}

local c_config = {
  stack_limit = 9999,
  mass_use_limit = 9999,
}

local stackable = {
  "Tarots",
  "Planets",
  "Spectral",
}

local mass_useable = {
  "Planets",
}

local mass_useable_unique = {
  "c_hermit",
  "c_temperance",
}


--- Quantity Getter/Setter Methods

function Card:get_quantity()
  return (self.ability or {}).qty or 1
end

function Card:set_quantity(qty)
end

function Card:add_quantity(qty)
end

function Card:sub_quantity(qty)
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
end

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
end



function Card:can_stack()
end

function Card:can_devide()
end

function Card:can_mass_use()
end

function can_use_buttons()
end

G.FUNCS.can_split_half = function(e)
end

G.FUNCS.can_split_one = function(e)
end

G.FUNCS.can_merge = function(e)
end

G.FUNCS.can_mass_use = function(e)
end


function Card:get_max_use()
end

G.FUNCS.split_half = function(e)
end

G.FUNCS.split_one = function(e)
end

G.FUNCS.merge_cards = function(e)
end

G.FUNCS.mass_use = function(e)
end



function Card:try_split()
end

function Card:try_merge()
end


local use_card_ref = G.FUNCS.use_card
G.FUNCS.use_card = function (e, mute, nosave)
end



function add_consumeable_useage(card, qty)
end


--- UI
function Card:create_stack_UI()
end

local highlight_ref = Card.highlight
function Card:highlight(is_highlighted) end
