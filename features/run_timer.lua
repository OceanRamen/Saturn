Timer = {}
Timer.__index = Timer

function Timer:new(callback)
  local obj = {
    callback = callback or nil,
    elapsed = 0,
    running = false,
    disp = "",
  }
  setmetatable(obj, Timer)
  return obj
end

function Timer:start()
  self.elapsed = 0
  self.running = true
end

function Timer:stop()
  self.running = false
  if self.callback then
    self.callback(self.elapsed)
  end
end

function Timer:update(dt)
  if self.running then
    self.elapsed = self.elapsed + dt
  end
end

function Timer:reset()
  self.elapsed = 0
end

-- Convert elapsed time to hours:minutes:seconds:milliseconds
function Timer:getFormattedTime()
  local totalMilliseconds = self.elapsed * 1000
  local milliseconds = totalMilliseconds % 1000
  local totalSeconds = math.floor(totalMilliseconds / 1000)
  local seconds = totalSeconds % 60
  local totalMinutes = math.floor(totalSeconds / 60)
  local minutes = totalMinutes % 60
  local hours = math.floor(totalMinutes / 60)

  return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
end


local game_start_run_ref = Game.start_run
function Game:start_run(args)
  game_start_run_ref(self, args)
  if S.SETTINGS.modules.run_timer.enabled then
    S.TIMER = Timer:new()
    S.TIMER:start(onTimerStop)
    Game.runTimerHUD = UIBox({
      definition = create_UIBox_runTimer(),
      config = { align = "cri", offset = { x = 0.5, y = 2.1 }, major = G.ROOM_ATTACH },
    })
  end
end

local win_game_ref = win_game
function win_game()
  if Saturn.TIMER and Saturn.TIMER.running then
    Saturn.TIMER:stop()
    print(Saturn.TIMER.elapsed)
  end
  win_game_ref()
end

local game_update_game_over_ref = Game.update_game_over
function Game:update_game_over(dt)
  if Saturn.TIMER and Saturn.TIMER.running then
    Saturn.TIMER:stop()
    print(Saturn.TIMER.elapsed)
  end
  game_update_game_over_ref(self, dt)
end

function create_UIBox_runTimer()
  return {
    n = G.UIT.ROOT,
    config = { align = "cm", padding = 0.03, colour = G.C.UI.TRANSPARENT_DARK, r = 0.1 },
    nodes = {
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.05, colour = G.C.DYN_UI.MAIN, r = 0.1 },
        nodes = {
          {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.DYN_UI.BOSS_DARK, r = 0.1, minw = 1.5, padding = 0.08 },
            nodes = {
              { n = G.UIT.R, config = { align = "cm", minh = 0.0 }, nodes = {} },
              {
                n = G.UIT.R,
                config = {
                  id = "speedrun_timer_right",
                  align = "cm",
                  padding = 0.05,
                  minw = 1.45,
                  emboss = 0.05,
                  r = 0.1,
                },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                      {
                        n = G.UIT.O,
                        config = {
                          object = DynaText({
                            string = { { ref_table = S.TIMER, ref_value = "disp" } },
                            colours = { G.C.WHITE },
                            shadow = true,
                            bump = false,
                            scale = 0.6,
                            pop_in = 0.5,
                            maxw = 5,
                            silent = true,
                          }),
                          id = "timer",
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  }
end
