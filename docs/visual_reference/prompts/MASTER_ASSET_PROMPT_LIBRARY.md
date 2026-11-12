# Master AI Art Prompt Library and Asset Queue

> Canonical source for the complete visual-asset backlog. This library is broader than the daily schedule: the schedule selects one prepared item per local day. Every item must pass `../ART_REVIEW_STANDARD.md` before it can be marked complete.

## Operating contract

- Coverage includes every current and planned player-facing visual category: playable cast and variants, named NPCs, common enemies, elites, bosses, props, equipment, consumables, materials, locations, exploration scenes, dungeons, battle stages, world-map art, VFX, UI illustrations, icons, and decorative interface parts.
- Canon and runtime data are authoritative. Never invent a canonical costume, weapon, location relationship, enemy species, faction emblem, or story event when the repository does not define it. Mark unresolved visual facts as **DESIGN INPUT REQUIRED** and prepare the rest of the prompt without generating until the missing fact is resolved.
- The current game identity is pixel-art characters and effects over dimensional/HD-2D Chinese myth environments, readable tactical silhouettes, block-constructed forms, restrained cinematic lighting, and the warm intimate dusk/summer-evening emotional tone. Do not copy proprietary assets or exact designs from other games.
- Character turnaround deliverable: one transparent PNG, 2×2, same model and neutral pose rotated through front 3/4, right profile, rear 3/4, left profile. Keep all limbs, hair, tail, clothing and carried gear fully visible; no labels, frames, shadows or scenery. Use the exact runtime crop dimensions in `AI_ART_PRODUCTION_SCHEDULE.md`.
- Environment deliverable: 16:9 wide composition, layered far/mid/near planes, deliberate gameplay-safe negative space, no characters, baked-in HUD, text, map pins or logos unless the item explicitly calls for an isolated UI illustration.
- Props/equipment deliverable: isolated transparent pixel-art object, front 3/4 plus orthographic side/back detail where useful, readable at inventory-icon scale; no hands/characters unless the item is an equipped-weapon reference.
- Monster/boss deliverable: transparent four-view turnaround using the same orientation/order as characters. Species, body plan, signature feature, attack silhouette and scale class must be explicit. No gore, no decorative clutter, no generic fantasy substitution.
- VFX deliverable: isolated transparent sprite-sheet/strip only when the asset pipeline explicitly supports animation; otherwise one readable key-frame concept on transparent background. State element, direction, impact origin, silhouette, palette, frame count and loop behavior. Never bake combat text or damage numbers.
- UI deliverable: isolated pixel-art component or icon on transparent background, exact aspect ratio and safe padding; no mock text unless exact in-game copy is specified. Preserve the project's angular pixel-frame language, dark blue-black base, teal normal/selected information, gold/orange enemy emphasis, red danger state.
- Every prompt must name asset ID, purpose, exact output type/canvas/aspect ratio, camera/view, composition, visual identity, palette/material, must-have details, forbidden details, and acceptance gates. If exact canvas is unknown, state **DESIGN INPUT REQUIRED — DO NOT GENERATE** rather than guessing.
- One image-generation call per America/Los_Angeles local calendar day. One selected queue item per call. Never retry on the same date. After generation, record actual outcome: `REJECTED`, `ACCEPTED FOR INTEGRATION`, `INTEGRATED — AWAITING SCREENSHOT REVIEW`, or `PRODUCTION ACCEPTED`. Only the last state counts as complete.
- When an item reaches PRODUCTION ACCEPTED, mark it complete with source path, runtime path, dimensions, file hash, exact tested commit SHA, CI run IDs, and screenshot evidence. Then advance to the next not-yet-accepted item. Rejection does not advance the completion cursor; revise and reschedule it without blocking non-generation work.

## Global copy-ready style prefix

Append this exact style contract to each asset-specific brief:

