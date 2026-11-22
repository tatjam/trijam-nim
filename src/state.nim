# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/random

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
  [mpFull: 0.3, mpWaning: 0.5, mpNew: 0.5, mpWaxing: 1.0]

const payoff: array[Action, array[SocialStanding, float]] = [
  aShine: [ssPraised: 3.0, ssAssumed: -2.0, ssForgotten: 0.0],
  aIntegrate: [ssPraised: 1.0, ssAssumed: 2.0, ssForgotten: -1.0],
  aIsolate: [ssPraised: -1.0, ssAssumed: 0.0, ssForgotten: 1.0],
]

# Emit as in the hidden markov chain meaning
const emit: array[SocialStanding, array[CrowdBehaviour, float]] = [
  ssPraised: [cbWarmToward: 0.6, cbUniformToward: 0.2, cbGlance: 0.15, cbIgnore: 0.05],
  ssAssumed: [cbWarmToward: 0.15, cbUniformToward: 0.6, cbGlance: 0.2, cbIgnore: 0.05],
  ssForgotten:
    [cbWarmToward: 0.05, cbUniformToward: 0.15, cbGlance: 0.55, cbIgnore: 0.25],
]

const nextPhase = array[MoonPhase, MoonPhase](
  [mpFull: mpWaning, mpWaning: mpNew, mpNew: mpWaxing, mpWaxing: mpFull]
)

type GameState* = ref object
  shine* = 0.8
  score* = 0.0
  tally*: array[Cause, float] = [0.0, 0.0, 0.0]

  socialStanding*: SocialStanding = ssAssumed
  moonPhase*: MoonPhase = mpWaxing
  rng*: Rand = initRand(1234)

proc effectOnShine(state: GameState, a: Action, n: float) =
  var lose: array[Cause, float]
  var gain = 0.0

  case a
  of aShine:
    gain = 0.10
    lose[cMoon] = 0.1 * n
    lose[cCrowd] = (
      case state.socialStanding
      of ssPraised: 0.01
      of ssAssumed: 0.12
      of ssForgotten: 0.06
    )
  of aIntegrate:
    lose[cMoon] = 0.05 * n
    lose[cSelf] = 0.15
  of aIsolate:
    gain = 0.08
    lose[cSelf] = 0.03

  var totalLose = 0.0
  for c in Cause:
    totalLose += lose[c]
    state.tally[c] += lose[c]

  state.shine = clamp(state.shine + gain - totalLose, 0.0, 1.0)
  if a == aIsolate:
    state.shine = min(state.shine, 0.6)

const transitionTable: array[SocialStanding, array[SocialStanding, float]] = [
  ssPraised: [ssPraised: 0.7, ssAssumed: 0.25, ssForgotten: 0.05],
  ssAssumed: [ssPraised: 0.05, ssAssumed: 0.7, ssForgotten: 0.25],
  ssForgotten: [ssPraised: 0.25, ssAssumed: 0.05, ssForgotten: 0.7],
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
  state.score += payoff[a][state.socialStanding] * n
  effectOnShine(state, a, n)
  effectOnSocialStanding(state, a, n)

proc getEmit*(state: GameState): array[CrowdBehaviour, float] =
  return emit[state.socialStanding]

proc finishTurn*(state: GameState) =
  state.moonPhase = nextPhase[state.moonPhase]
