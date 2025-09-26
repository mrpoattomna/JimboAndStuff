----------------------------------------------
------------MOD CODE -------------------------

function perform_operations(val1, op, val2)
    if op == "=" then return val2 end
    if op == "+" then return val1 + val2 end
    if op == "-" then return val1 - val2 end
    if op == "*" then return val1 * val2 end
    if op == "/" then return val1 / val2 end
    if op == "%" then return val1 % val2 end
    if op == "^" then return val1 ^ val2 end
end

function modify_joker_values(card, modifytbl, exclusions, ignoreimmutable, nodeckeffects)
    if not card or not modifytbl then return nil end
    if card.config.center.immutable and not ignoreimmutable then return nil end
    local cardwasindeck = card.added_to_deck
    if not nodeckeffects and cardwasindeck then card:remove_from_deck(true) end
    exclusions = exclusions or {}
    local ops = {"=", "+", "-", "*", "/", "%", "^"}
    local function modify_value(ref_table, ref_value, isdirectlyinability)
        if type(ref_table[ref_value]) == 'table' and (ignoreimmutable or ref_value ~= "immutable") then
            for k, v in pairs(ref_table[ref_value]) do
                modify_value(ref_table[ref_value], k, false)
            end
        elseif type(ref_table[ref_value]) == 'number' and ((not (exclusions[ref_value] == true or exclusions[ref_value] == ref_table[ref_value])) or not isdirectlyinability) then
            for i, v in ipairs(ops) do
                if modifytbl[v] then
                    ref_table[ref_value] = perform_operations(ref_table[ref_value], v, modifytbl[v])
                end
            end
        end
    end
    for k, v in pairs(card.ability) do
        modify_value(card.ability, k, true)
    end
    if not nodeckeffects and cardwasindeck then card:add_to_deck(true) end
end

SMODS.Sound({
	key = "emult",
	path = "ExponentialMult.wav",
})
SMODS.Sound({
	key = "echips",
	path = "ExponentialChips.wav",
})
SMODS.Sound({
	key = "xchip",
	path = "MultiplicativeChips.wav",
})

if SMODS and SMODS.Mods and (not SMODS.Mods.Talisman or not SMODS.Mods.Talisman.can_load) then
	local smods_xchips = false
	for _, v in pairs(SMODS.scoring_parameter_keys) do
		if v == "x_chips" then
			smods_xchips = true
			break
		end
	end
	local scie = SMODS.calculate_individual_effect
	function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
		local ret = scie(effect, scored_card, key, amount, from_edition)
		if ret then
			return ret
		end
		if (key == "e_chips" or key == "echips" or key == "Echip_mod") and amount ~= 1 then
			if effect.card then
				juice_card(effect.card)
			end
			local chips = SMODS.Scoring_Parameters["chips"]
			chips:modify((chips.current ^ amount) - chips.current)
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(
						scored_card,
						"jokers",
						nil,
						percent,
						nil,
						{ message = "^" .. amount, colour = G.C.EDITION, edition = true }
					)
				elseif key ~= "Echip_mod" then
					if effect.echip_message then
						card_eval_status_text(
							scored_card or effect.card or effect.focus,
							"extra",
							nil,
							percent,
							nil,
							effect.echip_message
						)
					else
						card_eval_status_text(scored_card or effect.card or effect.focus, "e_chips", amount, percent)
					end
				end
			end
			return true
		end
		if (key == "e_mult" or key == "emult" or key == "Emult_mod") and amount ~= 1 then
			if effect.card then
				juice_card(effect.card)
			end
			local mult = SMODS.Scoring_Parameters["mult"]
			mult:modify((mult.current ^ amount) - mult.current)
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(
						scored_card,
						"jokers",
						nil,
						percent,
						nil,
						{ message = "^" .. amount .. " " .. localize("k_mult"), colour = G.C.EDITION, edition = true }
					)
				elseif key ~= "Emult_mod" then
					if effect.emult_message then
						card_eval_status_text(
							scored_card or effect.card or effect.focus,
							"extra",
							nil,
							percent,
							nil,
							effect.emult_message
						)
					else
						card_eval_status_text(scored_card or effect.card or effect.focus, "e_mult", amount, percent)
					end
				end
			end
			return true
		end
	end
	for _, v in ipairs({
		"e_mult", "emult", "Emult_mod",
		"e_chips", "echips", "Echip_mod",
	}) do
		table.insert(SMODS.scoring_parameter_keys, v)
	end
	if not smods_xchips then
		for _, v in ipairs({ "x_chips", "xchips", "Xchip_mod" }) do
			table.insert(SMODS.scoring_parameter_keys, v)
		end
	end
	to_big = to_big or function(x) return x end
	to_number = to_number or function(x) return x end
	lenient_bignum = lenient_bignum or function(x) return x end
