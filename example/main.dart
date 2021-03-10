import 'package:http_recorder/http_recorder.dart';

void main() async {
  final client = RecordingIOClient();
  final recording = client.recordingInterceptor.start('snazzy');

  await client.get(Uri.parse('https://www.google.com'));
  await client.get(Uri.parse('https://www.nhost.io'));
  await client.get(Uri.parse('https://arstechnica.com'));

  recording.stop();
  print(recording.interactions);
}
