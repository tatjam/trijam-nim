# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------
# Wrappers for HTML 5 canvas with sum types

type
  Canvas* {.importc.} = ref object # a 2D context (the screen or an offscreen layer)
  Gradient* {.importc.} = ref object

  LineCap* = enum
    lcButt = "butt"
    lcRound = "round"
    lcSquare = "square"

  LineJoin* = enum
    ljMiter = "miter"
    ljRound = "round"
    ljBevel = "bevel"

  BlendMode* = enum
    bmSourceOver = "source-over"
    bmLighter = "lighter"
    bmSourceAtop = "source-atop"
    bmDestinationIn = "destination-in"
    bmDestinationOut = "destination-out"
    bmMultiply = "multiply"
    bmScreen = "screen"

  TextAlign* = enum
    taLeft = "left"
    taCenter = "center"
    taRight = "right"

  TextBaseline* = enum
    tbTop = "top"
    tbMiddle = "middle"
    tbAlphabetic = "alphabetic"

proc initCanvas*(
  id: cstring, w, h: int
): Canvas {.
  importjs:
    "(function(id,w,h){const c=document.getElementById(id);c.width=w;c.height=h;const x=c.getContext('2d');x.imageSmoothingEnabled=false;return x})(#,#,#)"
.}

proc newLayer*(
  w, h: int
): Canvas {.
  importjs:
    "(function(w,h){const c=document.createElement('canvas');c.width=w;c.height=h;const x=c.getContext('2d');x.imageSmoothingEnabled=false;return x})(#,#)"
.}

proc requestFrame*(cb: proc(t: float)) {.importjs: "window.requestAnimationFrame(#)".}

proc width*(c: Canvas): int {.importjs: "#.canvas.width".}
proc height*(c: Canvas): int {.importjs: "#.canvas.height".}

proc fillStyle*(c: Canvas, s: cstring) {.importjs: "#.fillStyle = #".}
proc fillStyle*(c: Canvas, g: Gradient) {.importjs: "#.fillStyle = #".}
proc strokeStyle*(c: Canvas, s: cstring) {.importjs: "#.strokeStyle = #".}
proc strokeStyle*(c: Canvas, g: Gradient) {.importjs: "#.strokeStyle = #".}
proc lineWidth*(c: Canvas, w: float) {.importjs: "#.lineWidth = #".}

proc jsLineCap(c: Canvas, s: cstring) {.importjs: "#.lineCap = #".}
proc lineCap*(c: Canvas, cap: LineCap) =
  c.jsLineCap(cstring($cap))

proc jsLineJoin(c: Canvas, s: cstring) {.importjs: "#.lineJoin = #".}
proc lineJoin*(c: Canvas, join: LineJoin) =
  c.jsLineJoin(cstring($join))

proc alpha*(c: Canvas, a: float) {.importjs: "#.globalAlpha = #".}
proc jsBlend(c: Canvas, mode: cstring) {.importjs: "#.globalCompositeOperation = #".}
proc blend*(c: Canvas, mode: BlendMode) =
  c.jsBlend(cstring($mode))

proc smoothing*(c: Canvas, on: bool) {.importjs: "#.imageSmoothingEnabled = #".}
proc setLineDash*(c: Canvas, d: seq[float]) {.importjs: "#.setLineDash(#)".}

proc shadow*(
  c: Canvas, blur: float, color: cstring, ox = 0.0, oy = 0.0
) {.
  importjs:
    "(function(c,b,col,x,y){c.shadowBlur=b;c.shadowColor=col;c.shadowOffsetX=x;c.shadowOffsetY=y})(#,#,#,#,#)"
.}

proc noShadow*(c: Canvas) {.importjs: "#.shadowBlur = 0".}