"Create original hand-crafted pixel art for a premium Chinese-mythology HD-2D turn-based JRPG. Use a deliberately limited palette, discrete intentional pixel clusters, crisp stepped contours, readable value grouping, and clean nearest-neighbor-friendly edges. Character/creature silhouettes must remain unmistakable at small gameplay scale. Use grounded Chinese mythological visual language and practical material construction. The overall world is built from readable blocks and layered planes, with restrained warm lantern light, dusk atmosphere, and a nostalgic intimate adventure mood. Do not imitate any copyrighted game asset or exact proprietary design. No photorealism, 3D render, painterly brushwork, watercolor, airbrush, smooth gradients, anti-aliased soft edges, noisy texture, blurry pixels, stock-art finish, watermark, signature, UI, lettering, or unintended background."

## A. Playable cast — individual ready briefs

### CHAR-WUKONG — Sun Wukong
**Status:** PROMPT READY; next scheduled slot 2026-11-13.  
**Output:** transparent 2×2 turnaround; runtime crop 128×192. Use the dedicated detailed prompt `2026-11-12-wukong-turnaround.md` as the authoritative full brief; do not paraphrase away its spatial locks.  
**Identity:** unmistakably simian agile adult Monkey King; expressive muzzle and ears; golden brow fillet; red/vermilion/ochre travel-battle clothing with restrained antique-gold details; lean compact silhouette. Ruyi Jingu Bang upright beside the body in anatomical right hand in all views; long monkey tail from lower back, clearly separated from legs and staff.  
**Reject:** human general face, missing/hidden/fused tail, staff across shoulders/back or diagonal, changing grip, different pose/costume between views, soft/painterly output.

### CHAR-TANG — Tang Sanzang
**Status:** PROMPT READY; schedule after Wukong.  
**Output:** transparent 2×2 turnaround; runtime crop 128×192.  
**Copy-ready brief:** "Create the same Tang Sanzang in four full-body rotated views: a calm adult Chinese Buddhist pilgrim, slender and composed, compassionate but resolute, with a clearly readable shaved monk's head, restrained Buddhist travel robes in warm saffron, muted vermilion, cream and earth tones, layered practical fabric, simple travel footwear, and a dignified pilgrim's bearing. His hands are empty or hold only a modest travel staff if and only if the approved character design specifies it; do not invent weapons or armor. Preserve identical facial structure, robe layers, proportions and stance across front 3/4, right profile, rear 3/4 and left profile. His silhouette must contrast with Wukong's agile fighter: vertical, quiet, light and unarmored. Avoid caricature, royal regalia, warrior armor, oversized prayer beads, modern monk stereotypes, extra limbs, text and scenery."  
**Must verify:** canonical monk appearance, readable robe layering, no unapproved weapon, complete sleeves/robe hem/feet.

### CHAR-BAJIE — Zhu Bajie
**Status:** PROMPT READY; schedule after Tang.  
**Output:** transparent 2×2 turnaround; runtime crop 128×192.  
**Copy-ready brief:** "Create the same Zhu Bajie in four full-body rotated views: a sturdy adult anthropomorphic pig demon with unmistakable broad pig snout, ears, tusks and expressive but intelligent eyes; broad rounded belly and powerful limbs; practical dark-ochre, muted rose, brown and travel-cloth layers; humorous warmth without becoming a childish mascot. Include the recognizable nine-toothed rake as his signature weapon, fully visible and consistently carried in the same anatomical hand and position in every view. The rake must not obscure the snout, belly silhouette, hands or feet. Show front 3/4, right profile, rear 3/4 and left profile of the same neutral battle-ready model, same proportions and costume. He must read as a loyal but flawed companion, not a generic boar monster or human soldier."  
**Must verify:** pig identity, adult proportions, belly/limb anatomy, rake teeth and handle, four-view consistency.

