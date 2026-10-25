extends RefCounted
# Seeded offers are saved by WorldModel; moving/reopening a draft never deals again.
static func deal(config: Dictionary, seed: int, expansion: int, chapter: int, reroll: bool = false) -> Array:
 var rules: Dictionary = config.draft_rules
 var pool: Array = config.draft_pools[str(mini(chapter,3))].duplicate()
 for type in rules.tutorial_cards+rules.foundation_cards:
  if not pool.has(type): pool.append(type)
 var rng := RandomNumberGenerator.new()
 rng.seed = seed+chapter*7919+(417 if reroll else 0)
 for index in range(pool.size()-1,0,-1):
  var other := rng.randi_range(0,index)
  var swap = pool[index]; pool[index] = pool[other]; pool[other] = swap
 var cards: Array = rules.tutorial_cards.duplicate() if expansion == 0 else [rules.foundation_cards[(expansion-1)%rules.foundation_cards.size()]]
 if expansion == 0 and not reroll:
  cards.append(config.draft_pools["1"][0])
  return cards
 var cursor: int = maxi(0,expansion-1)*2
 for offset in range(pool.size()):
  var candidate: String = pool[(cursor+offset)%pool.size()]
  if not cards.has(candidate): cards.append(candidate)
  if cards.size() == 3: break
 return cards
