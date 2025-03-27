local HARD_MAX = 9999

local CAN_STACK = {
  "Planet",
  "Tarot",
  "Spectral",
}
local CAN_MASS_USE = {
  "Planet",
}
local CAN_MASS_USE_INDIVIDUAL = {
  "The Hermit",
  "Temperance",
}

local function inTable(table, key)
  for k, v in pairs(table) do
    if v == key then
      return true
    end
  end
  return false
end

-- for compatability between saturn versions
local card_load = Card.load
function Card:load(cardTable, other_card)
  card_load(self, cardTable, other_card)
  if cardTable.ability.qty then
    self.ability.amt = cardTable.ability.qty
    self.ability.qty = nil
  end
  if not self.ability.amt then
    self.ability.amt = 1
  end

  self:set_stack_cost()
  self:set_cost()
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
          card:dissolve_stack()
        elseif
          love.keyboard.isDown("lctrl")
          and not Saturn.is_splitting
          and not Saturn.is_merging
        then
          if card:canMerge() and card:canSplit() then
            card:attemptMergeAll()
            --   if G.consumeables.highlighted[1] then
            --     card:attemptMerge(G.consumeables.highlighted[1])
            --   else
            --     card:attemptMergeAll()
            --   end
          end
          -- elseif card:canSplit() and card:getAmt() > 1 then
          --   if love.keyboard.isDown("lshift") then
          --     local qty = math.floor(card:getAmt() / 2)
          --     local new_card = card:split(qty)
          --   else
          --     local new_card = card:split(1)
          --   end
        end
      end
    end
  end

  if self.r_cursor_down.target == nil then
    self.r_cursor_down.target = G.ROOM
  end
end

function Card:getAmt()
  return (self.ability or {}).amt or 1
end

function Card:setAmt(amt)
  if self:canStack() then
    if self.ability then
      if amt <= 0 then
        self.ability.amt = 0
        Card:start_dissolve()
      elseif amt >= HARD_MAX then
        self.ability.amt = HARD_MAX
      else
        self.ability.amt = amt
      end
    end
  end
end

function Card:addAmt(amt)
  if self:canStack() then
    if self.ability then
      self:setAmt(self:getAmt() + amt)
    end
  end
end

function Card:subAmt(amt)
  if self:canStack() then
    if self.ability then
      self:setAmt(self:getAmt() - amt)
    end
  end
end

function Card:canStack()
  return inTable(CAN_STACK, self.ability.set)
    and self:getEditionType() == "negative"
end

function Card:canSplit()
  return inTable(CAN_STACK, self.ability.set)
end

function Card:canMerge()
  local can_merge = false
  for k, v in pairs(G.consumeables.cards) do
    if v then
      if
        v ~= self
        and (v.config or {}).center_key == (self.config or {}).center_key
        and v:getEditionType() == self:getEditionType()
      then
        can_merge = true
      end
    end
  end
  return can_merge
end

function Card:getEditionType()
  if self.edition then
    return self.edition.type or ""
  end
  return ""
end

function Card:canMassUse()
  return (
    inTable(CAN_MASS_USE, self.ability.set)
    or inTable(CAN_MASS_USE_INDIVIDUAL, self.config.center_key)
  )
end

-- local function apply_consumeable_useage(card, amount) end

-- local set_cost_ref = Card.set_cost
-- function Card:set_cost()
--   set_cost_ref(self)
-- end

function Card:set_stack_cost()
  self.extra_cost = 0 + G.GAME.inflation
  if self.edition then
    if G.P_CENTER_POOLS.Edition then
      for k, v in pairs(G.P_CENTER_POOLS.Edition) do
        if self.edition[v.key:sub(3)] then
          if v.extra_cost then
            self.extra_cost = self.extra_cost + v.extra_cost
          end
        end
      end
    else
      self.extra_cost = self.extra_cost
        + (self.edition.holo and 3 or 0)
        + (self.edition.foil and 2 or 0)
        + (self.edition.polychrome and 5 or 0)
        + (self.edition.negative and 5 or 0)
    end
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
  self.ability.stack_cost = self.sell_cost * ((self.ability or {}).amt or 1)
  self.ability.stack_cost_label = self.facing == "back" and "?"
    or self.ability.stack_cost
