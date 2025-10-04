JAS = SMODS.current_mod

JAS.optional_features = {
    retrigger_joker = true,
    cardareas = {discard = true, deck = true},
    quantum_enhancements = true
}

assert(SMODS.load_file("Items/Jokers.lua"))()
assert(SMODS.load_file("Items/Editions.lua"))()
assert(SMODS.load_file("Items/Tarots.lua"))()
assert(SMODS.load_file("Items/Spectral.lua"))()
assert(SMODS.load_file("Items/Enhancements.lua"))()
assert(SMODS.load_file("Items/Seals.lua"))()