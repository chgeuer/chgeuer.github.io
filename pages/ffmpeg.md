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
[dshow @ 0000000004d2d540]  "Headset Microphone (Plantronics C520-M)"
```

The strings `"Integrated Camera"`, `"Microphone (Realtek High Definition Audio)"` and `"Headset Microphone (Plantronics C520-M)"` now refer to the different usable sources. In ffmpeg, the `-i` parameter usually refers to the input file. In our case, we can now combine video & audio sources to an input specification for ffmpeg: 

- `-i video="Integrated Camera":audio="Headset Microphone (Plantronics C520-M)"`
- `-i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)"`

## Determine the capabilities of the hardware

```
ffmpeg -f dshow -i video="Integrated Camera":audio="Microphone (Realtek High Definition Audio)" -list_formats all
```

## Capture the local web cam & microphone and create a 5sec MP4 video

```
ffmpeg -f dshow -i video="Integrated Camera":audio="Headset Microphone (Plantronics C520-M)" -t 5 5-seconds.mp4
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
ffmpeg -f dshow -i video="screen-capture-recorder":audio="Headset Microphone (Plantronics C520-M)" -r 20 -t 10 screen-capture.mp4 
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






```
ffmpeg -re -i %SRC% -s 640x480  -preset veryslow -codec:v libx264 -pix_fmt yuv420p -pass 1 -b:v %VIDEOBITRATE% -minrate %VIDEOBITRATE% -maxrate %VIDEOBITRATE% -bufsize %VIDEOBITRATE% -r 30 -g 60 -keyint_min 60 -sc_threshold 0 -profile:v main -level 3.1 -codec:a aac -ar 44100 -b:a 96k -ac 2 -f rtp rtp://127.0.0.1:1234
```

- [Flash Media Live Encoder (FMLE)](http://www.adobe.com/de/products/flash-media-encoder.html) and [MainConcept AAC Encoder 1.0.6 Plugin for Adobe Flash Media Live Encoder](http://www.mainconcept.com/eu/products/plug-ins/plug-ins-for-adobe/aac-encoder-fmle.html)
- [Open Broadcaster Software](https://obsproject.com/) (OBS Classic & OBS Studio)
- [Blog: Azure Media Services RTMP Support and Live Encoder](https://azure.microsoft.com/en-us/blog/azure-media-services-rtmp-support-and-live-encoders/)
- [Telestream Wirecast Trial Version](http://www.telestream.net/wirecast/overview.htm)
- [nginx RTMP](https://obsproject.com/forum/resources/how-to-set-up-your-own-private-rtmp-server-using-nginx.50/)
- [Red 5 Server](http://red5.org/)


## Single bitrate:

```
ffmpeg.exe -v verbose 
    -i MysampleVideo.mp4 -strict -2 
    -codec:a aac -b:a 128k -ar 44100 
    -codec:v libx264 -b:v 400000 -bufsize 400k -maxrate 400k -preset medium  
    -r 30 -g 60 -keyint_min 60 
    -f flv rtmp://channel001-streamingtest.channel.media.windows.net:1935/live/a9bcd589da4b424099364f7ad5bd4940/mystream1
```

## Multi bitrate ( 3 bit rates 500, 300 and 150 Kbps)

```
ffmpeg.exe -threads 15 -re -i MysampleVideo.mp4 

        -strict experimental 
        -codec:a aac -ab 128k -ac 2 -ar 44100 
        -codec:v libx264 -s 800x600 -b:v 500k -minrate 500k -maxrate 500k -bufsize 500k  
        -r 30 -g 60 -keyint_min 60 -sc_threshold 0 
        -f flv rtmp://channel001-streamingtest.channel.media.windows.net:1935/live/a9bcd589da4b424099364f7ad5bd4940/Streams_500
        
        -strict experimental 
        -codec:a aac -ab 128k -ac 2 -ar 44100 
        -codec:v libx264 -s 640x480 -b:v 300k -minrate 300k -maxrate 300k -bufsize 300k 
        -r 30 -g 60 -keyint_min 60 -sc_threshold 0 
        -f flv rtmp://channel001-streamingtest.channel.media.windows.net:1935/live/a9bcd589da4b424099364f7ad5bd4940/Streams_300 
        -strict experimental 
        -codec:a aac -ab 128k -ac 2 -ar 44100 
        -codec:v libx264 -s 320x240 -b:v 150k -minrate 150k -maxrate 150k -bufsize 150k  
        -r 30 -g 60 -keyint_min 60 -sc_threshold 0 
        -f flv rtmp://channel001-streamingtest.channel.media.windows.net:1935/live/a9bcd589da4b424099364f7ad5bd4940/Streams_150