### CHAR-WUJING — Sha Wujing
**Status:** PROMPT READY; schedule after Bajie.  
**Output:** transparent 2×2 turnaround; runtime crop 128×192.  
**Copy-ready brief:** "Create the same Sha Wujing in four full-body rotated views: a tall, broad, dependable adult river-sand warrior with a restrained, quiet expression, rugged face, recognizable beard/hair and prayer-bead details, layered travel gear with restrained armor, and a sand/water palette of muted blue-grey, river stone, weathered brown and subdued ochre. Include the recognizable crescent-moon spade / monk's spade, with the full blade and shaft visible and held consistently in the same anatomical hand in all views. His silhouette is tall, stable and grounded, clearly distinct from Bajie's rounded mass and Wukong's compact agility. Show front 3/4, right profile, rear 3/4 and left profile of one identical model. Avoid ornate fantasy paladin armor, generic samurai styling, exaggerated monster anatomy or a second weapon."  
**Must verify:** tall stable silhouette, beard/beads, spade shape, no overlap/cropping.

### CHAR-LONGMA — Bai Longma
**Status:** PROMPT READY; schedule after Wujing.  
**Output:** transparent 2×2 turnaround; runtime crop 160×128.  
**Copy-ready brief:** "Create the same Bai Longma as a horizontal quadruped dragon-horse, never humanoid: elegant white horse body, four anatomically consistent legs and hooves, unmistakable Eastern dragon ancestry expressed through a subtle pair of horns, dragon-like facial structure, fine scale accents, flowing mane, and a long readable tail. Use restrained pearl-white, cool silver, pale blue-grey and small muted gold accents. The top-left view is front 3/4 quadruped stance; remaining views are right-side profile, rear 3/4 and left-side profile. Keep body horizontal and proportions identical. Do not add a rider, saddle, armor, wings or extra limbs unless a separate approved story variant calls for them. Avoid western unicorn/pegasus tropes, humanoid dragon, tiny pony proportions and mascot styling."  
**Must verify:** quadruped body plan, four legs/hooves, Eastern dragon cues, full tail/mane/horns.

### CHAR-YELLOW-WIND-KING — Yellow Wind King
**Status:** PROMPT READY; scheduled after Longma.  
**Output:** transparent 2×2 turnaround; runtime crop 144×192.  
**Copy-ready brief:** "Create the same imposing Yellow Wind King boss in four full-body rotated views. He is a formidable yellow/ochre/brown wind-demon with a readable weasel/marten-like demon face and muzzle, sharp alert eyes, distinctive ears, layered robes and restrained armor shaped by wind-worn cloth and practical boss protection. Use dusty ochre, sand gold, umber, muted bronze and deep shadow accents. Controlled sand/wind motifs may appear as small attached design details, but do not obscure the silhouette or become detached VFX. He must read as a named mythic boss, larger and more imposing than a common enemy, not a generic wolf, rat, human general or furry mascot. Keep all views the same model and costume; front 3/4, right profile, rear 3/4, left profile. Any weapon must be grounded in approved encounter/story data; if not specified, do not invent one."  
**Must verify:** mustelid-like demon identity, boss-scale silhouette, no generic wolf substitution, full robe/feet.

## B. Named monster and enemy roster — one asset per ID

**Deliverable for each ID:** transparent 2×2 creature turnaround, consistent orthographic camera and ground baseline, front 3/4 / right profile / rear 3/4 / left profile. Include a small scale cue only if it does not compromise the clean transparent sheet; no scenery. Use species/body plan and signature combat read below. Never merge different IDs into one generic monster sheet.

