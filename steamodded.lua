if Saturn then
  Saturn.current_mod = SMODS.current_mod
end

SMODS.Voucher:take_ownership("observatory", {
  calculate = function(self, card, context)
    if
      context.other_consumeable
      and context.other_consumeable.ability.set == "Planet"
      and context.other_consumeable.ability.consumeable.hand_type
        == context.scoring_name
    then
      return {
        x_mult = card.ability.extra
          ^ (context.other_consumeable.ability.amt or 1),
        message_card = context.other_consumeable,
      }
    end
  end,
}, true)

if (SMODS.Mods["Pokermon"] or {}).can_load then
  SMODS.Joker:take_ownership("poke_mega_alakazam", {
    calculate = function(self, card, context)
      if context.other_consumeable then
        local Xmult = nil
        if context.other_consumeable.ability.name == "twisted_spoon" then
          Xmult = card.ability.extra.Xmult_multi2
            ^ (context.other_consumeable.ability.amt or 1)
        else
          Xmult = card.ability.extra.Xmult_multi
            ^ (context.other_consumeable.ability.amt or 1)
        end
        return {
          message = localize({
            type = "variable",
            key = "a_xmult",
            vars = { Xmult },
          }),
          colour = G.C.XMULT,
          Xmult_mod = Xmult,
        }
      end
    end,
  }, true)
end
