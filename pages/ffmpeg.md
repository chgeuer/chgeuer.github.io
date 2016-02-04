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

## Determine the capabilities of the hardware

```
ffmpeg -f dshow -i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)" -list_formats all
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

# Streaming to Azure Media Services Live Streaming

After creating an Azure Media Services Live channel, we get two RTMP ingest endpoints, which differ in their TCP port number (1935 and 1936):

- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef`
- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef`

For ffmpeg to work, we need to append the channel name `/channel1` to the URLs: 

- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef/channel1`
- `rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1936/live/deadbeef012345678890abcdefabcdef/channel1`

## Input specs

The [Azure Blog](https://azure.microsoft.com/en-us/blog/azure-media-services-rtmp-support-and-live-encoders/) now tells us to use RTMP with H.264 video and AAC audio, a 2-second key-frame interval, and CBR (constant bit rate) encoding. 


## Configuring ffmpeg

### Links

- [ffmpeg - command line options](https://ffmpeg.org/ffmpeg.html)
- [ffmpeg - Streaming](https://trac.ffmpeg.org/wiki/StreamingGuide)
- [ffmpeg - Encoding for streaming sites](https://trac.ffmpeg.org/wiki/EncodingForStreamingSites)
- https://sonnati.wordpress.com/2011/08/19/ffmpeg-%E2%80%93-the-swiss-army-knife-of-internet-streaming-%E2%80%93-part-iii/

### Command line arguments

#### misc

- `-y` Overwrite output files without asking
- `-loglevel debug` (or verbose, quiet, panic, fatal) 

### Input

- `-f dshow` use DirectShow Filter
- `-i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)"` use internal web cam and microphone

#### Video output

- `-s 640x480` Resolution
- `-codec:v libx264` H.264 / AVC video
- `-pix_fmt yuv420p` pixel format YUV420
- `-preset veryfast` (ultrafast,superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo)
- `-b:v 200k` target video bit rate
- `-minrate 200k` minimum video bit rate
- `-maxrate 200k` maximum video bit rate
- `-r 30` frame rate
- `-keyint_min 60` minimum GOP size
- `-g 60` maximum GOP size
- `-sc_threshold 0` scene change threshold
- `-bsf:v h264_mp4toannexb` bitstream filter. Use `ffmpeg -bsfs` for a full list
- `-profile:v main` preset according to [docs](https://trac.ffmpeg.org/wiki/Encode/H.264#a2.Chooseapreset)
- `-level 3.1` compatible level according to [docs](https://trac.ffmpeg.org/wiki/Encode/H.264#Compatibility)

#### Audio output

- `-codec:a libvo_aacenc` AAC audio
- `-b:a 128k` audio bit rate 
- `-ar 44100` audio sampling frequency
- `-ac 2` audio channels
- `-strict experimental`

#### overall stream

- `-bufsize 200k` buffer size
- `-maxrate 200k` maximim bit rate

#### Destination

- `-f flv rtmp://chan1-acc2.channel.mediaservices.windows.net:1936/live/deadbeef/chan1` target RTMP endpoint to push to

## Ingest the RTMP stream

```
set DEST=rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1935/live/deadbeef012345678890abcdefabcdef/channel1
set SRC=video="Integrated Camera":audio="Headset Microphone (GN 2000 USB OC)"

ffmpeg -f dshow -i %SRC% -s 640x480  -preset veryfast -codec:v libx264 -pix_fmt yuv420p -b:v 200k -minrate 200k -maxrate 200k -bufsize 200k -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -codec:a libvo_aacenc -b:a 48k -f flv %DEST%

set VIDEOBITRATE=200k

ffmpeg -f dshow -i %SRC% -s 640x480  -preset veryslow -codec:v libx264 -pix_fmt yuv420p -pass 1 -b:v %VIDEOBITRATE% -minrate %VIDEOBITRATE% -maxrate %VIDEOBITRATE% -bufsize %VIDEOBITRATE% -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -profile:v main -level 3.1 -codec:a aac -ar 44100 -b:a 96k -ac 2 -f flv %DEST%



set DEST=rtmp://channel1-mediaservice321.channel.mediaservices.windows.net:1935/live/deadbeef012345678890abcdefabcdef/channel1

set SRC="C:\Users\chgeuer\Cosmos Laundromat - First Cycle. Official Blender Foundation release.-Y-rmzh0PI3c.webm"

ffmpeg -re -f dshow -i %SRC% -s 640x480  -preset veryslow -codec:v libx264 -pix_fmt yuv420p -pass 1 -b:v %VIDEOBITRATE% -minrate %VIDEOBITRATE% -maxrate %VIDEOBITRATE% -bufsize %VIDEOBITRATE% -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -profile:v main -level 3.1 -codec:a aac -ar 44100 -b:a 96k -ac 2 -f flv %DEST%
```

You can use the [DASHPlayer](http://dashplayer.azurewebsites.net/) or [aka.ms/azuremediaplayer](http://amsplayer.azurewebsites.net/azuremediaplayer.html). Don't forget to append `(format=mpd-time-csf)` or `(format=m3u8-aapl)` to the streams for DASH or HLS streaming. 




# MPEG TS Streaming

RTP protocol (MPEG Transport Streams) encoded MPEG-2
-f mpegts udp://127.0.0.1:10000?pkt_size=1316
-f rtp    rtp://127.0.0.1:1234

- [FFMPEG for TS streaming](https://www.wowza.com/forums/content.php?213-How-to-use-FFmpeg-with-Wowza-Media-Server-(MPEG-TS))







ffmpeg -re -i %SRC% -s 640x480  -preset veryslow -codec:v libx264 -pix_fmt yuv420p -pass 1 -b:v %VIDEOBITRATE% -minrate %VIDEOBITRATE% -maxrate %VIDEOBITRATE% -bufsize %VIDEOBITRATE% -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -profile:v main -level 3.1 -codec:a aac -ar 44100 -b:a 96k -ac 2 -f rtp rtp://127.0.0.1:1234


http://www.adobe.com/de/products/flash-media-encoder.html
https://obsproject.com/
