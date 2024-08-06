G.FUNCS.retry_challenge = function(e)
  G.GAME.viewed_back = nil
  G.run_setup_seed = G.GAME.seeded
  G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
  G.forced_seed, G.setup_seed = nil, nil
  if G.GAME.seeded then
    G.forced_seed = G.GAME.pseudorandom.seed
  end
  local current_stake = G.GAME.stake
  local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
  local _challenge = G.challenge_tab
  if not G.challenge_tab then
    _stake = current_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
  else
    _stake = 1
  end
  G:delete_run()
  G:start_run({ stake = _stake, seed = _seed, challenge = _challenge })
end