| Asset ID | In-game name | Asset-specific visual direction |
|---|---|---|
| CAVE-GHOUL | 洞窟恶鬼 | Gaunt cave-dwelling humanoid ghoul; hunched rock-shelter silhouette, dim ember eyes, ragged mineral-stained wraps; claw threat. |
| STONE-IMP | 顽石小妖 | Compact stone-bodied imp; squat boulder-like torso, chipped rock plates, short powerful arms; distinct from humanoid ghoul. |
| CRAB-GUARD | 蟹将 | Upright aquatic crab soldier; hard shell, two readable pincers, disciplined guard posture, sea-green/bronze shell. |
| SHRIMP-SPEAR | 虾兵 | Slender shrimp-like aquatic foot soldier with segmented carapace and a simple spear; long narrow silhouette distinct from crab guard. |
| HEAVENLY-SOLDIER | 天兵 | Disciplined celestial infantry; Chinese-inspired lamellar armor, clean helmet silhouette, restrained cloud motifs, readable polearm or approved weapon. |
| HEAVENLY-ARCHER | 天将弓手 | Celestial ranged soldier; layered armor, clear bow and quiver silhouette, agile archer stance. |
| ERLANG-SHEN | 二郎神 | Named divine warrior, composed human face, third eye clearly visible, refined celestial armor, three-pointed double-edged spear; dignified rival, not generic soldier. |
| CELESTIAL-HOUND | 细犬 / 哮天犬 | Lean celestial hunting hound, alert canine anatomy, streamlined legs and pointed muzzle, mythic restraint; no oversized wolf bulk. |
| CELESTIAL-GENERAL | 天庭神将 | Elite celestial general; imposing Chinese lamellar armor, commanding silhouette, approved polearm, clearly above ordinary heavenly soldier. |
| HEAVEN-GUARD-CAPTAIN | 天宫禁卫 | Palace guard captain; heavier defensive armor and disciplined stance, distinct helmet/crest from general. |
| MOUNTAIN-GHOUL | 山魈 | Mountain-dwelling forest demon; rugged fur/wood/stone cues, long limbs, recognizably folkloric mountain spirit rather than generic zombie. |
| RIDGE-WOLF | 岭狼 | Lean mountain wolf with wind-worn fur and strong running silhouette; natural quadruped anatomy. |
| MOUNTAIN-SPIRIT | 山魈灵 | More supernatural mountain spirit than MOUNTAIN-GHOUL; mineral/woodland aura integrated into body, readable spirit silhouette. |
| STONE-FOX | 石狐妖 | Fox demon with stone-textured accents, sharp fox muzzle and tail(s) only as specified by canonical data; avoid kitsune stereotype overload. |
| SEA-SERPENT | 海蛇 | Long aquatic serpent with Eastern dragon-like flow but clearly serpent body plan; wave-scale texture, no limbs unless source data defines them. |
| TIDAL-SPIRIT | 潮灵 | Water elemental spirit with humanoid/flowing-water silhouette, readable core and tide crest, not a western mermaid. |
| YING-WATER-DEMON | 鹰愁水妖 | Ravine water demon; aquatic humanoid/river creature, cold blue-green palette, hooked current-like silhouette. |
| RIVER-EEL | 河鳗妖 | Long eel-like aquatic creature, smooth sinuous body and readable fin/tail, distinct from humanoid water demon. |
| VILLAGE-GHOUL | 庄外妖鬼 | Rural haunting ghoul, weathered clothing fragments and hunched silhouette; distinct from cave ghoul via open-field/worn village cues. |
| WILD-BOAR | 獠牙野妖 | Muscular boar demon with tusks, low charging silhouette, rough bristles; not a cute pig or Bajie duplicate. |
| WUKONG-MIRROR | 悟空化影 | A non-canonical shadow/illusion echo of Wukong; visibly spectral duplicate silhouette, never a replacement for the real hero or a new canon character. |
| MOUNTAIN-MONKEY | 山猴妖兵 | Aggressive smaller monkey-like mountain bandit; agile quadruped/bipedal primate cues, distinct from Wukong's regal identity and no golden fillet. |
| SAND-GUARD | 沙甲妖兵 | Armored sand soldier; layered sand-packed armor plates, shield/guard posture, warm ochre palette, distinct from wind spirit. |
| WIND-SPIRIT | 风砂精 | Agile semi-transparent sand/wind elemental, flowing narrow silhouette and visible wind ribbons integrated into body; no humanoid armor. |
| SAND-SHARK | 沙河恶鲛 | River predator with shark-like aquatic head and powerful tail, sand-scoured scales; clearly aquatic, not land wolf. |
| RIVER-WRAITH | 河魇 | Spectral river apparition, submerged cloth/flow silhouette and cold river-light core; distinct from physical sand shark. |
| RIVER-DEMON | 流河妖将 | Named river demon officer, armored aquatic humanoid, commanding weapon silhouette only if source confirms it. |
| SAND-GUARDIAN | 流沙守灵 | Ancient guardian spirit shaped by flowing sand and river stone, heavy defensive silhouette, distinct from sand soldier. |
| EAGLE-WATER-DEMON | 涧水妖 | Eagle Sorrow Stream aquatic demon; current-carved body, water-worn armor/skin, strong ravine-current attack read. |
| EAGLE-CLAW-DEMON | 鹰爪水魅 | Fast diving water wraith with clawed forelimbs and sharp aerial-dive silhouette; do not add actual eagle wings unless data confirms. |
| GAO-WILD-DEMON | 庄外野妖 | Gaojiazhuang outskirts wild demon; feral rural raider, rough silhouette, distinct from shaman. |
| GAO-SHAMAN | 庄外邪祟 | Ritual curse-caster; layered talisman/cloth details and controlled dark-ice motif, readable caster posture, no illegible text. |
| SANDS-WATER-WRAITH | 流沙水魅 | Flowing-sand river wraith, broad wave silhouette and spectral water body; readable slow/binding threat. |
| SANDS-RIPPER | 沙河凶灵 | Aggressive sand-river spirit, sharper cutting silhouette and dark undertow details, distinct from water wraith. |

