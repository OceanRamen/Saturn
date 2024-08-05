local lovely = require("lovely")
local nativefs = require("nativefs")

function Saturn:start_reroll(joker, edition)
	self.REROLL = {}
	self.REROLL.frames = 600
	self.REROLL.interval = 0.01
	self.REROLL.timer = 0
	self.REROLL.seeds = 0
	self.REROLL.elapsed = os.clock()

	self.REROLL.joker = joker
	self.REROLL.edition = edition or nil
	if joker:lower() == 'perkeo' or
	joker:lower() == 'caino' or
	joker:lower() == 'yorick' or
	joker:lower() == 'triboulet' or
	joker:lower() == 'chicot' then
		self.REROLL.type = 'leg'
	else
    self.REROLL.type = 'jok'
  end
	if edition then
			self.REROLL.type = self.REROLL.type .. 'edi'
	end
	self.REROLL.active = true
	self:log_console('rerolling for ' .. ((self.REROLL.edition ~= nil and self.REROLL.edition .. ' ') or '' ) .. self.REROLL.joker)
	self:reroll()
end

function Saturn:update_reroll(dt)
	self.REROLL.timer = self.REROLL.timer + dt
	if self.REROLL.timer >= self.REROLL.interval then
		self.REROLL.timer = self.REROLL.timer - self.REROLL.interval
		self:reroll()
	end
end

function Saturn:reroll()
  if self.REROLL.active then
    if self.REROLL.type == 'legedi' then
      self:reroll_legedi()
    elseif self.REROLL.type == 'leg' then
      self:reroll_leg()
    elseif self.REROLL.type == 'jokedi' then
      self:reroll_jokedi()
    else
      self:reroll_jok()
    end
  end
end

function Saturn:stop_reroll()
	self.REROLL.active = false
	self.REROLL.timer = 0
	self.REROLL.elapsed = os.clock() - self.REROLL.elapsed
	self:log_console('seeds searched: '..self.REROLL.seeds)
	self:log_console('time elapsed: '..format_time(self.REROLL.elapsed))
end

function Saturn:reroll_leg()
	local rerollsThisFrame = 0
	local extra_num = -0.561892350821
	local seed_found = nil
	local specific_found = false
	
	while not seed_found and rerollsThisFrame < self.REROLL.frames do
		rerollsThisFrame = rerollsThisFrame + 1
		extra_num = extra_num + 0.561892350821
		seed_found = random_string(
			8,
			extra_num
				+ G.CONTROLLER.cursor_hover.T.x * 0.33411983
				+ G.CONTROLLER.cursor_hover.T.y * 0.874146
				+ 0.412311010 * G.CONTROLLER.cursor_hover.time
		)
		self.RANDOM_STATE = {
			hashed_seed = pseudohash(seed_found),
		}
		self.REROLL.seeds = self.REROLL.seeds + 1
		soul_found = false
		if pseudorandom_element(G.P_CENTER_POOLS["Tag"], self:pseudoseed("Tag1" .. seed_found)).key == 'tag_charm' then
			for i = 1, 5 do
				if pseudorandom(self:pseudoseed("soul_Tarot1" .. seed_found)) > 0.997 then
					self:new_run(seed_found)
					local card = self:next_card('Joker', G.jokers, true, nil, nil, nil, nil, 'sou')
					if card.name:lower() == self.REROLL.joker:lower() then
						soul_found = true
					end
				end
			end
		end
		if not soul_found then
			seed_found = nil
		end
	end
	if seed_found then
		self:stop_reroll()
		self:new_run(seed_found)
	end
end

function Saturn:reroll_legedi()
	local rerollsThisFrame = 0
	local extra_num = -0.561892350821
	local seed_found = nil
	local specific_found = false
	
	while not seed_found and rerollsThisFrame < self.REROLL.frames do
		rerollsThisFrame = rerollsThisFrame + 1
		extra_num = extra_num + 0.561892350821
		seed_found = random_string(
			8,
			extra_num
				+ G.CONTROLLER.cursor_hover.T.x * 0.33411983
				+ G.CONTROLLER.cursor_hover.T.y * 0.874146
				+ 0.412311010 * G.CONTROLLER.cursor_hover.time
		)
		self.RANDOM_STATE = {
			hashed_seed = pseudohash(seed_found),
		}
		self.REROLL.seeds = self.REROLL.seeds + 1
		soul_found = false
		if pseudorandom_element(G.P_CENTER_POOLS["Tag"], self:pseudoseed("Tag1" .. seed_found)).key == 'tag_charm' then
			for i = 1, 5 do
				if pseudorandom(self:pseudoseed("soul_Tarot1" .. seed_found)) > 0.997 then
					self:new_run(seed_found)
					local card = self:next_card('Joker', G.jokers, true, nil, nil, nil, nil, 'sou')
					if card.name:lower() == self.REROLL.joker:lower() and card.edition == self.REROLL.edition then
						soul_found = true
					end
				end
			end
		end
		if not soul_found then
			seed_found = nil
		end
	end
	if seed_found then
		self:stop_reroll()
		self:new_run(seed_found)
	end
