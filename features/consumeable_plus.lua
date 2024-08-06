-- Modified version of https://github.com/jenwalter666/Incantation/blob/6787c7312d595b3a1a87e155428b9a9742693045/Incantation.lua

Stacker = { consumable_in_use = false, accelerate = false }

local MaxStack = 9999
local BulkUseLimit = 9999
local NaiveBulkUseCancel = 50
local AccelerateThreshold = 3
local UseStackCap = false
local UseBulkCap = false
local UnsafeMode = false

local HardLimit = 9007199254740992

local function tablecontains(haystack, needle)
  for k, v in pairs(haystack) do
    if v == needle then
      return true
    end
  end
  return false
end

local Stackable = {
  "Planet",
  "Tarot",
  "Spectral",
}

local StackableIndividual = {
  "c_black_hole",
}

local Divisible = {
  "Planet",
  "Tarot",
  "Spectral",
}

local DivisibleIndividual = {
  "c_black_hole",
}

local BulkUsable = {
  "Planet",
}

local BulkUsableIndividual = {
  "c_black_hole",
}


function Card:getQty()
  return (self.ability or {}).qty or 1
end

function Card:setQty(quantity)
  if self:CanStack() then
    if self.ability then
      self.ability.qty = math.min(HardLimit, math.floor(quantity))
      self:create_stack_display()
      self:set_cost()
    end
  end
end

function Card:addQty(quantity)
  self:setQty(self:getQty() + math.floor(quantity))
end

function Card:subQty(quantity, dont_dissolve)
  if quantity >= self:getQty() and not dont_dissolve then
    self:setQty(0)
    self.ignorestacking = true
    self:start_dissolve()
  else
    self:setQty(math.max(0, self:getQty() + math.ceil(quantity)))
  end
end

function Card:CanStack()
  return (self.config.center and self.config.center.can_stack)
    or tablecontains(Stackable, self.ability.set)
    or tablecontains(StackableIndividual, self.config.center_key)
end

function Card:CanDivide()
  return (self.config.center and self.config.center.can_divide)
    or tablecontains(Divisible, self.ability.set)
    or tablecontains(DivisibleIndividual, self.config.center_key)
end

function Card:CanBulkUse(ignoreunsafe)
  return (not ignoreunsafe and UnsafeMode)
    or (self.config.center and (self.config.center.can_bulk_use or (self.config.center.bulk_use and (type(
      self.config.center.bulk_use
    ) == "function"))))
    or tablecontains(BulkUsable, self.ability.set)
    or tablecontains(BulkUsableIndividual, self.config.center_key)
end

function Card:getmaxuse()
  return (self.config.center.bulk_use_limit or UseBulkCap)
      and math.min((self.config.center.bulk_use_limit or BulkUseLimit), self:getQty())
    or (self:getQty())
end

function set_consumeable_usage(card, qty)
  qty = math.floor(qty or 1)
  if card.config.center_key and card.ability.consumeable then
    if G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key] then
      G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count = G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count
        + qty
    else
      G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key] =
        { count = 1, order = card.config.center.order }
    end
    if G.GAME.consumeable_usage[card.config.center_key] then
      G.GAME.consumeable_usage[card.config.center_key].count = G.GAME.consumeable_usage[card.config.center_key].count
        + qty
    else
      G.GAME.consumeable_usage[card.config.center_key] =
        { count = 1, order = card.config.center.order, set = card.ability.set }
    end
    G.GAME.consumeable_usage_total = G.GAME.consumeable_usage_total
      or { tarot = 0, planet = 0, spectral = 0, tarot_planet = 0, all = 0 }
    if card.config.center.set == "Tarot" then
      G.GAME.consumeable_usage_total.tarot = G.GAME.consumeable_usage_total.tarot + qty
      G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet + qty
    elseif card.config.center.set == "Planet" then
      G.GAME.consumeable_usage_total.planet = G.GAME.consumeable_usage_total.planet + qty
      G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet + qty
    elseif card.config.center.set == "Spectral" then
      G.GAME.consumeable_usage_total.spectral = G.GAME.consumeable_usage_total.spectral + qty
    end

    G.GAME.consumeable_usage_total.all = G.GAME.consumeable_usage_total.all + qty

    if not card.config.center.discovered then
      discover_card(card)
    end

    if card.config.center.set == "Tarot" or card.config.center.set == "Planet" then
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