end

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

SMODS.Shader(
{
    key = "blueprint_edition_shader",
    path = "blueprint_edition_shader.fs"
})

SMODS.Sound({
    key = "error",
    path = "error.ogg",
})

SMODS.Edition
{
    key = "blueprint_edition",
    shader = "blueprint_edition_shader",
    loc_txt = {
        name = "Blueprint Edition",
        label = "Blueprint",
        text = {"Retriggers the Joker on the Right"}
    },
    in_shop = true,
    weight = 4,
    extra_cost = 10,
    sound = { sound = "xmpl_error", per = 1, vol = 0.7 },
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        local other_joker1 = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then other_joker1 = G.jokers.cards[i + 1] end
        end
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == other_joker1 then
            return {repetitions = 1}
        end
    end
}

SMODS.Joker
{
    key = "cooler_joker",
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
                Xmult = card.ability.extra.Xmult
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
    config = {extra = {dollars = 8 }},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss then
            return{
                dollars = card.ability.extra.dollars
            }
        end
        if context.end_of_round and context.game_over == false and G.GAME.blind.boss then
            return{
                dollars = card.ability.extra.dollars
            }
        end
    end
}



SMODS.Joker
{
    key = "3D_joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "3D Joker",
        text = {
            "Has a {C:green}#1# in #2#{} chance of making a Joker Negative",
            "At the start of a round"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 0},
    config = {extra = {odds = 10}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "xmpl_3D_joker")
        return { vars = { numerator, denominator} }
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind and SMODS.pseudorandom_probability(card, "xmpl_3D_joker", 1, card.ability.extra.odds) then
            --local chance  = 0
            local eligible_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    if G.jokers.cards[i].edition then
                        if not G.jokers.cards[i].edition.foil and not G.jokers.cards[i].edition.holo then
                            goto continue
                        end
                    end
                    table.insert(eligible_jokers, G.jokers.cards[i])
                end
                ::continue::
            end
            if #eligible_jokers > 0 then
                local random_index = math.random(#eligible_jokers)
                local random_joker = eligible_jokers[random_index]
                return{random_joker:set_edition({negative = true})}
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
        name = "Blurry Joker"
    },
    atlas = "Jokers",
    pos = {x = 3, y = 0},
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        local min = 0
        local max = 200
        local r_Xmoney = {}
        for i = min, max do
            r_Xmoney[#r_Xmoney + 1] = tostring(i/100)
        end
        main_start = {
            { n = G.UIT.T, config = { text = 'X', colour = G.C.MONEY, scale = 0.32 } },
            { n = G.UIT.O, config = { object = DynaText({ string = r_Xmoney, colours = {G.C.MONEY}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            { n = G.UIT.T, config = { text = ' Dollars', colour = G.C.MONEY, scale = 0.32 } },
            }
        return {main_start = main_start}
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
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker then
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
        name = "Jiggly Joker"
    },
    atlas = "Jokers",
    pos = {x = 5, y = 0},
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        local min = 0
        local max = 100
        local r_chips = {}
        for i = min, max do
            r_chips[#r_chips + 1] = tostring(i)
        end
        main_start = {
            { n = G.UIT.T, config = { text = '+', colour = G.C.CHIPS, scale = 0.32 } },
            { n = G.UIT.O, config = { object = DynaText({ string = r_chips, colours = {G.C.CHIPS}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            { n = G.UIT.T, config = { text = ' Chips', colour = G.C.BLACK, scale = 0.32 } }
            }
        return {main_start = main_start}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local chippy = math.random(1,100)
            return{
                card = card,
                chips = chippy
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
        name = "Glitched Joker"
    },
    atlas = "Jokers",
    pos = {x = 6, y = 0},
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        local min = 0
        local max = 1000
        local r_mults = {}
        for i = min, max do
            r_mults[#r_mults + 1] = tostring(i/100)
        end
        main_start = {
            { n = G.UIT.T, config = { text = 'X', colour = G.C.MULT, scale = 0.32 } },
            { n = G.UIT.O, config = { object = DynaText({ string = r_mults, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            { n = G.UIT.T, config = { text = ' Mult', colour = G.C.BLACK, scale = 0.32 } }
            }
        return {main_start = main_start}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local min, max = 0, 10
            Xmulty = (min + (max - min) * math.random())
            Xmulty = math.floor(Xmulty * 100 + 0.5) / 100
            return{
                card = card,
                Xmult = Xmulty
            }
        end
    end
}

SMODS.Joker
{
    key = "simple joker",
    rarity = 3,
    cost = 9,
    blueprint_compat = false,
    loc_txt = {
        name = "Simplified Joker",
        text = {
            "All cards are considered wild cards"
        }
    },
    atlas = "Jokers",
    pos = {x = 7, y = 0},
    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return{vars = {}}
    end,
    calculate = function (self, card, context)
        if context.debuff_card and not context.retrigger_joker and not context.blueprint_card then
            return{prevent_debuff = true}
        end
    end
    
}

local card_is_suit_ref = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    local ret = card_is_suit_ref(self, suit, bypass_debuff, flush_calc)
    if not ret and not SMODS.has_no_suit(self) and next(SMODS.find_card("j_xmpl_simple joker")) then
        return true
    end
    return ret
end

SMODS.Joker
{
    key = "mosaic joker",
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    loc_txt = {
        name = "Mosaic Joker",
        text = {
            "{X:chips,C:white}X#1#{} Chips"
        }
    },
    atlas = "Jokers",
    pos = {x = 8, y = 0},
    config = {extra = {Xchips = 4}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xchips}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return{
                card = card,
                xchips = card.ability.extra.Xchips,
            }
        end
    end
}

SMODS.Joker
{
    key = "headache_joker",
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    loc_txt = {
        name = "Illusion Joker",
        text = {
            "creates a negative {C:attention}Joker{} at the start of new round"
        }
    },
    atlas = "Jokers",
    pos = {x = 9, y = 0},
    config = {extra = {odds = 100}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_joker
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "xmpl_headache_joker")
        return { vars = { numerator, denominator} }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            if SMODS.pseudorandom_probability(card, "xmpl_3D_joker", 1, card.ability.extra.odds) then
                return
                {
                    SMODS.add_card
                    {
                        key = "j_xmpl_cooler_joker",
                        edition = "e_negative"
                    }
                }
            end
        return
        {
            SMODS.add_card
            {
                key = "j_joker",
                edition = "e_negative"
            }
        }
        end
    end
}

SMODS.Joker
{
    key = "static joker",
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    loc_txt = {
        name = "Static Joker",
    },
    atlas = "Jokers",
    pos = {x = 0, y = 1},
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        local min = 0
        local max = 1000
        local r_chips = {}
        for i = min, max do
            r_chips[#r_chips + 1] = tostring(i/100)
        end
        main_start = {
            { n = G.UIT.T, config = { text = 'X', colour = G.C.CHIPS, scale = 0.32 } },
            { n = G.UIT.O, config = { object = DynaText({ string = r_chips, colours = {G.C.CHIPS}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            { n = G.UIT.T, config = { text = ' Chips', colour = G.C.BLACK, scale = 0.32 } }
            }
        return {main_start = main_start}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local min, max = 0, 10
            Xchippy = (min + (max - min) * math.random())
            Xchippy = math.floor(Xchippy * 100 + 0.5) / 100
            return{
                card = card,
                xchips = Xchippy
            }
        end
    end
}

SMODS.Joker
{
    key = "dot joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "Dotted Joker",
        text = {
            "For each . in a Joker's name",
            "Retriggers all aces played",
            "{C:attention}Will contain dots from (i)s and (j)s etc"
        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 14  then
                local sum_counts = 0
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] ~= card then
                        local joker = G.jokers.cards[i].config.center.key
                        local textt = G.P_CENTERS[joker].name
                        local count = 0
                        for i=1, #textt do
                            if textt:sub(i, i) == "." then
                                count = count + 1
                            end
                        end
                        sum_counts = sum_counts + count
                        count = 0
                        for i=1, #textt do
                            if textt:sub(i, i) == "i" then
                                count = count + 1
                            end
                        end
                        sum_counts = sum_counts + count
                        count = 0
                        for i=1, #textt do
                            if textt:sub(i, i) == "j" then
                                count = count + 1
                            end
                        end
                        sum_counts = sum_counts + count
                        count = 0
                        for i=1, #textt do
                            if textt:sub(i, i) == ";" then
                                count = count + 1
                            end
                        end
                        sum_counts = sum_counts + count
                        count = 0
                        for i=1, #textt do
                            if textt:sub(i, i) == ":" then
                                count = count + 1
                            end
                        end
                        sum_counts = sum_counts + count
                    end
                end
                return {repetitions = sum_counts}
            end
        end
    end
}

SMODS.Joker
{
    key = "retro joker",
    rarity = 1,
    cost = 2,
    blueprint_compat = true,
    loc_txt = {
        name = "Retro Joker",
        text = {
            "{C:chips}+#1#{} Chips"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 1},
    config = {extra = {chips = 40}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return{
                card = card,
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker
{
    key = "jim joker",
    rarity = 4,
    cost = 25,
    blueprint_compat = true,
    loc_txt = {
        name = "Jim",
        text = {
            "Gains {X:mult,C:white}#1#X{}",
            "For every {C:money}1${} you have",
            "Currently {X:mult,C:white}X#2#{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 3, y = 1},
    config = {extra = {Xmoney_mult = 1}},
    loc_vars = function(self, info_queue, center)
        local Xmulty = G.GAME.dollars * center.ability.extra.Xmoney_mult
        return {vars = {center.ability.extra.Xmoney_mult,Xmulty}}
    end,
    calculate = function(self, card, context)
        card.ability.extra.Xmult = G.GAME.dollars
        if context.joker_main then
            return{
                card = card,
                Xmult = G.GAME.dollars * card.ability.extra.Xmoney_mult
            }
        end
    end
}
SMODS.Joker
{
    key = "Static TV",
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    loc_txt = {
        name = "Static TV",
        text = {
            "Warning: May cause Lag"
        }
    },
    atlas = "Jokers",
    pos = {x = 4, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, card)
        local min = 0
        local max = 250
        local r_mult = {}
        for i = min, max do
            r_mult[#r_mult + 1] = tostring(i/100)
        end
        main_start = {
            { n = G.UIT.T, config = { text = 'X', colour = G.C.IMPORTANT, scale = 0.32 } },
            { n = G.UIT.O, config = { object = DynaText({ string = r_mult, colours = {G.C.IMPORTANT}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0 }) } },
            { n = G.UIT.T, config = { text = ' All values', colour = G.C.BLACK, scale = 0.32 } }
            }
        return {main_start = main_start}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local mult_rand = (0 + (2.5 - 0) * math.random())
            mult_rand = math.floor(mult_rand * 100 + 0.5) / 100
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    modify_joker_values(G.jokers.cards[i], {["*"] = mult_rand}, {x_mult = 1, x_chips = 1, card_limit = true, extra_slots_used = true})
                end
            end
            return{
                message = 'X' .. mult_rand .. " Values",
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker
{
    key = "saturated joker",
    rarity = 2,
    cost = 5,
    blueprint_compat = true,
    loc_txt = {
        name = "Saturated Joker",
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:mult}+#2#{} Mult"
        }
    },
    atlas = "Jokers",
    pos = {x = 5, y = 1},
    config = {extra = {chips = 200, mult = 20}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips, center.ability.extra.mult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return{
                card = card,
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker
{
    key = "corrupt_joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = false,
    loc_txt = {
        name = "Corrupt Joker",
        text = {
            "Increases the chances for Rares and Uncommons"
        }
    },
    atlas = "Jokers",
    pos = {x = 6, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips}}
    end,
    add_to_deck = function (self, card, from_debuff)
        G.GAME.common_mod = 0.6
        G.GAME.uncommon_mod = 0.3
        G.GAME.rare_mod = 0.1
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.GAME.common_mod = 0.7
        G.GAME.uncommon_mod = 0.25
        G.GAME.rare_mod = 0.05
    end
}


SMODS.Joker
{
    key = "E_JOKER",
    rarity = 3,
    cost = 9,
    blueprint_compat = true,
    loc_txt = {
        name = "Error Joker",
        text = {
            "{C:mult}^#1#{} Mult",
            "{C:green}1 in 6{} to {C:attention}Delete your Save{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 7, y = 1},
    config = {extra = {ExponentialMult = 4}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.ExponentialMult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local rand = math.random(1,6)
            if rand == 1 then
                SMODS.restart_game()
                G.STATE =G.STATES.GAME_OVER
                G.STATE_COMPLETE = false
                G.FUNCS.quit()
            end
            return{
                card = card,
                e_mult = card.ability.extra.ExponentialMult,
                message = "^" .. card.ability.extra.ExponentialMult .. " Mult",
                colour = G.C.MULT,
                sound = "xmpl_emult"
            }
        end
    end
}

SMODS.Joker
{
    key = "oversaturated joker",
    rarity = 3,
    cost = 9,
    blueprint_compat = false,
    loc_txt = {
        name = "Oversaturated Joker",
        text = {
            "{C:attention}+#1#{} Shop slot",
            "{C:attention}+#2#{} Voucher slot",
            "{C:attention}+#3#{} Booster slot"
        }
    },
    atlas = "Jokers",
    pos = {x = 8, y = 1},
    config = {extra = {extra_shop_slot = 1, extra_booster_slot = 1, extra_voucher_slot = 1,}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.extra_shop_slot, center.ability.extra.extra_booster_slot, center.ability.extra.extra_voucher_slot}}
    end,
    add_to_deck = function (self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                change_shop_size(card.ability.extra.extra_shop_slot)
                SMODS.change_booster_limit(card.ability.extra.extra_booster_slot)
                SMODS.change_voucher_limit(card.ability.extra.extra_voucher_slot)
                return true
            end
        }))
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                change_shop_size(-card.ability.extra.extra_shop_slot)
                SMODS.change_booster_limit(-card.ability.extra.extra_booster_slot)
                SMODS.change_voucher_limit(-card.ability.extra.extra_voucher_slot)
                return true
            end
        }))
    end
}

SMODS.Joker
{
    key = "swirly joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "Swirly Joker",
        text = {
            "Increases played cards' ranks"
        }
    },
    atlas = "Jokers",
    pos = {x = 9, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            for i = 1, #G.play.cards do
                G.E_MANAGER:add_event(Event({
                    delay = 0.1,
                    func = function()
                        assert(SMODS.modify_rank(G.play.cards[i], 1))
                        return true
                    end
                }))
            end
            return{}
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
