// full_screen_media_viewer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final String url;
  final bool isVideo;

  const FullScreenMediaViewer({
    super.key,
    required this.url,
    required this.isVideo,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initVideo();
  }

  void _initVideo() async {
    if (widget.url.startsWith('http')) {
      // ignore: deprecated_member_use
      videoController = VideoPlayerController.network(widget.url);
    } else if (widget.url.startsWith('assets')) {
      videoController = VideoPlayerController.asset(widget.url);
    } else {
      videoController = VideoPlayerController.file(File(widget.url));
    }

    await videoController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: true,
      looping: false,
      showControls: true,
      allowFullScreen: true,
    );

    setState(() => isReady = true);
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: widget.isVideo ? _videoView() : _imageView()),
    );
  }

  Widget _videoView() {
    if (!isReady) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return Chewie(controller: chewieController!);
  }

  Widget _imageView() {
    return InteractiveViewer(
      clipBehavior: Clip.none,
      child: _loadImage(widget.url),
    );
  }

  Widget _loadImage(String url) {
    if (url.startsWith("http")) {
      return Image.network(url, fit: BoxFit.contain);
    } else if (url.contains("/storage") || url.contains("C:\\")) {
      return Image.file(File(url), fit: BoxFit.contain);
    } else {
      return Image.asset(url, fit: BoxFit.contain);
    }
  }
}