function Card:split(amount, forced)
  if not amount then
    amount = math.floor((self:getQty()) / 2)
  end
  amount = math.max(1, amount)
  if (self.ability.qty or 0) > 1 and (self:CanDivide() or forced) and not self.ignorestacking then
    local traysize = G.consumeables.config.card_limit
    if (self.edition or {}).negative then
      traysize = traysize + 1
    end
    local split = copy_card(self)
    local qty2 = math.min(self.ability.qty - 1, amount)
    G.consumeables.config.card_limit = #G.consumeables.cards + 1
    split.config.ignorestacking = true
    split.created_from_split = true
    split:add_to_deck()
    G.consumeables:emplace(split)
    split.ability.qty = qty2
    self.ability.qty = self.ability.qty - qty2
    G.consumeables.config.card_limit = traysize
    if qty2 > 1 then
      split:create_stack_display()
    end
    split:set_cost()
    self:set_cost()
    play_sound("card1")
    return split
  end
end

function Card:try_merge()
  if self:CanStack() and not self.ignorestacking then
    if not self.edition then
      self.edition = {}
    end
    for k, v in pairs(G.consumeables.cards) do
      if not v.edition then
        v.edition = {}
      end
      if
        v ~= self
        and not v.nomerging
        and not v.ignorestacking
        and v.config.center_key == self.config.center_key
        and ((v.edition.type or "") == (self.edition.type or ""))
        and (v:getQty() < (UseStackCap and MaxStack or HardLimit))
      then
        local space = (UseStackCap and MaxStack or HardLimit) - (v:getQty())
        v.ability.qty = (v:getQty()) + math.min((self:getQty()), space)
        v:create_stack_display()
        v:juice_up(0.5, 0.5)
        play_sound("card1")
        v:set_cost()
        if (self:getQty()) - space < 1 then
          self.ignorestacking = true
          self:start_dissolve()
          break
        else
          self.ability.qty = (self:getQty()) - space
          self:set_cost()
        end
      end
    end
  end
end

