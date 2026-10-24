extends SceneTree
class FailingStore:
 extends "res://scripts/SaveStore.gd"
 var stage := ""
 func copy_previous() -> Error:
  if stage == "backup": return ERR_FILE_CANT_WRITE
  return super.copy_previous()
 func commit_temporary() -> Error:
  if stage == "rename": return ERR_FILE_CANT_WRITE
  return super.commit_temporary()
const Model = preload("res://scripts/WorldModel.gd")
var checks := 0
var failures := 0
func check(ok: bool, title: String) -> void:
 checks += 1
 if not ok: failures += 1; printerr("FAIL: "+title)
func _init() -> void:
 var store = FailingStore.new()
 store.path = "user://io-failure-test.json"
 var model = Model.new()
 check(store.save_state(model.state),"initial committed save")
 var committed := FileAccess.get_file_as_string(store.path)
 model.harvest("0,0")
 for stage in ["backup","rename"]:
  store.stage = stage
  check(not store.save_state(model.state),stage+" failure reported")
  check(store.error != "","specific I/O error available")
  check(FileAccess.get_file_as_string(store.path) == committed,stage+" failure preserves committed primary")
  check(store.load_state().inventory.wood == 0,"interrupted transaction cannot become committed")
 store.stage = ""
 check(store.save_state(model.state),"retry after I/O recovery")
 check(store.load_state().inventory.wood == 1,"only recovered transaction committed")
 print("SAVE IO RESULT: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