end

function getDupe(card)
  local cards = G.consumeables.cards
  for k, v in pairs(cards) do
    if isDupe(v, card) then
      return v
    end
  end
  return nil
end

function isDupe(a, b)
  return a ~= b
    and a.ability.set == b.ability.set
    and a.config.center_key == b.config.center_key
    and a:getEditionType() == b:getEditionType()
end

function Card:dissolve_stack()
  if self:canSplit() then
    if (self.ability or {}).amt then
      if self.ability.amt > 0 then
        local qty = self:getAmt() - 1
        Saturn.is_splitting = true
        for i = 1, qty do
          G.E_MANAGER:add_event(
            Event({
              delay = easedCurve(i, qty),
              func = function()
                if i % 3 == 0 then
                  play_sound(
                    "card1",
                    1.3 + math.random() * 0.2,
                    0.2 * easedCurve(i, qty, 0.6)
                  )
                end
                if i % 4 == 0 then
                  G.ROOM.jiggle = G.ROOM.jiggle + (easedCurve(i, qty, 0.4))
                  play_sound(
                    "cardSlide1",
                    1.4 + math.random() * 0.2,
                    0.2 * easedCurve(i, qty, 0.6)
                  )
                end
                local card_limit = G.consumeables.config.card_limit
                if (self.edition or {}).negative then
                  card_limit = card_limit + 1
                end
                local new_stack = copy_card(self)
                new_stack.ignoreStack = true
                new_stack:add_to_deck()
                G.consumeables:emplace(new_stack, "front")
                new_stack.ability.amt = 1
                self.ability.amt = (self.ability.amt - new_stack.ability.amt)
                self:set_stack_cost()
                new_stack:set_stack_cost()
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
    end
  end
end

function Card:split(amt)
  if self:canSplit() then
    if (self.ability or {}).amt then
      if self.ability.amt > 0 and self.ability.amt - amt > 0 then
        local card_limit = G.consumeables.config.card_limit
        if (self.edition or {}).negative then
          card_limit = card_limit + 1
        end
        local new_stack = copy_card(self)
        new_stack.ignoreStack = true
        new_stack:add_to_deck()
        G.consumeables:emplace(new_stack)
        new_stack.ability.amt = amt
        self.ability.amt = self.ability.amt - new_stack.ability.amt
        self:set_stack_cost()
        new_stack:set_stack_cost()
        if new_stack.ability.amt >= 2 then
          new_stack:createStackUI()
        end
        G.consumeables.config.card_limit = card_limit
        play_sound("card3", 0.9 + math.random() * 0.1, 0.4)
        return new_stack
      end
    end
  end
end

function easedCurveReversed(k, N, max_value)
  local curve = (k / N) ^ 3
  if max_value and curve > max_value then
    curve = max_value
  end
  return curve
end

function easedCurve(k, N, max_value)
  local curve = (k / N) ^ 3
  if max_value and curve > max_value then
    curve = max_value
  end
  return curve
end

function Card:attemptMergeAll()
  if not self:canStack() then
    return
  end
  local cards = {}
  -- Add all duplicates to table cards
  for k, v in pairs(G.consumeables.cards) do
    if isDupe(v, self) then
      table.insert(cards, v)
    end
  end
  if #cards > 0 then
    self:createStackUI()
    Saturn.is_merging = true
  end
  for k, v in pairs(cards) do
    if not (self:getAmt() < HARD_MAX) then
    else
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
            self:addAmt(math.min(v:getAmt(), (HARD_MAX - self:getAmt())))
            self:set_stack_cost()
            -- Remove card
            if (v:getAmt() - (HARD_MAX - self:getAmt())) < 1 then
              v:remove()
            else
              self.ability.amt = (v:getAmt() - (HARD_MAX - self:getAmt()))
              v:set_stack_cost()
            end
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

function Card:attemptMerge(target, no_dissolve)
  if not self:canStack() then
    return
  end
  target = target or nil
  if target then
    if not isDupe(target, self) then
      target = getDupe(self) or nil
    end
  else
    target = getDupe(self) or nil
  end
  no_dissolve = no_dissolve or false
  if target and (target:getAmt() < HARD_MAX) then
    target:addAmt(math.min(self:getAmt(), (HARD_MAX - target:getAmt())))
    target:createStackUI()
    target:juice_up(0.3, 0.4)
    play_sound("card1", 1.3 + math.random() * 0.2, 0.2)
    target:set_stack_cost()
    if (self:getAmt() - (HARD_MAX - target:getAmt())) < 1 then
      if not no_dissolve then
        self:start_dissolve(nil, true)
      else
        self:remove()
      end
    else
      play_sound("cancel")
      self.ability.amt = (self:getAmt() - (HARD_MAX - target:getAmt()))
      self:set_stack_cost()
    end
  end
end

function Card:massUse()
  local card = self
  -- Get stack amount
  local stack_amt = (card.ability or {}).amt or 1
  if card:canMassUse() and stack_amt > 0 then
    -- CASE: PLANET
    if card.ability.set == "Planet" then
      update_hand_text(
        { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
        {
          handname = localize(
            card.ability.consumeable.hand_type,
            "poker_hands"
          ),
          chips = to_big(
            G.GAME.hands[card.ability.consumeable.hand_type].chips
          ),
          mult = to_big(G.GAME.hands[card.ability.consumeable.hand_type].mult),
          level = to_big(
            G.GAME.hands[card.ability.consumeable.hand_type].level
          ),
        }
      )
      delay(1.3)
      level_up_hand(card, card.ability.consumeable.hand_type, nil, stack_amt)
      update_hand_text(
        { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
        { mult = 0, chips = 0, handname = "", level = "" }
      )
    -- CASE: TAROT
    elseif
      card.ability.set == "Tarot"
      and inTable(CAN_MASS_USE_INDIVIDUAL, card.ability.name)
    then
      local money_total = to_big(G.GAME.dollars)
      stop_use()
      if card.ability.name == "The Hermit" then
        for i = 1, stack_amt do
          money_total = money_total
            + math.max(
              to_big(0),
              math.min(money_total, to_big(card.ability.extra))
            )
        end
        money_total = money_total - to_big(G.GAME.dollars)
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(money_total, true)
            return true
          end,
        }))
        delay(0.6)
      elseif card.ability.name == "Temperance" then
        money_total = to_big(0)
        for i = 1, stack_amt do
          money_total = money_total + to_big(card.ability.money)
        end
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            play_sound("timpani")
            card:juice_up(0.3, 0.5)
            ease_dollars(money_total, true)
            return true
          end,
        }))
        delay(0.6)
      end
    end
    card:remove()
    card:start_dissolve()
  end
