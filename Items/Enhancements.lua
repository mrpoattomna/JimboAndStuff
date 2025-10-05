SMODS.Atlas{
    key = "enhancements",
    path = "Enhancements.png",
    px = 71,
    py = 95
}

SMODS.Enhancement{
    key = "growth",
    atlas = "enhancements",
    pos = {x = 0, y = 0},
    config = {extra = {mult = 2, chips = 5}},
    loc_txt = {
        name = "Growth",
        text = {
            "When scored card Gains",
            "{C:mult}+#1#{} Mult",
            "{C:chips}+#2#{} Chips"
        }
    },
    loc_vars = function (self, info_queue, card)
        return{vars = {card.ability.extra.mult, card.ability.extra.chips}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.perma_bonus = (card.ability.perma_bonus or 0) +
                card.ability.extra.chips
            card.ability.perma_mult = (card.ability.perma_mult or 0) +
                card.ability.extra.mult
            return {
                card = card,
                message = "Upgrade"
            }
        end
    end
}