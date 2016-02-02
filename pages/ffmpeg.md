---
layout: default
title: "ffmpeg adventures"
date: 2016-02-02
keywords: 
published: true
---




## Write a 10 second screen capture (at 20 fps) to local MP4 file

```
ffmpeg -f dshow -i video="screen-capture-recorder":audio="virtual-audio-capturer" -r 20 -t 10 screen-capture.mp4 
```
