local lovely = require("lovely")
local nativefs = require("nativefs")

Saturn.ST = {}

local localizations = {
    --- Money Generators
    {id = "j_golden", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#2#{C:inactive}){}"},
    {id = "j_ticket", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#2#{C:inactive}){}"},
    {id = "j_business", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_delayed_grat", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#2#{C:inactive}){}"},
    {id = "j_faceless", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_todo_list", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_rough_gem", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#2#{C:inactive}){}"},
    {id = "j_matador", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#2#{C:inactive}){}"},
    {id = "j_cloud_9", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_rocket", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_satellite", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_mail", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#3#{C:inactive}){}"},
    {id = "j_gift", counter_text = "{C:inactive}(Total value added: {C:money}$#2#{C:inactive}){}"},
    {id = "j_reserved_parking", counter_text = "{C:inactive}(Total $$$ generated: {C:money}$#4#{C:inactive}){}"},
    --- Card Generators
    {id = "j_8_ball", counter_text = "{C:inactive}(Total cards generated: {C:tarot}$#3#{C:inactive}){}"},
    {id = "j_space", counter_text = "{C:inactive}(Total hands upgraded: {C:planet}$#3#{C:inactive}){}"},
    {id = "j_dna", counter_text = "{C:inactive}(Total cards generated: {C:planet}$#1#{C:inactive}){}"},
    {id = "j_sixth_sense", counter_text = "{C:inactive}(Total cards generated: {C:spectral}$#1#{C:inactive}){}"},
    {id = "j_superposition", counter_text = "{C:inactive}(Total cards generated: {C:tarot}$#1#{C:inactive}){}"},
    {id = "j_seance", counter_text = "{C:inactive}(Total cards generated: {C:spectral}$#2#{C:inactive}){}"},
    {id = "j_riff_raff", counter_text = "{C:inactive}(Total jokers generated: {C:joker}$#2#{C:inactive}){}"},
    {id = "j_vagabond", counter_text = "{C:inactive}(Total cards generated: {C:tarot}$#2#{C:inactive}){}"},
}

function Saturn.ST.addCounterLocalization() 
    for _, k in ipairs(localizations) do
        local text = G.localization.descriptions.Joker[k.id].text
        table.insert(text, #text+1, k.counter_text)
    end
end