**Boss and bounty extension roster:**  
- `YELLOW_WIND_KING` — use CHAR-YELLOW-WIND-KING brief; boss body plan and mustelid face are mandatory.  
- `BOUNTY_YELLOW_FANG` / 黄牙老妖 — **DESIGN INPUT REQUIRED** for species, face, body plan, weapon and canonical size; prepare no speculative final design. Prompt direction once approved: optional high-threat bounty boss, yellow-fang visual motif, fire/staff vulnerability communicated through armor gaps and stance, distinct from Yellow Wind King.  
- `BOUNTY_IRON_HORN` / 铁角大王 — **DESIGN INPUT REQUIRED** for species/body plan/weapon. Prompt direction: optional A-tier heavy horned cave boss, iron/stone material identity, readable horn silhouette, distinct from all mainline bosses.  
- `BOUNTY_DRAGON_BONE_RECLUSE` / 龙骨道人 — **DESIGN INPUT REQUIRED** for age/species/robes/weapon and relationship to Longma. Prompt direction: optional S-tier secluded bone/river mystic, restrained dragon-bone material language, distinct from a generic lich.

## C. Environment and location roster — individual scene prompts

**Shared scene format:** 16:9 wide playable background, 1920×1080 preferred (or largest exact 16:9 output supported); no people, enemies, animals, signage text, HUD, pins or UI. Build far/mid/near depth layers and preserve clean character-combat staging space.

