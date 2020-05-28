import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

// bloc
import 'package:armeasuringcup/bloc/ios_ar_bloc.dart';

// widgets
import 'package:armeasuringcup/widgets/keyboard_overlay.dart';

class VolumePanel extends StatefulWidget {
  @override
  _VolumePanelState createState() => _VolumePanelState();
}

class _VolumePanelState extends State<VolumePanel> {
  TextEditingController volumeTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    IOSARBloc _iosARBloc = Provider.of<IOSARBloc>(context);
    FocusNode volumeFocusNode = FocusNode();

    print("build IOS Bottom Sheet");
    return Container(
      height: 175,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: StreamBuilder<double>(
          stream: _iosARBloc.volumeStream,
          initialData: _iosARBloc.volumeBS.value,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            double volume = snapshot.data;
            volumeTextController.text = volume.toString();
            double maxRange = volume > 1000 ? volume : 1000;

            print('max range: $maxRange');
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        focusNode: volumeFocusNode,
                        controller: volumeTextController,
                        onTap: () {
                          KeyboardVisibilityNotification().addNewListener(
                            onShow: () {
                              KeyboardOverlay.showOverlay(context);
                            },
                            onHide: () {
                              KeyboardOverlay.removeOverlay();
                              double volume =
                                  double.tryParse(volumeTextController.text);
                              if (volume != null)
                                _iosARBloc.updateVolume(volume: volume);
                            },
                          );
                        },
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text('ml'),
                  ],
                ),
                Slider(
                  min: 0.0,
                  max: maxRange,
                  value: volume,
                  divisions: 100,
                  onChanged: (value) {
                    _iosARBloc.updateVolume(
                        volume: ((value * 10).roundToDouble() / 10));
                  },
                ),
              ],
            );
          }),
    );
  }
}
