# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scenes, canvases, texts, sprites, vecs, easings, canvas_utils, audio]
import std/[random, options, math]
import config, state, assets, flow

type CrowdMan = object
  variant: int
  pos: V2
  baseDir: float
  baseSpeed: float
  glanceT: float
  glanced: bool
  nearTrigger: float
  animT: float
  doing: CrowdBehaviour

proc update(man: var CrowdMan, dt: float, playerX: float) =
  let dx = man.pos.x - playerX
  let toward = if dx > 0: -1.0 else: 1.0

  man.animT += dt
  if man.glanceT > 0.0:
    man.glanceT -= dt * man.baseSpeed

  var vx = 0.0

  case man.doing
  of cbWarmToward, cbUniformToward:
    let speed = if man.doing == cbWarmToward: 40.0 else: 32.0
    if abs(dx) > man.nearTrigger:
      vx = toward * speed * man.baseSpeed
    elif not man.glanced:
      man.glanceT = 9999.0
      man.glanced = true
      beep(1000.0, 2.0, 0.4, 1500.0, wSine)
  of cbGlance:
    vx = man.baseDir * 35.0 * man.baseSpeed
    if not man.glanced and abs(dx) < man.nearTrigger:
      beep(500.0, 2.0, 0.4, 100.0, wSine)
      man.glanceT = 10.0
      man.glanced = true
  of cbIgnore:
    vx = man.baseDir * 38.0 * man.baseSpeed

  if man.glanceT <= 0.0:
    man.pos.x += vx * dt

proc draw(man: CrowdMan, c: Canvas, playerX: float) =
  let sheet =
    if man.glanceT > 0.0: res.crowdIdle[man.variant]
    else: res.crowdWalk[man.variant]
  c.drawAnim(
    sheet, man.animT, man.pos.x, man.pos.y,
    fps = 2.0 * man.baseSpeed, scale = 2.0, flipX = man.baseDir < 0.0
  )

type TurnScene* = ref object of Scene
  state*: GameState
  time: float
  moonPos: V2
  fade: float
  crowd: seq[CrowdMan]
  rng: Rand
  playerX: float
  prog: float
  playedOutcome: bool
  drawPlayerPos: V2
  drawPlayer: Sheet
  playerIntensity: float
  gatePhase: float
  playerPhase: float

method enter*(s: TurnScene) =
  s.time = 0.0
  s.rng = initRand(s.state.rng.rand(9999999))
  s.playerX = Wf / 2

  let emit = s.state.getEmit()
  let numMen = s.rng.rand(5) + 5
  s.crowd.setLen(0)

  for i in 0 ..< numMen:
    let emission = weightedPick(s.rng, emit)
    let left = s.rng.rand(100) > 50
    let man = CrowdMan(
      variant: s.rng.rand(manNames.len - 1),
      pos:
        if left: V2(x: -s.rng.rand(100.0), y: Hf - 150.0)
        else: V2(x: s.rng.rand(100.0) + Wf, y: Hf - 150.0),
      baseDir: if left: 1.0 else: -1.0,
      baseSpeed: s.rng.rand(1.0) + 2.0,
      glanceT: 0.0,
      glanced: false,
      nearTrigger: s.rng.rand(300.0) + 30.0,
      animT: 0.0,
      doing: emission,
    )
    s.crowd.add(man)

  if isNone s.state.lastAction:
    s.state.lastAction = some(aShine)
    s.state.lastStanding = some(ssAssumed)

  case get s.state.lastAction
  of aShine:
    s.playerX = 167 * 2
    s.drawPlayerPos = V2(x: 123 * 2, y: 118 * 2)
    s.drawPlayer = res.litChurch
  of aIntegrate:
    s.playerX = 390 * 2
    s.drawPlayerPos = V2(x: 402 * 2, y: 216 * 2)
    s.drawPlayer = res.lamp
  of aIsolate:
    s.playerX = 452 * 2
    s.drawPlayerPos = V2(x: 505 * 2, y: 176 * 2)
    s.drawPlayer = res.litHouse

