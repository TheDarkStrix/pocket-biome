extends RefCounted
# New quotes use revision2; already-saved quotes retain their original policy.
const CURRENT_REVISION = 2
static func price(economy: Dictionary, expansions: int, revision: int = CURRENT_REVISION) -> int:
 var count := maxi(0,expansions)
 var early := int(economy.get("expansion_linear_after",12))
 if revision == 1 or count <= early:
  return roundi(float(economy.expansion_base)*pow(float(economy.expansion_growth),count))
 var anchor := roundi(float(economy.expansion_base)*pow(float(economy.expansion_growth),early))
 return mini(int(economy.get("expansion_price_cap",360)),anchor+(count-early)*int(economy.get("expansion_linear_step",12)))
static func valid_quote(economy: Dictionary, expansions: int, quote: Dictionary) -> bool:
 var revision = quote.get("pricing_revision",1)
 if not (revision is int or revision is float) or not is_finite(float(revision)) or float(revision) != floorf(float(revision)) or int(revision) not in [1,CURRENT_REVISION]: return false
 return quote.get("cost",-1) == price(economy,expansions,int(revision))
