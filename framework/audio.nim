# Copyright (C) 2026 tatjam
# SPDX-License-Identifier: GPL-3.0-or-later

type
  AudioCtx = ref object
  Wave* = enum
    wSquare = "square"
    wSine = "sine"
    wSaw = "sawtooth"
    wTri = "triangle"

var ac: AudioCtx

proc newAudioCtx(): AudioCtx {.
  importjs: "new (window.AudioContext || window.webkitAudioContext)()"
.}

proc resume(a: AudioCtx) {.importjs: "#.resume()".}
proc jsBeep(
  a: AudioCtx, f0, f1, dur, vol: float, wave: cstring
) {.
  importjs: """(function(a,f0,f1,d,v,w){
    const t=a.currentTime, o=a.createOscillator(), g=a.createGain();
    o.type=w; o.frequency.setValueAtTime(f0,t);
    o.frequency.exponentialRampToValueAtTime(f1,t+d);
    g.gain.setValueAtTime(v,t); g.gain.exponentialRampToValueAtTime(0.0001,t+d);
    o.connect(g); g.connect(a.destination); o.start(t); o.stop(t+d);
  })(#,#,#,#,#,#)"""
.}

proc unlockAudio*() =
  if ac.isNil:
    ac = newAudioCtx()
  ac.resume()

proc beep*(freq: float, dur = 0.12, vol = 0.1, slideTo = 0.0, wave = wSquare) =
  if ac.isNil:
    return
  ac.jsBeep(freq, (if slideTo > 0: slideTo else: freq), dur, vol, cstring($wave))