end

function Card:massSell()
  local card = self
  local stack_amt = (card.ability or {}).amt or 1
  if card:canStack() and stack_amt > 0 then
    local money_total = card.ability.stack_cost
    stop_use()
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.4,
      func = function()
        play_sound("timpani")
        card:juice_up(0.3, 0.5)
        ease_dollars(money_total, true)
        return true
      end,
    }))
    delay(0.6)
    card:remove()
    card:start_dissolve()
  end
end

local function canPerformActions(skip_check)
  if
    not skip_check
    and (
      (G.play and #G.play.cards > 0)
      or G.CONTROLLER.locked
      or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)
    )
  then
    return false
  end
  if
    G.STATE ~= G.STATES.HAND_PLAYED
    and G.STATE ~= G.STATES.DRAW_TO_HAND
    and G.STATE ~= G.STATES.PLAY_TAROT
  then
    return true
  else
    return false
  end
end

G.FUNCS.can_split_one = function(e)
  local card = e.config.ref_table
  if
    card.highlighted
    and card:canSplit()
    and canPerformActions(nil)
    and (card:getAmt() > 1)
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "split_one"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.split_one = function(e)
  local card = e.config.ref_table
  card:split(1)
end

G.FUNCS.can_split_half = function(e)
  local card = e.config.ref_table
  if
    card.highlighted
    and card:canSplit()
    and canPerformActions(nil)
    and (card:getAmt() > 1)
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "split_half"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.split_half = function(e)
  local card = e.config.ref_table
  card:split(math.floor(card.ability.amt / 2))
