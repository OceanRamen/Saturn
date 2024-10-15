--- CONSTANTS
local CAN_STACK_SET = {
  "Planet",
  "Tarot",
  "Spectral",
}
local CAN_USE_SET = {
  "Planet",
}
local CAN_USE_KEY = {
  "The Hermit",
  "Temperance",
}
MAX_SIZE = 9999

local Stack = require("stack")

REF = {}

function Card:shouldInit()
  if self:canStack() then
    self.stack = self.stack or Stack:new()
  end
end

function Card:canStack()
  return inTable(CAN_STACK_SET, self.ability.set)
    and (self.edition or {}).type == "negative"
end

function Card:canSplit()
  self:shouldInit()
  return inTable(CAN_STACK_SET, self.ability.set)
    and ((self.stack or {}):getSize() > 1)
end

function Card:canMerge()
  self.editions = self.edition or {}
  for k, v in pairs(G.consumeables.cards) do
    if v and isCopy(self, v) then
      return true
    end
  end
  return false
end

function Card:canMassUse()
  return (
    inTable(CAN_USE_SET, self.ability.set)
    or inTable(CAN_USE_KEY, self.config.center_key)
  )
end

function Card:split(n)
  self:shouldInit()
  if not self:canSplit() then
    return
  end
  -- Ensure n is not bigger than stack size
  n = math.min(self.stack:getSize(), n)
  local card_limit = G.consumeables.config.card_limit
  if (self.edition or {}).negative then
    card_limit = card_limit + 1
  end
  local split_index = self.stack:getSize() - n
  local new_stack = self.stack:split(split_index)
  local new_card = copy_card(self)
  new_card.stack = new_stack
  new_card.sort_id = new_card.stack:pop()
  new_card.ignoreStack = true
  new_card:add_to_deck()
  G.consumeables:emplace(new_card)
  self:setStackCost()
  new_card:setStackCost()
  if new_card.stack:getSize() >= 2 then
    new_card:createStackUI()
  end
  G.consumeables.config.card_limit = card_limit
  play_sound("card3", 0.9 + math.random() * 0.1, 0.4)
  return new_card
end

