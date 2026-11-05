**Pocket Biome — game direction and next development priorities**

Delivery follow-up: [Implemented work and external requirements](DIRECTOR_DELIVERY.md) · [Three audits](DIRECTOR_ITERATIONS.md). The backlog below preserves the original proposal.

Review date: 2026-11-05. Source reviewed: `235e72f`. This is a proposed backlog, with experiments and release gates distinguished from committed features. The current restoration implementation is documented in [Restoration campaign](RESTORATION_CAMPAIGN.md).

The intended experience: **build a tiny living sanctuary, understand how its parts help each other, and feel proud of the world you shaped.** Moment-to-moment play should make the player feel observant, inventive and capable. The next phase should test that experience through one excellent first-session slice before expanding every system.

Current foundation: five chapters, twenty discoveries, five home restorations, earned care tools, alternate habitat layouts, wildlife preferences, four expeditions, replay attempts, crafting/automation, layout recovery, teaching and a finale. These are implemented. They are starting points for the improvements below. The existing 1,573-assertion report demonstrates technical coverage; it does not establish enjoyment or demand.

Source-based concerns: home influences predominantly accumulate toward fixed caps; evolution only advances to a higher tier; some ordinary actions require multiple sheets; expedition progression currently provides restoration records rather than useful home capabilities; full collection is mandatory for the ending. These are design risks, not observations from unfamiliar players.

A fresh constructed rules probe at `/workspace/runtime/director-review/rules_probe.gd` confirms that Rainforest remains Rainforest after its Oak is cooled to zero heat, and an Oak adjacent to Water reaches 100 moisture after sixty active ticks. This makes the distinction between permanent discovery and current ecological condition especially important. The probe is not a manual playthrough.

1. **P0 — Define and protect the core player promise.**
   - Build around a repeating sequence: notice a struggling place → form a plan → arrange neighbors → observe a visible response → refine → welcome wildlife → gain a useful option.
   - Evaluate each feature by whether it improves a decision, communicates its result, or strengthens ownership of the island.
   - Keep a clear primary path alongside optional creative and expedition goals. Maintain one consistent painted visual language.
   - Done when the opening and one complete restoration express this sequence without requiring a developer explanation.

2. **P0 — Make environmental rules understandable and interesting.**
   - Prototype conditions approaching understandable local balances, with limited positive and negative influences, instead of relying mainly on accumulation to 0/100.
   - Keep Journal discoveries permanent. Explain whether a discovered biome represents a permanent transformation or a live condition. Give struggling and thriving habitats readable appearance/status differences.
   - Resolve same-tier transformation ambiguity: offer an explicit safe change/replant route or clearly communicate permanent specialization. Test controlled transitions before changing the entire simulation; prevent rapid visual oscillation.
   - Show whether moisture/heat is rising, falling or stable. Explain the strongest nearby cause in plain language.
   - Done when a player can predict a simple Water/tree/shade interaction and recover a poorly arranged habitat without replacing tiles by trial and error. Migration, boosts, ownership, cadence and protected-node access must remain valid.

3. **P0 — Make each decision offer a tradeoff.**
   - Deepen existing alternatives: a compact habitat can conserve land but use a care slot; a broader woodland can support itself while using more space. Provide comparable benefits and costs.
   - Keep resource access and essential restoration recovery free from irreversible failure. Optional mastery can introduce tighter constraints.
   - Avoid one adjacency pattern or one production building becoming the automatic answer to every problem.
   - Done when several tested openings succeed through different placements and explainable choices, with no universally dominant layout found in the tested cases.

4. **P0 — Bring the most-used actions onto the island.**
   - Tapping land opens a compact contextual strip: inspect, move, tend, and the relevant project. Destructive restoration remains behind a clear consequence preview.
   - Expose the current project with a compact card and a direct route to its missing relationship. Keep completed projects and detailed reference material secondary.
   - Reduce repeated navigation through Pack, World, care slots and confirmation sheets. Use clear buttons with adequate touch targets and stable camera behavior.
   - Done when finding a project requirement, beginning a move and selecting a care tool each take at most two deliberate actions from normal play; final placement confirmation can remain a separate safety step.

5. **P0 — Show consequences before commitment.**
   - Placement/movement previews should show useful influence lines, affected neighbors and potential habitat losses. Explain valid/invalid destinations at the target.
   - Example: “Reaches these roots; may welcome frogs” or “Moving this tree breaks the butterfly shelter.” Show directional effects rather than claiming an exact future outcome when other influences can change it.
   - Add optional moisture, heat and habitat-connection overlays with symbols and text, not colour alone.
   - Done when the preview matches the authoritative transaction and players can explain why a placement helps before confirming it.

