local kpur = Controller.key_press_update
function Controller:key_press_update(key, dt)
  kpur(self, key, dt)
  if key == "t" then
    if not G.OVERLAY_MENU then
      Saturn.ui.opts.func()
    else
      G.FUNCS.exit_overlay_menu()
    end
  end
end
