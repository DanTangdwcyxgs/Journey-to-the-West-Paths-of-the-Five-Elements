# Story Structure & Chapter Pacing

## Core Experience

The game is a five-protagonist JRPG built around a fixed Journey to the West chronology and flexible player entry point.

The intended experience is:

**Choose one hero → live that hero's origin → reach their canonical pilgrimage encounter → recruit characters as the story reaches them → finish the remaining personal chapters → bring the five stories together → complete the shared pilgrimage.**

The player should feel that each character existed before the player met them.

---

## 1. New Game: Five Doors

The opening screen presents five protagonists equally:

- Sun Wukong
- Tang Sanzang
- Zhu Bajie
- Sha Wujing
- Bai Longma

Each has:

- a different opening map;
- a different tutorial encounter;
- a different narrative voice;
- a different combat introduction;
- a different emotional problem;
- a different route into the common Journey.

The selection does not choose a cosmetic avatar. It selects the player's first narrative lens.

---

## 2. The Five Opening Campaigns

### Wukong Opening — The Rebel

Tone: energetic, mythic, rebellious.

The player sees the world from above and below: Flower Fruit Mountain, the Dragon Palace, the Underworld and Heaven.

The opening should make the player feel exceptionally powerful, then gradually introduce the one thing Wukong cannot defeat with raw strength: the limits imposed by Heaven and fate.

Ending beat: Wukong is sealed beneath Five Elements Mountain.

This acts as a dramatic handoff into the Tang story.

### Tang Opening — The Pilgrim

Tone: quiet, human, spiritual.

The player begins with a fragile protagonist. Combat should emphasize survival, preparation, blessings and reading enemies rather than raw damage.

The opening follows Tang's formation, his decision to seek the scriptures and the beginning of his pilgrimage.

Ending beat: Tang encounters Wukong at Five Elements Mountain and releases him.

### Bajie Opening — The Fallen Marshal

Tone: tragic comedy gradually becoming emotional.

The player first experiences Bajie as Tianpeng, allowing the later pig-demon personality to feel like a transformation rather than a joke.

The opening follows his fall, rebirth and life around Gaojiazhuang.

Ending beat: the encounter with Tang and Wukong at Gaojiazhuang leads to Bajie's recruitment.

### Wujing Opening — The Exile

Tone: lonely, restrained and atmospheric.

The player spends significant time at the Flowing Sands River. The route should use environmental storytelling and repeated encounters to communicate isolation.

Ending beat: Tang's group offers Wujing a way out of endless punishment, and he joins.

### Longma Opening — The Dragon

Tone: regal, mysterious and identity-focused.

The player begins before Longma becomes the white horse. The Dragon Court should feel culturally and visually different from the human world.

Ending beat: Longma's punishment and transformation place him on the pilgrimage route.

The game initially presents him as a mount rather than exposing his complete combat kit. This delayed mechanical reveal should be intentional.

---

## 3. Canonical Recruitment Backbone

The broad recruitment chronology is fixed:

`Wukong imprisoned → Tang pilgrimage → Wukong released/recruited → Bai Longma joins as the mount → Zhu Bajie recruited → Sha Wujing recruited`

The 1986 TV adaptation uses the same broad progression: early Wukong material, Five Elements Mountain, Wukong joining Tang, Zhu Bajie, then Sha Wujing. citeturn371545search0turn371545search4

The game can expand, compress or reinterpret connective material, but it should preserve these major anchors unless a deliberate narrative revision is approved.

---

## 4. What Happens After Recruitment

Recruitment does not mean the character's story is over.

Instead it changes the chapter structure.

Before recruitment:

`Character Origin Chapters`

After recruitment:

`Shared Journey Chapters + Character Perspective Chapters`

Example:

Bajie joins at Gaojiazhuang. After that:

- the shared party continues toward the next pilgrimage event;
- Bajie's personal chapter may unlock after a later milestone;
- that chapter can reveal his old relationship with Heaven;
- the player returns to the shared timeline when it ends.

This mirrors the JRPG idea that every party member has a personal narrative, while avoiding five parallel campaigns that never actually connect.

---

## 5. The First Major Convergence

