SMODS.Atlas{
    key = "Spectral",
    path = "Spectral.png",
    px = 71,
    py = 95
}

SMODS.Sound({
    key = "lol",
    path = "lol.ogg"
})

SMODS.Consumable{
    key = 'slight of hand',
    set = 'Spectral',
    atlas = "Spectral",
    loc_txt = {
        name = "Slight of Hand",
        text = {
            "Select one card to turn {C:dark_edition}Negative{}"
        }
    },
    pos = { x = 0, y = 0 },
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Edition", key = "e_negative_playing_card", config = G.P_CENTERS.e_negative.config }
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

SMODS.Consumable{
    key = 'black cards',
    set = 'Spectral',
    atlas = "Spectral",
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = "Black Cards",
        text = {
            "Turns all Cards held in hand into {C:dark_edition}Negative{}",
            "{C:attention}-1 Joker Slot{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = "Edition", key = "e_negative_playing_card", config = G.P_CENTERS.e_negative.config }
        return{}
    end,
    use = function (self, card, area, copier)
        local used_tarot = copier or card
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    G.hand.cards[i]:set_edition("e_negative", true)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
        G.jokers:change_size(-1)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0 and G.jokers.config.card_limit > 0
    end
}

SMODS.Consumable{
    key = "nostalgia",
    atlas = "Spectral",
    pos = {x = 2, y =0},
    set = "Spectral",
    config = {max_highlighted = 1, extra = {seal = "xmpl_epik_face"}},
    loc_txt = {
        name = "Nostalgia",
        text = {
            "Applies {C:attention}Epik Seal{} to #1# Selected Card"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
        return { vars = { card.ability.max_highlighted } }
    end,
    use = function(self, card, area, copier)
        local conv_card = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('xmpl_lol')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                conv_card:set_seal(card.ability.extra.seal, nil, true)
                return true
            end
        }))

        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end
}