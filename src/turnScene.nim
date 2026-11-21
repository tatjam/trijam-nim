# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, audio, sprite, vec], state, assets, config, scenes

var res: Assets = nil

type TurnScene* = ref object of Scene
  state*: GameState
  time: float
  moonPos: V2
  fade: float

method enter*(s: TurnScene) =
  res = loadAssets()
  s.time = 0.0

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

  const backY = 100.0
  c.drawFrame(res.background, 0, 0.0, backY, 2.0)
  c.drawFrame(res.background, 0, res.background.fw.toFloat * 2.0, backY, 2.0)

  echo s.moonPos.x
  c.drawFrame(res.moon, 0, s.moonPos.x, s.moonPos.y, 2.0)

  c.fillStyle("#000")
  c.alpha(s.fade)
  c.fillRect(0, 0, Wf, Hf)
  c.alpha(1.0)
