extends SceneTree
const Model=preload("res://scripts/WorldModel.gd")
const Hub=preload("res://scripts/ServiceHub.gd")
class Bridge extends RefCounted:
 var shown:=0
 func showInterstitialAt(_kind: String) -> void:shown+=1
var checks:=0
var failures:=0
func check(ok: bool, text: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+text)
func _init() -> void:call_deferred("run")
func run() -> void:
 var reports:=[]
 for scenario in ["short_first_session","story_session","returning_mastery"]:
  var h=Hub.new();h.model=Model.new();h.model.state.learning={"completed":true};h.cadence.path="user://exposure-%d.json" % Time.get_ticks_usec();h.clock_override=10000;root.add_child(h);h.bridge=Bridge.new()
  if scenario=="returning_mastery":h.cadence.impressions=[5000.0]
  var schedule:Dictionary={90:"habitat",220:"expedition"} if scenario=="short_first_session" else {100:"habitat",400:"river",500:"chapter",700:"habitat",900:"expedition",1100:"chapter",1300:"habitat",1500:"chapter",1700:"mastery"}
  if scenario=="returning_mastery":
   schedule={}
   for second in range(120,1801,120):schedule[second]="mastery"
  var limit:=300 if scenario=="short_first_session" else 1800
  var impressions:=[];var prior_baseline:=[];var previous_old:=-10000
  for second in range(1,limit+1):
   h.clock_override+=1;h.advance_play_time(1)
   if not schedule.has(second):continue
   var kind:String=schedule[second]
   h.interstitial_ready=true;h.offer_break(kind,str(second))
   if h.maybe_interstitial(kind):
    var token:String=scenario+":"+str(second)
    for event in ["show_requested","impression","dismissed"]:h._ad_lifecycle(JSON.stringify({"event":event,"kind":"interstitial","placement":token,"context":kind}))
    impressions.append(second)
   # Retained old timing/cap for illustrative comparison. Old replay/mastery had no placement.
   if second>=480 and second-previous_old>=600 and prior_baseline.size()<2 and kind not in ["mastery","expedition_replay"]:
    prior_baseline.append(second);previous_old=second
  for index in range(1,impressions.size()):check(impressions[index]-impressions[index-1]>=180,"all simulated exposures retain format spacing")
  check(impressions.size()<=6,"every half-hour scenario obeys the rolling cap")
  reports.append({"scenario":scenario,"active_seconds":limit,"new_simulated_impressions":impressions,"old_timing_cap_comparison":prior_baseline,"opportunities":h.opportunity_counts,"blocked":h.blocked_counts})
  h.queue_free();await process_frame
 check(reports[0].new_simulated_impressions.size()==1 and reports[0].old_timing_cap_comparison.is_empty(),"a valid short first session can monetize after the protected opening")
 check(reports[2].new_simulated_impressions.size()>0 and reports[2].old_timing_cap_comparison.is_empty(),"returning challenge sessions have genuine automatic monetization opportunities")
 var result={"passed":failures==0,"scenarios":reports,"scope":"Synthetic completed-result schedules with 100% simulated SDK fill. Policy exposure coverage only; not real impressions, retention, eCPM, income or proof of an optimal cadence."}
 var file=FileAccess.open("res://artifacts/ad-exposure.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"  "));file.close()
 print("AD EXPOSURE RESULT: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
