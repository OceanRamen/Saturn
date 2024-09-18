-- Toggle sticky-counters
local r_click_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
  if
    self.hovering.target.ability
    and self.hovering.target.ability.set == "Joker"
  then
    self.hovering.target:counter_lock()
  end
  r_click_ref(self, x, y)
end

--- Fuck obelisk. We are removing it.

local joker_counter_types = {
  -- Money Gen
  ["Delayed Gratification"] = "money_gen",
  ["Business Card"] = "money_gen",
  ["Faceless Joker"] = "money_gen",
  ["Cloud 9"] = "money_gen",
  ["Rocket"] = "money_gen",
  ["Reserved Parking"] = "money_gen",
  ["Mail-In Rebate"] = "money_gen",
  ["Golden Joker"] = "money_gen",
  ["Golden Ticket"] = "money_gen",
  ["Rough Gem"] = "money_gen",
  ["Matador"] = "money_gen",
  ["Satellite"] = "money_gen",
  ["To Do List"] = "money_gen",
  -- Value Gen
  ["Egg"] = "value_gen",
  ["Gift Card"] = "value_gen",
  -- Card Gen
  ["8 Ball"] = "card_gen",
  ["Sixth Sense"] = "card_gen",
  ["Superposition"] = "card_gen",
  ["Seance"] = "card_gen",
  ["Vagabond"] = "card_gen",
  ["Hallucination"] = "card_gen",
  ["Cartomancer"] = "card_gen",
  ["Perkeo"] = "card_gen",
  -- Joker Gen
  ["Riff-raff"] = "jokers_gen",
  -- Card Add
  ["Marble Joker"] = "cards_add",
  ["DNA"] = "cards_add",
  ["Certificate"] = "cards_add",
  -- Card Rem
  ["Trading Card"] = "cards_rem",
  -- Joker Rem
  ["Ceremonial Dagger"] = "jokers_rem",
  -- Hand Upgrade
  ["Burnt Joker"] = "hands_upgraded",
  ["Space Joker"] = "hands_upgraded",
  -- Turned to gold
  ["Midas Mask"] = "turned_gold",
  -- Plus Hands
  ["Burglar"] = "plus_hands",
  -- Retriggers
  ["Dusk"] = "retriggers",
  ["Hack"] = "retriggers",
  ["Mime"] = "retriggers",
  ["Seltzer"] = "retriggers",
  ["Sock and Buskin"] = "retriggers",
  ["Hanging Chad"] = "retriggers",
}

local counter_type_table = {
  ["money_gen"] = {
    text = "Money Generated",
    colour = G.C.MONEY,
    prefix = "$",
  },
  ["value_gen"] = {
    text = "Value Generated",
    colour = G.C.MONEY,
    prefix = "$",
  },
  ["card_gen"] = {
    text = "Cards Generated",
    colour = G.C.SECONDARY_SET.Tarot,
    prefix = "",
  },
  ["jokers_gen"] = {
    text = "Jokers Generated",
    colour = G.C.RARITY[2],
    prefix = "",
  },
  ["cards_add"] = {
    text = "Cards Added",
    colour = G.C.CHANCE,
    prefix = "",
  },
  ["cards_rem"] = {
    text = "Cards Removed",
    colour = G.C.G.C.RED,
    prefix = "",
  },
  ["jokers_rem"] = {
    text = "Jokers Destroyed",
    colour = G.C.RED,
    prefix = "",
  },
  ["hands_upgraded"] = {
    text = "Hands Upgraded",
    colour = G.C.HAND_LEVELS[6],
    prefix = "",
  },
  ["turned_gold"] = {
    text = "Turned to Gold",
    colour = G.C.MONEY,
    prefix = "",
  },
  ["plus_hands"] = {
    text = "Plus Hands",
    colour = G.C.BLUE,
    prefix = "",
  },
  ["retriggers"] = {
    text = "Retriggers",
    colour = G.C.GREEN,
    prefix = "",
  },
}

--- Counter Load/Save

local sr = Card.save
function Card:save()
  local ret = save_ref(self)
  ret = self:save_counters(ret)
  return ret
end

function Card:load_counters(cardTable)
  if cardTable["counter"] then
    local counter_value = cardTable["counter"]
    self:init_counter()
    if self:has_counter() and counter_value ~= 0 then
      self:set_counter(counter_value)
      self:display_counter(false)
    end
  end
  if cardTable["saturn_counter"] then
    self.counter_ref_table = cardTable["saturn_counter"]
    self:init_counter(self.counter_ref_table)
    if self:has_counter() then
      self:display_counter(false)
    end
  end