| Asset ID | Location | Scene-specific prompt direction |
|---|---|---|
| SCENE-JOURNEY-SCENERY | 旅途通用场景 | Layered mountain ridges, distant Chinese temple/settlement, mid-ground cliff road, readable foreground standing plane, foliage, warm lantern glows; intimate dusk. |
| SCENE-FIVE-ELEMENTS-MOUNTAIN | 五行山 | Monumental five-element mountain mass, weathered stone steps, old seal scars, sparse pines and a quiet pilgrim path; oppressive ancient scale but warm human-scale foreground. |
| SCENE-EAGLE-SORROW | 鹰愁涧 | Narrow mountain ravine, clear rushing stream, wet rock banks, waterfall mist, dramatic vertical cliff layers, safe readable path/encounter floor. |
| SCENE-BLACK-WIND-NORTH-PATH | 黑风山北道 | Dark pine ridge path, layered black-green slopes, broken trail markers, distant cave/fortress hint, cool shadows and a few warm lights; no horror clutter. |
| SCENE-GAOJIAZHUANG | 高老庄 | Rural Chinese village courtyard, tiled roofs, earthen walls, fields and mountain backdrop; lived-in warm domestic details, open space for dialogue and combat. |
| SCENE-FLOWING-SANDS | 流沙河 | Broad dangerous river, shifting sandbars, ancient ferry remnants, layered river fog and eroded banks; water and sand must read as one treacherous boundary. |
| SCENE-DRAGON-BONE-SANCTUM | 龙骨秘境 | Optional expedition zone; ancient river gorge and bone-like mineral formations, hidden sanctum entrance, high-threat atmosphere; do not imply canonical mainline event. |
| SCENE-YELLOW-WIND-RIDGE | 黄风岭 | Wind-scoured ochre ridges, abandoned caravan road, buried waystation, sandstorm curtains, visible safe route and retreat path. |
| SCENE-ABANDONED-INN | 废弃驿站 | Half-buried roadside inn, broken timber beams, faded travel objects, sand drifts, legible investigation space; no readable writing. |
| SCENE-SANDSTORM-PASS | 风沙关 | Narrow pass under layered sandstorm, rock shelter and route fork, strong wind direction visible in dust/cloth/grass, no baked-in characters. |
| SCENE-YELLOW-WIND-GATE | 黄风洞外 | Cave gate carved into eroded sandstone, deep black opening, wind funnel and sparse warning markers; boss threshold composition. |
| SCENE-YELLOW-WIND-CAVE | 黄风洞 | Interior cavern with layered sandstone arches, sand channels, torch/ember pools and readable battle floor; depth without visual noise. |
| SCENE-YELLOW-WIND-BATTLE | 黄风妖王战场 | Left party-safe staging area, right boss-safe staging area, central VFX clearance; distant ridges, sandstorm, ruined fortress shapes, distinct floor and restrained ember cracks. |
| SCENE-DRAGON-PALACE | 东海龙宫 | Chinese myth underwater palace, jade/bronze columns, flowing water-light, shell and wave ornament; no western castle or modern aquarium. |
| SCENE-HEAVEN-PALACE | 天宫 | Grand celestial Chinese palace terraces, cloud sea, layered roofs, restrained gold/cinnabar, clear approach path; majestic but readable. |
| SCENE-WATER-CURTAIN-CAVE | 水帘洞 | Waterfall curtain, hidden cave mouth, wet stone, peach-tree/monkey habitat cues, natural refuge rather than generic dungeon. |
| SCENE-DOUBLE-RIDGE | 双叉岭 | Remote forked mountain ridge, old road, dense trees and threatening gullies, early-journey loneliness. |
| SCENE-WUJING-RIVERBANK | 流沙河古渡 | Riverbank ferry remains, weathered posts, waterline clues and sand movement, quiet tragic atmosphere. |

**World map illustration:** create a separate 16:9 high-level illustrated map with five canonical story nodes (五行山、鹰愁涧、黑风山北道、高老庄、流沙河) plus Dragon Bone Sanctum as optional expedition; preserve unlabelled open node areas. Do not add invented story locations or text labels. Current `world_map.json` is the location authority.

## D. Equipment, props, consumables and materials

**Deliverable:** isolated transparent pixel-art object, 1:1 icon canvas only if the existing UI slot confirms 1:1; otherwise **DESIGN INPUT REQUIRED**. Provide one high-detail object reference and a separate icon-scale simplification only when both are requested. No lettering, price tags, rarity borders or UI card.

