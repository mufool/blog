---
title: iOS上hls无法播放问题
date: 2016-08-01 18:09:53
tags: [HLS]
---

前段时间在一个直播项目中遇到一个直播流在pc，android均可以正常播放，但是在ios上无法播放的问题；检查过后发现并不是数据生成的异常导致的，最后怀疑可能是数据流本身的编解码参数有错误。通过ffmeg拉流解析发现，video的profile为h264 high 4:2:2，而ios设备目前并不支持profile高于high级别高于4.1的视频的解码。

<!-- more -->

> File format for the file segmenter can be a QuickTime movie, MPEG-4 video, or MP3 audio, using the specified encoding.
>
> Stream format for the stream segmenter must be MPEG elementary audio and video streams, wrapped in an MPEG-2 transport stream, and using the following encoding. The Audio Technologies and Video Technologies list supported compression formats.
> - Encode video using H.264 compression
>  * H.264 Baseline 3.0: All devices
>  * H.264 Baseline 3.1: iPhone 3G and later, and iPod touch 2nd generation and later.
>  * H.264 Main profile 3.1: iPad (all versions), Apple TV 2 and later, and iPhone 4 and later.
>  * H.264 Main Profile 4.0: Apple TV 3 and later, iPad 2 and later, and iPhone 4S and later
>  * H.264 High Profile 4.0: Apple TV 3 and later, iPad 2 and later, and iPhone 4S and later.
>  * H.264 High Profile 4.1: iPad 2 and later and iPhone 4S and later.
>
> - A frame rate of 10 fps is recommended for video streams under 200 kbps. For video streams under 300 kbps, a frame rate of 12 to 15 fps is recommended. For all other streams, a frame rate of 29.97 is recommended.
>
> - Encode audio as either of the following:
>  * HE-AAC or AAC-LC, stereo
>  * MP3 (MPEG-1 Audio Layer 3), stereo

以上是iOS设备上支持的音视频编解码格式，以及相关参数的推荐设置。

参考：
[HTTP Live Streaming Overview](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/UsingHTTPLiveStreaming/UsingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH102-SW21)
[h264 profile & level](http://blog.csdn.net/sphone89/article/details/17492433)

