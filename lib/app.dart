import 'dart:async';

import 'package:flutter/material.dart';

import 'audio/number_audio_player.dart';
import 'core/app_theme.dart';
import 'practice/number_source.dart';
import 'range/range_screen.dart';

class NombresApp extends StatefulWidget {
  const NombresApp({super.key, this.audioPlayer, this.numberSource});

  final NumberAudioPlayer? audioPlayer;
  final NumberSource? numberSource;

  @override
  State<NombresApp> createState() => _NombresAppState();
}

class _NombresAppState extends State<NombresApp> {
  late final NumberAudioPlayer _audioPlayer;
  late final bool _ownsAudioPlayer;

  @override
  void initState() {
    super.initState();
    _ownsAudioPlayer = widget.audioPlayer == null;
    _audioPlayer = widget.audioPlayer ?? AssetNumberAudioPlayer();
  }

  @override
  void dispose() {
    if (_ownsAudioPlayer) unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nombres à l’Oreille',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: RangeScreen(
        audioPlayer: _audioPlayer,
        numberSource: widget.numberSource,
      ),
    );
  }
}
