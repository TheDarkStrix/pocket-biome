# Ready-resource gathering

After the first individual harvest, a labelled Gather ready control appears during ordinary home-island play. It collects every currently ready node that fits storage, once per node. It remains present but disabled at zero ready nodes, so cooldown changes do not make the camera/layout jump. Draft resume, placement/Pulse cancellation and the sanctuary-fusion shortcut keep their existing meanings and priority. Pack provides the same action and updates its count when cooldowns finish.

The action plans collection in sorted tile order with a virtual inventory, so several nodes producing one resource cannot overbook its remaining storage. Fusion owner/reservation cells are counted once. It then invokes the existing per-node harvest authority, preserving yields, Coins, chapter/tutorial rewards, storage limits and cooldowns. It never calls harvest on cooling nodes, so repeated Gather presses cannot accelerate timers. The preview is read-only. Individual tile harvesting and its existing interactions remain available.

The UI gives one audio/haptic response, bounded resource flights and a combined collection summary. It persists the batch and refreshes resource/queue state. Gather is hidden or guarded during title, photo, unrelated modal, placement and targeting flows. It does not perform automatic/offline collection and does not change the economy or grant an ad reward.

The floating button occupies the lower corner of the world region rather than adding a permanent footer row. Tests cover touch activation, exact equivalence to individual ready-node harvests, rapid repeat, storage limits/shared-resource capacity, cooldown recovery, modal/placement priority, saved rewards, six phone/text-size configurations and preservation of world-first screen allocation. Rendered fixtures are retained at `/workspace/runtime/gather-review`.

This reduces repeated collection inputs. Its impact on novice enjoyment and session pacing still requires player observation; no percentage reduction in human tap count or retention improvement is claimed.

Final private Android validation: eight Python audit tests, 1,383 assertions across 25 Godot suites, both original campaign completion probes and startup passed. Universal and ARM64 package signature/alignment/content checks passed. Nothing was publicly distributed.
