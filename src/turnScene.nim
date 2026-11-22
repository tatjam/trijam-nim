# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, audio, sprite, vec], state, assets, config, scenes
import std/[random, math]

var res: Assets = nil

type CrowdMan = object
  variant: int
  pos*: V2
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

  man.animT += dt * 2.0 * man.baseSpeed
  if man.glanceT > 0.0:
    man.glanceT -= dt * man.baseSpeed

  var vx = 0.0

  case man.doing
  of cbWarmToward, cbUniformToward:
    let speed = if man.doing == cbWarmToward: 40.0 else: 32.0
    if abs(dx) > man.nearTrigger:
      vx = toward * speed * man.baseSpeed
    else:
      man.glanceT = 9999.0
  of cbGlance:
    vx = man.baseDir * 30.0 * man.baseSpeed
    if not man.glanced and abs(dx) < man.nearTrigger:
      man.glanceT = 10.0
      man.glanced = true
  of cbIgnore:
    vx = man.baseDir * 18.0 * man.baseSpeed

  if man.glanceT <= 0.0:
    man.pos.x += vx * dt

proc draw(man: CrowdMan, c: Canvas, assets: Assets, playerX: float) =
  let asset =
    if man.glanceT > 0.0:
      assets.crowdIdle[man.variant]
    else:
      assets.crowdWalk[man.variant]

  let frame = int(floorMod(man.animT, asset.frames.toFloat))

  c.drawFrame(asset, frame, man.pos.x, man.pos.y, 2.0, man.baseDir < 0.0)

type TurnScene* = ref object of Scene
  state*: GameState
  assets*: Assets

  time: float
  moonPos: V2
  fade: float

  crowd: seq[CrowdMan]
  rng: Rand
  playerX: float

method enter*(s: TurnScene) =
  s.time = 0.0
  s.rng = initRand(s.state.rng.rand(9999999))
  s.playerX = Wf / 2

  # Build the crowd
  let emit = s.state.getEmit()
  let numMen = s.rng.rand(15) + 5

  s.crowd.setLen(0)

  for i in 0 ..< numMen:
    let emission = weightedPick(s.rng, emit)
    let left = s.rng.rand(100) > 50
    let man = CrowdMan(
      variant: s.rng.rand(manNames.len - 1),
      pos:
        if left:
          V2(x: -s.rng.rand(100.0), y: Hf - 150.0)
        else:
          V2(x: s.rng.rand(100.0) + Wf, y: Hf - 150.0),
      baseDir: if left: 1.0 else: -1.0,
      baseSpeed: s.rng.rand(1.0) + 2.0,
      glanceT: 0.0,
      glanced: false,
      nearTrigger: s.rng.rand(300.0) + 30.0,
      animT: 0.0,
      doing: emission,
    )
    s.crowd.add(man)

method update*(s: TurnScene, dt: float, ctx: Context) =
  if loadImageProgress() != 1.0:
    return

  const moonStart = V2(x: Wf, y: Hf - 300)
  const moonEnd = V2(x: 0.0, y: 0.0)
  s.time += dt
  let prog = s.time / 20.0

  s.moonPos = moonStart * (1.0 - prog) + moonEnd * prog

  if prog > 0.95:
    s.fade = (prog - 0.95) / 0.05
  else:
    s.fade = 0.0

  for man in s.crowd.mitems:
    man.update(dt, s.playerX)

  if prog > 1.0:
    s.state.finishTurn()
    goToScene sidAction

method draw*(s: TurnScene, c: Canvas) =
  if loadImageProgress() != 1.0:
    c.fillStyle("#000")
    c.alpha(loadImageProgress())
    c.fillRect(0, 0, Wf, Hf)
    c.alpha(1.0)
    return

  case s.state.moonPhase
  of mpNew:
    c.fillStyle("#063540")
  of mpWaxing:
    c.fillStyle("#094d5d")
  of mpWaning:
    c.fillStyle("#094d5d")
  of mpFull:
    c.fillStyle("#035062")

  c.fillRect(0, 0, Wf, Hf)
  c.alpha(1.0)

  c.drawFrame(s.assets.moon, ord(s.state.moonPhase), s.moonPos.x, s.moonPos.y, 2.0)

  const backY = 100.0
  c.drawFrame(s.assets.background, 0, 0.0, backY, 2.0)
  c.drawFrame(s.assets.background, 0, s.assets.background.fw.toFloat * 2.0, backY, 2.0)

  c.drawFrame(s.assets.middleground, 0, 0.0, 0.0, 2.0)

  for man in s.crowd.mitems:
    man.draw(c, s.assets, s.playerX)

  c.fillStyle("#000")
  c.alpha(s.fade)
  c.fillRect(0, 0, Wf, Hf)
  c.alpha(1.0)
