import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detector_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,

      // enableTracking: true
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  bool leftIsOpen = false;
  bool rightIsOpen = false;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PositionedDirectional(
          end: 0,
          top: 0,
          start: 0,
          bottom: 0,
          child: DetectorView(
            title: 'Face Detector',
            customPaint: _customPaint,
            text: _text,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.sizeOf(context).height * 0.15,
          start: MediaQuery.sizeOf(context).width * 0.15,
          child: Icon(
            leftIsOpen ? Icons.check : Icons.close,
            color: leftIsOpen ? Colors.green : Colors.red,
            size: 35,
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.sizeOf(context).height * 0.15,
          end: MediaQuery.sizeOf(context).width * 0.15,
          child: Icon(
            rightIsOpen ? Icons.check : Icons.close,
            color: rightIsOpen ? Colors.green : Colors.red,
            size: 35,
          ),
        )
      ],
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    List<Face> faces = await _faceDetector.processImage(inputImage);
    // print("testtttt ${faces.length}");
    //todo only one face...
    for (var face in faces) {
      // text += 'face: ${face.boundingBox}\n\n';
      // Get landmarks of the left and right eyes
      if (face.leftEyeOpenProbability! >= 0.98635888937860727) {
        setState(() {
          leftIsOpen = true;
        });
      } else {
        setState(() {
          leftIsOpen = false;
        });
      }
      if (face.rightEyeOpenProbability! >= 0.99258323386311531) {
        setState(() {
          rightIsOpen = true;
        });
      } else {
        setState(() {
          rightIsOpen = false;
        });
      }
    }
    // if(faces.length==1){
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // String text = 'Faces found: ${faces.length}\n\n';
      for (var face in faces) {
        // text += 'face: ${face.boundingBox}\n\n';
        // Get landmarks of the left and right eyes
        print("face.leftEyeOpenProbability ${face.leftEyeOpenProbability}");
        print("face.rightEyeOpenProbability ${face.rightEyeOpenProbability}");
      }
      // _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      // _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
    // }else if (faces.length>1){

    //todo can't capture image ....
    //todo bool variable to show error flag

    // }
    // setState(() {
    //
    // });
    print("testtttt ${_text}");
    ///////////////////////////////
  }
}