```

# My `ffmpeg` collection of stuff

- FFMPEG nutzen um HLS zu erzeugen https://bitbucket.org/walterebert/ffmpeg-hls/src

### Convert YT videos

```powershell

dir *.webm | foreach { ffmpeg -i $_.Name -ab 192k $_.Name.Replace("WEBM", "mp3").Replace("webm", "mp3") }

dir *.mkv | foreach { ffmpeg -i $_.Name -ab 192k $_.Name.Replace("mkv", "mp3") }

dir *.mkv | foreach { ffmpeg -i $_.Name -vcodec copy -acodec copy -map_metadata 0 $_.Name.Replace("mkv", "mp4") }

dir *.mkv | foreach { ffmpeg -i $_.Name -vcodec copy -ab 192k -map_metadata 0 $_.Name.Replace("mkv", "mp4") }

```

### Download HLS

```
ffmpeg -i https://...akamaihd.net/.../name/a.mp4/index.m3u8 -c copy -bsf:a aac_adtstoasc "foo.mp4"
```

# Interesting FFMPEG Articles

- [ffmbc - FFMedia Broadcast](https://code.google.com/p/ffmbc/)

# Using FFMPEG to convert audio files

```Powershell
ffmpeg -i infile.flac outfile.wav

REM http://etree.org/shnutils/shntool/
shntool.exe split -f infile.cue -t %n-%t -m /- outfile.wav

dir *.wav | foreach { ffmpeg -i $_.Name -ab 320k $_.Name.Replace("wav", "mp3") }

REM Convert FLAC to MP3 VBR
dir *.flac | foreach { ffmpeg -i $_.Name -qscale:a 1 $_.Name.Replace("flac", "mp3") }

REM Convert FLAC to MP3 320k
dir *.flac | foreach { ffmpeg -i $_.Name -ab 320k $_.Name.Replace("flac", "mp3") }

REM Create M4B from MP3
ffmpeg -i "concat:01.mp3|02.mp3" -c:a libvo_aacenc -vn out.m4a
ren out.m4a out.m4b
```

# Convert a bunch of MP3 files to an iPod audio book

```Powershell
# Convert a bunch of MP3 files to an iPod audio book

$folder = "C:\Users\Public\Music\Star Wars Episode 1 - Die dunkle Bedrohung"

