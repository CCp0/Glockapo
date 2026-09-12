# Glockapo — Tech Plan (Draft 2)

Status: **planning phase, nothing built yet**. This document is the blueprint the
implementation work will follow. Numeric values marked *(tunable)* are
placeholders to wire up first and balance later, not final design.

## 1. Premise recap

A kakapo with a glock stands in a ground arena shooting flying birds. Kills
drop rocks; filling a rock counter (20) unlocks a "Fly" button that launches
a vertical ascent mini-sequence where the kakapo flies by pointing its
glock(s) at the ground and firing, burning rocks as fuel while dodging
obstacles, ending in a nest-destruction cutscene. Then it loops back into a
harder arena wave. Target platforms: phone (touch) and desktop, from one
Godot 4.7 GL Compatibility project.

**First end-to-end draft is a single biome: a forest arena with wood
pigeons.** The game is planned so that a sea arena (seagulls) and a city
arena (city pigeons) can be added later as data, not rewritten code — see
§4.

## 2. Decisions locked in during planning

| Question | Decision |
|---|---|
| Controls | Phone: virtual joystick (move) + fire button. Desktop: WASD move, mouse aim, left‑click fire. Both feed the same abstracted input layer. |
| Post-nest loop | Return to the ground arena with a **harder** wave (more/faster enemies); endless arcade structure, no fixed ending. |
| Branch-hopping vs. Fly sequence | **Two separate mechanics.** Down-shot recoil hops to branch/stump platforms happen *inside* the ground arena (local, cheap, no rock cost). The 20-rock "Fly" sequence is a distinct full-screen vertical-ascent scene/transition. |
| Fail state | Kakapo has HP. Enemies can damage it on contact/dive, in both the arena and the flight sequence. 0 HP → game-over screen with score, then restart. |
| Flight combat capability | **None.** Flight is entirely movement/dodging — glocks fire only for propulsion (recoil), bullets in this mode never damage anything. Obstacles (branches, diving birds) must be dodged, not shot. |
| Running out of rocks mid-flight | Kakapo immediately drops back into the ground arena (rocks = 0) and resumes fighting to build the count back up — no cutscene, no HP penalty just for running dry. |
| Biome scope for draft 1 | Forest + wood pigeons only. Sea/seagulls and city/city-pigeons are planned as additional data slots (§4), not built yet. |
| Rock threshold vs. drop rate | Threshold stays **fixed at 20** — that's the Fly-button gate, not a difficulty knob. Instead, each kill has a **percentage chance to drop a rock**, and that chance rises with wave number (harder/faster enemies later, but rocks flow in faster too). Reaching 20 never forces flight — the player can keep fighting past it (rocks bank as flight fuel, §3) for as long as they can survive, purely their call. |
| High scores | Track and persist (across app restarts) two personal-best stats: **most birds downed in a single wave**, and **most nests destroyed in a single run**. Shown on the game-over screen alongside that run's numbers. **On-device only for this draft** — local save file, no accounts or online leaderboard. |

## 3. Open assumptions (flag for confirmation before/while building)

Everything previously listed here was confirmed correct except the
mid-flight fallback, which is now a locked decision (§2). Remaining
placeholders:

- **Lateral flight cost**: 1 rock per left/right shot during Fly ascent (vs.
  2 rocks for a straight-up shot), since it moves you less vertically.
