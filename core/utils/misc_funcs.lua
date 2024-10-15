function isActionable(skip_check)
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

function easedCurve(k, N, max_value, reversed)
  reversed = reversed or false
  local curve
  if reversed then
    curve = (k / N) ^ 3
    if max_value and curve > max_value then
      curve = max_value
    end
  else
    curve = (k / N) ^ 3
    if max_value and curve > max_value then
      curve = max_value
    end
  end
  return curve
end

function getCopy(card)
  local cards = G.consumeables.cards
  for k, v in pairs(cards) do
    if isCopy(v, card) then
      return v
    end
  end
  return nil
end

function isCopy(a, b)
  a.edition = a.edition or {}
  b.edition = b.edition or {}
  return a ~= b
    and a.ability.set == b.ability.set
    and a.config.center_key == b.config.center_key
    and (a.edition.type or "") == (b.edition.type or "")
end