local useconsumeref = Card.use_consumeable
function Card:use_consumeable(area, copier)
  local obj = self.config.center
  local qty = self:getQty()
  if not self.naivebulkuse and self.bulkuse and obj.bulk_use and type(obj.bulk_use) == "function" then
    set_consumeable_usage(self, qty)
    return obj:bulk_use(self, area, copier, qty)
  elseif not self.naivebulkuse and self.ability.consumeable.hand_type then
    update_hand_text(
      { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
      {
        handname = localize(self.ability.consumeable.hand_type, "poker_hands"),
        chips = G.GAME.hands[self.ability.consumeable.hand_type].chips,
        mult = G.GAME.hands[self.ability.consumeable.hand_type].mult,
        level = G.GAME.hands[self.ability.consumeable.hand_type].level,
      }
    )
    level_up_hand(copier or self, self.ability.consumeable.hand_type, nil, qty)
    update_hand_text(
      { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
      { mult = 0, chips = 0, handname = "", level = "" }
    )
    set_consumeable_usage(self, qty)
  elseif not self.naivebulkuse and self.ability.name == "Black Hole" then
    update_hand_text(
      { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
      { handname = localize("k_all_hands"), chips = "...", mult = "...", level = "" }
    )
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.2,
      func = function()
        play_sound("tarot1")
        self:juice_up(0.8, 0.5)
        G.TAROT_INTERRUPT_PULSE = true
        return true
      end,
    }))
    update_hand_text({ delay = 0 }, { mult = "+", StatusText = true })
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.9,
      func = function()
        play_sound("tarot1")
        self:juice_up(0.8, 0.5)
        return true
      end,
    }))
    update_hand_text({ delay = 0 }, { chips = "+", StatusText = true })
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.9,
      func = function()
        play_sound("tarot1")
        self:juice_up(0.8, 0.5)
        G.TAROT_INTERRUPT_PULSE = nil
        return true
      end,
    }))
    update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = "+" .. qty })
    delay(1.3)
    for k, v in pairs(G.GAME.hands) do
      level_up_hand(self, k, true, qty)
    end
    update_hand_text(
      { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
      { mult = 0, chips = 0, handname = "", level = "" }
    )
    set_consumeable_usage(self, qty)
  else
    Stacker.accelerate = qty > AccelerateThreshold
    self.cardinuse = true
    Stacker.consumable_in_use = true
    local lim = math.min(qty, NaiveBulkUseCancel)
    local newqty = math.max(0, qty - lim)
    if not self.ability.qty then
      self.ability.qty = 1
    end
    for i = 1, lim do
      useconsumeref(self, area, copier)
      G.E_MANAGER:add_event(Event({
        trigger = "immediate",
        delay = 0.1,
        blockable = true,
        func = function()
          self.ability.qty = self.ability.qty - 1
          play_sound("button", self.ability.qty <= 0 and 1 or 0.85, 0.7)
          return true
        end,
      }))
    end
    G.E_MANAGER:add_event(Event({
      trigger = "after",
      delay = 0.1,
      blockable = true,
      func = function()
        Stacker.consumable_in_use = false
        Stacker.accelerate = false
        if obj.keep_on_use and obj:keep_on_use(self) then
          self.ignorestacking = false
          self.ability.qty = obj.keep_on_use_retain_stack and qty or (newqty + 1)
        else
          if newqty > 0 then
            self:split(newqty, true)
          end
          self:start_dissolve()
        end
        return true
      end,
    }))
  end
end

local startdissolveref = Card.start_dissolve
function Card:start_dissolve(a, b, c, d)
  if self.ability.qty and self.ability.qty > 1 and Stacker.consumable_in_use then
    return
  end
  self.ignorestacking = true
  return startdissolveref(self, a, b, c, d)
end

local usecardref = G.FUNCS.use_card

function CanUseStackButtons()
  if
    ((G.play and #G.play.cards > 0) or G.CONTROLLER.locked or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))
    and G.STATE ~= G.STATES.HAND_PLAYED
    and G.STATE ~= G.STATES.DRAW_TO_HAND
    and G.STATE ~= G.STATES.PLAY_TAROT
  then
    return false
  end
  return true
end

G.FUNCS.use_card = function(e, mute, nosave)
  local card = e.config.ref_table
  local fallback = e.config.ref_table
  local useamount = card.bulkuse and card:getmaxuse() or 1
  if ((card.ability or {}).qty or 1) > useamount then
    card.highlighted = false
    card.bulkuse = false
    local split = card:split(useamount, true)
    if card.naivebulkuse then
      split.naivebulkuse = true
      card.naivebulkuse = false
    end
    e.config.ref_table = split
  end
  if e then
    usecardref(e, mute, nosave)
  elseif fallback then
    usecardref(fallback, mute, nosave)
  else
    print("Problem trying to use consumable, corrupted data?")
  end
end

G.FUNCS.can_split_half = function(e)
  local card = e.config.ref_table
  if (card:getQty()) > 1 and card.highlighted and CanUseStackButtons() and not card.ignorestacking then
    e.config.colour = G.C.PURPLE
    e.config.button = "split_half"
    e.states.visible = true
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.states.visible = false
  end
end

G.FUNCS.can_split_one = function(e)
  local card = e.config.ref_table
  if (card:getQty()) > 1 and card.highlighted and CanUseStackButtons() and not card.ignorestacking then
    e.config.colour = G.C.GREEN
    e.config.button = "split_one"
    e.states.visible = true
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.states.visible = false
  end
end

function Card:MergeAvailable()
  if not self.edition then
    self.edition = {}
  end
  for k, v in pairs(G.consumeables.cards) do
    if v then
      if not v.edition then
        v.edition = {}
      end
      if
        v ~= self
        and (v.config or {}).center_key == (self.config or {}).center_key
        and (v.edition.type or "") == (self.edition.type or "")
      then
        return true
      end
    end
  end
end

G.FUNCS.can_merge_card = function(e)
  local card = e.config.ref_table
  if
    card:CanStack()
    and card.highlighted
    and not card.ignorestacking
    and CanUseStackButtons()
    and card:MergeAvailable()
  then
    e.config.colour = G.C.SECONDARY_SET.Planet
    e.config.button = "merge_card"
    e.states.visible = true
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.states.visible = true
  end
end

G.FUNCS.can_use_all = function(e)
  local card = e.config.ref_table
  local obj = card.config.center
  if
    card:CanBulkUse()
    and ((tablecontains(BulkUsable, card.ability.set) or tablecontains(BulkUsableIndividual, card.config.center_key)) or (obj.bulk_use and type(
      obj.bulk_use
    ) == "function"))
    and (card:getQty()) > 1
    and card.highlighted
    and CanUseStackButtons()
    and not card.ignorestacking
  then
    e.config.colour = G.C.DARK_EDITION
    e.config.button = "use_all"
    e.states.visible = true
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.states.visible = false
  end
end

G.FUNCS.can_use_naivebulk = function(e)
  local card = e.config.ref_table
  local obj = card.config.center
  if
    (card:CanBulkUse() or UnsafeMode)
    and (UnsafeMode or not obj.bulk_use or type(obj.bulk_use) ~= "function")
    and (card:getQty()) > 1
    and card.highlighted
    and CanUseStackButtons()
    and not card.ignorestacking
  then
    e.config.colour = G.C.BLACK
    e.config.button = "use_naivebulk"
    e.states.visible = true
  else
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = nil
    e.states.visible = false
  end
end

G.FUNCS.split_half = function(e)
  local card = e.config.ref_table
  card:split(math.floor(card.ability.qty / 2))
end

G.FUNCS.split_one = function(e)
  local card = e.config.ref_table
  card:split(1)
end

G.FUNCS.merge_card = function(e)
  local card = e.config.ref_table
  card:try_merge()
end

G.FUNCS.use_all = function(e)
  local card = e.config.ref_table
  local obj = card.config.center
  if card:CanBulkUse() and (not obj.can_use or obj:can_use(card)) and (card:getQty()) > 1 and card.highlighted then
    card.bulkuse = true
    G.FUNCS.use_card(e, false, true)
  end
end

G.FUNCS.use_naivebulk = function(e)
  local card = e.config.ref_table
  local obj = card.config.center
  if
    card:CanBulkUse()
    and (not obj.can_use or obj:can_use(card))
    and (card:getQty()) > 1
    and card.highlighted
    and UnsafeMode
  then
    card.naivebulkuse = true
    card.bulkuse = true
    G.FUNCS.use_card(e, false, true)
  end
end

G.FUNCS.disablestackdisplay = function(e)
  local card = e.config.ref_table
  e.states.visible = ((card:getQty()) > 1 and not card.ignorestacking) or card.cardinuse
end

function Card:create_stack_display()
  if not self.children.stackdisplay and self:CanStack() then
    self.children.stackdisplay = UIBox({
      definition = {
        n = G.UIT.ROOT,
        config = {
          minh = 0.6,
          maxh = 1.2,
          minw = 0.5,
          maxw = 2,
          r = 0.001,
          padding = 0.1,
          align = "cm",
          colour = G.C.SECONDARY_SET.Planet,
          shadow = false,
          func = "disablestackdisplay",
          ref_table = self,
        },
        nodes = {
          {
            n = G.UIT.T,
            config = {
              text = "x",
              scale = 0.4,
              colour = G.C.UI.TEXT_LIGHT,
            },
          },
          {
            n = G.UIT.T,
            config = {
              ref_table = self.ability,
              ref_value = "qty",
              scale = 0.4,
              colour = G.C.UI.TEXT_LIGHT,
            },
          },
        },
      },
      config = {
        align = "tm",
        bond = "Strong",
        parent = self,
      },
      states = {
        collide = { can = false },
        drag = { can = true },
      },
    })
  end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
  card_load_ref(self, cardTable, other_card)
  if self.ability then
    if self.ability.qty then
      self:create_stack_display()
    end
  end
end

local deckadd = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  deckadd(self, from_debuff)
  if G.consumeables then
    if self:CanStack() then
      if not self.config.ignorestacking then
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.1,
          blocking = false,
          func = function()
            if self and self.area and self.area ~= "shop" and self.area ~= "pack_cards" then
              self:try_merge()
            end
            return true
          end,
        }))
      end
      self.config.ignorestacking = nil
    end
  end