function Card:tryMergeAll()
  self:shouldInit()
  if not self:canStack() then
    return
  end
  local cards = {}
  for k, v in pairs(G.consumeables.cards) do
    if isCopy(v, self) then
      table.insert(cards, v)
    end
  end
  if not (#cards >= 1) then
    return
  end
  self:createStackUI()
  Saturn.is_merging = true
  for k, v in pairs(cards) do
    v:shouldInit()
    if self.stack:getSize() + v.stack:getSize() < MAX_SIZE then
      G.E_MANAGER:add_event(
        Event({
          delay = easedCurve(k, #cards),
          func = function()
            if k % 2 == 0 then
              play_sound(
                "card1",
                1.3 + math.random() * 0.2,
                0.2 * easedCurve(k, #cards, 0.6)
              )
            end
            if k % 3 == 0 then
              G.ROOM.jiggle = G.ROOM.jiggle + (easedCurve(k, #cards, 0.4))
              play_sound(
                "cardSlide1",
                1.4 + math.random() * 0.2,
                0.2 * easedCurve(k, #cards, 0.6)
              )
            end
            self.stack:merge(v)
            self:setStackCost()
            v:remove()
            return true
          end,
        }),
        "other"
      )
    end
  end
  G.E_MANAGER:add_event(
    Event({
      trigger = "after",
      func = function()
        Saturn.is_merging = false
        self:juice_up(0.2, 0.3)
        return true
      end,
    }),
    "other"
  )
end

function Card:tryMerge(target, no_dissolve)
  self:shouldInit()
  self.edition = self.edition or {}
  if not self:canStack() then
    return
  end
  target = target or getCopy(self)
  if target and not isCopy(target, self) then
    target = getCopy(self)
  end
  if not target then
    error("Error: No valid target found for merging.")
    return
  end
  target:shouldInit()
  no_dissolve = no_dissolve or false
  if not target.stack then
    error("Error: Target stack is not initialized.")
    return
  end
  if target.stack:getSize() < MAX_SIZE then
    target.stack:merge(self)
    target:createStackUI()
    target:juice_up(0.3, 0.4)
    play_sound("card1", 1.3 + math.random() * 0.2, 0.2)
    target:setStackCost()
    if not no_dissolve then
      self:start_dissolve(nil, true)
    else
      self:remove()
    end
  else
    error("Error: Target stack size exceeds the maximum limit.")
  end
end

function Card:massUse()
  self:shouldInit()
  local size = (self.stack or {}):getSize()
  if self:canMassUse() and size > 0 then
    if self.ability.set == "Planet" then
      update_hand_text(
        { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
        {
          handname = localize(
            self.ability.consumeable.hand_type,
            "poker_hands"
          ),
          chips = G.GAME.hands[self.ability.consumeable.hand_type].chips,
          mult = G.GAME.hands[self.ability.consumeable.hand_type].mult,
          level = G.GAME.hands[self.ability.consumeable.hand_type].level,
        }
      )
      delay(1.3)
      level_up_hand(
        self,
        self.ability.consumeable.hand_type,
        nil,
        self.stack:getSize()
      )
      update_hand_text(
        { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
        { mult = 0, chips = 0, handname = "", level = "" }
      )
    elseif
      self.ability.set == "Tarot" and inTable(CAN_USE_KEY, self.ability.name)
    then
      local money = G.GAME.dollars
      stop_use()
      if self.ability.name == "The Hermit" then
        for i = 1, self.stack:getSize() do
          money = money + math.max(0, math.min(money, self.ability.extra))
        end
        money = money - G.GAME.dollars
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            play_sound("timpani")
            self:juice_up(0.3, 0.5)
            ease_dollars(money, true)
            return true
          end,
        }))
        delay(0.6)
      elseif self.ability.name == "Temperance" then
        money = 0
        for i = 1, self.stack:getSize() do
          money = money + self.ability.money
        end
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            play_sound("timpani")
            self:juice_up(0.3, 0.5)
            ease_dollars(money, true)
            return true
          end,
        }))
        delay(0.6)
      end
    end
    self:remove()
    self:start_dissolve()
  end
end

function Card:massSell()
  self:shouldInit()
  local size = (self.stack or {}):getSize() or 1
  if self:canStack() and size > 0 then
    local money = self.ability.stack_cost
    stop_use()
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.4,
      func = function()
        play_sound("timpani")
        self:juice_up(0.3, 0.5)
        ease_dollars(money, true)
        return true
      end,
    }))
    delay(0.6)
    self:remove()
    self:start_dissolve()
  end
end

function Card:dissolveStack()
  self:shouldInit()
  if not self:canSplit() then
    return
  end
  local size = self.stack:getSize()
  if not (size > 1) then
    return
  end
  local n = size - 1
  Saturn.is_splitting = true
  for i = 1, n do
    G.E_MANAGER:add_event(
      Event({
        delay = easedCurve(i, n),
        func = function()
          if i % 3 == 0 then
            play_sound(
              "card1",
              1.3 + math.random() * 0.2,
              0.2 * easedCurve(i, n, 0.6)
            )
          end
          if i % 4 == 0 then
            G.ROOM.jiggle = G.ROOM.jiggle + (easedCurve(i, n, 0.4))
            play_sound(
              "cardSlide1",
              1.4 + math.random() * 0.2,
              0.2 * easedCurve(i, n, 0.6)
            )
          end
          local card_limit = G.consumeables.config.card_limit
          if (self.edition or {}).negative then
            card_limit = card_limit + 1
          end
          local new_card = copy_card(self)
          new_card.stack = Stack:new()
          new_card.sort_id = self.stack:pop()
          new_card.ignoreStack = true
          new_card:add_to_deck()
          G.consumeables:emplace(new_card, "front")
          self:setStackCost()
          new_card:setStackCost()
          G.consumeables.config.card_limit = card_limit
          return true
        end,
      }),
      "other"
    )
  end
  G.E_MANAGER:add_event(
    Event({
      trigger = "after",
      func = function()
        Saturn.is_splitting = false
        return true
      end,
    }),
    "other"
  )
end