proc save*(c: Canvas) {.importjs: "#.save()".}
proc restore*(c: Canvas) {.importjs: "#.restore()".}
proc translate*(c: Canvas, x, y: float) {.importjs: "#.translate(@)".}
proc rotate*(c: Canvas, radians: float) {.importjs: "#.rotate(@)".}
proc scale*(c: Canvas, x, y: float) {.importjs: "#.scale(@)".}
proc resetTransform*(c: Canvas) {.importjs: "#.resetTransform()".}

proc fillRect*(c: Canvas, x, y, w, h: float) {.importjs: "#.fillRect(@)".}
proc strokeRect*(c: Canvas, x, y, w, h: float) {.importjs: "#.strokeRect(@)".}
proc clearRect*(c: Canvas, x, y, w, h: float) {.importjs: "#.clearRect(@)".}

proc beginPath*(c: Canvas) {.importjs: "#.beginPath()".}
proc closePath*(c: Canvas) {.importjs: "#.closePath()".}
proc moveTo*(c: Canvas, x, y: float) {.importjs: "#.moveTo(@)".}
proc lineTo*(c: Canvas, x, y: float) {.importjs: "#.lineTo(@)".}
proc arc*(c: Canvas, x, y, r, a0, a1: float) {.importjs: "#.arc(@)".}
proc ellipse*(c: Canvas, x, y, rx, ry, rot, a0, a1: float) {.importjs: "#.ellipse(@)".}
proc pathRect*(c: Canvas, x, y, w, h: float) {.importjs: "#.rect(@)".}
proc roundRect*(c: Canvas, x, y, w, h, r: float) {.importjs: "#.roundRect(@)".}
proc quadTo*(c: Canvas, cx, cy, x, y: float) {.importjs: "#.quadraticCurveTo(@)".}
proc bezierTo*(
  c: Canvas, c1x, c1y, c2x, c2y, x, y: float
) {.importjs: "#.bezierCurveTo(@)".}

proc fill*(c: Canvas) {.importjs: "#.fill()".}
proc stroke*(c: Canvas) {.importjs: "#.stroke()".}
proc clip*(c: Canvas) {.importjs: "#.clip()".}

proc linearGradient*(
  c: Canvas, x0, y0, x1, y1: float
): Gradient {.importjs: "#.createLinearGradient(@)".}

proc radialGradient*(
  c: Canvas, x0, y0, r0, x1, y1, r1: float
): Gradient {.importjs: "#.createRadialGradient(@)".}

proc addStop*(
  g: Gradient, at: float, color: cstring
) {.importjs: "#.addColorStop(#,#)".}

proc font*(c: Canvas, f: cstring) {.importjs: "#.font = #".}
proc jsTextAlign(c: Canvas, a: cstring) {.importjs: "#.textAlign = #".}
proc textAlign*(c: Canvas, a: TextAlign) =
  c.jsTextAlign(cstring($a))

proc jsTextBaseline(c: Canvas, b: cstring) {.importjs: "#.textBaseline = #".}
proc textBaseline*(c: Canvas, b: TextBaseline) =
  c.jsTextBaseline(cstring($b))

proc fillText*(c: Canvas, s: cstring, x, y: float) {.importjs: "#.fillText(@)".}
proc strokeText*(c: Canvas, s: cstring, x, y: float) {.importjs: "#.strokeText(@)".}
proc textWidth*(c: Canvas, s: cstring): float {.importjs: "#.measureText(#).width".}

proc drawCanvas*(dst, src: Canvas) {.importjs: "#.drawImage(#.canvas,0,0)".}
proc drawCanvas*(dst, src: Canvas, x, y: float) {.importjs: "#.drawImage(#.canvas,@)".}
proc drawCanvas*(
  dst, src: Canvas, x, y, w, h: float
) {.importjs: "#.drawImage(#.canvas,@)".}

proc drawCanvas*(
  dst, src: Canvas, sx, sy, sw, sh, dx, dy, dw, dh: float
) {.importjs: "#.drawImage(#.canvas,@)".}