6. **P0 — Rebalance gathering, waiting and construction around decisions.**
   - Measure time spent collecting, waiting, arranging and browsing. Preserve Gather ready and make helpers relieve repetition at a useful point.
   - Keep construction costs and machine returns legible. Ensure a player can experiment with essential terrain without a long material-recovery penalty.
   - Prototype a safe observe/advance control or clearly visible short growth cycle for relevant situations; test energy, economy and production implications before enabling it globally. Existing active-time/offline rules must remain explicit.
   - Done when a short session contains several meaningful choices and long idle stretches are explainable and avoidable. Do not extend playtime by raising prices alone.

7. **P0 — Turn the opening into an excellent first-session slice.**
   - Refine the implemented guidance using animated cause/effect, a small visible problem and one useful tool at a time.
   - Teach error recovery: a harmless poor placement should be understandable and correctable. Keep skip/help available.
   - Prototype target: a visible success in roughly the first one to two minutes, followed by a first restoration and a useful earned tool within a short first session. These are design targets to test, not measured current completion times.
   - Done when an unfamiliar private tester understands the first Water relationship, completes the first restoration without spoken instructions and can name a goal they want to try next.

8. **P0 — Make restoration completion a visible payoff.**
   - Focus briefly on the actual completed habitat. Show its visitor arrival and environmental recovery, use a short musical response, and explain the unlocked capability in one sentence.
   - Let the player try the new capability immediately, then return to their island. Support skip and reduced motion.
   - Give each chapter a recognizable environmental problem and visible result beyond its progress counters. Reuse existing projects and art where possible.
   - Done when a player can identify what changed in the world, what they earned and why the next goal is useful.

9. **P1 — Give wildlife behavior and identity.**
   - Extend current preference-based presence with bounded behaviors: a bird travels between suitable trees, frogs gather at a sheltered water edge, butterflies follow a valid flower corridor.
   - Add a small number of memorable recurring visitors and simple field notes. Introduce one occasional habitat request that encourages a new layout rather than repeated feeding.
   - Use preference tradeoffs to create choices; avoid making every species demand the same maximized statistics.
   - Done when changing the layout visibly changes at least one understandable animal behavior. No hunger, breeding or large population simulation is required for this scope.

10. **P1 — Make expeditions valuable to home play.**
    - Award a once-only earned home option for selected first completions: a terrain variant, care modifier, visitor invitation or nonblocking decoration blueprint. Explain its use before departure and celebrate it on return.
    - Add objective families such as a two-habitat corridor, preserving a protected grove, or splitting a limited water supply. Reuse good rules before increasing board count or size.
    - Keep original restoration records, replay attempts, reward receipts and ad milestones independent. A player can finish the core home campaign without an ad or purchase.
    - Done when at least one expedition teaches a rule and gives the player a new useful home-island choice. Optional expedition rewards must not become an unexplained mandatory progression gate.

11. **P1 — Add optional mastery to replay.**
    - Keep relaxed completion as the default. Add selected authored variants: a lower supply budget, a no-replant solution, or a target season count.
    - Preserve personal bests separately from the latest attempt. Explain each constraint before starting and verify multiple legal solutions where the design promises them.
    - Reward mastery with optional presentation or recognition; do not force speed grades onto the main restoration path.
    - Done when replay involves a fresh planning decision and failure never damages the original island or home resources.

12. **P1 — Improve the campaign's climax and full-collection role.**
    - Prototype an ending based on the connected sanctuary plus selected significant restorations/discoveries; move exhaustive collection to optional mastery if it causes repetitive hunting.
    - Choose the required collection amount from observed pacing rather than setting an arbitrary new number now.
    - At first finale completion, verify a currently thriving connected habitat arrangement, while retaining permanent historical achievements and once-only rewards afterward.
    - Show the actual island's transformation and visitor life. Provide a clean credits/celebration moment and continued creative play.
    - Done when the ending tests learned spatial skills, feels climactic and remains recoverable from adverse but valid layouts. Preserve all previously earned endings.

13. **P1 — Add personal expression without consuming strategic space.**
    - Provide a small coherent set of paths, pond edges, signs, lamps and seating in a nonblocking decoration layer.
    - Start with earned items and a restrained palette. Let players name the sanctuary, preserve a before/after portrait and create distinct-looking islands from the same toolkit.
    - Keep placement, selection and terrain readability reliable around decorations. Bound rendering and save costs.
    - Done when players can personalize a small island without sacrificing necessary habitat cells or losing track of selectable land.

14. **P1 — Add a light narrative thread.**
    - Give the island a reason to need restoration and let recurring visitors or short journal observations acknowledge progress.
    - Use short, skippable moments tied to actual accomplishments: the first frog, a sheltered workshop, the first connected migration route.
    - Avoid lengthy opening dialogue. Make ecological results carry most of the storytelling.
    - Done when a player can describe why they are restoring the island and recognizes at least one returning presence by the finale.

