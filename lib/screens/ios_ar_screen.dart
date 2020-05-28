import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:provider/provider.dart';

// bloc
import 'package:armeasuringcup/bloc/ios_ar_bloc.dart';

// widgets
import 'package:armeasuringcup/widgets/volume_panel.dart';

class IOSARScreen extends StatefulWidget {
  @override
  _IOSARScreenState createState() => _IOSARScreenState();
}

class _IOSARScreenState extends State<IOSARScreen> {
  ARKitSceneView _sceneView;
  IOSARBloc _arBloc;
  VolumePanel _volumePanel;

  @override
  void initState() {
    super.initState();
    _sceneView = ARKitSceneView(
      onARKitViewCreated: _onARKitViewCreated,
      enableTapRecognizer: true,
      enablePinchRecognizer: true,
    );
    _volumePanel = VolumePanel();
  }

  void _onARKitViewCreated(ARKitController controller) {
    print("ARKit view created");
    _arBloc.onARKitViewCreated(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    _arBloc = Provider.of<IOSARBloc>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          _sceneView,
        ],
      ),
      bottomSheet: _volumePanel,
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 75),
        child: FloatingActionButton.extended(
          onPressed: _arBloc.resetCup,
          label: Row(
            children: <Widget>[
              Icon(Icons.autorenew),
              SizedBox(width: 10),
              Text('Reset')
            ],
          ),
        ),
      ),
    );
  }
}
