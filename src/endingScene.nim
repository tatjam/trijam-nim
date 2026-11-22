# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, mouse, audio, text], state, config, scenes
import std/options

type EndingScene* = ref object of Scene
  state*: GameState

method update*(s: EndingScene, dt: float, ctx: Context) =
  discard

method draw*(s: EndingScene, c: Canvas) =
  c.fillStyle("#edc372")
  c.fillRect(0, 0, Wf, Hf)
