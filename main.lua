----------------------------------------------
------------MOD CODE -------------------------

SMODS.current_mod.optional_features = {
    retrigger_joker = true,
    cardareas = {discard = true, deck = true},
    quantum_enhancements = true
}

SMODS.Atlas
{
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
}

SMODS.Joker
{
    key = "cooler joker",
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    loc_txt = {
        name = "The Cooler Joker",
        text = {
            "{X:mult,C:white}X#1#{} Mult"
        }
    },
    atlas = "Jokers",
    pos = {x = 0, y = 0},
    config = {extra = {Xmult = 4}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return{
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult .. " Mult",
                colour = G.C.Xmult
            }
        end
    end
}

SMODS.Joker
{
    key = "looting joker",
    rarity = 2,
    cost = 7,
    blueprint_compat = false,
    loc_txt = {
        name = "Looter Joker",
        text = {
            "Gain {C:money}#1#${} when you",
            "Enter a Boss Blind",
            "and When you Defeat it"
        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 0},
    config = {extra = {money = 8}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.money}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss then
            ease_dollars(card.ability.extra.money)
            return{
                message = '+' .. card.ability.extra.money .. "$",
                colour = G.C.money
            }
        end
         if context.end_of_round and context.game_over == false and G.GAME.blind.boss then
            ease_dollars(card.ability.extra.money)  -- Fixed: moved outside return
            return{
                message = '+' .. card.ability.extra.money .. "$",
                colour = G.C.money
            }
        end
    end
}



SMODS.Joker
{
    key = "3D joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "3D Joker",
        text = {
            "Has a {C:green}1 in 10{} chance of making a joker negative",
            "At the start of a round"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 0},
    config = {},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind then
            local chance  = 10
            local eligible_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    if G.jokers.cards[i].config.center.key == "j_oops" then
                        chance = math.ceil(chance / 2)
                    end
                    if G.jokers.cards[i].edition then
                        if G.jokers.cards[i].edition.negative then
                            goto continue
                        end
                    end
                    table.insert(eligible_jokers, G.jokers.cards[i])
                end
                ::continue::
            end
            local num = math.random(1,chance)
            if num == 1 then
                if #eligible_jokers > 0 then
                    local random_index = math.random(#eligible_jokers)
                    local random_joker = eligible_jokers[random_index]
                    -- Do something with random_joker
                    return{random_joker:set_edition({negative = true})}
                end
            end
        end
    end
}


SMODS.Joker
{
    key = "Blurred Joker",
    rarity = 1,
    cost = 3,
    blueprint_compat = true,
    loc_txt = {
        name = "Blurry Joker",
        text = {
            "{C:attention}Randomizes Money{}",
            "{C:Blue}Every Hand{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 3, y = 0},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local min, max = 0, 2
            G.GAME.dollars = math.ceil(G.GAME.dollars * (min + (max - min) * math.random()))
            return{
                card = card,
                message = "money randomized",
                colour = G.C.money
            }
        end
    end
}

SMODS.Joker
{
    key = "ultimate joker",
    rarity = 4,
    cost = 25,
    blueprint_compat = true,
    loc_txt = {
        name = "Ultima Joker",
        text = {
            "Retriggers all Jokers"
        }
    },
    atlas = "Jokers",
    pos = {x = 4, y = 0},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {retrigger_joker = false}}
    end,
    calculate = function(self, card, context)
        if context.retrigger_joker_check then
            return { repetitions = 1 }
        end
    end
}

SMODS.Joker
{
    key = "jiggly joker",
    rarity = 1,
    cost = 2,
    blueprint_compat = true,
    loc_txt = {
        name = "Jiggly Joker",
        text = {
            "{C:chips}+??{} Chips"
        }
    },
    atlas = "Jokers",
    pos = {x = 5, y = 0},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local chippy = math.random(1,100)
            return{
                card = card,
                chip_mod = chippy,
                message = '+' .. chippy .. " Chips",
                colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Joker
{
    key = "glitchy joker",
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    loc_txt = {
        name = "Glitched Joker",
        text = {
            "{X:mult,C:white}X??{} Mult"
        }
    },
    atlas = "Jokers",
    pos = {x = 6, y = 0},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local min, max = 0, 10
            Xmulty = (min + (max - min) * math.random())
            Xmulty = math.floor(Xmulty * 100 + 0.5) / 100
            return{
                card = card,
                Xmult_mod = Xmulty,
                message = 'X' .. Xmulty .. " Mult",
                colour = G.C.Xmult
            }
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
