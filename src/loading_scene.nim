# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/scenes, framework/canvases
import framework/texts, framework/canvas_utils, framework/sprites
import flow

type LoadScene* = ref object of Scene

proc newLoadScene*(data: SceneData): Scene = LoadScene()

method update*(s: LoadScene, dt: float, ctx: Context) =
  if loadImageProgress() >= 1.0:
    goToScene(sidHello)

method draw*(s: LoadScene, c: Canvas) =
  c.clear("#101018")
  c.drawText("Loading...", c.width.float / 2, c.height.float / 2)
