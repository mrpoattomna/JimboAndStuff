SMODS.Shader(
{
    key = "blueprint_edition_shader",
    path = "blueprint_edition_shader.fs"
})

SMODS.Sound({
    key = "error",
    path = "error.ogg",
})

print("hello")

SMODS.Edition
{
    key = "blueprint_edition",
    shader = "blueprint_edition_shader",
    loc_txt = {
        name = "Blueprint Edition",
        label = "Blueprint",
        text = {
            "Retriggers the Joker on the Right",
            "If on a card does nothing lol"
        }
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
            return {
                repetitions = 1
            }
        end
    end
}