end

local hlref = Card.highlight
function Card:highlight(is_highlighted)
  if self:CanStack() and self.added_to_deck and not self.ignorestacking then
    if is_highlighted then
      self.children.splithalfbutton = UIBox({
        definition = {
          n = G.UIT.ROOT,
          config = {
            minh = 0.3,
            maxh = 0.6,
            minw = 0.3,
            maxw = 4,
            r = 0.08,
            padding = 0.1,
            align = "cm",
            colour = G.C.SECONDARY_SET.Planet,
            shadow = true,
            button = "split_half",
            func = "can_split_half",
            ref_table = self,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = "SPLIT HALF",
                scale = 0.3,
                colour = G.C.UI.TEXT_LIGHT,
              },
            },
          },
        },
        config = {
          align = "bmi",
          offset = {
            x = 0,
            y = 0.5,
          },
          bond = "Strong",
          parent = self,
        },
      })
      self.children.splitonebutton = UIBox({
        definition = {
          n = G.UIT.ROOT,
          config = {
            minh = 0.3,
            maxh = 0.6,
            minw = 0.3,
            maxw = 4,
            r = 0.08,
            padding = 0.1,
            align = "cm",
            colour = G.C.SECONDARY_SET.Planet,
            shadow = true,
            button = "split_one",
            func = "can_split_one",
            ref_table = self,
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
        },
        config = {
          align = "bmi",
          offset = {
            x = 0,
            y = 1,
          },
          bond = "Strong",
          parent = self,
        },
      })
      self.children.mergebutton = UIBox({
        definition = {
          n = G.UIT.ROOT,
          config = {
            minh = 0.3,
            maxh = 0.6,
            minw = 0.3,
            maxw = 4,
            r = 0.08,
            padding = 0.1,
            align = "cm",
            colour = G.C.SECONDARY_SET.Planet,
            shadow = true,
            button = "merge_card",
            func = "can_merge_card",
            ref_table = self,
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
        },
        config = {
          align = "bmi",
          offset = {
            x = 0,
            y = 1.5,
          },
          bond = "Strong",
          parent = self,
        },
      })
      self.children.useallbutton = UIBox({
        definition = {
          n = G.UIT.ROOT,
          config = {
            minh = 0.3,
            maxh = 0.6,
            minw = 0.3,
            maxw = 4,
            r = 0.08,
            padding = 0.1,
            align = "cm",
            colour = G.C.SECONDARY_SET.Planet,
            shadow = true,
            button = "use_all",
            func = "can_use_all",
            ref_table = self,
          },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                text = "BULK USE" .. (UnsafeMode and " (NORMAL)" or ""),
                scale = 0.3,
                colour = G.C.UI.TEXT_LIGHT,
              },
            },
          },
        },
        config = {
          align = "bmi",
          offset = {
            x = 0,
            y = 2,
          },
          bond = "Strong",
          parent = self,
        },
      })
      if UnsafeMode then
        self.children.useallnaivebutton = UIBox({
          definition = {
            n = G.UIT.ROOT,
            config = {
              minh = 0.3,
              maxh = 0.6,
              minw = 0.3,
              maxw = 4,
              r = 0.08,
              padding = 0.1,
              align = "cm",
              colour = G.C.BLACK,
              shadow = true,
              button = "use_naivebulk",
              func = "can_use_naivebulk",
              ref_table = self,
            },
            nodes = {
              {
                n = G.UIT.T,
                config = {
                  text = "BULK USE (ONE-AT-A-TIME)",
                  scale = 0.3,
                  colour = G.C.RED,
                },
              },
            },
          },
          config = {
            align = "bmi",
            offset = {
              x = 0,
              y = 2.5,
            },
            bond = "Strong",
            parent = self,
          },
        })
      end
    else
      if self.children.splithalfbutton then
        self.children.splithalfbutton:remove()
        self.children.splithalfbutton = nil
      end
      if self.children.splitonebutton then
        self.children.splitonebutton:remove()
        self.children.splitonebutton = nil
      end
      if self.children.mergebutton then
        self.children.mergebutton:remove()
        self.children.mergebutton = nil
      end
      if self.children.useallbutton then
        self.children.useallbutton:remove()
        self.children.useallbutton = nil
      end
      if UnsafeMode then
        if self.children.useallnaivebutton then
          self.children.useallnaivebutton:remove()
          self.children.useallnaivebutton = nil
        end
      end
    end
  end
  return hlref(self, is_highlighted)
end

local costref = Card.set_cost
function Card:set_cost()
  costref(self)
  self.sell_cost = self.sell_cost * ((self.ability or {}).qty or 1)
  self.sell_cost_label = self.facing == "back" and "?" or self.sell_cost
end

