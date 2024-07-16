// lib/widgets/video_player/video_player.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:sriram_s_application3/Services/api_service.dart';

class RTSPVideoPlayer extends StatefulWidget {
  final String rtspUrl;

  RTSPVideoPlayer({required this.rtspUrl});

  @override
  _RTSPVideoPlayerState createState() => _RTSPVideoPlayerState();
}

class _RTSPVideoPlayerState extends State<RTSPVideoPlayer> {
  late VlcPlayerController _vlcPlayerController;
  Timer? _timer;
  ApiService apiService = ApiService();
  bool isError = false;
  String errorMessage = '';

  @override
  void dispose() {
    _timer?.cancel();
    _vlcPlayerController.dispose();
    super.dispose();
  }

  void _onFrameCaptured() async {
    try {
      if (_vlcPlayerController.value.isPlaying) {
        final snapshot = await _vlcPlayerController.takeSnapshot();
        if (snapshot != null) {
          String base64Snapshot = base64Encode(snapshot);
          await apiService.sendFaces(
            name: 'ImageName',
            embedding: base64Snapshot,
            image: base64Snapshot, // Ensure image is included
          );
        } else {
          print('Snapshot is null');
        }
      }
    } catch (e) {
      print('Error capturing frame: $e');
    }
  }

  void _startFrameCapture() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (_vlcPlayerController.value.isInitialized && _vlcPlayerController.value.isPlaying) {
        _onFrameCaptured();
      }
    });
  }

  void _initializePlayer() {
    _vlcPlayerController = VlcPlayerController.network(
      widget.rtspUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    _vlcPlayerController.addListener(() {
      if (_vlcPlayerController.value.hasError) {
        setState(() {
          isError = true;
          errorMessage = _vlcPlayerController.value.errorDescription ?? 'Unknown error';
        });
      } else if (_vlcPlayerController.value.isInitialized) {
        _startFrameCapture();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isError
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isError = false;
                  errorMessage = '';
                  _initializePlayer();
                });
              },
              child: Text('Retry'),
            ),
          ],
        )
            : VlcPlayer(
          controller: _vlcPlayerController,
          aspectRatio: 4 / 3,
          placeholder: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
