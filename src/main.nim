# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/loop, framework/scenes, framework/canvases
import framework/texts, framework/canvas_utils
import flow, loading_scene

const
  W = 1300
  H = 700
  dt = 1.0 / 60.0
  gameKeys = ["w", "a", "s", "d", " "]

type HelloScene = ref object of Scene

proc newHelloScene(data: SceneData): Scene = HelloScene()

method draw(s: HelloScene, c: Canvas) =
  c.clear("#101018")
  c.drawText("Hello world!", c.width.float / 2, c.height.float / 2)

register(sidLoad, newLoadScene)
register(sidHello, newHelloScene)

startLoop("c", W, H, dt, @gameKeys, newLoadScene(SceneData(kind: sidLoad)))
