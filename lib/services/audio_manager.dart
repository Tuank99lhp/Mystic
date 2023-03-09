import 'package:just_audio/just_audio.dart';

final _loudnessEnhancer = AndroidLoudnessEnhancer();

AudioPlayer audioPlayer = AudioPlayer(
  audioPipeline: AudioPipeline(
    androidAudioEffects: [
      _loudnessEnhancer,
    ],
  ),
);