end

local lr = Card.load
function Card:load(cardTable, other_card)
  lr(self, cardTable, other_card)
  self:load_counters(cardTable)
end

--- Counter Validation

function Card:should_init()
  if self.ability and self.ability.set == "Joker" and self.area == G.jokers then
    if not self:has_counter() then
      self:init_counter(self.counter_ref_table)
      self.counter_ref_table = self.counter
    end
  end
end

function Card:should_display(hover)
  if self:check_enabled() then
    self:display_counter(hover)
  end
end

function Card:check_enabled()
  local show_counter = false
  if self.ability.set == "Joker" and self.area == G.jokers then
    self:should_init()
    local counter_type = joker_counter_types[self.ability.name]
    if counter_type then
      if Saturn.config["track_" .. counter_type] then
        show_counter = true
      end
    end
  end
  return show_counter
end

function Card:is_valid()
  local counter_type = joker_counter_types[self.ability.name]
  return (counter_type and true) or false
end

function Card:has_counter()
  if self and self.counter then
    return true
  else
    return false
  end
end

local hr = Card.hover
function Card:hover()
  hr(self)
  self:should_init()
  self:should_display(true)
end

local shr = Card.stop_hover
function Card:stop_hover()
  shr(self)
  self:should_init()
  self:should_display()
end

local cjr = Card.calculate_joker
function Card:calculate_joker(context)
  self:should_init()
  local ret = cjr(self, context)
  self:calculate_counters(context)
  return ret
end

local cdr = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
  self:should_init()
  local ret = cdr(self)
  self:counter_bonus()
  return ret
end

local cur = Card.update
function Card:update(dt)
  self:should_init()
  cur(self, dt)
  self:update_counter()
end

function Card:init_counter(args)
  local args = args or {}
  args.counter_type = self:is_valid()
  if args.counter_type then
    self.counter = {
      counter_type = args.counter_type,
      counter_text = args.counter_text
        or counter_type_table[args.counter_type].text,
      counter_text_colour = args.text_colour or G.C.UI.TEXT_LIGHT,
      counter_text_size = args.text_size or 0.3,
      counter_prefix = args.prefix
        or counter_type_table[args.counter_type].prefix,
      counter_value = args.counter_value or 0,
      counter_old_value = args.counter_old_value or 0,
      counter_value_num = args.counter_value_num or 1,
      counter_value_colour = args.counter_value_colour
        or counter_type_table[args.counter_type].colour,
      counter_value_size = args.counter_value_size or 0.3,
      counter_offset = args.counter_offset or 0.05,

      locked = args.locked or false,
    }
  end
  self.counter_ref_table = self.counter
end

function Card:counter_lock()
  self:should_init()
  if self:has_counter() and self:check_enabled() then
    self.counter.locked = not self.counter.locked
  end
end

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
      self:should_display()
    end
    if
      self.counter.counter_value_text ~= self.counter.counter_old_value_text
    then
      self.counter.counter_old_value_text = self.counter.counter_value_text
      self:should_display()
    end
    if force then
      self:should_display()
    end
  end
end

function update_all_counters(force)
  if not (G.jokers and G.jokers.cards) then
    return
  end
  for k, v in pairs(G.jokers.cards) do
    if v.ability and v.ability.set == "Joker" then
      v:update_counter(force)
    end
  end
end

function Card:increment_counter(counter)
  if not counter then
    counter = 0
  end
  self:should_init()
  if self:has_counter() then
    self.counter.counter_value = self.counter.counter_value + counter
  end
end

function Card:decrement_counter(counter)
  if not counter then
    counter = 0
  end
  self:should_init()
  if self:has_counter() then
    self.counter.counter_value = self.counter.counter_value - counter
  end
end

function Card:reset_counter()
  self:should_init()
  if self:has_counter() then
    self.counter.counter_value = 0
  end
end

function Card:set_counter(counter)
  if self then
    self:should_init()
    if self:has_counter() then
      if not counter then
        counter = self.counter.counter_value
      end
      self.counter.counter_value = counter
    end
  end
end

function Card:set_counter_text(text)
  self:should_init()
  if self:has_counter() then
    self.counter.counter_value_text = text
    self.counter.counter_value_num = #text
  end
end

function Card:get_counter_value()
  if self:has_counter() then
    return self.counter.counter_value
  end
end

function Card:counter_bonus() end
function Card:calculate_counters(context) end
