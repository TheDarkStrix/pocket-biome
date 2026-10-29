# Concept-to-game comparison — 0.19

Reference: the original four-panel board [cohesive-ui-concept.png](cohesive-ui-concept.png), generated in this project and selected by the user. This is an element-by-element implementation audit. The board remains a proposal image; actual gameplay uses independent runtime assets and live controls.

| Reference element | Implemented runtime counterpart | Evidence / limit |
| --- | --- | --- |
| Warm cloud realm and distant wooded islands | Painted sky with foreground foliage, distance haze and controlled drift/lighting | Actual views60–64; one background plate, not separately animated distant islands |
| Deep floating island silhouette | Occupied-cell cliff mesh with painted stone, irregular tips, hanging roots and local mist | Expansion, fusion reservations, irregular layouts and all four quarter turns supported |
| Water descending from the island | Shader-animated ribbons and spray at up to two exposed unfrozen water edges | Real native0.18 outlet and environment tests; water type and boundary determine eligibility |
| Connected grassy surface | Shared textured caps; runtime polygon clipping removes baked sprite soil skirts |0.19 removes the stack of separate raised pads; atlas surface colors/prop forms still differ from the illustration |
| Oak, pond, rocks, planting beds, structures | Existing authored-atlas terrain/node/structure sprites | Real data-driven objects; not a literal reconstruction of the illustration's island arrangement |
| Wood/leaf Pocket Biome logo | Independent transparent illustrated logo on the live title scene | No concept-board crop is shipped as a screen |
| One large title action | Centered green Start/Continue control | Live save-sensitive action; width360 logical pixels |
| Small sound and settings title controls | Opposite-side icon buttons; mute state indicated by tint/tooltip | About and safe New World confirmation retained in Settings |
| Compact named Wood/Stone/Coins bar | Three connected framed groups, larger painted icons and exact/compact amounts | Full eight-currency stock remains in Pack; other materials were not removed |
| Goal-book plaque and Settings gear | Short quest plaque/book opens real next-step guidance; gear opens Settings | Live action/progress, touch and large text validated; no invented unread-count notification |
| Three tactile bottom tools | Painted medallions for Pack, larger Build, Pulse with live energy ring | Replaces five small tools; all old destinations retained |
| Pack/inventory hub | Eight illustrated stock cells and Journal/World/Projects/Trade tools | Exact counts and actual routes; its layout is original because no Pack panel was shown in the board |
| Lower Build tray over visible island | Compact framed workbench occupying at most57% of safe height | World stays visible, previous camera restored on close; it is a blocking selection tray, not free camera input through a modal |
| Land / Structures / Craft tabs | Three illustrated, touch-safe tabs | All18 configured recipes remain reachable across the three categories |
| Three visible illustrated Build choices | Horizontal selectable object shelf, retained selection, gold focus frame | Three fit at standard portrait width; horizontal swipe exposes the rest; Workbench/Windmill/Totem lead Structures |
| Highlighted structure on the actual land | Translucent selected-object preview and gold diamond on an eligible empty Meadow | Cosmetic only; selecting/browsing never reserves or deploys land |
| Material objects beside one Build action | Exact required ingredient icons and Build/Craft action; live missing-resource/prerequisite explanations | CampaignSystem owns debit, queue and completion; no mock construction |
| Finished structure placement | Same selected object changes to Place after normal queue completion | Returns to island, highlights valid Meadows; cancellation keeps blueprint; saved land draft/full island conflicts explained |
| Project/blueprint access | Working/ready summary appears when relevant and links to complete existing queues, batches and stock; idle access stays in Pack | All three slots and batch1–3 retained |
| Darkened island above Draft | Actual live diorama under a gradient scrim | Inactive expansion controls suppressed; camera restored on dismissal |
| Draft heading and coin badge | Cinzel title and framed live Coin quote | Uses saved quote, not illustrative board values |
| Three illustrated draft cards | Focusable three-card hand, raised selected card, gold edge, terrain art | Selection and Info preserve saved offers; reroll/placement use existing authorities |
| Growth / Moisture / Magic markers | Painted leaf/Dew and authored droplet symbols with readable trait names | Heat/Frost/resource traits supported for later offers too |
| Place selected terrain / Later | Green named confirmation and quiet Later action | Exact saved quote charged once; Later retains transaction |
| Consistent text and material language | Cinzel display/Lato body, cream/shadow lettering, shared slate/bronze frames and green primary action | Large-text, small-phone and touch checks; no claim of pixel-identical typography or approved creative finish |

Actual screenshots60–64 are constructed Godot art fixtures, not earned progression or generated mockups. Native evidence is scoped separately in TEST_REPORT.md. The generated medallion is an independent blank tool socket; its icon, text, energy, hit target and response remain live. No reference-game screenshot or flattened board is used as executable UI.

# # Still requires acceptance

The concept's illustrated props, individual flower arrangements, hand-shaped terrain contours and surface coloration are not identical to the current atlas artwork. Windmill blade layering/rotation remains unfinished; mist/canopy/water effects do not stand in for that missing animation. Human creative review, actual mid-range device performance/audio and provider/store qualification remain open. This pass implements the four panels' navigation/composition and transactions; it is not certification of production readiness or final visual approval.
