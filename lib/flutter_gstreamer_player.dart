import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class GstPlayer extends StatelessWidget {
  final String pipeline;

  GstPlayer({super.key, required this.pipeline});

  final _controller = GstPlayerTextureController();

  Future<void> initializeController() async {
    await _controller.initialize(
      pipeline,
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentPlatform = Theme.of(context).platform;
    initializeController();

    switch (currentPlatform) {
      case TargetPlatform.android:
        return Texture(textureId: _controller.textureId);
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}

class GstPlayerTextureController {
  static const MethodChannel _channel =
      MethodChannel('flutter_gstreamer_player');

  int textureId = 0;
  static int _id = 0;

  Future<int> initialize(String pipeline) async {
    GstPlayerTextureController._id = GstPlayerTextureController._id + 1;

    textureId = await _channel.invokeMethod('PlayerRegisterTexture', {
      'pipeline': pipeline,
      'playerId': GstPlayerTextureController._id,
    });

    return textureId;
  }

  Future<void> dispose() {
    return _channel.invokeMethod('dispose', {'textureId': textureId});
  }
}
