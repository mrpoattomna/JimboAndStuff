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

SMODS.Sound({
	key = "explode",
	path = "explosion.ogg",
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


SMODS.Atlas
{
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
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
            "{X:mult,C:white}X#1#{} Mult",
            "{V:1}Yes I did steal that idea{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 0, y = 0},
    config = {extra = {Xmult = 4}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult, colours = {HEX("dda0dd")}}}
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
    blueprint_compat = true,
    loc_txt = {
        name = "Looter Joker",
        text = {
            "Gain {C:money}#1#${} when you",
            "Enter a Boss Blind",
            "and When you Defeat it",
            "{V:1}YOINK{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 0},
    config = {extra = {dollars = 8 }},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.dollars, colours = {HEX("dda0dd")}}}
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
            "Has a {C:green, E:1}#1# in #2#{} chance of making a Joker Negative",
            "At the start of a round",
            "{V:1}Hey this doesn't look 3D{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 0},
    config = {extra = {odds = 10}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "xmpl_3D_joker")
        return { vars = { numerator, denominator, colours = {HEX("dda0dd")}} }
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind and SMODS.pseudorandom_probability(card, "xmpl_3D_joker", 1, card.ability.extra.odds) then
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
        name = "Blurry Joker",
        text = {
            "{V:1}Gambling core{}"
        }
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
        return {main_start = main_start, vars = {colours = {HEX("dda0dd")}}}
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
            "Retriggers all Jokers",
            "{V:1}The Ultimate Life Form{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 4, y = 0},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
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
        name = "Jiggly Joker",
        text = {
            "{V:1}wobble* wobble*{}"
        }
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
        return {main_start = main_start, vars = {colours = {HEX("dda0dd")}}}
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
        name = "Glitched Joker",
        text = {
            "{V:1}wow this mod sure loves Gambling{}"
        }
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
        return {main_start = main_start, vars = {colours = {HEX("dda0dd")}}}
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
            "All cards are considered wild cards",
            "{V:1}are suits too much for you?{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 7, y = 0},
    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return{vars = {colours = {HEX("dda0dd")}}}
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
            "{X:chips,C:white}X#1#{} Chips",
            "{V:1}YOO Xchips that is in almost{}",
            "{V:1}every mod so original{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 8, y = 0},
    config = {extra = {Xchips = 4}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xchips, colours = {HEX("dda0dd")}}}
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
            "creates a negative {C:attention}Joker{} at the start of new round",
            "{V:1}hey no you can't just sell them for money{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 9, y = 0},
    config = {extra = {odds = 100}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_joker
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "xmpl_headache_joker")
        return { vars = { numerator, denominator, colours = {HEX("dda0dd")}} }
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
        text = {
            "{V:1}I CAN'T STOP WITH THESE JOKERS{}"
        }
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
        return {main_start = main_start, vars = {colours = {HEX("dda0dd")}}}
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
            "{C:attention}Will contain dots from (i)s and (j)s etc",
            "{V:1}this one is stupid{}",
            "{V:1}I don't even think this works right{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
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
            "{C:chips}+#1#{} Chips",
            "{V:1}hey look, retroslop{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 1},
    config = {extra = {chips = 40}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips, colours = {HEX("dda0dd")}}}
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
            "Gains {X:mult,C:white}#1#X{} Mult",
            "For every {C:money}1${} you have",
            "Currently {X:mult,C:white}X#2#{}",
            "{V:1}Jimbo's Chineese cousin{}",
            "{V:1}Jimbo hates him{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 3, y = 1},
    config = {extra = {Xmoney_mult = 1}},
    loc_vars = function(self, info_queue, center)
        local Xmulty = G.GAME.dollars * center.ability.extra.Xmoney_mult
        return {vars = {center.ability.extra.Xmoney_mult,Xmulty,  colours = {HEX("dda0dd")}}}
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
            "Warning: May cause Lag",
            "{V:1}FUNNY MESS GO BRRRRRRRRR{}"
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
        return {main_start = main_start, vars = {colours = {HEX("dda0dd")}}}
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
            for i = 1, #G.consumeables.cards do
                modify_joker_values(G.consumeables.cards[i], {["*"] = mult_rand}, {x_mult = 1, x_chips = 1, card_limit = true, extra_slots_used = true})
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
            "{C:mult}+#2#{} Mult",
            "{V:1}Not that bad to look at{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 5, y = 1},
    config = {extra = {chips = 200, mult = 20}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips, center.ability.extra.mult, colours = {HEX("dda0dd")}}}
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
            "Increases the chances for {C:rare}Rares{} and {C:uncommon}Uncommons{}",
            "{V:1}Sharp looking{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 6, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips, colours = {HEX("dda0dd")}}}
    end,
    add_to_deck = function (self, card, from_debuff)
        G.GAME.common_mod = (G.GAME.common_mod or 0.7) - 0.1
        G.GAME.uncommon_mod = (G.GAME.uncommon_mod or 0.25) + 0.05
        G.GAME.rare_mod = (G.GAME.rare_mod or 0.05) + 0.05
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.GAME.common_mod = G.GAME.common_mod + 0.1
        G.GAME.uncommon_mod = G.GAME.uncommon_mod - 0.05
        G.GAME.rare_mod = G.GAME.rare_mod - 0.05
    end
}


