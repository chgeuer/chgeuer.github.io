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

On my work laptop, I have an integrated web cam, a built-in microphone, and an additional head set: 


```
C:\Users\chgeuer>ffmpeg -list_devices true -f dshow -i dummy

ffmpeg version N-69972-g6c91afe Copyright (c) 2000-2015 the FFmpeg developers
...
[dshow @ 0000000004d2d540] DirectShow video devices (some may be both video and audio devices)
[dshow @ 0000000004d2d540]  "Integrated Camera"
[dshow @ 0000000004d2d540] DirectShow audio devices
[dshow @ 0000000004d2d540]  "Microphone (Realtek High Definition Audio)"
[dshow @ 0000000004d2d540]  "Headset Microphone (GN 2000 USB OC)"
```

The strings `"Integrated Camera"`, `"Microphone (Realtek High Definition Audio)"` and `"Headset Microphone (GN 2000 USB OC)"` now refer to the different usable sources. In ffmpeg, the `-i` parameter usually refers to the input file. In our case, we can now combine video & audio sources to an input specification for ffmpeg: 

- `-i video="Integrated Camera":audio="Headset Microphone (GN 2000 USB OC)"`
- `-i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)"`


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

After creating an Azure Media Services Live channel, we get two RTMP ingest endpoints, which differ in their TCP port number (1935 and 1936):

- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef`
- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef`

For ffmpeg to work, we need to append the channel name `/channel1` to the URLs: 

- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef/channel1`
- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef/channel1`



```
set DEST=rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1935/live/deadbeef012345678890abcdefabcdef/channel1

set SRC=video="Integrated Camera":audio="Headset Microphone (GN 2000 USB OC)"

ffmpeg -f dshow -i %SRC% -s 640x480  -preset veryfast -codec:v libx264 -b:v 200k -pix_fmt yuv420p -maxrate 200k -bufsize 200k -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -codec:a libvo_aacenc -b:a 48k -f flv %DEST%
```

