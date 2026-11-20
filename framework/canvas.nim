# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

import std/math

type
  Canvas* {.importc.} = ref object # a 2D context (the screen or an offscreen layer)
  Gradient* {.importc.} = ref object
  Img* {.importc.} = ref object # HTML image
    complete*: bool
    naturalWidth*: int
    naturalHeight*: int

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

# butt | round | square
proc lineCap*(c: Canvas, s: cstring) {.importjs: "#.lineCap = #".}

# miter | round | bevel
proc lineJoin*(c: Canvas, s: cstring) {.importjs: "#.lineJoin = #".}

proc alpha*(c: Canvas, a: float) {.importjs: "#.globalAlpha = #".}
proc blend*(c: Canvas, mode: cstring) {.importjs: "#.globalCompositeOperation = #".}
  # source-over (default) | lighter | source-atop | destination-in | destination-out | multiply | screen

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
proc textAlign*(c: Canvas, a: cstring) {.importjs: "#.textAlign = #".}
  # left | center | right

proc textBaseline*(c: Canvas, b: cstring) {.importjs: "#.textBaseline = #".}
  # top | middle | alphabetic

proc fillText*(c: Canvas, s: cstring, x, y: float) {.importjs: "#.fillText(@)".}
proc strokeText*(c: Canvas, s: cstring, x, y: float) {.importjs: "#.strokeText(@)".}
proc textWidth*(c: Canvas, s: cstring): float {.importjs: "#.measureText(#).width".}

proc newImg(): Img {.importjs: "new Image()".}
proc `src=`(i: Img, s: cstring) {.importjs: "#.src = #".}

proc drawImage*(c: Canvas, i: Img, x, y: float) {.importjs: "#.drawImage(#,@)".}
proc drawImage*(
  c: Canvas, i: Img, sx, sy, sw, sh, dx, dy, dw, dh: float
) {.importjs: "#.drawImage(#,@)".}

proc drawCanvas*(dst, src: Canvas) {.importjs: "#.drawImage(#.canvas,0,0)".}
proc drawCanvas*(dst, src: Canvas, x, y: float) {.importjs: "#.drawImage(#.canvas,@)".}
proc drawCanvas*(
  dst, src: Canvas, x, y, w, h: float
) {.importjs: "#.drawImage(#.canvas,@)".}

proc drawCanvas*(
  dst, src: Canvas, sx, sy, sw, sh, dx, dy, dw, dh: float
) {.importjs: "#.drawImage(#.canvas,@)".}

var pendingImgs: seq[Img]

func ready*(i: Img): bool =
  i.complete and i.naturalWidth > 0

proc loadImg*(path: cstring): Img =
  result = newImg()
  result.src = path
  pendingImgs.add result

proc allLoaded*(): bool =
  for i in pendingImgs:
    if not i.ready:
      return false
  true

template saved*(c: Canvas, body: untyped) =
  ## Runs body between save() and restore().
  c.save()
  body
  c.restore()

proc clear*(c: Canvas, color: cstring) =
  c.fillStyle(color)
  c.fillRect(0, 0, c.width.float, c.height.float)

proc line*(c: Canvas, x0, y0, x1, y1: float) =
  c.beginPath()
  c.moveTo(x0, y0)
  c.lineTo(x1, y1)
  c.stroke()

proc fillCircle*(c: Canvas, x, y, r: float) =
  c.beginPath()
  c.arc(x, y, r, 0, TAU)
  c.fill()

proc strokeCircle*(c: Canvas, x, y, r: float) =
  c.beginPath()
  c.arc(x, y, r, 0, TAU)
  c.stroke()

proc polygon*(c: Canvas, pts: openArray[(float, float)], close = true) =
  if pts.len == 0:
    return
  c.beginPath()
  c.moveTo(pts[0][0], pts[0][1])
  for i in 1 ..< pts.len:
    c.lineTo(pts[i][0], pts[i][1])
  if close:
    c.closePath()

proc drawFrame*(c: Canvas, i: Img, fw, fh, frame: int, x, y: float, scale = 1.0) =
  if not i.ready:
    return
  let cols = max(1, i.naturalWidth div fw)
  c.drawImage(
    i,
    ((frame mod cols) * fw).float,
    ((frame div cols) * fh).float,
    fw.float,
    fh.float,
    round(x),
    round(y),
    fw.float * scale,
    fh.float * scale,
  )

proc glow*(c: Canvas, x, y, r: float, color: cstring) =
  let g = c.radialGradient(x, y, 0, x, y, r)
  g.addStop(0, color)
  g.addStop(1, "rgba(0,0,0,0)")
  c.fillStyle(g)
  c.fillRect(x - r, y - r, r * 2, r * 2)

proc lightBlob*(c: Canvas, x, y, r: float) =
  c.glow(x, y, r, "rgba(255,255,255,1)")

proc tintLayer*(c: Canvas, color: cstring, a = 1.0) =
  c.save()
  c.blend("source-atop")
  c.alpha(a)
  c.fillStyle(color)
  c.fillRect(0, 0, c.width.float, c.height.float)
  c.restore()