SMODS.Joker
{
    key = "error_joker",
    rarity = 3,
    cost = 9,
    blueprint_compat = true,
    loc_txt = {
        name = "Error Joker",
        text = {
            "{X:mult,C:white}^#1#{} Mult",
            "{C:green,E:1}#2# in #3#{} {C:attention}FIXED CHANCE{} to {C:attention}Delete your Run{}",
            "{V:1}If you win a whole run with this guy{}",
            "{V:1}Go play the lottery{}",
            "{V:1}also oops doesn't affect him cause I am nice{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 7, y = 1},
    config = {extra = {ExponentialMult = 4, immutable = {odds = 6}}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.immutable.odds, "xmpl_error_joker", false, true)
        return {vars = {card.ability.extra.ExponentialMult, numerator, denominator, colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if SMODS.pseudorandom_probability(card, "xmpl_error_joker", 1, card.ability.extra.immutable.odds, nil, true) then
                SMODS.restart_game()
                G.STATE =G.STATES.GAME_OVER
                G.STATE_COMPLETE = false
                G.FUNCS.quit()
            end
            return{
                card = card,
                Emult_mod = card.ability.extra.ExponentialMult,
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
            "{C:attention}+#3#{} Booster slot",
            "{V:1}EWW why did I do that{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 8, y = 1},
    config = {extra = {extra_shop_slot = 1, extra_booster_slot = 1, extra_voucher_slot = 1,}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.extra_shop_slot, center.ability.extra.extra_booster_slot, center.ability.extra.extra_voucher_slot, colours = {HEX("dda0dd")}}}
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
    blueprint_compat = false,
    loc_txt = {
        name = "Swirly Joker",
        text = {
            "Increases played card's rank by {C:attention}1{}",
            "{V:1}Fun Fact: almost every joker is just jimbo{}",
            "{V:1}in a random filter in photopea...",
            "{V:1}I suck at graphics and art{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 9, y = 1},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint_card then
            local cards = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                assert(SMODS.modify_rank(scored_card, 1))
            end
            return{
                message = "Rank Up"
            }
        end
    end
}

SMODS.JimboQuip({
	key = 'evil_quip1',
	type = 'loss',
    filter = function(self, type)
        if next(SMODS.find_card('j_xmpl_evil_joker')) then
            return true, {weight = 33}
        end
    end,
    extra = {center = "j_xmpl_evil_joker"}
})

SMODS.JimboQuip({
	key = 'evil_quip2',
	type = 'loss',
    filter = function(self, type)
        if next(SMODS.find_card('j_xmpl_evil_joker')) then
            return true, {weight = 33}
        end
    end,
    extra = {center = "j_xmpl_evil_joker"}
})

SMODS.JimboQuip({
	key = 'evil_quip3',
	type = 'loss',
    filter = function(self, type)
        if next(SMODS.find_card('j_xmpl_evil_joker')) then
            return true, {weight = 33}
        end
    end,
    extra = {center = "j_xmpl_evil_joker"}
})

SMODS.JimboQuip({
	key = 'evil_quip4',
	type = 'loss',
    filter = function(self, type)
        if next(SMODS.find_card('j_xmpl_evil_joker')) then
            return true, {weight = 33}
        end
    end,
    extra = {center = "j_xmpl_evil_joker"}
})

SMODS.JimboQuip({
	key = 'evil_quip5',
	type = 'loss',
    filter = function(self, type)
        if next(SMODS.find_card('j_xmpl_evil_joker')) then
            return true, {weight = 33}
        end
    end,
    extra = {center = "j_xmpl_evil_joker"}
})

SMODS.Joker
{
    key = "evil_joker",
    rarity = 3,
    cost = 20,
    blueprint_compat = false,
    loc_txt = {
        name = "{C:red}EVIL{} Joker",
        text = {
            "Refuses to reveal his {C:red, E:2}EVIL{} plan",
            "{X:mult,C:white}X100{} Mult",
            "{X:chips,C:white}X100{} Chips",
            "{V:1}Jimbo's evil clone{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 0, y = 2},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            G.STATE = G.STATES.GAME_OVER
            G.STATE_COMPLETE = false
        end
    end
}

SMODS.Joker
{
    key = "outline joker",
    rarity = 2,
    cost = 7,
    blueprint_compat = true,
    loc_txt = {
        name = "Outline Joker",
        text = {
            "gains {X:mult,C:white}X#1#{}",
            "When a card with the {C:spades}Spades{} or {C:clubs}Clubs{} Suit is scored",
            "when it reaches {X:mult,C:white}X#2#{} mult",
            "Gains {C:attention}#3# Joker Slot{} and resets its mult",
            "Currently {X:mult,C:white}X#4#{} mult",
            "Currently {C:attention}+#5#{} Joker Slots",
            "{V:1}Couldn't think of a name{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 2},
    config = {extra = {extra_Xmult = 0.15, required_mult = 10, extra_Joker_slot = 1, current_Xmult = 1, current_Joker_slots = 0}},
    loc_vars = function(self, info_queue, center)
        return {vars = {
            center.ability.extra.extra_Xmult, 
            center.ability.extra.required_mult, 
            center.ability.extra.extra_Joker_slot, 
            center.ability.extra.current_Xmult,
            center.ability.extra.current_Joker_slots,
            colours = {HEX("dda0dd")}
        }}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and 
        (context.other_card:is_suit("Clubs") or  context.other_card:is_suit("Spades")) and not context.blueprint_card then
            card.ability.extra.current_Xmult = card.ability.extra.current_Xmult + card.ability.extra.extra_Xmult
            if card.ability.extra.current_Xmult >= card.ability.extra.required_mult and not context.blueprint_card then
                card.ability.extra.current_Joker_slots = card.ability.extra.current_Joker_slots + card.ability.extra.extra_Joker_slot
                G.jokers:change_size(card.ability.extra.extra_Joker_slot)
                card.ability.extra.current_Xmult = 1
                return{
                    message = "Upgrade",
                    colour = G.C.IMPORTANT,
                    message_card = card
                }
            end
            return{
                message = "Upgrade",
                colour = G.C.IMPORTANT,
                message_card = card
            }
        end
        if context.joker_main then
            print(card.ability.extra.current_Joker_slots)
            return{
                Xmult = card.ability.extra.current_Xmult
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.jokers:change_size(card.ability.extra.current_Joker_slots)
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.jokers:change_size(-card.ability.extra.current_Joker_slots)
    end
}

SMODS.Joker
{
    key = "blueprintify joker",
    rarity = 4,
    cost = 25,
    blueprint_compat = true,
    loc_txt = {
        name = "Blueprintify Joker",
        text = {
            "Gives a random Joker {C:attention}Blueprint Edition{}",
            "At the start of a round",
            "{V:1}No he doesn't increase the chances for blueprint{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 2},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue+1] = G.P_CENTERS.e_xmpl_blueprint_edition
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
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
                return{random_joker:set_edition("e_xmpl_blueprint_edition", true)}
            end
        end
    end
}

SMODS.Joker
{
    key = "pixilated joker",
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    loc_txt = {
        name = "Pixilated Joker",
        text = {
            "Applies a random {C:attention}Edition{} or {C:attention}Seal{} or {C:attention}Enhancement{}",
            "On all scoring cards",
            "{V:1}The pixels are WAY too big{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 3, y = 2},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint_card then
            local cards = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                local rand_ench = math.random(1,3)
                if rand_ench == 1 then
                    local enhancement_pool = {}
                    for _, enhancement in pairs(G.P_CENTER_POOLS.Enhanced) do
                        if enhancement.key ~= 'm_stone' then
                            enhancement_pool[#enhancement_pool + 1] = enhancement
                        end
                    end
                    local random_enhancement = pseudorandom_element(enhancement_pool, 'edit_card_enhancement')
                    scored_card:set_ability(random_enhancement)
                elseif rand_ench == 2 then
                    local random_seal = SMODS.poll_seal({mod = 10, guaranteed = true})
                    if random_seal then
                        scored_card:set_seal(random_seal, true, true)
                    end
                elseif rand_ench == 3 then
                    local random_edition = poll_edition('edit_card_edition', nil, true, true)
                    if random_edition then
                        scored_card:set_edition(random_edition, true, true)
                    end
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        scored_card:juice_up()
                        return true
                    end
                }))
            end
            if cards then
                return{
                    message = "Cards Modified"
                }
            end
        end
    end
}

SMODS.Joker
{
    key = "black and white joker",
    rarity = 1,
    cost = 5,
    blueprint_compat = false,
    loc_txt = {
        name = "Black and White Joker",
        text = {
            "{C:money}+#1#${} per Joker",
            "Currently {C:money}+#2#${} at the end of round",
            "{V:1}I ran out of colors{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 4, y = 2},
    config = {extra = {dollars = 1}},
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.dollars, center.ability.extra.dollars*(G.jokers and #G.jokers.cards or 0), colours = {HEX("dda0dd")}}}
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars*(G.jokers and #G.jokers.cards or 0)
    end
}

SMODS.Joker
{
    key = "2 sides",
    rarity = 2,
    cost = 7,
    blueprint_compat = true,
    loc_txt = {
        name = "2 Sides",
        text = {
            "Copies a Joker to its left",
            "or to its right",
            "{V:1}I just make random stuff deal with it"
        }
    },
    atlas = "Jokers",
    pos = {x = 5, y = 2},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.joker_main or context.final_scoring_step or context.before or context.end_of_round or context.setting_blind or context.discard or context.buying_card or context.selling_card or context.reroll_shop then
            local copy = math.random(1,2)
            if copy == 1 then
                local other_joker = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
                end
                return {
                    SMODS.blueprint_effect(card, other_joker, context),
                    message = {"RIGHT"}
                }
            end
            if copy == 2 then
                local other_joker = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i - 1] end
                end
                return {
                    SMODS.blueprint_effect(card, other_joker, context),
                    message = {"LEFT"}
                }
            end
        end
    end
}

SMODS.Joker
{
    key = "glitchyness",
    rarity = 3,
    cost = 9,
    blueprint_compat = true,
    loc_txt = {
        name = "Glitchyness",
        text = {
            "{C:green,E:1}#1# in #2#{} {C:attention}FIXED CHANCE{} to retrigger",
            "all scoring cards",
            "{V:1}surely not putting a limit to this will not bite me back, right?{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 6, y = 2},
    config = {extra = {immutable = {odds = 2}}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.immutable.odds, "xmpl_glitchyness", false, true)
        return {vars = {numerator, denominator, colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        func = function (card, context, count)
            if SMODS.pseudorandom_probability(card, "xmpl_glitchyness", 1, card.ability.extra.immutable.odds, nil, true) then
                count = count + 1
                return func(card, context, count)
            else
                return count
            end
        end
        if context.repetition and context.cardarea == G.play then
            local count = 0
            count = func(card, context, count)
            return{
                repetitions = count,
                message = "Again!"
            }
        end
    end
}

SMODS.Joker
{
    key = "inverted joker",
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    loc_txt = {
        name = "Inverted Joker",
        text = {
            "{C:attention}+#1#{} Joker Slots",
            "{V:1}I was too lazy to steal the asset of negative Joker{}",
            "{V:1}actually forget that I said anything about stealing stuff{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 7, y = 2},
    config = {extra = {extra_joker_slots = 2}, card_limit = 1},
    
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.extra_joker_slots, colours = {HEX("dda0dd")}}}
    end,
    add_to_deck = function (self, card, from_debuff)
        G.jokers:change_size(card.ability.extra.extra_joker_slots)
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.jokers:change_size(-card.ability.extra.extra_joker_slots)
    end
}

SMODS.Joker
{
    key = "circle_joker",
    rarity = 1,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "Circle Joker",
        text = {
            "{C:chips}+#1#{} Chips Per {C:attention}Stone Card{} scored",
            "Currently {C:chips}+#2#{} Chips",
            "If you have four extra copies of this Joker",
            "Gives {X:chips,C:white}X#3#{} Chips",
            "{C:green,E:1}#4# in #5#{} of creating a negative copy of itself",
            "{C:green,E:1}#6# in #7#{} of destroying itself",
            "{V:1}Yes I took Jimbo and Turned him into a circle, Kinda{}",
            "{V:1}I don't regret disfiguring him{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 8, y = 2},
    config = {extra = {chips = 15, Xchips = 2, odds1 = 20, odds2 = 10, current_chips = 0}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        local numerator1, denominator1 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds1, "xmpl_circle_joker")
        local numerator2, denominator2 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds2, "xmpl_circle_joker")
        return {vars = {card.ability.extra.chips, card.ability.extra.current_chips, card.ability.extra.Xchips,
        numerator1, denominator1, numerator2, denominator2, colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and SMODS.pseudorandom_probability(card, "xmpl_circle_joker", 1, card.ability.extra.odds1) then
            return{
                SMODS.add_card
                    {
                        key = "j_xmpl_circle_joker",
                        edition = "e_negative"
                    }
            }
        end
        if context.setting_blind and not context.blueprint_card then
            if SMODS.pseudorandom_probability(card, "xmpl_circle_joker", 1, card.ability.extra.odds2) then
                SMODS.destroy_cards(card, nil, nil, true)
                return{
                    message = "DESTROYED",
                    sound = "xmpl_explode"
                }
            else
                return{
                    message = "Safe"
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, "m_stone") then
                card.ability.extra.current_chips = card.ability.extra.current_chips + card.ability.extra.chips
                return{
                    message = "Upgrade",
                    message_card = card
                }
            end
        end
        if context.joker_main then
            local count = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].config.center.key == "j_xmpl_circle_joker" then
                    count = count + 1
                end
            end
            if count >= 5 then
                return{
                    xchips = card.ability.extra.Xchips,
                    chips = card.ability.extra.current_chips
                }
            else
                return{
                    chips = card.ability.extra.current_chips
                }
            end
        end
    end
}

SMODS.Joker
{
    key = "cosmic_belt",
    rarity = 4,
    cost = 25,
    blueprint_compat = true,
    loc_txt = {
        name = "Cosmic Belt",
        text = {
            "{C:green,E:1}#1# in #2#{} chance to double the Level of played Poker hand",
            "{V:1}Made From a Supernova inside a Blackhole{}",
            "{V:1}I don't know how space works{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 9, y = 2},
    config = {extra = {odds = 4}},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "xmpl_cosmic_belt")
        return {vars = {numerator, denominator, colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.before and SMODS.pseudorandom_probability(card, "xmpl_cosmic_belt", 1, card.ability.extra.odds) then
            return{
                level_up = G.GAME.hands[context.scoring_name].level,
                message = "Level Up"
            }
        end
    end
}

SMODS.Joker
{
    key = "stained glass",
    rarity = 1,
    cost = 3,
    blueprint_compat = true,
    loc_txt = {
        name = "Stained Glass",
        text = {
            "Glass Cards Have now {C:attention}2X{} the durability",
            "{V:1}this is the ugliest stained glass ever{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 0, y = 3},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.mod_probability and not context.blueprint and context.identifier == "glass" then
            return {
                denominator = context.denominator * 2
            }
        end
    end
}

SMODS.Joker
{
    key = "switcher joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    loc_txt = {
        name = "Switching Joker",
        text = {
            {
                "Dark Mode:",
                "Gains {C:mult}+#1#{} Mult",
                "When the played card is {C:spades}Spades{} or {C:clubs}Clubs{} and is not scored",
                "Currently {C:mult}+#2#{} Mult"
            },
            {
                "Light Mode",
                "Gains {X:chips,C:white}X#3#{} Chips",
                "When the played card is {C:diamonds}Diamonds{} or {C:hearts}Hearts{} and is scored",
                "Currently {X:chips,C:white}X#4#{} Chips"
            },
            {
                "Will Switch to the other ability after a hand is Scored",
                "Current Mode: #5#",
                "{V:1}would've made it change sprites but I am a terrible programmer and artist{}"
            }

        }
    },
    atlas = "Jokers",
    pos = {x = 1, y = 3},
    config = {extra = {mult_gain = 5, current_mult = 0, Xchips_gain = 0.05, current_Xchips = 1, immutable = {current_mode = "Light"}}},
    loc_vars = function(self, info_queue, center)
        --info_queue[#info_queue+1] = {set = "Other", key = "xmpl_light_mode"}
        return {vars = {center.ability.extra.mult_gain, center.ability.extra.current_mult, center.ability.extra.Xchips_gain, center.ability.extra.current_Xchips,
        center.ability.extra.immutable.current_mode, colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == "unscored" and context.individual and (context.other_card:is_suit("Spades") or context.other_card:is_suit("Clubs")) 
        and not context.blueprint_card and card.ability.extra.immutable.current_mode == "Dark" then
            card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.mult_gain
            return{
                message = "Upgrade",
                message_card = card
            }
        end
        if context.cardarea == G.play and context.individual and (context.other_card:is_suit("Diamonds") or context.other_card:is_suit("Hearts")) 
        and not context.blueprint_card and card.ability.extra.immutable.current_mode == "Light" then
            card.ability.extra.current_Xchips = card.ability.extra.current_Xchips + card.ability.extra.Xchips_gain
            return{
                message = "Upgrade",
                message_card = card
            }
        end
        if context.joker_main then
            if card.ability.extra.immutable.current_mode == "Light" then
                card.ability.extra.immutable.current_mode = "Dark"
                return{
                    xchips = card.ability.extra.current_Xchips
                }
            elseif card.ability.extra.immutable.current_mode == "Dark" then
                card.ability.extra.immutable.current_mode = "Light"
                return{
                    mult = card.ability.extra.current_mult
                }
            end
        end
    end
}

SMODS.Joker
{
    key = "oiled joker",
    rarity = 2,
    cost = 6,
    blueprint_compat = false,
    loc_txt = {
        name = "Oily Joker",
        text = {
            "Decreases played card's rank by {C:attention}1{}",
            "{V:1}Fun Fact: almost every joker is just jimbo{}",
            "{V:1}This one looks familiar{}"
        }
    },
    atlas = "Jokers",
    pos = {x = 2, y = 3},
    config = {extra = {}},
    loc_vars = function(self, info_queue, center)
        return {vars = {colours = {HEX("dda0dd")}}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint_card then
            local cards = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                assert(SMODS.modify_rank(scored_card, -1))
            end
            return{
                message = "Rank Down"
            }
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------