Function concatenate($lines) {
    $sb = New-Object -TypeName "System.Text.StringBuilder";
    [void]$sb.Append("""");
    [void]$sb.Append("concat:");
    for ($i=0; $i -le $lines.Length; $i++) {
        [void]$sb.Append($lines[$i].Name);
        if ($i -le ($lines.Length - 2)) {
            [void]$sb.Append("|");
        }
    }
    [void]$sb.Append("""");
    return $sb.ToString();
}
Set-Location $folder
$filename = (Get-Item $folder).Name
$inputfiles = Get-ChildItem -Filter *.mp3 | Sort-Object -Property Name
$concatenation = concatenate($inputfiles)

# ffmpeg -i "concat:01.mp3|02.mp3" -c:a libvo_aacenc -vn 1.m4a
ffmpeg -i $concatenation -c:a libvo_aacenc -vn "$filename.m4a"
# Rename-Item -Path "$filename.m4a" -NewName "$filename.m4b"

# compare two videos @see http://ianfeather.co.uk/compare-two-webpagetest-videos-using-ffmpeg/
ffmpeg -i before.mp4 -i after.mp4 -filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" output.mp4
```

# Using FFMPEG to create VOD files

```Batchfile
SET FFMPEG="c:\program files\ffmpeg\bin\ffmpeg.exe"
SET GOPSIZE=-g 25
SET GOPSIZE=
SET VIDEOBITRATE=-b:v 1500k
SET RESOLUTION=-s "960x540"
SET RESOLUTION=

REM http://www.idude.net/index.php/how-to-watermark-a-video-using-ffmpeg
SET WATERMARK=   -filter_complex "overlay=main_w-overlay_w-10:main_h-overlay_h-10"
SET WATERMARK=   -filter_complex "overlay=(main_w+overlay_w)/2:(main_h+overlay_h)/2"
SET WATERMARK=   -vf "movie=logo2.png [watermark]; [in][watermark] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]"

SET CODEC_MP4=   -vcodec libx264   -pix_fmt yuv420p                     %WATERMARK% %GOPSIZE% %VIDEOBITRATE%
SET CODEC_WEBM=  -vcodec libvpx    -acodec libvorbis -ab 160000 -f webm %WATERMARK% %GOPSIZE% %VIDEOBITRATE%
SET CODEC_OGV=   -vcodec libtheora -acodec libvorbis -ab 160000         %WATERMARK% %GOPSIZE% %VIDEOBITRATE%
SET CODEC_POSTER= -ss 00:02 -vframes 1 -r 1              -f image2        %WATERMARK% 

%FFMPEG% -i %1 %CODEC_MP4%    %RESOLUTION% "%~n1.mp4"
%FFMPEG% -i %1 %CODEC_WEBM%   %RESOLUTION% "%~n1.webm"
%FFMPEG% -i %1 %CODEC_OGV%    %RESOLUTION% "%~n1.ogv"
%FFMPEG% -i %1 %CODEC_POSTER% %RESOLUTION% "%~n1.jpg"

REM http://stackoverflow.com/questions/7333232/concatenate-two-mp4-files-using-ffmpeg
REM file '1.mp4'
REM file '2.mp4'
REM %FFMPEG% -f concat -i mylist.txt -c copy output

REM Remux MOV to MP4
ffmpeg -i input.mov -vcodec copy -acodec libvo_aacenc -map_metadata 0 result.mp4

dir *.MOV | foreach { ffmpeg -i $_.Name -vcodec copy -acodec libvo_aacenc $_.Name.Replace("MOV", "mp4") }


REM Remux MKV to MP4
ffmpeg -i a.mkv -vcodec copy -ab 128k -acodec libvo_aacenc -map_metadata 0 a.mp4
ffmpeg -i a.mkv -vcodec copy -acodec copy                  -map_metadata 0 a.mp4
```
# Convert FLV (Flash Video) into real MP4

Files are FLVs, but named MP4. Make them *real* MP4. The ``-map_metadata 0`` ensures that metadata like date etc flows over to the new file.

```Powershell
dir *.mp4 | foreach { Rename-Item $_.Name  $_.Name.Replace("MP4", "flv").Replace("mp4", "flv") }
dir *.flv | foreach { ffmpeg -i $_.Name -vcodec copy -acodec copy         -map_metadata 0 $_.Name.Replace('FLV', 'mp4').Replace('flv', 'mp4') }
dir *.MOV | foreach { ffmpeg -i $_.Name -vcodec copy -acodec libvo_aacenc -map_metadata 0 $_.Name.Replace('MOV', 'mp4').Replace('mov', 'mp4')  }
```

```console
powershell -Command "dir *.MOV | foreach { ffmpeg -i $_.Name -vcodec copy -acodec libvo_aacenc -map_metadata 0 $_.Name.Replace('MOV', 'mp4').Replace('mov', 'mp4') }"
powershell -Command "dir *.AVI | foreach { ffmpeg -i $_.Name -map_metadata 0 $_.Name.Replace('AVI', 'mp4').Replace('avi', 'mp4') }"
```


# Concatenate video files

In order to concatenate MP4 files, each file must be converted into a Transport Stream (.ts), i.e. without a MOOV atom, and then concatenated and re-written into a proper .mp4 file (with MOOV atom): 

```Powershell
dir *.mp4 | foreach { ffmpeg -i $_.Name -c copy -bsf:v h264_mp4toannexb -f mpegts $_.Name.Replace("MP4", "ts").Replace("mp4", "ts") }

ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
```

Alternatively, you can list all input files in a text file: 

```shell
$ cat m.txt
file 'm1-01 - Introduction - Introduction.ts'
file 'm1-02 - Introduction - Tools.ts'

$ ffmpeg -f concat -i list.txt -c copy -bsf:a aac_adtstoasc output.mp4
```


# Create MP4 from single images

```Powershell
ffmpeg -start_number 3407 -i img_%4d.jpg -c:v libx264 -s "1404x936" out.mp4
```

# Using RTMPDump to fetch an RTMP source

- See also http://stream-recorder.com/forum/tutorial-using-rtmpdump-download-bbc-iplayer-t7368.html
- http://rtmpdump.mplayerhq.hu/ and http://rtmpdump.mplayerhq.hu/download/rtmpdump-2.4-git-010913-windows.zip

```cmd
rtmpdump --protocol 0 --host cp45414.edgefcs.net -a "ondemand?auth=daEa9dhbhaJd4dmc8bicPd1cJdcdzcUcwcd-btFUIl-bWG-CqsEHnBqLEpGnxK&aifp=v001&slist=public/mps_h264_med/public/news/world/1078000/1078809_h264_800k.mp4;public/mps_h264_lo/public/news/world/1078000/1078809_h264_496k.mp4;public/mps_h264_hi/public/news/world/1078000/1078809_h264_1500k.mp4" -y "mp4:public/mps_h264_lo/public/news/world/1078000/1078809_h264_496k.mp4" -o someresolution.flv

ffmpeg -i someresolution.flv  -c:v copy -c:a copy someresolution.mp4

rtmpdump --protocol 0 --host cp45414.edgefcs.net -a "ondemand?auth=daEa9dhbhaJd4dmc8bicPd1cJdcdzcUcwcd-btFUIl-bWG-CqsEHnBqLEpGnxK&aifp=v001&slist=public/mps_h264_hi/public/news/world/1078000/1078809_h264_1500k.mp4" -y "mp4:public/mps_h264_hi/public/news/world/1078000/1078809_h264_1500k.mp4" -o 1078809_h264_1500k.flv

ffmpeg -i 1078809_h264_1500k.flv  -c:v copy -c:a copy 1078809_h264_1500k.mp4
```

- [YouTube Advanced encoding settings](http://support.google.com/youtube/answer/1722171)

```
ffmpeg -i "1.mkv" -vcodec h264 -acodec libvo_aacenc "1.mp4"
ffmpeg -i "1.mkv" -vcodec copy -acodec libvo_aacenc "1.mp4"
```


# Download YouTube and create an animated GIF from sub-part

```batch
youtube-dl.exe https://www.youtube.com/watch?v=bY73vFGhSVk

REM Trim time and crop sub-part and save as mp4
ffmpeg -i "Zootopia Official US Sloth Trailer-bY73vFGhSVk.mp4" -ss 00:01:49 -t 00:00:11.3 -vf "crop=480:320:600:100" -c:v libx264 -c:a aac -strict experimental -b:a 128k "laughing sloth.mp4"

REM generate color palette
ffmpeg -i "laughing sloth.mp4" -y -vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png

REM Render GIF using palette
ffmpeg -i "laughing sloth.mp4" -i palette.png -filter_complex "fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif
```


# Capture web cam on my Lenovo

```batch
ffmpeg -list_devices true -f dshow -i dummy

ffmpeg -f dshow -i video="Integrated Camera":audio="Microphone Array (Realtek High Definition Audio)" out.mp4
```

# Concatenate videos

## Convert individually to TS

```bash
ffmpeg -i "m0-01 - A.mp4" -c copy -bsf:v h264_mp4toannexb -f mpegts "m0-01 - A.ts"
ffmpeg -i "m1-01 - B.mp4" -c copy -bsf:v h264_mp4toannexb -f mpegts "m1-01 - B.ts"
```

## `ts.txt`

```powershell

("file '" + (((dir "*.ts" | select -ExpandProperty Name) -replace "'", "\'") -join "'`nfile '") + "'") | Out-File -Encoding ascii -FilePath ts.txt

```

```text
file 'm0-01 - A.ts'
file 'm1-01 - B.ts'
```

## Concatenate

```bash
ffmpeg -f concat -i ts.txt -c copy -bsf:a aac_adtstoasc output.mp4
```

```powershell

dir *.mp4 | foreach { ffmpeg -i $_.Name -c copy -bsf:v h264_mp4toannexb -f mpegts $_.Name.Replace("MP4", "ts").Replace("mp4", "ts") }

("file '" + (((dir "*.ts" | select -ExpandProperty Name) -replace "'", "\'") -join "'`nfile '") + "'") | Out-File -Encoding ascii -FilePath ts.txt

ffmpeg -f concat -safe 0 -i ts.txt -c copy -bsf:a aac_adtstoasc output.mp4

```

# Download HDS Videos on Windows

The following snippet uses a PHP Script (executed at the command line) to download an HDS manifest and assembles the video fragments:

- Download [PHP for Windows](http://windows.php.net/downloads/releases/php-7.1.2-nts-Win32-VC14-x86.zip) and unpack to `C:\php`
- Edit `C:\php\php.ini` and uncomment the `extension=php_curl.dll` line
- ´git clone https://github.com/K-S-V/Scripts`
- `php.exe AdobeHDS.php --manifest "http://adaptiv.wdr.de/...mp4.csmil/manifest.f4m?g=...&hdcore=3.10.0&plugin=aasp-3.10.0.29.28" --delete`
- Use `ffmpeg` to convert FLV to MP4 (`ffmpeg -i 1.flv  -vcodec copy -acodec copy -map_metadata 0 1.mp4`)

