import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class IOSARBloc {
  ARKitController arKitController;
  ARKitPlaneAnchor anchor;
  ARKitNode cup;

  final vector.Vector3 initialScale = vector.Vector3(2.5, 5, 2.5);
  BehaviorSubject<vector.Vector3> scaleBS;

  final double initialVolume = 98.17; // in ml
  BehaviorSubject<double> volumeBS;

  IOSARBloc() {
    scaleBS = BehaviorSubject<vector.Vector3>.seeded(this.initialScale);
    volumeBS = BehaviorSubject<double>.seeded(this.initialVolume);
  }

  Stream<vector.Vector3> get scaleStream => scaleBS.stream;
  Stream<double> get volumeStream => volumeBS.stream;

  void onARKitViewCreated({ARKitController controller}) {
    this.arKitController = controller;
    this.arKitController.onARTap = _onARTap;
    this.arKitController.onNodePinch = _onNodePinch;
  }

  void resetCup() {
    if (cup == null) return;
    cup.scale.value = this.initialScale;
    volumeBS.add(initialVolume);
  }

  void _onARTap(List<ARKitTestResult> ar) {
    final featurePoint = ar.firstWhere(
        (result) => result.type == ARKitHitTestResultType.featurePoint);
    if (featurePoint != null) _moveCup(featurePoint);
  }

  void _moveCup(ARKitTestResult featurePoint) {
    if (cup == null) _createCup();
    cup.position.value = vector.Vector3(
      featurePoint.worldTransform.getColumn(3).x,
      featurePoint.worldTransform.getColumn(3).y,
      featurePoint.worldTransform.getColumn(3).z,
    );
  }

  void _createCup() {
    ARKitMaterial material = ARKitMaterial(
      diffuse: ARKitMaterialProperty(color: Colors.lightBlue),
      transparency: 0.7,
    );
    ARKitCylinder cylinder = ARKitCylinder(
      height: 0.01, // set to 1 cm
      radius: 0.01, // set to 1 cm
      materials: [material],
    );
    cup = ARKitNode(
      geometry: cylinder,
      position: vector.Vector3(0, 0, 0),
      scale: scaleBS.value,
    );
    updateVolume(volume: volumeBS.value);
    arKitController.add(cup);
  }

  void _onNodePinch(List<ARKitNodePinchResult> pinch) {
    if (cup == null) return;
    final pinchNode = pinch.firstWhere(
      (result) => result.nodeName == cup.name,
      orElse: () => null,
    );
    if (pinch == null) return;
    // Scale only the x and z values. We only want to scale the width
    final pinchScale = vector.Vector3(
      cup.scale.value.x * pinchNode.scale,
      cup.scale.value.y,
      cup.scale.value.z * pinchNode.scale,
    );
    cup.scale.value = pinchScale;
    scaleBS.add(pinchScale);

    // now that the radius is changed, update height
    updateHeight();
  }

  void updateVolume({@required double volume}) {
    volumeBS.add(volume);
    updateHeight();
  }

  void updateHeight() {
    if (cup == null) return;
    double height = calculateHeightFromVolume(volume: volumeBS.value);

    // raise/lower cup to accommodate new height
    // Position is in meters, scale is in centimeters
    final newPosition = vector.Vector3(
      cup.position.value.x,
      cup.position.value.y + (height - cup.scale.value.y) / 200,
      cup.position.value.z,
    );
    cup.position.value = newPosition;

    // update the actual scale with new height
    final newScale = vector.Vector3(
      cup.scale.value.x,
      height,
      cup.scale.value.z,
    );
    cup.scale.value = newScale;
    scaleBS.add(newScale);
  }

  double calculateHeightFromVolume({@required double volume}) {
    double radius = cup.scale.value.x; // in cm
    return volume / (pi * pow(radius, 2));
  }

  void dispose() {
    scaleBS.close();
    volumeBS.close();
    arKitController?.dispose();
  }
}