function Card:setStackCost()
  self:shouldInit()
  self.extra_cost = 0 + G.GAME.inflation
  if self.edition then
    self.extra_cost = self.extra_cost
      + (self.edition.holo and 3 or 0)
      + (self.edition.foil and 2 or 0)
      + (self.edition.polychrome and 5 or 0)
      + (self.edition.negative and 5 or 0)
  end
  self.cost = math.max(
    1,
    math.floor(
      (self.base_cost + self.extra_cost + 0.5)
        * (100 - G.GAME.discount_percent)
        / 100
    )
  )
  if
    self.ability.set == "Booster" and G.GAME.modifiers.booster_ante_scaling
  then
    self.cost = self.cost + G.GAME.round_resets.ante - 1
  end
  if
    self.ability.set == "Booster"
    and not G.SETTINGS.tutorial_complete
    and G.SETTINGS.tutorial_progress
    and not G.SETTINGS.tutorial_progress.completed_parts["shop_1"]
  then
    self.cost = self.cost + 3
  end
  if
    (
      self.ability.set == "Planet"
      or (self.ability.set == "Booster" and self.ability.name:find("Celestial"))
    ) and #find_joker("Astronomer") > 0
  then
    self.cost = 0
  end
  if self.ability.rental then
    self.cost = 1
  end
  self.ability.stack_cost = math.max(1, math.floor(self.cost / 2))
    + (self.ability.extra_value or 0)
  if
    self.area
    and self.ability.couponed
    and (self.area == G.shop_jokers or self.area == G.shop_booster)
  then
    self.cost = 0
  end
  self.ability.stack_cost = self.sell_cost * ((self.stack or {}):getSize() or 1)
  self.ability.stack_cost_label = self.facing == "back" and "?"
    or self.ability.stack_cost
end

function Card:createStackUI()
  if self.children.stack_ui then
    return
  end
  if not self:canStack() then
    return
  end
  self.children.stack_ui = G.UIDEF.counterStackSize(self)
end

REF.card_load = Card.load
function Card:load(cardTable, other_card)
  REF.card_load(self, cardTable, other_card)
  if self.stack and self.stack:getSize() > 1 then
    self:createStackUI()
  end
end

REF.card_sell = Card.sell_card
function Card:sell_card()
  if not self:canStack() then
    return REF.card_sell(self)
  end
  if not (self.stack:getSize() > 1) then
    return REF.card_sell(self)
  end
  local sell_card = self:split(1)
  if sell_card then
    sell_card:sell_card()
  end
  self:highlight(true)
end

REF.add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  REF.add_to_deck(self, from_debuff)
  if not G.consumeables then
    return
  end
  if not self:canStack() then
    return
  end
  self.stack = self.stack or Stack:new()
  if (not self:canMerge()) or self.ignoreStack then
    return
  end
  if not Saturn.config.enable_stacking then
    return
  end
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 0.1,
    fuc = function()
      self:tryMerge(nil, true)
      return true
    end,
  }))
end

REF.use_card = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
  local card = e.config.ref_table
  if (card.stack or {}):getSize() > 1 then
    card.highlighted = false
    local split = card:split(1)
    e.config.ref_table = split
  end
  if e then
    REF.use_card(e, mute, nosave)
  else
    error("Error trying to use consumeable")
  end
end

REF.card_highlight = Card.highlight
function Card:highlight(is_highlighted)
  if not self:canStack() then
    goto ret
  end
  if not self.added_to_deck then
    goto ret
  end
  if is_highlighted then
    --DEBUG
    if self.stack then
      print(self.stack:getSize())
    end
    -- TODO: FIX
    -- self.children.stackActionButtons = UIBox({
    --   definition = G.UIDEF.buttonMassUseSell(self),
    --   config = {
    --     align = "cl",
    --     offset = {
    --       x = 0.6,
    --       y = 0,
    --     },
    --     parent = self,
    --   },
    -- })
    local y_offset = 0
    if self:canSplit() then
      y_offset = y_offset + 1
    end
    if self:canMerge() then
      y_offset = y_offset + 1
    end
    self.children.stackActionContainer = UIBox({
      definition = G.UIDEF.stackActionContainer(self),
      config = {
        align = "bmi",
        offset = {
          x = 0,
          y = y_offset,
        },
        bond = "Strong",
        parent = self,
      },
    })
  else
    if self.children.stackActionButtons then
      self.children.stackActionButtons:remove()
      self.children.stackActionButtons = nil
    end
    if self.children.stackActionContainer then
      self.children.stackActionContainer:remove()
      self.children.stackActionContainer = nil
    end
  end
  ::ret::
  return REF.card_highlight(self, is_highlighted)
