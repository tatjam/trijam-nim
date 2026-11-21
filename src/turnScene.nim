# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/[scene, canvas, audio], state

type TurnScene* = ref object of Scene
  state*: GameState

method update*(s: TurnScene, dt: float, ctx: Context) =
  discard

method draw*(s: TurnScene, c: Canvas) =
  discard