method update*(s: TurnScene, dt: float, ctx: Context) =
  if loadImageProgress() != 1.0:
    return

  var dt = dt * 2

  const moonStart = V2(x: Wf, y: Hf - 300)
  const moonEnd = V2(x: 0.0, y: 0.0)
  s.time += dt
  s.prog = s.time / 20.0
  s.moonPos = lerp(moonStart, moonEnd, s.prog)

  if s.prog > 0.95:
    s.fade = min((s.prog - 0.95) / 0.05, 1.0)
  else:
    s.fade = 0.0

  for man in s.crowd.mitems:
    man.update(dt, s.playerX)

  let darken = clamp01(1.0 - s.state.shine / 0.8)
  let g = s.gatePhase
  let gate = (sin(g * 0.9) + sin(g * 1.7 + 2.0) + sin(g * 2.9 + 0.7)) / 3.0
  let thr = 0.8 - 1.6 * darken
  let burst = smoothstep((gate - thr) / 0.3)

  let p = s.playerPhase
  let wobble = (sin(p) + sin(p * 2.31 + 1.7) + sin(p * 5.77 + 0.3)) / 3.0
  let flicker01 = wobble * 0.5 + 0.5

  let baseDim = 0.25 * darken
  let amp = 0.6 * darken * burst
  s.playerIntensity = clamp01(1.0 - baseDim - amp * flicker01)

  s.gatePhase += dt
  s.playerPhase += dt * 12.0

  if s.prog > 1.0 and not s.playedOutcome:
    let v = payoff[get s.state.lastAction][get s.state.lastStanding]
    const base = 330.0
    if abs(v) < 0.05:
      beep(base, 0.80, 0.15, 0.0, wSine)
    else:
      let semis = 4.0 + 3.0 * abs(v)
      let far = base * pow(2.0, semis / 12.0)
      if v > 0:
        beep(base, 1.0, 0.30, far, wTri)
      else:
        beep(far, 1.0, 0.20, base, wSaw)
    s.playedOutcome = true

  if s.prog > 1.2:
    s.state.finishTurn()
    if s.state.shine <= 0:
      goToScene sidEnding
    elif s.state.night >= s.state.lastNight:
      goToScene sidEnding
    else:
      goToScene sidAction

const outcomeText: array[Action, array[SocialStanding, string]] = [
  aShine: [
    ssPraised: "How public, like a Frog, to tell your name to an admiring Bog!",
    ssAssumed: "How dreary to be Somebody!",
    ssForgotten: "The Soul selects her own Society, then shuts the door.",
  ],
  aIntegrate: [
    ssPraised: "Then there's a pair of us! Don't tell, they'd banish us, you know!",
    ssAssumed: "I'm Nobody! Who are you? Are you Nobody too?",
    ssForgotten: "To tell your name, the livelong June.",
  ],
  aIsolate: [
    ssPraised: "Unmoved she notes the Chariots, pausing at her low gate.",
    ssAssumed: "To her divine Majority, presents no more.",
    ssForgotten: "Choose one, then close the Valves of her attention, like Stone.",
  ],
]

method draw*(s: TurnScene, c: Canvas) =
  if loadImageProgress() != 1.0:
    c.fadeOverlay(loadImageProgress())
    return

  case s.state.moonPhase
  of mpNew: c.clear("#01080e")
  of mpWaxing: c.clear("#0a3d4f")
  of mpFull: c.clear("#145f70")
  of mpWaning: c.clear("#0b2f45")

  c.drawFrame(res.moon, ord(s.state.moonPhase), s.moonPos.x, s.moonPos.y, 2.0)

  const backY = 100.0
  c.drawFrame(res.background, 0, 0.0, backY, 2.0)
  c.drawFrame(res.background, 0, res.background.fw.toFloat * 2.0, backY, 2.0)
  c.drawFrame(res.middleground, 0, 0.0, 0.0, 2.0)

  c.alpha(s.playerIntensity)
  c.drawFrame(s.drawPlayer, 0, s.drawPlayerPos.x, s.drawPlayerPos.y, 2.0)
  c.alpha(1.0)

  for man in s.crowd.mitems:
    man.draw(c, s.playerX)

  c.fadeOverlay(s.fade)

  if s.prog >= 1:
    let text = outcomeText[get s.state.lastAction][get s.state.lastStanding]
    c.drawText(text, Wf / 2, Hf / 2, aCenter, "#fff")
