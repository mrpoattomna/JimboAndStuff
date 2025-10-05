SMODS.Atlas{
    key = "seals",
    path = "seals.png",
    px = 27,
    py = 27
}

SMODS.Sound({
    key = "vine",
    path = "vine-boom.ogg"
})

SMODS.Sound({
    key = "bruh",
    path = "bruh.ogg"
})

SMODS.Seal{
    key = "epik_face",
    atlas = "seals",
    pos = {x= 0, y = 0},
    badge_colour = G.C.YELLOW,
    config = {extra = {odds1 = 4, odds2 = 3, retriggers = 3}},
    loc_txt = {
        name = "EpiK Face",
        label = "VERY EPIK",
        text = {
            "Retriggers this card {C:attention}#1#{} times",
            "{C:green,E:1}#2# in #3#{} chance to destroy all cards held in hand",
            "{C:green,E:1}#4# in #5#{} chance to destroy itself"
        }
    },
    loc_vars = function (self, info_queue, card)
        local numerator1, denominator1 = SMODS.get_probability_vars(card, 1, card.ability.seal.extra.odds1, "epik_face_hand")
        local numerator2, denominator2 = SMODS.get_probability_vars(card, 1, card.ability.seal.extra.odds2, "epik_face_itself")
        return{vars = {card.ability.seal.extra.retriggers, numerator1 , denominator1, numerator2, denominator2}}
    end,
    calculate = function (self, card, context)
        if context.final_scoring_step and context.cardarea == G.play and SMODS.pseudorandom_probability(card, "xmpl_epik_face_hand", 1, card.ability.seal.extra.odds1) then
            for i = 1, #G.hand.cards do
                SMODS.destroy_cards(G.hand.cards[i])
            end
            return{
                message = "EPIK PRANK",
                sound = "xmpl_bruh"
            }
        end
        if context.after and context.cardarea == G.play and SMODS.pseudorandom_probability(card, "xmpl_epik_face", 1, card.ability.seal.extra.odds2) then
            SMODS.destroy_cards(card)
            return{
                remove = true,
                message = "EPIK OUTRO",
                sound = "xmpl_vine"
            }
        end
        if context.repetition then
            return {
                repetitions = card.ability.seal.extra.retriggers,
            }
        end
    end
}