# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, audio, sprite, vec], state, assets, config, scenes
import std/rand

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
  let toward = if dx > 0: 1.0 else: -1.0

  man.animT += dt * 2.0 * man.baseSpeed
  if man.glanceT > 0.0:
    man.glanceT -= dt * man.baseSpeed

  var vx = 0.0

  case man.doing
  of cbWarmToward, cbUniformToward:
    let speed = if man.doing == cbWarmToward: 40.0 else: 28.0
    if abs(dx) > 24:
      vx = toward * speed
    else:
      man.glanceT = 9999.0
  of cbGlance:
    vx = man.baseDir * 30.0
    if not man.glanced and abs(dx) < man.nearTrigger:
      man.glanceT = 1.0
      man.glanced = true
  of cbIgnore:
    vx = man.baseDir * 18.0

proc draw(man: CrowdMan, playerX: float) =
  discard

type TurnScene* = ref object of Scene
  state*: GameState
  time: float
  moonPos: V2
  fade: float

  crowd: seq[CrowdMan]
  rng: Rand

method enter*(s: TurnScene) =
  res = loadAssets()
  s.time = 0.0

  # Build the crowd
  let emit = s.state.getEmit()
  for man in 

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

  c.drawFrame(res.moon, ord(s.state.moonPhase), s.moonPos.x, s.moonPos.y, 2.0)

  const backY = 100.0
  c.drawFrame(res.background, 0, 0.0, backY, 2.0)
  c.drawFrame(res.background, 0, res.background.fw.toFloat * 2.0, backY, 2.0)

  c.drawFrame(res.middleground, 0, 0.0, 0.0, 2.0)

  c.fillStyle("#000")
  c.alpha(s.fade)
  c.fillRect(0, 0, Wf, Hf)
  c.alpha(1.0)
