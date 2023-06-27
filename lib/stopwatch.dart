import 'package:wakelock/wakelock.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class StopWatchWidget extends StatefulWidget {
  const StopWatchWidget({super.key});

  @override
  State<StopWatchWidget> createState() => _StopWatchWidgetState();
}

class _StopWatchWidgetState extends State<StopWatchWidget> {
  final _stopWatch = Stopwatch();
  bool _isRunning = false;
  bool _isReset = true;
  Timer? _timer;

  void startStopWatch() {
    Wakelock.enable().onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to enable wakelock."),
        ),
      );
    });
    setState(() {
      _isRunning = true;
      _isReset = false;
    });
    _stopWatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
      setState(() {});
    });
  }

  void stopStopWatch() {
    setState(() {
      _isRunning = false;
    });
    _stopWatch.stop();
    _timer?.cancel();
  }

  void resetStopWatch() {
    Wakelock.disable().onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to disable wakelock."),
        ),
      );
    });
    setState(() {
      _isReset = true;
    });
    _stopWatch.reset();
  }

  @override
  void dispose() {
    _stopWatch.stop();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _stopWatch.elapsed.inMinutes;
    final seconds = _stopWatch.elapsed.inSeconds % 60;
    final tenMilliseconds = (_stopWatch.elapsed.inMilliseconds ~/ 10) % 100;

    return InkWell(
      onTap: () {
        if (_isReset) {
          startStopWatch();
          return;
        }
        if (_isRunning) {
          stopStopWatch();
          return;
        }
        startStopWatch();
      },
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${tenMilliseconds.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: Builder(
                builder: (context) {
                  if (_isReset) {
                    return const Text(
                      'Tap to start',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  if (_isRunning) {
                    return const Text(
                      'Tap to stop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () {
                      resetStopWatch();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