| Asset ID / item | Prompt direction |
|---|---|
| PROP-RUYI-JINGU-BANG | Wukong's golden magical staff; clear cylindrical shaft, recognizable heavier end caps/rings, restrained red/dark details; upright silhouette, no weapon glow baked in. |
| PROP-NINE-TOOTHED-RAKE | Bajie's nine-toothed rake; unmistakable nine teeth, sturdy agricultural-metal construction elevated to mythic weapon, readable handle. |
| PROP-MONK-SPADE | Wujing's crescent-moon monk's spade; crescent blade and counterweight/shaft geometry readable, practical metal/wood. |
| PROP-PILGRIM-STAFF | Tang's travel staff only if approved by character design; otherwise omit. |
| ITEM-HERB / 金疮草 | Small medicinal herb bundle with distinct leaves and tied stem; restorative, natural, no bottle label. |
| ITEM-PEACH / 仙桃片 | Carefully sliced immortal peach, warm pink/cream flesh and subtle golden seed/core cue; appetizing but not photoreal. |
| ITEM-BP-TALISMAN / 聚气符 | Folded/rolled talisman charm with restrained red-gold seal geometry; no illegible pseudo-calligraphy. |
| ITEM-SHIELD-CHARM / 护心符 | Protective heart-guard charm, jade/bronze/cloth construction, shield motif through shape not text. |
| ITEM-FIRE-REED / 火纹草 | Fire-pattern reed/material bundle, warm ember-red veins, botanical silhouette; no flame explosion. |
| MAT-DEMON-FANG / 妖牙 | Single polished demon fang, chipped natural ivory/ochre material, readable pointed silhouette. |
| MAT-IRON-HORN-CORE | Dense iron-horn mineral core, dark iron and bronze striation; compact material icon. |
| MAT-DRAGON-BONE | Pale dragon-bone fragment, layered fossil grain and subtle cool glow; avoid human remains/gore. |
| EQUIP-FANG-TALISMAN | Small protective fang talisman, clear tooth + cord construction, no readable text. |
| EQUIP-HORNWARD-CHARM | Iron-horn defensive charm, forged metal ring/plate and cord, robust silhouette. |
| EQUIP-DRAGON-VEIL | Dragon-themed veil/ward, translucent cool fabric with restrained scale motif, no ornate text. |

All other `data/items/*.json` entries must be appended here as soon as discovered. Never silently omit newly added IDs.

## E. VFX library — asset prompts

Each VFX item is a transparent isolated effect with a readable origin, direction, silhouette, limited palette and no background. Confirm the project's actual animation importer before requesting a multi-frame sheet.

- `VFX-FIRE-HIT`: compact warm flame burst with sharp pixel clusters, clear impact center and short outward arc; orange/red/gold, no smoke cloud hiding target.
- `VFX-WATER-SLASH`: curved blue-white water blade, directional crescent, crisp droplets, readable at small size.
- `VFX-WIND-CUT`: narrow ochre/teal spiral slash, directional motion and clean center.
- `VFX-EARTH-IMPACT`: chunky stone shards radiating from ground contact, controlled debris count.
- `VFX-ICE-BREAK`: crystalline pale-blue fracture burst, radial shards with clear center.
- `VFX-DARK-SEAL`: restrained violet/ink binding ring, no faux text or pseudo-runes.
- `VFX-BREAK-STATE`: concise shield-fracture motif, high contrast and no words/numbers.
- `VFX-HEALING`: warm jade/cream rising motes, gentle vertical flow, no medical cross.
- `VFX-SANDSTORM`: directional ochre dust ribbon with layered pixel particles, transparent gaps preserved.
- `VFX-DRAGON-SHIFT`: elegant scale/element transition accents around a clean central silhouette; no full character redraw.

## F. UI illustration and icon backlog

The UI is not a generic web dashboard. Keep the project's angular pixel-frame language: dark blue-black base, crisp double-line cut corners, teal normal/selected information, gold/orange enemy focus, red danger, compact pixel typography. The following are separate assets, not one giant UI poster:

