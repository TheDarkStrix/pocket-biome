extends RefCounted
# Operational session counters. Only native callbacks count impressions/paid value.
const EVENTS = ["request","loaded","no_fill","load_failed","show_requested","impression","dismissed","show_failed","paid"]
var counts := {}
var placements := {}
var paid_micros := {}
var seen := {}
func ingest(payload: String) -> Dictionary:
 var value = JSON.parse_string(payload)
 if not value is Dictionary or value.get("event") not in EVENTS or value.get("kind") not in ["rewarded","interstitial"] or not value.get("placement") is String or value.placement.is_empty() or value.placement.length() > 80: return {}
 var token: String = value.placement+":"+value.event
 if seen.has(token): return {}
 if value.event == "paid":
  var amount = value.get("value_micros")
  var currency = value.get("currency")
  if not (amount is int or amount is float) or not is_finite(float(amount)) or amount < 0 or amount != floorf(amount) or amount > 1000000000000: return {}
  if not currency is String or currency.length() != 3 or currency != currency.to_upper(): return {}
  for character in currency:
   if character.unicode_at(0) < 65 or character.unicode_at(0) > 90: return {}
 seen[token] = true
 while seen.size() > 512: seen.erase(seen.keys()[0])
 var key: String = value.kind+"_"+value.event
 counts[key] = int(counts.get(key,0))+1
 var context: String = value.get("context","") if value.get("context","") is String else ""
 if context not in ["chapter","habitat","river","expedition","expedition_replay","mastery"]: context = "unattributed"
 var placement_key: String = value.kind+":"+context
 if not placements.has(placement_key): placements[placement_key] = {"events":{},"paid_micros_by_currency":{}}
 var summary: Dictionary = placements[placement_key]
 summary.events[value.event] = int(summary.events.get(value.event,0))+1
 var safe := {"event":value.event,"kind":value.kind,"context":context}
 if value.event == "paid":
  paid_micros[value.currency] = int(paid_micros.get(value.currency,0))+int(value.value_micros)
  summary.paid_micros_by_currency[value.currency] = int(summary.paid_micros_by_currency.get(value.currency,0))+int(value.value_micros)
  safe["currency"] = value.currency; safe["value_micros"] = int(value.value_micros)
 return safe
func report() -> String:
 return JSON.stringify({"scope":"Current app session; SDK-reported paid value is not a publisher payout. Requests are not impressions. Currencies are never combined.","counts":counts,"placements":placements,"paid_micros_by_currency":paid_micros},"  ")
