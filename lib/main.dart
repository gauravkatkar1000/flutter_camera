import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      await pauseRecording();
      print("--------------- Recording Paused ---------------");

      Future.delayed(const Duration(seconds: 61), () {
        print("After 61 secs ---------------------------");
        print(_cameraController);
      });
    } else if (state == AppLifecycleState.resumed) {
      await resumeRecording();
      print("--------------- Recording Resumed ---------------");
    }
  }

  pauseRecording() async {
    await _cameraController!.pausePreview();
    await _cameraController!.pauseVideoRecording();
  }

  resumeRecording() async {
    try {
      await _cameraController!.resumePreview();
      await _cameraController!.resumeVideoRecording();
    } catch (e) {
      log("Error in resuming video ", error: e);
    }
  }

  initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cameraController != null &&
                _cameraController!.value.isInitialized) ...{
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 400,
                      width: 300,
                      color: Colors.black,
                      child: CameraPreview(_cameraController!),
                    ),
                    Visibility(
                        visible: _cameraController!.value.isRecordingVideo,
                        child: const Icon(
                          Icons.circle,
                          color: Colors.red,
                        ))
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: !_cameraController!.value.isRecordingVideo
                    ? () async {
                        try {
                          await _cameraController!.startVideoRecording();
                          setState(() {});
                        } catch (e) {
                          log("Error in startVideoRecording", error: e);
                        }
                      }
                    : null,
                child: const Text("Start Recording"),
              ),
              ElevatedButton(
                onPressed: _cameraController!.value.isRecordingVideo
                    ? () async {
                        try {
                          await _cameraController!.stopVideoRecording();
                          setState(() {});
                        } catch (e) {
                          log("Error in stopVideoRecording", error: e);
                        }
                      }
                    : null,
                child: const Text("Stop Recording"),
              ),
            } else ...{
              Container(
                height: 400,
                width: 300,
                color: Colors.black,
              ),
            }
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
