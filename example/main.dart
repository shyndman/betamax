import 'package:http/http.dart';
import 'package:http_recorder/http_recorder.dart';

void main() async {
  final client = RecordingIOClient();
  final recording = client.recordingInterceptor.start('snazzy');

  await client.get(Uri.parse('https://www.google.com'));
  await client.get(Uri.parse('https://www.nhost.io'));
  await client.get(Uri.parse('https://arstechnica.com'));
  await client.post(Uri.parse('https://arstechnica.com'), body: {
    'name': 'Henry',
    'species': 'Dog',
  });

  final streamedRequest =
      StreamedRequest('post', Uri.parse('https://www.google.com'));
  final responseFuture = client.send(streamedRequest);
  streamedRequest.sink
    ..add('name=Henry&species=dog'.codeUnits)
    ..close();
  await responseFuture;

  recording.stop();
  await recording.waitForOutstandingResponses();

  print(recording.interactions.join('\n'));
}