end

function Saturn:reroll_jokedi()
	local rerollsThisFrame = 0
	local extra_num = -0.561892350821
	local seed_found = nil
	local specific_found = false
	
	while not seed_found and rerollsThisFrame < self.REROLL.frames do
		rerollsThisFrame = rerollsThisFrame + 1
		extra_num = extra_num + 0.561892350821
		seed_found = random_string(
			8,
			extra_num
				+ G.CONTROLLER.cursor_hover.T.x * 0.33411983
				+ G.CONTROLLER.cursor_hover.T.y * 0.874146
				+ 0.412311010 * G.CONTROLLER.cursor_hover.time
		)
		self.RANDOM_STATE = {
			hashed_seed = pseudohash(seed_found),
		}
		self.REROLL.seeds = self.REROLL.seeds + 1
		self:new_run(seed_found)
		local joker_found = false
		local cards = {
			self:next_card("Joker", G.pack_cards, nil, nil, true, true, nil, "buf"),
			self:next_card("Joker", G.pack_cards, nil, nil, true, true, nil, "buf"),
		}
		if (cards[1].name:lower() == self.REROLL.joker:lower() and cards[1].edition == self.REROLL.edition) or
		(cards[2].name:lower() == self.REROLL.joker:lower() and cards[2].edition == self.REROLL.edition) then
			joker_found = true
		end
		if not joker_found then
			seed_found = nil
		end
	end
	if seed_found then
		self:stop_reroll()
		self:new_run(seed_found)
	end
end

function Saturn:reroll_jok()
	local rerollsThisFrame = 0
	local extra_num = -0.561892350821
	local seed_found = nil
	local specific_found = false
	
	while not seed_found and rerollsThisFrame < self.REROLL.frames do
		rerollsThisFrame = rerollsThisFrame + 1
		extra_num = extra_num + 0.561892350821
		seed_found = random_string(
			8,
			extra_num
				+ G.CONTROLLER.cursor_hover.T.x * 0.33411983
				+ G.CONTROLLER.cursor_hover.T.y * 0.874146
				+ 0.412311010 * G.CONTROLLER.cursor_hover.time
		)
		self.RANDOM_STATE = {
			hashed_seed = pseudohash(seed_found),
		}
		self.REROLL.seeds = self.REROLL.seeds + 1
		local joker_found = false
		self:new_run(seed_found)
		local cards = {
			self:next_card("Joker", G.pack_cards, nil, nil, true, true, nil, "buf"),
			self:next_card("Joker", G.pack_cards, nil, nil, true, true, nil, "buf"),
		}
		if cards[1].name:lower() == self.REROLL.joker:lower() or
		cards[2].name:lower() == self.REROLL.joker:lower() then
			joker_found = true
		end
		if not joker_found then
			seed_found = nil
		end
	end
	if seed_found then
		self:stop_reroll()
		self:new_run(seed_found)
	end
end

function Saturn:wait(seconds)
	local start = os.clock()
	while os.clock() - start < seconds do
	end
end

function Saturn:pseudoseed(key, predict_seed)
	if key == "seed" then
		return math.random()
	end

	if predict_seed then
		local _pseed = pseudohash(key .. (predict_seed or ""))
		_pseed = math.abs(tonumber(string.format("%.13f", (2.134453429141 + _pseed * 1.72431234) % 1)))
		return (_pseed + (pseudohash(predict_seed) or 0)) / 2
	end

	if not self.RANDOM_STATE[key] then
		self.RANDOM_STATE[key] = pseudohash(key .. (self.RANDOM_STATE.seed or ""))
	end

	self.RANDOM_STATE[key] =
		math.abs(tonumber(string.format("%.13f", (2.134453429141 + self.RANDOM_STATE[key] * 1.72431234) % 1)))
	return (self.RANDOM_STATE[key] + (self.RANDOM_STATE.hashed_seed or 0)) / 2
end

function Saturn:new_run(seed)
	_stake = G.GAME.stake
	G:delete_run()
	G:start_run({
		stake = _stake,
		seed = seed,
		challenge = G.GAME and G.GAME.challenge and G.GAME.challenge_tab,
		})
	G.GAME.seeded = false
end

function Saturn:check_valid(name)
	local valid = false
	if #name > 0 then
		for k, v in pairs(G.P_CENTER_POOLS['Joker']) do
			if v.name:lower() == name:lower() then
				valid = true
				break
			end
		end
	end
	return valid
end

function Saturn:next_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if _type ~= 'Joker' then return nil end
    
    local area = area or G.jokers
	
	local _pool, _pool_key = get_current_pool(_type, _rarity, legendary, key_append)
    center = pseudorandom_element(_pool, pseudoseed(_pool_key))
    local it = 1
    while center == 'UNAVAILABLE' do
        it = it + 1
        center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
    end

    center = G.P_CENTERS[center]
	local edi = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante)
	if edi == nil then
		edition = nil
	else
		for key,value in pairs(edi) do 
			edition = tostring(key)
		end
	end

    local card = {
        name = center.name,
        edition = edition
    }
    
    return card
end