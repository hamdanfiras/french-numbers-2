import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/number_audio_player.dart';
import 'number_source.dart';

enum _PracticePhase { answering, incorrect }

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    required this.minimum,
    required this.maximum,
    required this.audioPlayer,
    this.numberSource,
    super.key,
  });

  final int minimum;
  final int maximum;
  final NumberAudioPlayer audioPlayer;
  final NumberSource? numberSource;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final NumberSource _numberSource;
  late final TextEditingController _answerController;
  late final FocusNode _answerFocus;
  late int _currentNumber;

  _PracticePhase _phase = _PracticePhase.answering;
  bool _isPlaying = false;
  int _playRequest = 0;

  @override
  void initState() {
    super.initState();
    _numberSource = widget.numberSource ?? RandomNumberSource();
    _answerController = TextEditingController()..addListener(_refresh);
    _answerFocus = FocusNode();
    _currentNumber = _nextNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAndFocus());
  }

  @override
  void dispose() {
    _playRequest++;
    unawaited(widget.audioPlayer.stop());
    _answerController
      ..removeListener(_refresh)
      ..dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  int _nextNumber({int? previous}) {
    return _numberSource.next(
      minimum: widget.minimum,
      maximum: widget.maximum,
      previous: previous,
    );
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _playAndFocus() async {
    final request = ++_playRequest;
    if (_phase == _PracticePhase.answering) _answerFocus.requestFocus();
    setState(() => _isPlaying = true);
    Object? playbackError;
    try {
      await widget.audioPlayer.play(_currentNumber);
    } on Object catch (error) {
      playbackError = error;
    }
    if (!mounted || request != _playRequest) return;
    setState(() => _isPlaying = false);
    if (playbackError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lire le nombre. Réessayez.'),
        ),
      );
      return;
    }
  }

  void _submit() {
    if (_answerController.text.isEmpty || _isPlaying) return;
    final answer = int.parse(_answerController.text);
    if (answer == _currentNumber) {
      _beginNextQuestion();
      return;
    }

    _answerFocus.unfocus();
    setState(() => _phase = _PracticePhase.incorrect);
  }

  void _beginNextQuestion() {
    final previous = _currentNumber;
    _answerController.clear();
    setState(() {
      _phase = _PracticePhase.answering;
      _currentNumber = _nextNumber(previous: previous);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAndFocus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercice'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Retour',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _phase == _PracticePhase.answering
                    ? _AnsweringView(
                        key: const ValueKey('answering'),
                        controller: _answerController,
                        focusNode: _answerFocus,
                        isPlaying: _isPlaying,
                        onReplay: _isPlaying ? null : _playAndFocus,
                        onSubmit: _answerController.text.isEmpty || _isPlaying
                            ? null
                            : _submit,
                      )
                    : _IncorrectView(
                        key: const ValueKey('incorrect'),
                        correctNumber: _currentNumber,
                        onNext: _beginNextQuestion,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnsweringView extends StatelessWidget {
  const _AnsweringView({
    required super.key,
    required this.controller,
    required this.focusNode,
    required this.isPlaying,
    required this.onReplay,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isPlaying;
  final VoidCallback? onReplay;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Écoutez le nombre',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Vous pouvez le réécouter autant que nécessaire.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        Center(
          child: Semantics(
            button: true,
            label: isPlaying
                ? 'Lecture en cours'
                : 'Réécouter le nombre',
            child: FilledButton.tonalIcon(
              key: const Key('replayButton'),
              onPressed: onReplay,
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Réécouter'),
              style: FilledButton.styleFrom(minimumSize: const Size(176, 54)),
            ),
          ),
        ),
        const SizedBox(height: 48),
        TextField(
          key: const Key('answerField'),
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onSubmitted: (_) => onSubmit?.call(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'Votre réponse',
            hintText: '—',
            floatingLabelAlignment: FloatingLabelAlignment.center,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('submitButton'),
          onPressed: onSubmit,
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

class _IncorrectView extends StatelessWidget {
  const _IncorrectView({
    required super.key,
    required this.correctNumber,
    required this.onNext,
  });

  final int correctNumber;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      label: 'Réponse incorrecte. La bonne réponse était $correctNumber.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.close_rounded,
            size: 58,
            color: colors.error,
            semanticLabel: 'Réponse incorrecte',
          ),
          const SizedBox(height: 24),
          Text(
            'La bonne réponse était',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '$correctNumber',
            key: const Key('correctAnswer'),
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            key: const Key('nextButton'),
            onPressed: onNext,
            child: const Text('Suivant'),
          ),
        ],
      ),
    );
  }
}