end

G.FUNCS.can_merge = function(e)
  local card = e.config.ref_table
  if
    card.highlighted
    and card:canStack()
    and canPerformActions(nil)
    and card:canMerge()
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.DARK_EDITION
    e.config.button = "merge_card"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.can_merge_all = function(e)
  local card = e.config.ref_table
  if
    card.highlighted
    and card:canStack()
    and canPerformActions(nil)
    and card:canMerge()
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.DARK_EDITION
    e.config.button = "merge_all"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.merge_all = function(e)
  local card = e.config.ref_table
  card:attemptMergeAll()
end

G.FUNCS.merge_card = function(e)
  local card = e.config.ref_table
  card:attemptMerge()
end

G.FUNCS.can_mass_use = function(e)
  local card = e.config.ref_table
  if
    canPerformActions(nil)
    and card:canMassUse()
    and (inTable(CAN_MASS_USE, card.ability.set) or inTable(
      CAN_MASS_USE_INDIVIDUAL,
      card.config.center_key
    ))
    and (card:getAmt() > 1)
    and card.highlighted
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.RED
    e.config.button = "mass_use"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.mass_use = function(e)
  local card = e.config.ref_table
  if card:canMassUse() and (card:getAmt() > 1) and card.highlighted then
    card:massUse()
  end
end

G.FUNCS.can_mass_sell = function(e)
  local card = e.config.ref_table
  if
    card.highlighted
    and canPerformActions(nil)
    and (card:getAmt() > 1)
    and not Saturn.is_splitting
    and not Saturn.is_merging
  then
    e.states.visible = true
    e.config.colour = G.C.GREEN
    e.config.button = "mass_sell"
  else
    e.states.visible = false
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
  end
end

G.FUNCS.mass_sell = function(e)
  local card = e.config.ref_table
  card:massSell()
end

local sell_card_ref = Card.sell_card
function Card:sell_card()
  if not self:canStack() then
    return sell_card_ref(self)
  end
  if not (self:getAmt() > 1) then
    return sell_card_ref(self)
  end
  local sell_card = self:split(1)
  sell_card:sell_card()
  self:highlight(true)
end

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  add_to_deck_ref(self, from_debuff)
  if G.consumeables then
    if self:canStack() then
      self.ability.amt = 1
      if not self.ignoreStack then
        if self:canMerge() and Saturn.config.enable_stacking then
          G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.1,
            func = function()
              self:attemptMerge(nil, true)
              return true
            end,
          }))
        end
      end
    end
  end
end

local use_card_ref = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
  local card = e.config.ref_table
  if ((card.ability or {}).amt or 1) > 1 then
    card.highlighted = false
    local split = card:split(1)
    e.config.ref_table = split
  end
  if e then
    use_card_ref(e, mute, nosave)
  else
    print("Error trying to use consumeable")
  end
end

local load_ref = Card.load
function Card:load(cardTable, other_card)
  load_ref(self, cardTable, other_card)
  if self.ability then
    if self.ability.amt then
      self:createStackUI()
    end
  end
end

G.FUNCS.disable_stack_ui = function(e)
  local card = e.config.ref_table
  if card:getAmt() > 1 then
    e.states.visible = true
  else
    e.states.visible = false
  end
end

