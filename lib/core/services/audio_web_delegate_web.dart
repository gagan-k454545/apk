import 'dart:js_interop';

@JS('window.TossSound.unlock')
external void _unlock();

@JS('window.TossSound.whoosh')
external void _whoosh(double at, double dur);

@JS('window.TossSound.clink')
external void _clink(double at, double gain);

@JS('window.TossSound.tick')
external void _tick(double at);

@JS('window.TossSound.pop')
external void _pop(double at);

class WebAudioDelegate {
  static void unlock() {
    try {
      _unlock();
    } catch (_) {}
  }

  static void whoosh([double at = 0, double dur = 0.35]) {
    try {
      _whoosh(at, dur);
    } catch (_) {}
  }

  static void clink([double at = 0, double gain = 1.0]) {
    try {
      _clink(at, gain);
    } catch (_) {}
  }

  static void tick([double at = 0]) {
    try {
      _tick(at);
    } catch (_) {}
  }

  static void pop([double at = 0]) {
    try {
      _pop(at);
    } catch (_) {}
  }
}