The first important convergence should happen when the party is large enough that the player realizes:

> These are not five separate heroes anymore. They are becoming a group.

The game should deliberately slow down for:

- camp conversations;
- arguments;
- small comedic scenes;
- disagreements about Tang's decisions;
- memories of each character's former life;
- reactions to newly recruited members.

This is not filler. It is the point where the game changes from an anthology of origins into a party JRPG.

---

## 6. Full Party Convergence

When all five have joined, trigger a major shared chapter rather than simply displaying "Party Complete" in the UI.

The chapter should:

1. establish the five-character party as the permanent core cast;
2. acknowledge each character's different reason for travelling;
3. create one problem none of the characters can solve alone;
4. introduce a major new threat;
5. transition the game into the long shared pilgrimage.

This is the real end of the opening act of the game.

---

## 7. Personal Chapter Pattern

Every important character chapter should roughly follow:

`Hook → Personal problem → Exploration → Character-specific mechanic → Escalation → Boss/Set Piece → Emotional resolution → New world milestone`

The "character-specific mechanic" is important. A chapter should not be mechanically interchangeable between characters.

Examples:

- Wukong: transformation / disguise / brute-force environmental interactions
- Tang: protection, purification, negotiation, support and risk management
- Bajie: food/resource mechanics, charge attacks and defensive disruption
- Wujing: water manipulation, control and endurance
- Longma: form switching, mobility and elemental adaptation

---

## 8. Pacing Rule: Do Not Frontload Lore Without Gameplay

No character should spend the entire origin campaign in dialogue scenes.

A rough target for a major chapter is:

- exploration / interaction: 35–45%
- combat: 30–40%
- story/dialogue: 15–25%
- optional discovery: 5–15%

These are tuning targets rather than hard limits.

The purpose is to maintain JRPG momentum while giving each protagonist enough narrative space.

---

## 9. Canonical Event Ownership

Every major Journey to the West event gets one canonical chapter owner.

For example:

- Five Elements Mountain: Tang/Wukong convergence chapter
- Gaojiazhuang: Bajie recruitment chapter
- Flowing Sands River: Wujing recruitment chapter
- White Bone Demon: shared party chapter

Other characters can have perspective scenes connected to the same event, but there should be a single authoritative gameplay version.

This prevents narrative repetition.

---

## 10. Flashbacks

Flashbacks are allowed and encouraged for character development, but every flashback must declare its position in the global timeline.

A flashback should be marked with:

- `is_flashback = true`
- `historical_timeline_index`
- `spoiler_safe_until`

Flashbacks are the main tool for telling a character's past after recruitment without breaking chronology.

---

## 11. Relationship Progression

The party should have relationship states independent from chapter completion.

At minimum:

- Wukong ↔ Tang
- Wukong ↔ Bajie
- Wukong ↔ Wujing
- Wukong ↔ Longma
- Tang ↔ Bajie
- Tang ↔ Wujing
- Tang ↔ Longma
- Bajie ↔ Wujing
- Bajie ↔ Longma
- Wujing ↔ Longma

Relationships can influence:

- camp dialogue;
- optional co-op skills;
- reaction dialogue during bosses;
- side quests;
- alternate battle bonuses;
- ending details.

They should not initially change the main timeline. Narrative stability comes first; relationship branching can expand later.

---

## 12. The 81 Trials Are Not 81 Main Chapters

The 81 Trials system is a world-content framework rather than a requirement for 81 giant story chapters.

Recommended distribution:

- 12–15 Major Trials: major narrative chapters
- 20–25 Minor Trials: personal quests, optional dungeons and regional arcs
- remaining trials: elite encounters, exploration events, challenge battles and short incidents

The major story should feel like a journey through a world full of dangers, not a checklist of exactly 81 boss fights.

---

## 13. Golden Rule for Future Writers

When adding any new chapter, the writer must answer these questions:

1. Who owns this chapter?
2. Where does it sit on the global timeline?
3. Which character is emotionally changed by it?
4. Does it add something mechanically distinct?
5. Does it advance the party or deepen an individual?
6. Can it be removed without breaking chronology?
7. Is it repeating an existing canonical event?

A chapter that cannot answer these questions should not be implemented yet.
