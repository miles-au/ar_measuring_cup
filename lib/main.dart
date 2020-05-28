import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// bloc
import 'bloc/ios_ar_bloc.dart';
//import 'bloc/android_ar_bloc.dart';

// screens
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IOSARBloc>(create: (_) => IOSARBloc()),
//        Provider<AndroidARBloc>(create: (_) => AndroidARBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
        },
      ),
    );
  }
}
