function Saturn.hide_played_cards(deck_tables, unplayed_only)
  if not Saturn.config.hide_played or not unplayed_only then
    return
  end

  local areas = {}
  local cards_to_remove = {}
  for _, v in ipairs(deck_tables) do
    local area = v.nodes[1].config.object
    table.insert(areas, area)
    for _, card in ipairs(area.cards) do
      if card.greyed then
        table.insert(cards_to_remove, card)
      end
    end
  end

  for _, card in ipairs(cards_to_remove) do
    card:remove()
  end

  for _, area in ipairs(areas) do
    -- Work DAMN YOU!
    area.config.card_limit = #area.cards
    area.config.card_count = #area.cards
    area:calculate_parrallax()
    area:align_cards()
    area:hard_set_cards()
  end
end
