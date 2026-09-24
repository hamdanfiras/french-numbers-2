import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/number_audio_player.dart';
import '../practice/number_source.dart';
import '../practice/practice_screen.dart';

class RangeScreen extends StatefulWidget {
  const RangeScreen({required this.audioPlayer, this.numberSource, super.key});

  final NumberAudioPlayer audioPlayer;
  final NumberSource? numberSource;

  @override
  State<RangeScreen> createState() => _RangeScreenState();
}

class _RangeScreenState extends State<RangeScreen> {
  static const _defaultMinimum = 60;
  static const _defaultMaximum = 99;

  late final TextEditingController _minimumController;
  late final TextEditingController _maximumController;

  @override
  void initState() {
    super.initState();
    _minimumController = TextEditingController(text: '$_defaultMinimum')
      ..addListener(_refresh);
    _maximumController = TextEditingController(text: '$_defaultMaximum')
      ..addListener(_refresh);
  }

  @override
  void dispose() {
    _minimumController
      ..removeListener(_refresh)
      ..dispose();
    _maximumController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  int? get _minimum => int.tryParse(_minimumController.text);
  int? get _maximum => int.tryParse(_maximumController.text);

  bool get _isValid {
    final minimum = _minimum;
    final maximum = _maximum;
    return minimum != null &&
        maximum != null &&
        minimum >= 0 &&
        maximum <= 999 &&
        minimum <= maximum;
  }

  String? get _validationMessage {
    if (_minimumController.text.isEmpty || _maximumController.text.isEmpty) {
      return 'Saisissez les deux limites.';
    }
    if (_minimum == null || _maximum == null) {
      return 'Utilisez uniquement des nombres entiers.';
    }
    if (_minimum! < 0 || _maximum! > 999) {
      return 'Choisissez des nombres entre 0 et 999.';
    }
    if (_minimum! > _maximum!) {
      return 'La première limite doit être inférieure à la seconde.';
    }
    return null;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _startPractice() async {
    if (!_isValid) return;
    FocusScope.of(context).unfocus();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(
          minimum: _minimum!,
          maximum: _maximum!,
          audioPlayer: widget.audioPlayer,
          numberSource: widget.numberSource,
        ),
      ),
    );
    if (!mounted) return;
    _minimumController.text = '$_defaultMinimum';
    _maximumController.text = '$_defaultMaximum';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = _validationMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.hearing_rounded,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                    semanticLabel: 'Écoute',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nombres à l’Oreille',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choisissez une plage, puis écoutez et saisissez les nombres.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Plage d’entraînement',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _RangeField(
                          key: const Key('minimumField'),
                          label: 'De',
                          controller: _minimumController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RangeField(
                          key: const Key('maximumField'),
                          label: 'À',
                          controller: _maximumController,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    child: error == null
                        ? const SizedBox(height: 32)
                        : Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 12),
                            child: Text(
                              error,
                              key: const Key('rangeError'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                  ),
                  FilledButton(
                    key: const Key('startButton'),
                    onPressed: _isValid ? _startPractice : null,
                    child: const Text('Commencer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeField extends StatelessWidget {
  const _RangeField({
    required super.key,
    required this.label,
    required this.controller,
    required this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label),
    );
  }
}