15. **P1 — Make animation and audio explain game state.**
    - Preserve the painted assets. Emphasize localized water flow, recovering foliage, shade, useful machine activity and visitor arrival/departure. Avoid unrelated particles that obscure placement.
    - Add restrained layers of environmental sound and distinct cues for ready, placed, recovered, discovered and unlocked states.
    - Prioritize contrast, touch feedback, reduced motion, colour-independent symbols, readable small-phone text and sensible audio mixing.
    - Done when key changes are understandable with sound off, and remain clear with reduced motion enabled. Listening and phone review are required; screenshot differences alone cannot validate this.

16. **P1 — Give returning players a clear, calm re-entry.**
    - On resume, show the unfinished project, any ready blueprint and a relevant visitor observation. Let the player return directly to the island.
    - Add a bounded authored optional challenge rotation after the main loop works. Avoid required streaks or permanent loss for missing days.
    - Keep offline behavior and any paused environmental challenge explicit.
    - Done when a returning player can identify a useful action without reconstructing their entire plan from several menus.

17. **P0 validation — Build a private feedback loop.**
    - Add an opt-in local playtest report covering time to first success, project completions, help use, canceled/stale placements, long gaps without progress, route depth and save errors. Build a bounded debug view of it.
    - Combine scripted touch walkthroughs, blind rule-based agents, adverse-layout tests and direct private observation. Each catches different problems; automated agents cannot establish enjoyment.
    - A small initial set of individual unfamiliar-player sessions can reveal comprehension failures. If personal testers are unavailable, use invited or paid private testing when feasible; a public launch is not required. Keep recordings and exported reports under the tester's control.
    - Starting acceptance target: in five exploratory sessions, at least four players reach the first restoration without spoken guidance and can explain a cause/effect relationship. Treat this as a small usability gate, not a market success or retention estimate. Ask what they planned to do next and observe whether they choose to continue.

18. **P0/P1 release — Prove native reliability and accessibility.**
    - Test current builds on representative physical Android devices for touch, cutouts, readable UI, rendering, memory, heat and long sessions.
    - Verify background/return, process death, replacement installs, interrupted placement and failed-save recovery. Define any backup/export and restore UX before promising save portability.
    - Exercise offline/no-fill ads, interrupted consent, billing restore, Remove Ads and reward/save failures through real provider sandbox flows.
    - Done when evidence matches the exact signed source/build intended for distribution. Existing desktop checks and static APK audits cover part of this, not device acceptance.

19. **P1 commercial — Make revenue measurable and protect the experience.**
    - Keep the hybrid model: restrained interstitials at completed chapter/expedition transitions, optional rewarded extras and Remove Ads. Preserve teaching, placement, celebrations and active decisions from automatic interruptions.
    - Begin qualification with current delay/spacing/caps. Adjust frequency only after observing sessions, retention and confirmed ad results.
    - Implement separate request, load, no-fill, impression, dismissal and paid-revenue callbacks. Existing `interstitial_shown` is dispatch evidence, not proof of a paid impression. Avoid double counting.
    - Set the intended audience and publisher/consent configuration, production signing, policy/support URLs and billing setup. Do not invent account details or assume audience classification.
    - Evaluate income against acquired and retained players, confirmed impressions and net yield. Filling more slots cannot guarantee revenue. Acquisition/distribution economics are a separate part of the business plan.
    - Done when native callbacks, entitlement/reward safety and actual test reports agree; commercial performance still requires real operating data.

20. **Later — Expand only the systems players value.**
    - Candidates after core validation: additional connected regions, a small curated expedition pack, new visitor behaviors and a modest earned cosmetic collection.
    - Defer multiplayer, broad animal breeding, many new currencies, an enormous crafting tree, compulsory daily chores and unbounded procedural maps.
    - Expansion gate: the current slice is understandable, players willingly continue, core reliability is demonstrated and the new content reinforces a validated activity.

**Delivery order**

| Delivery | Scope | Exit evidence |
|---|---|---|
| A — Strong first session | Rule clarity prototype, consequential previews, direct contextual actions, balanced first project and visible payoff; local playtest reporting | A complete privately testable opening with clear cause/effect and safe recovery |
| B — Satisfying campaign | Apply proven rules to chapter goals; wildlife behavior; expedition-to-home reward; climax/full-collection decision | Multiple deliberate solutions, end-to-end earned progression and private player feedback |
| C — Replay and ownership | Selected mastery variants, personal bests, restrained decorations, returning-player summary | Fresh optional goals and personal expression without mandatory chores |
| D — Release qualification | Device/lifecycle/accessibility, native monetization and billing, signing, policies, truthful store presentation | Evidence for the exact release candidate; retention and revenue evaluated through measured operation |

These deliveries describe order and acceptance, not a promise of completion dates. Re-estimate after the rule and interaction prototypes. Keep feature experiments reversible, migrate saves explicitly, and avoid growing the backlog to disguise a weak first session.

**Recommendation:** build Delivery A first. The immediate design goal is a player who understands a problem, tries their own solution, sees the island respond and wants to make one more improvement.
