# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/[random, options]

type Cause* = enum
  cMoon
  cCrowd
  cSelf

type Action* = enum
  aShine
  aIntegrate
  aIsolate

const actionName*: array[Action, string] =
  [aShine: "Shine", aIntegrate: "Integrate", aIsolate: "Isolate"]

type MoonPhase* = enum
  mpFull
  mpWaning
  mpNew
  mpWaxing

type SocialStanding* = enum
  ssPraised
  ssAssumed
  ssForgotten

type CrowdBehaviour* = enum
  cbWarmToward
  cbUniformToward
  cbGlance
  cbIgnore

const noticeability: array[MoonPhase, float] =
  [mpFull: 0.3, mpWaning: 0.6, mpNew: 1.0, mpWaxing: 0.6]

const payoff*: array[Action, array[SocialStanding, float]] = [
  aShine: [ssPraised: 5.5, ssAssumed: -3.0, ssForgotten: -4.5],
  aIntegrate: [ssPraised: 0.5, ssAssumed: 2.5, ssForgotten: -1.0],
  aIsolate: [ssPraised: -2.50, ssAssumed: -0.5, ssForgotten: 0.25],
]

# Emit as in the hidden markov chain meaning
const emit: array[SocialStanding, array[CrowdBehaviour, float]] = [
  ssPraised: [cbWarmToward: 0.6, cbUniformToward: 0.2, cbGlance: 0.15, cbIgnore: 0.05],
  ssAssumed: [cbWarmToward: 0.05, cbUniformToward: 0.2, cbGlance: 1.0, cbIgnore: 0.05],
  ssForgotten:
    [cbWarmToward: 0.05, cbUniformToward: 0.15, cbGlance: 0.55, cbIgnore: 0.55],
]

const nextPhase = array[MoonPhase, MoonPhase](
  [mpFull: mpWaning, mpWaning: mpNew, mpNew: mpWaxing, mpWaxing: mpFull]
)

type GameState* = ref object
  night* = 1
  lastNight* = 12
  shine* = 1.0
  score* = 0.0
  tally*: array[Cause, float] = [0.0, 0.0, 0.0]

  socialStanding*: SocialStanding = ssAssumed
  moonPhase*: MoonPhase = mpWaxing
  rng*: Rand = initRand(1234)
  lastAction*: Option[Action] = none(Action)
  lastStanding*: Option[SocialStanding] = none(SocialStanding)

proc effectOnShine(state: GameState, a: Action, n: float) =
  var lose: array[Cause, float]
  var gain = 0.0

  case a
  of aShine:
    if state.socialStanding == ssPraised:
      gain = 0.3
    else:
      gain = 0.04
    lose[cMoon] = 0.14 * n
    lose[cCrowd] = (
      case state.socialStanding
      of ssPraised: 0.08
      of ssAssumed: 0.18
      of ssForgotten: 0.12
    )
    lose[cSelf] = 0.04
  of aIntegrate:
    if state.socialStanding == ssAssumed:
      gain = 0.05
    lose[cMoon] = 0.06 * n
    lose[cSelf] = 0.11
    lose[cCrowd] = 0.04
  of aIsolate:
    gain = 0.22
    lose[cSelf] = 0.05
    lose[cCrowd] = 0.02

  var totalLose = 0.0
  for c in Cause:
    totalLose += lose[c]
    state.tally[c] += lose[c]

  let before = state.shine
  state.shine = clamp(state.shine + gain - totalLose, 0.0, 1.0)
  if a == aIsolate:
    state.shine = min(state.shine, max(before, 0.6))

const transitionTable: array[SocialStanding, array[SocialStanding, float]] = [
  ssPraised: [ssPraised: 0.45, ssAssumed: 0.45, ssForgotten: 0.1],
  ssAssumed: [ssPraised: 0.15, ssAssumed: 0.55, ssForgotten: 0.35],
  ssForgotten: [ssPraised: 0.02, ssAssumed: 0.23, ssForgotten: 0.75],
]

const pushTo: array[Action, SocialStanding] =
  [aShine: ssPraised, aIntegrate: ssAssumed, aIsolate: ssForgotten]

proc weightedPick*[T](rng: var Rand, options: array[T, float]): T =
  var total = 0.0
  for v in options:
    total += v

  # This picks the options according to their weight
  var r = rng.rand(total)
  for t in low(T) .. high(T):
    r -= options[t]
    if r < 0.0:
      return t

  return high(T)

proc effectOnSocialStanding(state: GameState, a: Action, n: float) =
  var transitions = transitionTable[state.socialStanding]
  transitions[pushTo[a]] += 0.2 * n
  state.socialStanding = weightedPick(state.rng, transitions)

proc playTurn*(state: GameState, a: Action) =
  let n = noticeability[state.moonPhase]
  state.lastStanding = some(state.socialStanding)
  state.score += payoff[a][state.socialStanding] * n
  effectOnShine(state, a, n)
  effectOnSocialStanding(state, a, n)
  state.lastAction = some(a)

proc getEmit*(state: GameState): array[CrowdBehaviour, float] =
  return emit[get state.lastStanding]

proc finishTurn*(state: GameState) =
  state.moonPhase = nextPhase[state.moonPhase]
  state.night += 1

proc reset*(state: GameState) =
  state.night = 1
  state.shine = 1.0
  state.score = 0.0
  state.tally = [0.0, 0.0, 0.0]

  state.socialStanding = ssAssumed
  state.moonPhase = mpWaxing
  state.rng = initRand(state.rng.rand(100000))
  state.lastAction = none(Action)
  state.lastStanding = none(SocialStanding)
