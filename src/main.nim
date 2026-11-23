# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import framework/loop, framework/scenes, framework/canvases
import framework/texts, framework/canvas_utils, framework/gui
import flow, loading_scene

const
  W = 1300
  H = 700
  dt = 1.0 / 60.0
  gameKeys = ["w", "a", "s", "d", " "]
  guiStyle = GuiStyle(
    fill: "#6e582e",
    fillActive: "#a48c73",
    fillAccent: "#58789e",
    border: "#000",
    text: "#fff",
    textSize: 36,
  )

type HelloScene = ref object of Scene
  count: int
  hover: bool

proc newHelloScene(data: SceneData): Scene =
  HelloScene()

proc demoButton(): GuiButton =
  GuiButton(x: W / 2 - 150, y: H / 2 + 100, w: 300, h: 80, text: "Click me")

proc demoBar(count: int): GuiBar =
  GuiBar(
    x: W / 2 - 200,
    y: H / 2 + 220,
    w: 400,
    h: 40,
    fraction: count.float / 10.0,
    label: "Progress",
    color: "",
  )

method update(s: HelloScene, dt: float, ctx: Context) =
  let btn = demoButton()
  s.hover = btn.hovered(ctx.mous)
  if btn.clicked(ctx.mous):
    echo "Click"
    s.count = (s.count + 1) mod 11

method draw(s: HelloScene, c: Canvas) =
  c.clear("#101018")
  c.drawText("Hello world!", c.width.float / 2, c.height.float / 2)
  demoButton().draw(c, guiStyle, s.hover)
  demoBar(s.count).draw(c, guiStyle)

register(sidLoad, newLoadScene)
register(sidHello, newHelloScene)

startLoop("c", W, H, dt, @gameKeys, newLoadScene(SceneData(kind: sidLoad)))
