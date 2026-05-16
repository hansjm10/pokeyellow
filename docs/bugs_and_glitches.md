# Bugs and Glitches

These are sections of the original Pokémon Yellow game code that clearly do not work as intended or only work in limited circumstances.

Fixes are written in the `diff` format. If you've used Git before, this should look familiar:

```diff
 this is some code
-delete red - lines
+add green + lines
```


## Contents

- [Triage status](#triage-status)
- [Options menu code fails to clear joypad state on initialization](#options-menu-code-fails-to-clear-joypad-state-on-initialization)
- [Battle transitions fail to account for scripted battles](#battle-transitions-fail-to-account-for-scripted-battles)
- [Rocket Hideout B1F door sound repeats](#rocket-hideout-b1f-door-sound-repeats)
- [`wPikachuFollowCommandBuffer` can overflow](#wpikachufollowcommandbuffer-can-overflow)
- [Unexpected Counter damage](#unexpected-counter-damage)


## Triage status

| Bug | Status | Notes |
| --- | --- | --- |
| Options menu code fails to clear joypad state on initialization | Ready | Localized input-state fix. |
| Battle transitions fail to account for scripted battles | Ready | Bound the party scan by `wPartyCount`; preserve `b = 0` for the transition-table offset; use the normal low-level-enemy path if there is no usable party mon. |
| Rocket Hideout B1F door sound repeats | Ready | Localized event-flag fix. |
| `wPikachuFollowCommandBuffer` can overflow | Ready | Add a capacity check before appending. The candidate below drops new commands while the buffer is full. |
| Unexpected Counter damage | Needs design | Counter needs dedicated last-damage state; clearing `wDamage` directly can affect Bide. |


## Options menu code fails to clear joypad state on initialization

This bug (or feature!) results in all options being shifted left or right if the respective direction is pressed on the same frame the options menu is opened.
The bug also exists in pokegold and pokecrystal.

**Fix:** Update [engine/menus/options.asm](/engine/menus/options.asm)

```diff
  DisplayOptionMenu_:
+
+   call JoypadLowSensitivity
    call InitOptionsMenu
```


## Battle transitions fail to account for scripted battles

When Oak Catches Pikachu in the Pallet Town cutscenes you don't yet have any Pokemon in Party.
The Battle Transitions code has no error handling for this and reads wPartyMon1HP from wRivalName+6.
This means you can manipulate this first transition to be faster by choosing a default rival name or writing and deleting 6 characters in a custom rival name.
A similar series of bugs appears to exist in pokecrystal.

**Triage:** Ready. Update [engine/battle/battle_transitions.asm](/engine/battle/battle_transitions.asm).

`GetBattleTransitionID_CompareLevels` scans from `wPartyMon1HP` until it finds a non-fainted party mon.
It does not check `wPartyCount`, so when the party is empty, or if every party mon is fainted, the scan can leave party data and read unrelated WRAM.

**Candidate fix:** Track the number of party mons remaining while scanning.
Since `BattleTransition` later uses `bc` as the transition-table offset, clear `b` again before returning.
If there are no party mons to compare against, clear `BIT_STRONGER_BATTLE_TRANSITION` and use the normal low-level-enemy path.

```diff
 GetBattleTransitionID_CompareLevels:
+   ld a, [wPartyCount]
+   and a
+   jr z, .lowLevelEnemy
+   ld b, a
    ld hl, wPartyMon1HP
 .faintedLoop
    ld a, [hli]
    or [hl]
    jr nz, .notFainted
    ld de, PARTYMON_STRUCT_LENGTH - 1
    add hl, de
+   dec b
+   jr z, .lowLevelEnemy
    jr .faintedLoop
 .notFainted
    ld de, MON_LEVEL - (MON_HP + 1)
    add hl, de
@@
    ld a, [wCurEnemyLevel]
    sub e
    jr nc, .highLevelEnemy
+.lowLevelEnemy
    res BIT_STRONGER_BATTLE_TRANSITION, c
    ld a, 1
    ld [wBattleTransitionSpiralDirection], a
+   ld b, 0
    ret
 .highLevelEnemy
    set BIT_STRONGER_BATTLE_TRANSITION, c
    xor a
    ld [wBattleTransitionSpiralDirection], a
+   ld b, 0
    ret
```


## Rocket Hideout B1F door sound repeats

After beating the Rocket who opens the door on Rocket Hideout B1F, the door-opening sound plays every time the map is loaded.
The script checks `EVENT_ENTERED_ROCKET_HIDEOUT` after playing the sound, but never sets it.

**Fix:** Update [scripts/RocketHideoutB1F.asm](/scripts/RocketHideoutB1F.asm)

```diff
 .play_sound_door_open
    ld a, SFX_GO_INSIDE
    call PlaySound
-   CheckEventHL EVENT_ENTERED_ROCKET_HIDEOUT
+   SetEvent EVENT_ENTERED_ROCKET_HIDEOUT
 .door_open
```


## `wPikachuFollowCommandBuffer` can overflow

AppendPikachuFollowCommandToBuffer doesn't have any length checking for the buffer of Pikachu commands.
This can be abused to write data into any address past d437, typically by putting pikachu to sleep in the Pewter Center with Jigglypuff.
While in this state, walking down writes 01, up 02, left 03, and right 04.
This bug is generally known as "Pikawalk."
A typical use for this would be to force the in game time to 255:59.

**Triage:** Ready. Update [engine/pikachu/pikachu_follow.asm](/engine/pikachu/pikachu_follow.asm).

`wPikachuFollowCommandBufferSize` is initialized to `$ff`; the first append increments it to `0` and writes to `wPikachuFollowCommandBuffer`.
The last valid buffer index is `$f`.
When the size reaches `$f`, another append increments it to `$10` and writes one byte past the 16-byte buffer.

**Candidate fix:** Treat `$f` and higher as full, while preserving `$ff` as the empty sentinel.
This version discards new follow commands while the buffer is full.

```diff
 AppendPikachuFollowCommandToBuffer:
    ld hl, wPikachuFollowCommandBufferSize
+   ld a, [hl]
+   cp $ff
+   jr z, .append
+   cp $f
+   ret nc
+.append
    inc [hl]
    ld e, [hl]
    ld d, 0
    ld hl, wPikachuFollowCommandBuffer
```

An alternate fix would make the buffer drop the oldest command instead of the newest command, but that is a larger behavior change because it affects how closely Pikachu follows after a long blocked period.


## Unexpected Counter damage

Counter simply doubles the value of wDamage which can hold the last value of damage dealt whether it was from you, your opponent, a switched out opponent, or a player in another battle.
This is because wDamage is used for both the player's damage and opponent's damage, and is not cleared out between switching or battles.

**Triage:** Needs design in [engine/battle/core.asm](/engine/battle/core.asm).

The bug is centered on `HandleCounterMove`.
It checks whether the target's last selected move is Counter-able, but then doubles the shared `wDamage` value.
That value is also used by normal damage application and by Bide, so a simple "clear `wDamage` at the start of each turn" fix is risky.

**Candidate direction:** Add Counter-specific last-damage state instead of reusing `wDamage`.

- Clear the Counter damage state at battle start, when a mon switches, and when a new action window begins.
- When direct Normal or Fighting damage is applied to the player, store the actual HP loss in a "damage the player can Counter" variable.
- When direct Normal or Fighting damage is applied to the enemy, store the actual HP loss in a "damage the enemy can Counter" variable.
- Update `HandleCounterMove` to double the side-specific Counter damage value instead of `wDamage`.
- Leave `wDamage` available for existing damage display, HP bar, recoil, drain, and Bide behavior.

Before committing a code fix, verify at least these cases:

- Counter after taking Normal/Fighting damage in the same turn still works.
- Counter after switching does not reuse damage from the previous active mon.
- Counter at the start of a new battle does not reuse damage from the previous battle.
- Bide still accumulates and releases damage correctly.
