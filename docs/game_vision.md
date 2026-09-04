# Game Vision & Canon

## 1. One-Sentence Definition

**A pixel-art HD-2D turn-based JRPG that retells the Journey to the West with the broad narrative rhythm, character relationships, iconic encounters and emotional progression of the classic TV adaptation, expressed through an Octopath Traveler-like JRPG presentation and combat framework.**

The project is not intended to be a generic original story that merely borrows Journey to the West characters.

The Journey to the West story is the **narrative spine**. JRPG systems and HD-2D/pixel presentation are the **gameplay and presentation language**.

---

## 2. Adaptation Priority

When design choices conflict, use this priority order:

1. Preserve the recognizable Journey to the West story and chronology.
2. Preserve the personalities and relationships of the five protagonists.
3. Preserve the major progression and iconic events of the classic television telling.
4. Adapt scenes into interactive JRPG gameplay without destroying their narrative meaning.
5. Use JRPG systems to add depth, replayability and tactical decision-making.
6. Add original connective material only where it strengthens the existing story.

The game should feel like **playing a pixel-art JRPG adaptation of the television Journey to the West**, not like watching a completely unrelated story using Journey to the West names.

---

## 3. Television-Style Narrative Target

The narrative tone should closely follow the familiar television Journey to the West experience:

- Wukong's mythic origin and rebellion form the huge prelude.
- Tang Sanzang's pilgrimage becomes the central road story.
- Wukong is the first major companion obtained by Tang.
- Bai Longma becomes the mount and an important member of the journey.
- Zhu Bajie enters as a comedic but emotionally complicated companion.
- Sha Wujing joins as the quiet, dependable final core member.
- The group then travels through a sequence of increasingly dangerous trials.
- Famous demons and locations are retained as recognizable story anchors.
- The emotional center gradually moves from individual legends to the relationships of the five-member pilgrimage group.

The adaptation can expand scenes, add optional conversations and create original side stories, but it should not arbitrarily replace the iconic narrative sequence.

---

## 4. Five-Character Opening Structure

The player may choose any of the five protagonists at the beginning.

The choice means **which story the player enters first**, not which version of history exists.

### Starting as Sun Wukong

The player experiences the longest mythic prelude:

Stone birth → Flower Fruit Mountain → immortality → Puti Zushi → Dragon Palace → Underworld → Heaven → Qitian Dasheng → heavenly rebellion → Erlang Shen → furnace → Buddha → Five Elements Mountain.

The opening ends with imprisonment.

The player then enters Tang's chronology and experiences the moment Wukong becomes part of the pilgrimage.

### Starting as Tang Sanzang

The player begins with Tang's human-scale world:

early life → Buddhist formation → imperial mission → Guanyin's instruction → departure → early journey → Five Elements Mountain → release of Wukong.

This route reveals the pilgrimage from the traveler's perspective rather than the warrior's.

### Starting as Zhu Bajie

The player experiences the fall of Tianpeng and the creation of Bajie:

Heavenly Marshal → personal failure → punishment → rebirth → mortal life → Gaojiazhuang → Tang/Wukong encounter → recruitment.

### Starting as Sha Wujing

The player experiences the exile narrative:

Celestial general → punishment → Flowing Sands River → isolation → Guanyin's promise → Tang's party → recruitment.

### Starting as Bai Longma

The player begins in the Dragon world:

Dragon Prince → court and family conflict → punishment → transformation → Eagle Sorrow Stream → Tang's pilgrimage → becoming the white horse.

Longma's full combat identity is intentionally revealed later.

---

## 5. Important Structural Rule: Origin ≠ Campaign Order

The five origin routes are **personal chronology modules**.

The global campaign is **world chronology**.

They are different systems.

A player who chooses Bajie first can learn Bajie's past first. This must not imply that the entire world has already reached Gaojiazhuang.

The save state therefore tracks:

- starting_character;
- personal_route_progress for all five characters;
- global_timeline_index;
- recruited_characters;
- shared_chapter_progress;
- historical/flashback unlocks.

---

## 6. Recruitment Must Be a Story Event

The game must never unlock a character merely because the player has reached an arbitrary gameplay level.

