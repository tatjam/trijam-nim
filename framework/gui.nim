# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Style-driven GUI widgets

import mice, canvases, texts

type
  GuiStyle* = object
    fill*: string
    fillActive*: string
    fillAccent*: string
    border*: string
    text*: string
    textSize*: int

  GuiButton* = object
    x*, y*, w*, h*: float
    text*: string

  GuiBar* = object
    x*, y*, w*, h*: float
    fraction*: float
    label*: string
    color*: string

proc contains*(b: GuiButton, x, y: float): bool =
  x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h

proc hovered*(b: GuiButton, m: Mouse): bool =
  b.contains(m.pos.x, m.pos.y)

proc clicked*(b: GuiButton, m: Mouse): bool =
  b.hovered(m) and bLeft in m.pressed

proc draw*(b: GuiButton, c: Canvas, style: GuiStyle, active = false) =
  c.fillStyle(cstring(if active: style.fillActive else: style.fill))
  c.strokeStyle(cstring(style.border))
  c.fillRect(b.x, b.y, b.w, b.h)
  c.strokeRect(b.x, b.y, b.w, b.h)
  c.drawText(b.text, b.x + b.w / 2, b.y + b.h / 2, aCenter, style.text, style.textSize)

proc draw*(b: GuiBar, c: Canvas, style: GuiStyle) =
  let fill = if b.color == "": style.fillAccent else: b.color
  c.drawText(b.label, b.x - 24, b.y + b.h / 2, aRight, style.text, style.textSize - 4)
  c.fillStyle(cstring(style.fill))
  c.fillRect(b.x, b.y, b.w, b.h)
  c.fillStyle(cstring(fill))
  c.fillRect(b.x, b.y, b.w * b.fraction, b.h)
  c.strokeStyle(cstring(style.border))
  c.strokeRect(b.x, b.y, b.w, b.h)
  c.drawText(
    $(int(b.fraction * 100.0 + 0.5)) & "%",
    b.x + b.w + 24,
    b.y + b.h / 2,
    aLeft,
    style.text,
    style.textSize - 4,
  )
