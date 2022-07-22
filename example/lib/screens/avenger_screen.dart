import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class AvengerScreen extends StatefulWidget {
  const AvengerScreen({Key key}) : super(key: key);

  @override
  _AvengerScreenState createState() => _AvengerScreenState();
}

class _AvengerScreenState extends State<AvengerScreen> {
  ArCoreController arCoreController;
  Map<int, ArCoreAugmentedImage> augmentedImagesMap = Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avenger'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        // enableTapRecognizer: true,
        type: ArCoreViewType.AUGMENTEDIMAGES,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // arCoreController.onPlaneTap = controlOnPlaneTap;
    arCoreController.onTrackingImage = controlOnTrackingImage;

    loadSingleImage();
  }

  void controlOnPlaneTap(List<ArCoreHitTestResult> hitResults) {
    final hit = hitResults.first;

    addCharactor(hit);
  }

  void controlOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;
      _addSphere(augmentedImage);
    }
  }

  Future addCharactor(ArCoreHitTestResult hit) async {
    final bytes =
        (await rootBundle.load('assets/ironman.png')).buffer.asUint8List();
    final node = ArCoreNode(
        image: ArCoreImage(bytes: bytes, width: 300, height: 300),
        position: hit.pose.translation + vector.Vector3(0, 0, 0),
        rotation: hit.pose.rotation + vector.Vector4(0.0, 0.0, 0.0, 0.0));
    arCoreController.addArCoreNode(node, parentNodeName: 'a');
  }

  Future loadSingleImage() async {
    final ByteData bytes =
        await rootBundle.load('assets/earth_augmented_image.jpg');
    arCoreController.loadSingleAugmentedImage(
        bytes: bytes.buffer.asUint8List());
  }

  Future _addSphere(ArCoreAugmentedImage arCoreAugmentedImage) async {
    final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');

    final material = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244),
        textureBytes: textureBytes.buffer.asUint8List());
    final sphere = ArCoreCube(
        materials: [material],
        size: vector.Vector3(
            arCoreAugmentedImage.extentX / 2,
            arCoreAugmentedImage.extentX / 2,
            arCoreAugmentedImage.extentX / 2));
    final node = ArCoreNode(
      shape: sphere,
    );
    arCoreController.addArCoreNodeToAugmentedImage(
        node, arCoreAugmentedImage.index,
        parentNodeName: "parent");
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