function Card:createStackUI()
  local tcm = {
    ["Planet"] = G.C.MONEY,
    ["Tarot"] = lighten(G.C.SECONDARY_SET.Planet, 0.3),
    ["Spectral"] = lighten(G.C.GREEN, 0.3),
  }
  local colour = tcm[self.ability.set] or G.C.GREEN
  if not self.children.stack_ui and self:canStack() then
    self.children.stack_ui = UIBox({
      definition = {
        n = G.UIT.ROOT,
        config = {
          align = "cm",
          colour = G.C.CLEAR,
          shadow = true,
          func = "disable_stack_ui",
          ref_table = self,
        },
        nodes = {
          {
            n = G.UIT.R,
            config = {
              align = "cm",
              minh = 0.3,
              maxh = 1,
              minw = 0.5,
              maxw = 1.5,
              padding = 0.1,
              r = 0.02,
              colour = HEX("22222266"),
              res = 0.5,
            },
            nodes = {
              {
                n = G.UIT.O,
                config = {
                  object = DynaText({
                    string = {
                      {
                        prefix = "+",
                        ref_table = self.ability,
                        ref_value = "amt",
                      },
                    },
                    colours = { colour },
                    shadow = true,
                    silent = true,
                    bump = true,
                    pop_in = 0.2,
                    scale = 0.4,
                  }),
                },
              },
            },
          },
        },
      },
      config = {
        align = "cm",
        bond = "Strong",
        parent = self,
        offset = {
          x = -0.7,
          y = 1.2,
        },
      },
      states = {
        collide = { can = false },
        drag = { can = true },
      },
    })
  end
end

