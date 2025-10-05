SMODS.Atlas{
    key = "tarots",
    path = "Tarots.png",
    px = 71,
    py = 95
}

SMODS.Consumable{
    key = "omen",
    atlas = "tarots",
    pos = {x = 0, y = 0},
    set = "Tarot",
    config = { extra = { spectrals = 2 } },
    loc_txt = {
        name = "The Omen",
        text = {
            "Creates 2 random {C:spectral}Spectral{} Cards"
        }
    },
    use = function(self, card, area, copier)
        for i = 1, math.min(card.ability.extra.spectrals, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Spectral'})
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards-1 < G.consumeables.config.card_limit
    end
}

SMODS.Consumable{
    key = "growth",
    atlas = "tarots",
    pos = {x = 1, y = 0},
    set = "Tarot",
    config = {max_highlighted = 2, mod_conv = "m_xmpl_growth"},
    loc_txt = {
        name = "The Growth",
        text = {
            "Applies {C:enhanced}Growth{} to #1# Selected cards"
        }
    },
    loc_vars = function (self, info_queue, card)
        return{vars = {card.ability.max_highlighted, localize { type = 'name_text', set = 'Enhanced', key = card.ability.mod_conv }}}
    end
}