---
layout: default
title: "ffmpeg adventures"
date: 2016-02-02
keywords: 
published: true
---



## Figure out which DirectShow input devices I have

```
ffmpeg -list_devices true -f dshow -i dummy
```

## Capture the local web cam & microphone and create a 10sec MP4 video

```
ffmpeg -f dshow -i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)" -t 10 out.mp4
```

# Screen capture

## Screen capture filter

For capturing the local screen, you need a driver to tap into the video card. `ffmpeg` on Windows ships with the GDI grabber [`-f gdigrab`](https://www.ffmpeg.org/ffmpeg-devices.html#gdigrab) filter. 

It is also possible to use a DirectShow filter (`-f dshow`), but then you need a driver. 

- https://github.com/rdp/screen-capture-recorder-to-video-windows-free
- https://sourceforge.net/projects/screencapturer/files 
- http://netcologne.dl.sourceforge.net/project/screencapturer/Setup%20Screen%20Capturer%20Recorder%20v0.12.8.exe

After installing the driver above, you will be able to use the ffmpeg input 

```
   -i video="screen-capture-recorder":audio="virtual-audio-capturer"
```

## Write a 10 second screen capture (at 20 fps) to local MP4 file

```
ffmpeg -f dshow -i video="screen-capture-recorder":audio="virtual-audio-capturer" -r 20 -t 10 screen-capture.mp4 
```


## Play back current screen

```
ffplay -f dshow -i video="screen-capture-recorder" -vf scale=1280:720
```


# Azure Media Players

You can use the [DASHPlayer](http://dashplayer.azurewebsites.net/) or [aka.ms/azuremediaplayer](http://amsplayer.azurewebsites.net/azuremediaplayer.html). 



# Streaming to Azure Media Services Live Streaming

```
set DEST=rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1935/live/deadbeef012345678890abcdefabcdef/channel1

set SRC=video="Integrated Camera":audio="Headset Microphone (GN 2000 USB OC)"

REM set SRC=video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)"

ffmpeg -f dshow -i %SRC% -s 640x480  -preset veryfast -codec:v libx264 -b:v 200k -pix_fmt yuv420p -maxrate 200k -bufsize 200k -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -codec:a libvo_aacenc -b:a 48k -f flv %DEST%
```