end

function set_consumeable_usage(card, amt)
  amt = math.floor(amt or 1)
  if card.config.center_key and card.ability.consumeable then
    if
      G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key]
    then
      G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count = G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count
        + amt
    else
      G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key] =
        { count = 1, order = card.config.center.order }
    end
    if G.GAME.consumeable_usage[card.config.center_key] then
      G.GAME.consumeable_usage[card.config.center_key].count = G.GAME.consumeable_usage[card.config.center_key].count
        + amt
    else
      G.GAME.consumeable_usage[card.config.center_key] =
        { count = 1, order = card.config.center.order, set = card.ability.set }
    end
    G.GAME.consumeable_usage_total = G.GAME.consumeable_usage_total
      or { tarot = 0, planet = 0, spectral = 0, tarot_planet = 0, all = 0 }
    if card.config.center.set == "Tarot" then
      G.GAME.consumeable_usage_total.tarot = G.GAME.consumeable_usage_total.tarot
        + amt
      G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet
        + amt
    elseif card.config.center.set == "Planet" then
      G.GAME.consumeable_usage_total.planet = G.GAME.consumeable_usage_total.planet
        + amt
      G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet
        + amt
    elseif card.config.center.set == "Spectral" then
      G.GAME.consumeable_usage_total.spectral = G.GAME.consumeable_usage_total.spectral
        + amt
    end

    G.GAME.consumeable_usage_total.all = G.GAME.consumeable_usage_total.all
      + amt

    if not card.config.center.discovered then
      discover_card(card)
    end

    if
      card.config.center.set == "Tarot" or card.config.center.set == "Planet"
    then
      G.E_MANAGER:add_event(Event({
        trigger = "immediate",
        func = function()
          G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
              G.GAME.last_tarot_planet = card.config.center_key
              return true
            end,
          }))
          return true
        end,
      }))
    end
  end
  G:save_settings()
end

local lmr = love.mousereleased
function love.mousereleased(x, y, button)
  lmr(x, y, button)
  if button == 2 then
    G.CONTROLLER:R_cursor_release(x, y)
  end
end

function Controller:R_cursor_release(x, y)
  x = x or self.cursor_position.x
  y = y or self.cursor_position.y
  if
    (self.locked and (not G.SETTINGS.paused or G.screenwipe))
    or self.locks.frame
  then
    return
  end

  self.r_cursor_up.T =
    { x = x / (G.TILESCALE * G.TILESIZE), y = y / (G.TILESCALE * G.TILESIZE) }
  self.r_cursor_up.time = G.TIMERS.TOTAL
  self.r_cursor_up.handled = false
  self.r_cursor_up.target = nil
  self.is_r_cursor_down = false

  self.r_cursor_up.target = self.hovering.target or self.focused.target
  if self.r_cursor_up.target == nil then
    self.r_cursor_up.target = G.ROOM
  end
end

local qrcpr = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
  qrcpr(self, x, y)
  x = x or self.cursor_position.x
  y = y or self.cursor_position.y

  self.r_cursor_down.T =
    { x = x / (G.TILESCALE * G.TILESIZE), y = y / (G.TILESCALE * G.TILESIZE) }
  self.r_cursor_down.time = G.TIMERS.TOTAL
  self.r_cursor_down.handled = false
  self.r_cursor_down.target = nil
  self.is_r_cursor_down = true

  local press_node = (self.HID.touch and self.cursor_hover.target)
    or self.hovering.target
    or self.focused.target

  if press_node then
    self.r_cursor_down.target = press_node.states.click.can and press_node
      or press_node:can_drag()
      or nil
    if
      type(self.r_cursor_down.target) == "table"
      and self.r_cursor_down.target.__index == Card
    then
      local card = self.r_cursor_down.target
      if card.area == G.consumeables then
        if
          love.keyboard.isDown("lshift")
          and not Saturn.is_splitting
          and not Saturn.is_merging
        then
          card:dissolveStack()
        elseif
          love.keyboard.isDown("lctrl")
          and not Saturn.is_splitting
          and not Saturn.is_merging
        then
          if card:canMerge() then
            card:tryMergeAll()
          end
        end
      end
    end
  end

  if self.r_cursor_down.target == nil then
    self.r_cursor_down.target = G.ROOM
  end
end