function G.UIDEF.mass_use_and_sell(card)
  local use = {
    n = G.UIT.C,
    config = { align = "cl" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          ref_table = card,
          align = "cl",
          maxw = 1.25,
          padding = 0.1,
          r = 0.08,
          minw = 1.25,
          minh = (card.area and card.area.config.type == "joker") and 0 or 1,
          hover = true,
          shadow = true,
          colour = G.C.UI.BACKGROUND_INACTIVE,
          one_press = true,
          button = "mass_use",
          func = "can_mass_use",
        },
        nodes = {
          {
            n = G.UIT.C,
            config = {
              align = "cm",
            },
            nodes = {
              {
                n = G.UIT.R,
                config = {
                  align = "cm",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = "USE ALL",
                      colour = G.C.UI.TEXT_LIGHT,
                      scale = 0.3,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = {
                  align = "cr",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                      align = "cm",
                      minw = 0.3,
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = "(",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          ref_table = card.ability,
                          ref_value = "amt",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = ")",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
        },
      },
    },
  }
  local sell = {
    n = G.UIT.C,
    config = { align = "cl" },
    nodes = {
      {
        n = G.UIT.C,
        config = {
          ref_table = card,
          align = "cl",
          padding = 0.1,
          r = 0.08,
          minw = 1.25,
          hover = true,
          shadow = true,
          colour = G.C.UI.BACKGROUND_INACTIVE,
          one_press = true,
          button = "mass_sell",
          func = "can_mass_sell",
        },
        nodes = {
          {
            n = G.UIT.C,
            config = {
              align = "cm",
            },
            nodes = {
              {
                n = G.UIT.R,
                config = {
                  align = "cm",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.T,
                    config = {
                      text = "SELL ALL",
                      colour = G.C.UI.TEXT_LIGHT,
                      scale = 0.3,
                      shadow = true,
                    },
                  },
                },
              },
              {
                n = G.UIT.R,
                config = {
                  align = "cr",
                  maxw = 1.25,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = {
                      align = "cm",
                      minw = 0.3,
                    },
                    nodes = {
                      {
                        n = G.UIT.T,
                        config = {
                          text = "(",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = localize("$"),
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          ref_table = card.ability,
                          ref_value = "stack_cost_label",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                      {
                        n = G.UIT.T,
                        config = {
                          text = ")",
                          colour = darken(G.C.UI.TEXT_LIGHT, 0.2),
                          scale = 0.25,
                          shadow = true,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
        },
      },
    },
  }

  local t = {
    n = G.UIT.ROOT,
    config = { padding = 0, colour = G.C.CLEAR },
    nodes = {
      {
        n = G.UIT.C,
        config = { padding = 0.15, align = "cl" },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = {
              sell,
            },
          },
          {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = {
              use,
            },
          },
        },
      },
    },
  }
  return t
end

function G.UIDEF.button_merge(card)
  local merge = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "merge_card",
      func = "can_merge",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "MERGE",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return merge
end

function G.UIDEF.button_merge_all(card)
  local merge = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "merge_all",
      func = "can_merge_all",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "MERGE ALL",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return merge
end

function G.UIDEF.button_split_one(card)
  local t = {
    n = G.UIT.C,
    config = {
      align = "cm",
      ref_table = card,
      minh = 0.3,
      maxh = 0.6,
      minw = 0.3,
      maxw = 4,
      r = 0.01,
      padding = 0.1,
      colour = G.C.DARK_EDITION,
      shadow = true,
      button = "split_one",
      func = "can_split_one",
    },
    nodes = {
      {
        n = G.UIT.T,
        config = {
          text = "SPLIT ONE",
          scale = 0.3,
          colour = G.C.UI.TEXT_LIGHT,
        },
      },
    },
  }
  return t
end

local highlight_ref = Card.highlight
function Card:highlight(is_highlighted)
  if self:canStack() and self.added_to_deck then
    if is_highlighted then
      self.children.stack_actions_button = UIBox({
        definition = G.UIDEF.mass_use_and_sell(self),
        config = {
          align = "cl",
          offset = {
            x = 0.6,
            y = 0,
          },
          parent = self,
        },
      })
      local y = 0
      if self:canSplit() then
        y = y + 0.5
        self.children.split_one_button = UIBox({
          definition = {
            n = G.UIT.ROOT,
            config = {
              padding = 0,
              colour = G.C.CLEAR,
            },
            nodes = {
              G.UIDEF.button_split_one(self),
            },
          },
          config = {
            align = "bmi",
            offset = {
              x = 0,
              y = y,
            },
            bond = "Strong",
            parent = self,
          },
        })
      end
      if self:canMerge() then
        y = y + 0.5
        self.children.merge_button = UIBox({
          definition = {
            n = G.UIT.ROOT,
            config = {
              padding = 0,
              colour = G.C.CLEAR,
            },
            nodes = {
              G.UIDEF.button_merge(self),
            },
          },
          config = {
            align = "bmi",
            offset = {
              x = 0,
              y = y,
            },
            bond = "Strong",
            parent = self,
          },
        })
      end
      if self:canMerge() then
        y = y + 0.5
        self.children.merge_all_button = UIBox({
          definition = {
            n = G.UIT.ROOT,
            config = {
              padding = 0,
              colour = G.C.CLEAR,
            },
            nodes = {
              G.UIDEF.button_merge_all(self),
            },
          },
          config = {
            align = "bmi",
            offset = {
              x = 0,
              y = y,
            },
            bond = "Strong",
            parent = self,
          },
        })
      end
      if self:canSplit() then
        --TODO: SPLIT HALF BUTTON
      end
    else
      if self.children.stack_actions_button then
        self.children.stack_actions_button:remove()
        self.children.stack_actions_button = nil
      end
      if self.children.merge_button then
        self.children.merge_button:remove()
        self.children.merge_button = nil
      end
      if self.children.merge_all_button then
        self.children.merge_all_button:remove()
        self.children.merge_all_button = nil
      end
      if self.children.split_one_button then
        self.children.split_one_button:remove()
        self.children.split_one_button = nil
      end
      if self.children.split_half_button then
        self.children.split_half_button:remove()
        self.children.split_half_button = nil
      end
    end
  end
  return highlight_ref(self, is_highlighted)
end
