SMODS.Atlas{
    key = "Specteral",
    path = "Specteral.png",
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = 'slight of hand',
    set = 'Specteral',
    pos = { x = 0, y = 0 },
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local slight_card = G.hand.highlighted[1]
                slight_card:set_edition("e_negative", true)
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end
}