- `UI-ICON-ELEMENT-FIRE/WATER/WIND/EARTH/ICE/STRIKE/DARK`: one distinct 1:1 transparent icon per element, instantly recognizable in monochrome silhouette and color.
- `UI-ICON-WEAKNESS`, `UI-ICON-SHIELD`, `UI-ICON-BREAK`, `UI-ICON-BP`, `UI-ICON-MERCY`, `UI-ICON-MOMENTUM`, `UI-ICON-RAGE`, `UI-ICON-TIDE`, `UI-ICON-DRAGON-SHIFT`: separate 1:1 pixel symbols, no letters or numerals.
- `UI-FRAME-COMMAND`, `UI-FRAME-TARGET`, `UI-FRAME-PARTY`, `UI-FRAME-STATUS`, `UI-FRAME-ACTION-QUEUE`: isolated reusable angular frame parts, consistent corner cuts and line weights.
- `UI-ICON-ITEM-HERB/PEACH/TALISMAN/CHARM/FIRE-REED`: simplified readable versions of their corresponding item assets.
- `UI-MAP-MARKER-STORY/EXPEDITION/BOUNTY`: three separate node markers, distinct silhouettes, no embedded text.
- `UI-CURSOR-SELECTED`, `UI-CURSOR-FOCUS`, `UI-STATE-DANGER`, `UI-STATE-CLEARED`: tiny state ornaments, no text.

**DESIGN INPUT REQUIRED before generating UI:** exact icon pixel canvas, frame tile dimensions, nine-slice rules, existing pixel font metrics and runtime atlas/import path. Do not guess sizes or bake text.

## G. Daily queue and completion ledger

The dated daily schedule is the only execution cursor. This table is the full category backlog; the schedule may split a large family into multiple days.

| Priority band | Scope | Status |
|---|---|---|
| P0 | Five playable heroes + Yellow Wind King | Individual briefs ready; Wukong next |
| P1 | Current enemy IDs in `data/combat/encounters.json` and `shared_encounters.json` | Per-ID visual briefs ready; split into daily assets |
| P1 | Mainline and optional world locations / battle stages | Scene briefs ready; exact existing scene dimensions/path still to be confirmed before generation |
| P2 | Signature weapons, current consumables and bounty materials | Briefs ready; exact UI icon canvas/path to be confirmed |
| P2 | Bosses Yellow Fang, Iron Horn, Dragon Bone Recluse | Partial briefs only; design input required before generation |
| P3 | Element/status/character-resource icons and battle UI frames | Visual language ready; pixel dimensions/atlas contract required |
| P3 | Combat VFX families and Longma transformation effects | Briefs ready; animation/import contract required |
| P4 | NPCs, merchants, villagers, pilgrims, quest givers, wildlife, decorative props, additional chapters/locations | Inventory expansion required from narrative/event data before any claim of exhaustive coverage |

### Per-asset status record template

```yaml
asset_id: CHAR-WUKONG
status: PROMPT_READY # PROMPT_READY | GENERATED_PENDING_REVIEW | REJECTED | ACCEPTED_FOR_INTEGRATION | INTEGRATED_AWAITING_SCREENSHOT | PRODUCTION_ACCEPTED
prompt_file: docs/visual_reference/prompts/2026-11-12-wukong-turnaround.md
generation_date_local:
source_path:
runtime_path:
dimensions:
sha256:
review_score:
critical_failures: []
tested_commit_sha:
ci_run_ids: []
screenshot_evidence:
completed_at:
```

A prompt is not "completed" when it has merely been used once. Mark the prompt's asset as completed only when its corresponding asset is **PRODUCTION ACCEPTED**. Rejected prompts are revised and retain their asset ID/history.

## H. Inventory completeness rule

Before claiming "all assets are covered", compare this library against:
1. every character/NPC in `data/narrative/`;
2. every enemy and boss in `data/combat/`;
3. every world node, region, dungeon and scene in `data/world/` and `data/dungeons/`;
4. every item, equipment profile and reward in `data/items/` and combat reward data;
5. every runtime-loaded resource in `assets/`, `ui/`, and scene files;
6. all VFX, UI icon/frame slots referenced by scripts.

Any new ID must receive an asset record and prompt before it can enter the daily generation queue. The current library is the first full-scope baseline, not a claim that undiscovered future content is already enumerated.