Recruitment occurs because the story reaches the character's canonical joining point.

The broad party backbone is:

**Tang's pilgrimage begins → Wukong is released → Longma becomes the pilgrimage mount → Bajie joins → Wujing joins → the core party is complete.**

The exact number and order of intervening trials can be tuned, but these recruitment anchors remain stable.

---

## 7. JRPG Adaptation Philosophy

JRPG mechanics should make the player **play the story's conflicts**, not replace them.

Examples:

- Wukong being arrogant can be represented through high-damage but risk-heavy skills.
- Tang's compassion can create mechanics around protection, purification and restraint.
- Bajie's appetite can become a resource mechanic without reducing him to a joke.
- Wujing's patience can translate into defensive scaling and control.
- Longma's identity can be represented through stance/formation/element switching.

The combat system should reinforce characterization.

---

## 8. Octopath-Like Inspiration Boundary

The project may draw inspiration from the following **design language**:

- turn-based tactical combat;
- weakness exploitation;
- break states;
- boost points;
- party composition;
- character-focused stories;
- pixel-art characters in dimensional environments;
- dramatic lighting;
- cinematic combat camera movement;
- strong JRPG menus and battle feedback.

The project should not copy proprietary assets, exact character designs, dialogue, maps or internal implementation from another game.

The target is **the feeling and design vocabulary of modern HD-2D JRPGs**, while the story and world remain rooted in Journey to the West.

---

## 9. Visual Identity

The visual target is:

**pixel characters + detailed 3D/2.5D environments + depth + dynamic lighting + cinematic camera + Chinese mythological materials and architecture.**

### Exploration

- pixel-art protagonists;
- layered 2.5D environments;
- villages, mountains, temples, rivers and heavenly palaces;
- Chinese architectural silhouettes;
- atmospheric fog, rain, sand and fire;
- dynamic day/night or story-specific lighting where useful.

### Battle

- clean JRPG command interface;
- readable enemy silhouettes;
- weakness icons;
- shield/break indicator;
- BP display;
- turn-order strip;
- dramatic camera movement for Break and signature skills.

The screen should remain readable first. Spectacle cannot obscure tactical information.

---

## 10. Narrative Tone

The game may move between comedy, tragedy, mythology and adventure exactly because Journey to the West itself contains those tonal shifts.

The five protagonists should not share one uniform tone:

- Wukong: energetic, rebellious, proud, increasingly burdened.
- Tang: calm, compassionate, stubborn, morally serious.
- Bajie: funny, worldly, selfish at times, but deeply loyal.
- Wujing: restrained, reliable, lonely, quietly compassionate.
- Longma: proud, mysterious, dutiful, searching for identity.

Comedy should never erase consequence.

Dark scenes should never erase the adventurous spirit of the pilgrimage.

---

## 11. Content Rule

The main story should prioritize recognizable Journey to the West milestones.

Original content is encouraged in three places:

1. Character origin expansion.
2. Travel scenes and party relationship development between canonical events.
3. Optional side quests and minor trials.

Original content should **connect**, **deepen** or **reinterpret** the canonical journey rather than constantly replacing it.

---

## 12. 81 Trials Philosophy

The "81 Trials" should be a thematic world structure rather than a demand for exactly 81 large chapters.

Major canonical stories become major trials.

Smaller problems become minor trials, side quests, elite encounters or environmental events.

The player should repeatedly feel:

> Another mountain. Another temple. Another demon. Another moral test. Another step toward the scriptures.

That repetition is part of the identity of the pilgrimage.

---

## 13. End-State Fantasy

The final game should create the feeling that the player has lived through the complete pilgrimage with these five characters.

A player who started as Wukong should remember how different the group felt when Tang first arrived.

A player who started as Tang should remember how frightening and uncontrollable Wukong initially was.

A player who started as Bajie should eventually understand why the pig demon became indispensable.

The ending should therefore feel like the completion of **five character stories and one shared Journey**.

---

## 14. Canon Rule for Development

Before adding any major feature, ask:

**Does this make the game feel more like an interactive Journey to the West JRPG, or does it pull the game toward being a generic fantasy JRPG?**

If the latter, the feature requires explicit justification before implementation.