- **Rock carry-over**: rocks keep accumulating past 20 while the Fly button
  is visible (you don't have to press it the instant it lights up), and
  the *entire* current rock balance becomes your flight fuel budget when
  you press Fly.
- **Reload**: 8-round mag, infinite reserve ammo, auto-reload on empty with
  a short lockout *(tunable ~0.6s)*; also manually triggerable (R key /
  reload button on touch) to reload early during a lull.
- **Difficulty ramp per wave**: enemy spawn rate and speed increase per
  loop; rock threshold stays fixed at 20 (§2) throughout.
- **Rock drop chance curve**: starts around 50% per kill in wave 1,
  +5 percentage points per wave, capped at 100% *(tunable — direction is
  locked per §2, exact numbers are the thing to balance in playtesting)*.
- **Nest height**: ascent scene has a fixed world-space height to climb;
  scales slightly per wave alongside enemy difficulty.
- **Pickup collection**: rocks drop as physical pickups enemies leave
  behind that the kakapo must walk over (Area2D overlap), not auto-granted
  on kill — gives the arena a little more movement/positioning value.
- **Flight obstacle damage/spawn rate**: obstacle contact damage and
  spawn cadence during ascent are tunable constants, balanced once the
  scene is playable; kakapo likely keeps the same brief hit-invincibility
  window used in the arena so obstacles can't chain-hit it every frame.

## 4. Biome abstraction (built now, populated later)

To keep forest/sea/city as a data swap rather than a rewrite, enemies,
platforms, and flight obstacles are all driven by a `BiomeConfig` resource
instead of being hardcoded to "pigeon."

`resources/biome_config.gd` (a `Resource` script, instanced as `.tres`
files per biome):

```gdscript
class_name BiomeConfig
extends Resource

@export var id: String                          # "forest", "sea", "city"
@export var display_name: String
@export var sky_color: Color                     # placeholder flat background until real art exists
@export var ground_color: Color                  # placeholder flat ground until real art exists
@export var platform_scenes: Array[PackedScene]   # forest: branch/stump; sea: buoy/dock; city: ledge/awning
@export var enemy_scene: PackedScene              # forest: wood_pigeon.tscn
@export var flight_obstacle_scenes: Array[PackedScene] # forest: falling_branch.tscn, diving_bird.tscn
```

`Arena.tscn` and `FlyAscent.tscn` both take an `active_biome: BiomeConfig`
(set via `GameState.current_biome`, defaulting to `forest.tres`) and
instance everything from it — spawners never reference `wood_pigeon.tscn`
directly, they reference `GameState.current_biome.enemy_scene`.

Enemies share a common base so new biome variants are just new stats/art,
not new logic:

- `EnemyBase.gd` (`CharacterBody2D`): exported `speed`, `health`,
  `contact_damage`, `rock_drop_count`; generic flight-pattern hook
  (`_movement_pattern(delta)`) that subclass scenes can override via a
  `movement_pattern` enum (`STRAIGHT`, `SINE_DRIFT`, `DIVE`) rather than
  needing a new script per bird.
- `WoodPigeon.tscn` (draft 1): `EnemyBase` + wood-pigeon placeholder sprite
  + `STRAIGHT`/`SINE_DRIFT` pattern, moderate stats.
- Future `Seagull.tscn`, `CityPigeon.tscn`: same base, different sprite,
  stats, and pattern — no script changes expected.

Flight obstacles get an equally thin base (`FlightObstacleBase.gd`, an
`Area2D` that scrolls down-screen and deals `contact_damage` on overlap),
with `FallingBranch.tscn` and `DivingBird.tscn` as the two forest variants
for draft 1 (§12).

This is intentionally the *only* forward-looking abstraction in this plan —
everything else below is written concretely against the forest/wood-pigeon
draft.

## 5. Placeholder asset list (squares/circles per your instruction)

Existing real art (`assets/`): `Kakapo Sprite.png`, `GlockSprite.png`,
`BulletSprite.png`, `branch.png`, `StumpSprite.png`. Everything else below
is a primitive placeholder until real art exists:

| Asset | Placeholder |
|---|---|
| Wood pigeon | Grey **circle** (Polygon2D/Sprite2D from a generated circle texture), small triangle notch for a beak |
| Rock pickup | Small dark-grey **square** |
| Rock counter icon (top-right HUD) | Same grey **square**, static, next to a number label |
| HP indicator (top-left HUD) | Row of small red **squares** (pips) or a rect-based bar |
| Fly button | Standard rounded-rect UI `Button`, no custom art needed |
| Nest | Cluster of brown **squares/circles** in a rough ring |
| Bird close-up "face" flash | Big grey **circle** with two small black **circle** eyes, scaled up |
| Flash banner background | Flat green **ColorRect** |
| Speed lines behind kakapo | Several thin light-green **rectangles** (`Line2D` or `ColorRect`s) animated right→left |
| Second glock (flight, off-wing) | **No new art needed** — instance/mirror the existing `GlockSprite.png` on the opposite side |
| Muzzle flash | Small yellow **square** (or reuse `BulletSprite.png` scaled) |
| Falling branch (flight obstacle) | **No new art needed** — reuse existing `branch.png`, scrolling down-screen |
| Diving bird (flight obstacle) | Same grey **circle** as the wood pigeon, oriented/moving downward |

## 6. Input architecture

Single autoload, `InputBridge` (`autoloads/input_bridge.gd`), is the only
thing gameplay code reads. It normalizes both input sources into:

```
InputBridge.move_vector   : Vector2   # from WASD or joystick
InputBridge.aim_vector    : Vector2   # from mouse-relative-to-kakapo, or joystick's own aim stick
InputBridge.fire_held     : bool
InputBridge.reload_pressed: bool
```

- **Desktop**: `move_vector` from an `InputMap` (W/A/S/D → actions
  `move_up/down/left/right`), `aim_vector` computed each frame as
  `(get_global_mouse_position() - kakapo.global_position).normalized()`,
  `fire_held` from left mouse button, `reload_pressed` from R.
- **Touch**: a `VirtualJoystick.tscn` (draggable base+knob `Control`) for
  movement, a second small joystick *or* drag-anywhere gesture for aim, and
  a dedicated fire `TouchScreenButton`/`Button` for firing. These write
  straight into `InputBridge`.
- Both control sets are always instanced; a `Platform` autoload flips
  visibility of touch controls based on `OS.has_feature("mobile")` /
  a debug override, so one build works on both.

Gameplay scripts (kakapo, weapon) never branch on platform — they only
ever read `InputBridge`.

## 7. Game state & flow

Autoload `GameState` (`autoloads/game_state.gd`) holds cross-scene data and
the top-level mode:

```gdscript
enum Mode { ARENA, FLY_TRANSITION, FLY_ASCENT, NEST_CUTSCENE, GAME_OVER }

var mode: Mode = Mode.ARENA
var rocks: int = 0
var hp: int = 5              # (tunable)
var wave: int = 1
var current_biome: BiomeConfig   # defaults to forest.tres
var birds_downed_this_wave: int = 0   # reset at the start of each wave
var nests_destroyed_this_run: int = 0 # increments per completed nest cutscene
signal rocks_changed(new_value)
signal fly_unlocked
signal hp_changed(new_value)
signal died
```

Persisted meta-progression (the two high scores, §11.1) lives in a
*separate* autoload, `HighScores`, rather than `GameState` — `GameState` is
purely per-run/session and gets reset on restart; `HighScores` survives
app restarts.

`Main.tscn` is the root scene and owns a single child slot it swaps between
`Arena.tscn`, `FlyTransition.tscn`, `FlyAscent.tscn`, and `NestCutscene.tscn`
via `get_tree().change_scene_to_packed()` or by adding/removing them under a
`CanvasLayer`/`Node2D` container (simplest: keep `Arena` persistently loaded
in the background and overlay the transition/ascent/cutscene as full-screen
`CanvasLayer`s on top, since rocks/HP/wave state must survive the round
trip). Overlay approach avoids reloading the arena and its enemy state.

Flow:

```
ARENA (fight, collect rocks, hop branches)
   │  rocks >= 20 → GameState.fly_unlocked emitted → HUD shows "Fly" button
   ▼
[player presses Fly]
   │
FLY_TRANSITION (~1.2s, non-interactive)
   │  green flash + close-up bird face + light-green speed lines banner
   ▼
FLY_ASCENT (dual-glock vertical climb, burns rocks as fuel, dodge obstacles)
   │  reaches top height → NEST_CUTSCENE
   │  rocks hit 0 before top → drop straight back into ARENA (rocks=0), keep fighting
   ▼
NEST_CUTSCENE (brief scripted animation)
   │  on finish: wave += 1, difficulty ramps, rocks = 0
   ▼
back to ARENA
```

`hp` reaching 0 at any point in `ARENA` *or* `FLY_ASCENT` interrupts to
`GAME_OVER` (score screen: waves survived, nests destroyed; restart button
resets `GameState` and reloads `Main.tscn`).

## 8. Kakapo controller

`Kakapo.tscn` — `CharacterBody2D` with:

- `Sprite2D` (Kakapo Sprite.png)
- `GlockMount` (`Marker2D`) — child `Sprite2D` for the primary glock,
  rotates to face `aim_vector`
- `GlockMount2` (`Marker2D`, hidden until `Mode.FLY_ASCENT`) — mirrored
  glock instance for the second wing, used only during flight
- `Muzzle`/`Muzzle2` (`Marker2D`) — bullet spawn points at each glock's barrel
- `CollisionShape2D`
- `Weapon.gd` component (see §9)
- `Kakapo.gd` — reads `InputBridge`, has two behavior modes:
  - **Ground mode** (`ARENA`): applies `move_vector * speed` *(tunable)*
    plus gravity, walks on the arena floor and branch/stump platforms
    (`CharacterBody2D.move_and_slide` against a `platforms` collision
    layer). Firing applies a small recoil impulse opposite the bullet
    direction *(tunable, small)*. Firing straight down while airborne (just
    left a platform edge, or mid recoil-hop) adds extra upward impulse —
    this is the "shoot down to reach a higher branch" trick, reusing the
    same recoil code path with a bigger vertical multiplier when
    `aim_vector` is close to straight down.
  - **Ascent mode** (`FLY_ASCENT`): gravity still pulls the kakapo down
    (so momentum has to be maintained by shooting), but recoil impulses
    are much larger and rock-gated, and bullets fired in this mode are
    purely cosmetic propulsion — they carry no damage and don't collide
    with obstacles:
    - `aim_vector` ≈ straight up → vertical impulse *(tunable, big)*,
      cost 2 rocks.
    - `aim_vector` ≈ left/right-and-down (glock pointed at the ground to
      the side) → impulse at ~45°: half the vertical impulse of a
      straight-up shot, plus lateral impulse in the direction opposite the
      glock (shoot down-left → kakapo moves up-and-right), cost 1 rock
      *(assumption, §3)*.
    - No rocks left → shots still fire (satisfying, infinite ammo) but
      produce no impulse; kakapo begins to fall and drops back to `ARENA`
      per §2.
    - Kakapo has no attack available here — obstacle contact (§12) is
      handled purely by dodging (`move_vector` still gives some manual
      lateral nudge alongside the recoil-driven movement, per original
      "the more rocks you get the more movement you have" framing).

## 9. Weapon system

`Weapon.gd`, attached to the kakapo (and reused as-is for both muzzles in
flight mode — just called twice with different mount/muzzle references):

```gdscript
const MAG_SIZE := 8
var rounds_in_mag := MAG_SIZE
var reloading := false

func try_fire(aim_dir: Vector2, muzzle: Marker2D) -> Dictionary:
    # returns {fired: bool, impulse: Vector2} — Kakapo.gd applies the impulse
    # per current Mode so Weapon.gd stays mode-agnostic.
```

- Infinite reserve ammo; only `rounds_in_mag` is limited.
- Auto-reload starts the instant `rounds_in_mag == 0`; `reload_pressed`
  can trigger it early. `reloading` blocks `try_fire` and drives a small
  UI/animation cue (e.g. glock sprite tint or a reload arc).
- Bullets: pooled `Bullet.tscn` (`Area2D`, `BulletSprite.png`), fixed speed
  and lifetime, collision layer `player_bullets`, hits `enemies` layer only,
  and is spawned with collision disabled entirely while `Mode == FLY_ASCENT`
  (propulsion-only, per §8).

## 10. Wood pigeon (draft-1 enemy)

`WoodPigeon.tscn` extends `EnemyBase` (§4):

- Placeholder circle sprite (§5).
- `EnemySpawner.gd` on the arena spawns `GameState.current_biome.enemy_scene`
  at an interval/count driven by `GameState.wave` *(tunable curve)*, using
  the base's `SINE_DRIFT`/`STRAIGHT` movement patterns.
- 1–2 hit health *(tunable)*; on death, `GameState.birds_downed_this_wave += 1`
  and, per the wave's current drop chance (§3), spawn `RockPickup.tscn` at
  its position (falls to the ground under gravity, kakapo collects on
  overlap).
- Contact with the kakapo (or an occasional dive-attack toward it) deals
  damage → `GameState.hp -= 1` *(tunable)*, brief invincibility window on
  the kakapo after a hit to avoid instant-chunking.

## 11. Rock economy & HUD

- `RockPickup.tscn`: `Area2D` + square sprite; on kakapo overlap,
  `GameState.rocks += 1`, queue_free.
- HUD (`CanvasLayer` in `Main.tscn`):
  - Top-right: rock square icon + `Label` bound to `rocks_changed`.
  - Top-left: HP pips bound to `hp_changed`.
  - "Fly" `Button`, hidden until `fly_unlocked`, then shown; pressing it
    sets `GameState.mode = FLY_TRANSITION` and disables further arena input.

### 11.1 High scores & persistence

`HighScores` autoload (`autoloads/high_scores.gd`), backed by a
`ConfigFile` saved to `user://highscores.cfg` so it survives app restarts
(separate from `GameState`, which resets every run):

```gdscript
var best_birds_per_wave: int = 0
var best_nests_destroyed: int = 0

func report_wave_ended(birds_this_wave: int) -> bool:   # true if it's a new best
    ...
func report_nest_destroyed(nests_this_run: int) -> bool:
    ...
```

- **Most birds downed in a single wave**: a wave "ends" either when the
  player presses Fly or when they die — at that point
  `GameState.birds_downed_this_wave` is compared against
  `best_birds_per_wave` and the counter resets for the next wave.
- **Most nests destroyed in a single run**: `GameState.nests_destroyed_this_run`
  increments every time `NestCutscene` completes (§14); since it's
  monotonic within a run, it's compared/saved the moment it increases, and
  also again at game-over as a final check.
- The game-over screen (§7 flow) shows this run's final numbers next to
  the persisted bests, with a "NEW BEST!" callout when either was beaten.

## 12. Fly transition scene

`FlyTransition.tscn` — full-screen `CanvasLayer`, non-interactive, timed
via `AnimationPlayer`:

1. Flat green `ColorRect` fills the screen.
2. Big circular "bird face" placeholder pops in center/close-up.
3. Several thin light-green rectangles (`Line2D`s or `ColorRect`s) animate
   left-ward behind a small kakapo banner graphic, looping for the
   duration, to sell "flying fast."
4. After ~1.2s *(tunable)*, emits `finished` → `Main.gd` swaps to
   `FLY_ASCENT`.

## 13. Fly ascent scene

`FlyAscent.tscn` — vertical scene, camera follows kakapo upward against a
scrolling/parallax background (placeholder: plain color + simple cloud
squares). Kakapo enters with `GameState.rocks` as its fuel budget (HUD
rock counter now doubles as "fuel remaining" and visibly ticks down).
Both `GlockMount`/`GlockMount2` visible and active, but non-lethal (§8).

**Obstacles** (`ObstacleSpawner.gd`, driven by
`GameState.current_biome.flight_obstacle_scenes`):

- `FallingBranch.tscn` — reuses `branch.png`, scrolls down-screen at a
  fixed lane/x-position *(tunable spawn rate/lanes)*, static hazard the
  kakapo must steer around.
- `DivingBird.tscn` — reuses the wood-pigeon placeholder circle, drops
  down-screen faster and can drift toward the kakapo's x-position
  *(tunable)*.
- Both extend `FlightObstacleBase` (`Area2D`), dealing `contact_damage` to
  the kakapo on overlap and respecting the same brief hit-invincibility
  window as arena contact damage (§3).

Reaching a target world `y` position triggers `NEST_CUTSCENE`. Hitting 0
rocks before that drops the kakapo straight back into `ARENA` (§2/§8) —
no obstacle can be present at that exact instant since falling doesn't
persist a partial ascent; the arena reload is treated as returning to a
clean fight.

## 14. Nest cutscene

`NestCutscene.tscn` — short, non-interactive `AnimationPlayer` sequence:
kakapo sprite at a placeholder nest (brown squares/circles), a quick
peck/attack animation (even just a scale/shake tween on v1), then
`Main.gd` increments `GameState.wave` and `GameState.nests_destroyed_this_run`
(checking it against `HighScores.best_nests_destroyed`, §11.1), resets
`rocks = 0`, bumps the enemy spawner's difficulty, and returns to `ARENA`.

## 15. Collision layers

| Layer | Members |
|---|---|
| `ground` | Arena floor, walls |
| `platforms` | Branch, stump (one-way-up if desired) |
| `player` | Kakapo body |
| `player_bullets` | Bullets fired by kakapo (ground mode only — disabled in flight) |
| `enemies` | Wood pigeon bodies (future: seagull, city pigeon) |
| `pickups` | Rock pickups |
| `flight_obstacles` | Falling branches, diving birds (flight scene only) |

Bullets: mask `enemies` only, and only exist as collidable in `ARENA` mode.
Kakapo body: mask `ground`, `platforms`, `enemies`, `pickups` in the arena;
`flight_obstacles` in the ascent scene.

## 16. Proposed folder structure

```
autoloads/
  game_state.gd
  input_bridge.gd
  high_scores.gd
resources/
  biome_config.gd
  biomes/
    forest.tres            # sea.tres, city.tres added later
scenes/
  main.tscn
  arena.tscn            # existing arena.tscn becomes this, or is nested under it
  kakapo.tscn
  bullet.tscn
  enemies/
    enemy_base.tscn
    wood_pigeon.tscn
  rock_pickup.tscn
  fly_transition.tscn
  fly_ascent.tscn
  flight_obstacles/
    flight_obstacle_base.tscn
    falling_branch.tscn
    diving_bird.tscn
  nest_cutscene.tscn
  ui/
    hud.tscn
    virtual_joystick.tscn
    game_over.tscn
scripts/
  kakapo.gd
  weapon.gd
  enemy_base.gd
  enemy_spawner.gd
  flight_obstacle_base.gd
  obstacle_spawner.gd
assets/
  kakapo/ glock/ platforms/   # existing
  pigeon/ rocks/ nest/ fx/ ui/  # new placeholder primitives
docs/
  TECH_PLAN.md            # this file
```

## 17. Build order (feature-by-feature, one commit-sized chunk each)

Matches how you want to build it — each step is playable/visible on its own
before the next is layered in:

1. **Arena & general scene** — forest ground, camera, branch/stump
   platforms placed and collidable, no characters yet. Confirms the biome
   scaffolding (`BiomeConfig`, `forest.tres`) loads and drives what's drawn.
2. **Kakapo + movement** — drop the kakapo into the arena, ground-mode
   `CharacterBody2D` movement via `InputBridge` (WASD/joystick), gravity,
   platform collision. No gun yet.
3. **Gun** — `Weapon.gd`, aiming (mouse/aim-stick), firing, bullets, 8-round
   mag + reload, ground-mode recoil (including the down-shot platform-hop
   trick). No enemies yet, so this is testable by shooting into space.
4. **Wood pigeons** — `EnemyBase`/`WoodPigeon`, spawner, health, contact
   damage, percentage-based rock drop scaling with wave, HP pips +
   game-over screen (damage has to land somewhere once enemies exist).
5. **Rocks** — pickups, rock HUD counter, 20-rock threshold, Fly button,
   `birds_downed_this_wave` tracking, and a first pass at the `HighScores`
   autoload + game-over screen showing this run's numbers vs. persisted
   bests (both high-score stats are earnable from this point on, even
   before flight exists).
6. **Flight** — transition scene (green flash/banner), ascent scene with
   dual-glock propulsion physics, `FallingBranch`/`DivingBird` obstacles,
   rock-fuel burn, empty-rocks fallback to arena, nest cutscene (feeding
   `nests_destroyed_this_run` and its high score), wave-loop difficulty ramp.
7. **Cleanup & animations** — tune every `(tunable)` constant (including
   the rock-drop-chance curve), polish hit feedback/invincibility flicker,
   swap placeholder squares/circles for real art as it arrives, verify
   touch controls on an actual device, sanity-check that a second
   `BiomeConfig` (even a throwaway test one) could be dropped in without
   touching gameplay scripts.

## 18. Remaining questions for you

- Lateral flight cost and rock carry-over rule (§3) — still open, low-risk
  defaults, flag if you want them different before step 6.
- Target aspect ratio / reference resolution: picked a portrait 720×1280
  base viewport for the first commit (suits a mobile shooter and gives the
  Fly ascent room to climb vertically), with `stretch/aspect=expand` so it
  scales to other device ratios. Trivial to change — flag if you'd rather
  go landscape.
- Rock-drop-chance curve specifics (starting %, per-wave increment, cap)
  are a first guess (§3) — fine to leave for playtesting unless you have
  numbers in mind already.
- Any music/SFX plan for this draft, or purely visual/mechanical for now?

---
*File lives at `docs/TECH_PLAN.md`, inside the project's `res://` tree —
update it as decisions change rather than letting it drift from reality.*
