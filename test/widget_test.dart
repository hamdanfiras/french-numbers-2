import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nombres_a_l_oreille/app.dart';
import 'package:nombres_a_l_oreille/audio/number_audio_player.dart';
import 'package:nombres_a_l_oreille/practice/number_source.dart';

class FakeAudioPlayer implements NumberAudioPlayer {
  final played = <int>[];

  @override
  Future<void> play(int number) async => played.add(number);

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class SequenceNumberSource implements NumberSource {
  SequenceNumberSource(this.values);

  final List<int> values;
  int _index = 0;

  @override
  int next({required int minimum, required int maximum, int? previous}) {
    return values[_index++];
  }
}

void main() {
  testWidgets('shows the default range and validates bounds', (tester) async {
    await tester.pumpWidget(NombresApp(audioPlayer: FakeAudioPlayer()));

    final minimumFinder = find.descendant(
      of: find.byKey(const Key('minimumField')),
      matching: find.byType(TextField),
    );
    final maximumFinder = find.descendant(
      of: find.byKey(const Key('maximumField')),
      matching: find.byType(TextField),
    );
    final minimum = tester.widget<TextField>(minimumFinder);
    final maximum = tester.widget<TextField>(maximumFinder);
    expect(minimum.controller!.text, '60');
    expect(maximum.controller!.text, '99');

    await tester.enterText(find.byKey(const Key('minimumField')), '100');
    await tester.enterText(find.byKey(const Key('maximumField')), '99');
    await tester.pump();

    expect(
      find.text('La première limite doit être inférieure à la seconde.'),
      findsOneWidget,
    );
    final start = tester.widget<FilledButton>(
      find.byKey(const Key('startButton')),
    );
    expect(start.onPressed, isNull);
  });

  testWidgets('correct answers continue and incorrect answers wait', (
    tester,
  ) async {
    final audio = FakeAudioPlayer();
    final numbers = SequenceNumberSource([72, 80, 65]);
    await tester.pumpWidget(
      NombresApp(audioPlayer: audio, numberSource: numbers),
    );

    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pumpAndSettle();
    expect(audio.played, [72]);

    await tester.enterText(find.byKey(const Key('answerField')), '072');
    await tester.pump();
    tester
        .widget<FilledButton>(find.byKey(const Key('submitButton')))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(audio.played, [72, 80]);
    expect(find.byKey(const Key('answerField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('answerField')), '81');
    await tester.pump();
    tester
        .widget<FilledButton>(find.byKey(const Key('submitButton')))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('La bonne réponse était'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(audio.played, [72, 80]);

    await tester.tap(find.byKey(const Key('nextButton')));
    await tester.pumpAndSettle();
    expect(audio.played, [72, 80, 65]);
  });

  testWidgets('returning from practice restores the default range', (
    tester,
  ) async {
    await tester.pumpWidget(
      NombresApp(
        audioPlayer: FakeAudioPlayer(),
        numberSource: SequenceNumberSource([12]),
      ),
    );

    await tester.enterText(find.byKey(const Key('minimumField')), '10');
    await tester.enterText(find.byKey(const Key('maximumField')), '20');
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    final minimum = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('minimumField')),
        matching: find.byType(TextField),
      ),
    );
    final maximum = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('maximumField')),
        matching: find.byType(TextField),
      ),
    );
    expect(minimum.controller!.text, '60');
    expect(maximum.controller!.text, '99');
  });
}
