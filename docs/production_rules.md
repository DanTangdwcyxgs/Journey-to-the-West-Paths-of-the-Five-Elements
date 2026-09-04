# Production Rules

## 1. Adaptation Rule

The game must remain highly recognizable as Journey to the West.

The 1986 television adaptation is a primary pacing and presentation reference for the broad narrative flow, iconic scenes, character relationships and progression of the pilgrimage.

The project does not need to reproduce every scene literally. It should reproduce the **story logic** and recognizable sequence of major events while converting them into an interactive JRPG.

## 2. Three Reference Layers

### Narrative Reference

**Journey to the West / classic television telling**

Used for:
- chronology;
- characters;
- relationships;
- major encounters;
- locations;
- major emotional beats;
- overall pilgrimage progression.

### Gameplay Reference

**Modern HD-2D turn-based JRPGs / Octopath-like design language**

Used for:
- Break and weakness combat;
- Boost/BP decision-making;
- party building;
- character chapters;
- turn order;
- JRPG menus;
- tactical combat feedback;
- chapter-driven storytelling.

### Visual Reference

**HD-2D / pixel JRPG aesthetic**

Used for:
- pixel characters;
- dimensional environments;
- volumetric lighting;
- dramatic shadows;
- weather;
- layered parallax;
- cinematic battle presentation.

These three layers must not be confused. A gameplay system can be inspired by JRPGs without changing the Journey to the West narrative.

## 3. Story Before Systems

When creating a major feature, first identify its narrative purpose.

Example:

The Red Boy arc exists because it is part of the pilgrimage story. A combat gimmick is then designed to make that arc fun to play.

Do not invent a random boss first and retrofit a Journey to the West name afterward.

## 4. Iconic Event Preservation

Major recognizable events should normally retain:

- recognizable location;
- recognizable principal characters;
- recognizable conflict;
- recognizable resolution or consequence;
- recognizable relationship change.

Additional JRPG mechanics may be inserted between these anchors.

## 5. Expansion Rules

Original content is allowed when it does one or more of the following:

- expands a character's inner life;
- explains a relationship;
- provides playable context for a canonical event;
- creates optional exploration;
- creates a side quest;
- gives the player a meaningful gameplay choice that does not contradict canon;
- supports pacing between major television-style story beats.

Original content should not casually:

- kill or permanently alter a canonical protagonist;
- change the order of major recruitment events;
- replace iconic bosses without justification;
- make the journey unrelated to obtaining the scriptures.

## 6. Pixel / HD-2D Rule

The game is not simply a 2D pixel game.

The visual target is a deliberate contrast:

**pixel-art characters and effects + dimensional environments + cinematic lighting + atmospheric depth.**

Character readability should remain pixel-art-first. Environment detail can be significantly richer.

## 7. JRPG Structure Rule

The player experience should repeatedly alternate between:

`Story scene → exploration → NPC interaction → discovery → encounter → dungeon → boss → aftermath → party conversation → next destination`

Not every chapter must contain every element, but the overall rhythm should feel like a traditional story-driven JRPG.

## 8. Character Route Rule

Each protagonist needs:

- an origin;
- a personal conflict;
- a distinctive gameplay identity;
- a canonical recruitment/connection point;
- post-recruitment perspective material;
- a final payoff in the shared journey.

No protagonist should become irrelevant after recruitment.

## 9. Party Rule

The player should gradually experience the transformation:

`solo protagonist → temporary companions → small party → full five-person group → tightly bonded pilgrimage party.`

This progression should be visible in both gameplay and dialogue.

## 10. Combat Rule

Combat exists to express character and story.

The Break/Weakness/BP systems should remain simple enough to understand quickly but deep enough to create meaningful party decisions.

Every protagonist should have at least one mechanic that changes how the player approaches an encounter.

## 11. Boss Rule

Major bosses should combine three layers:

1. recognizable Journey to the West identity;
2. a gameplay gimmick connected to the story;
3. a dramatic presentation moment.

Example:

A sand-based demon should not merely have high defense. Sandstorm conditions, reduced accuracy, changing battlefield visibility or speed manipulation can turn the story concept into combat rules.

## 12. Dialogue Rule

Dialogue should prioritize:

- recognizable personalities;
- clear motivations;
- short memorable exchanges during travel;
- meaningful longer scenes at major turning points.

Avoid making every NPC or party conversation equally verbose.

## 13. Comedy Rule

Comedy is part of the Journey to the West identity, especially around Bajie, Wukong and the group's interpersonal conflicts.

Comedy should emerge naturally from character personality and situation.

It should not destroy the emotional weight of important scenes.

## 14. Canon Confidence Labels

Every story asset should declare one of:

- `CANON_ANCHOR` — major recognizable Journey to the West event.
- `CANON_EXPANSION` — original material inserted around a known event.
- `CHARACTER_EXPANSION` — original material expanding a protagonist's history.
- `SIDE_STORY` — optional original content.
- `GAMEPLAY_ONLY` — mechanical content with minimal narrative claim.

This allows writers to know how much creative freedom they have.

## 15. Future Content Test

Before implementation, the team should be able to answer:

**If the player recognizes Journey to the West, will this scene make sense as part of that story?**

If not, revise it or classify it explicitly as optional original content.
