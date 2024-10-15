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

Stack = {}
Stack.MAX_SIZE = 9999

function Stack:new(o, card)
  o = o or {} -- Create new obj if not provided with one
  setmetatable(o, self)
  self.__index = self
  self.card = card
  self.stack = {}
  return o
end

function Stack:pushId(id)
  -- Push sort_id to stack
  table.insert(self.stack, #self.stack + 1, id)
end

function Stack:popId()
  -- Pop last sort_id added
  local sort_id = table.remove(self.stack, #self.stack)
  return sort_id
end

-- Constructs new card object with specific sort_id
-- @param sort_id int
-- @return card obj
function Stack:constructCard(sort_id)
  local card = copy_card(self.card)
  card.sort_id = sort_id
  return card
end

function Stack:getSize()
  -- stack size + orignial card
  return #self.stack + 1
end

------
local ref = {}

function Card:shouldInit() end

function Card:pushToStack(card)
  local sort_id = card.sort_id
  self.stack.pushId(sort_id)
end

function Card:dissolveStack()
  self:shouldInit()
  if self:canSplit() then
    local size = self.stack:getSize()
    if size > 1 then
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
              local new_card = self.stack:popId()
              new_card = self.stack:constructCard(new_card)
              new_card.ignoreStack = true
              new_card:add_to_deck()
              G.consumeables:emplace(new_card, "front")
              --TODO: self:setStackCost()
              --TODO: new_card:setStackCost()
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
            Saturn.is_splitting = true
            return true
          end,
        }),
        "other"
      )
    end
  end
end

function Card:tryMergeAll() end

function Card:tryMerge() end

function Card:massUse() end

function Card:massSell() end

function Card:split(n)
  self.shouldInit()
  if self:canSplit() then
  end
end

---CHECKS
function Card:canStack()
  return inTable(CAN_STACK, self.ability.set) and (self.edition or {}).type == "negative"
end

function Card:canSplit()
  return inTable(CAN_STACK, self.ability.set)
end

function Card:canMerge()
  local can_merge = false
  self.edition = self.edition or {}
  for k, v in pairs(G.consumeables.cards) do
    if v then
      v.edition = v.edition or {}
      if v ~= self and isDupe(self, v) then
        can_merge = true
        break
      end
    end
  end
  return can_merge
end

function Card:canMassUse()
  return (inTable(CAN_MASS_USE, self.ability.set) or inTable(CAN_MASS_USE_INDIVIDUAL, self.config.center_key))
end

ref.load = Card.load
function Card:load(cardTable, other_card)
  ref.load(self, cardTable, other_card)
  if self.stack then
    if self.stack:getSize() > 1 then
      self:createStackUI()
    end
  end
end

ref.sell_card = Card.sell_card
function Card:sell_card()
  if not self:canStack() then
    return ref.sell_card(self)
  end
  local sell_card = self:split(1)
  if sell_card then
    sell_card:sell_card()
  end
  self:highlight(true)
end

ref.add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
  ref.add_to_deck(self, from_debuff)
  if G.consumeables then
    if self:canStack() then
      -- Initialize stack
      self.stack = Stack:new(nil, self)
      if not self.ignoreStack then
        if self:canMerge() and Saturn.config.enable_stacking then
          G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.1,
            func = function()
              self:tryMerge(nil, true)
              return true
            end,
          }))
        end
      end
    end
  end
end

ref.use_card = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
  local card = e.config.ref_table
  if (card.stack or {}):getSize() > 1 then
    card.highlighted = false
    local split = card:split(1)
    e.config.ref_table = split
  end
  if e then
    ref.use_card(e, mute, nosave)
  else
    error("Error trying to use consumeable")
  end
end

ref.highlight = Card.highlight
function Card:highlight(is_highlighted)
  return ref.highlight(self, is_highlighted)
end

--TODO: restructure Stack sell-cost mechanic

function Card:createStackUI() end
