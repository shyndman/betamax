import 'dart:async';

import 'package:http/http.dart';

/// A [ByteStream] that can be listened to repeatedly.
///
/// It does not create broadcast streams. It listens to its inner stream, and
/// re-streams its contents (in their entirety) to the single-use streams that
/// are returned to every caller of [listen].
///
/// NOTE: There are significant memory implications to using a stream that
/// stores everything that it reads. Use with caution.
class RepeatableByteStream extends ByteStream {
  RepeatableByteStream(Stream<List<int>> stream) : super(stream);

  StreamSubscription<List<int>>? _innerSubscription;
  var _innerStreamDone = false;
  final List<int> _innerStreamBytes = [];
  final List<StreamController<List<int>>> _listenerControllers = [];

  /// Listens to the byte stream.
  ///
  /// From the point of view of the caller, this is like listening to any other
  /// bytestream. Only difference is you can listen as many times as you want.
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // If we've already read the inner stream in its entirety, all we have to do
    // is return a new stream with its contents.
    if (_innerStreamDone) {
      return Stream<List<int>>.value(_innerStreamBytes).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    }

    // Set up a subscription on the inner stream, and rebroadcast all events
    // to the listeners.
    _innerSubscription ??= super.listen(
      (List<int> bytes) {
        _innerStreamBytes.addAll(bytes);
        _listenerControllers.addEvent(bytes);
      },
      onError: (Object e, [StackTrace? st]) {
        _listenerControllers.addError(e, st);
      },
      onDone: () {
        _innerStreamDone = true;
        _listenerControllers.closeAll();
        _listenerControllers.clear();
      },
      cancelOnError: false,
    );

    // Construct a new controller for the listener, pre-populate it with the
    // bytes we've already collected from the inner stream, and hand it on back.
    final controller = StreamController<List<int>>()
      // It's important that we copy the list, or else it will stick around in
      // the controller until someone subscribes, which may be AFTER the list
      // has been written to. This would result in partial or complete
      // duplication of the bytes in the output.
      ..add(_innerStreamBytes.toList());
    _listenerControllers.add(controller);
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension<T> on List<StreamController<T>> {
  void addEvent(T event) {
    for (final c in this) {
      c.add(event);
    }
  }

  void addError(Object e, [StackTrace? st]) {
    for (final c in this) {
      c.addError(e, st);
    }
  }

  void closeAll() {
    for (final c in this) {
      c.close();
    }
  }
}
