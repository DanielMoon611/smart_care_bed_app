import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  final ValueNotifier<bool> isInitFocused = ValueNotifier(false);

  late VoidCallback _cprListener;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   selectedMode.value = "STD1";
    // });

    _cprListener = () {
      if (CprLock.I.isLocked.value) {
        if (mounted) setState(() {});
      } else {
        isPauseFocused.value = false;
        activeMode.value = true;
        mode = '';
        if (mounted) setState(() {});
      }
    };
    CprLock.I.isLocked.addListener(_cprListener);
  }

  @override
  void dispose() {
    isInitFocused.dispose();
    CprLock.I.isLocked.removeListener(_cprListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final sideInfoPadding = screenWidth * 0.02;
    final horizontalOffset = screenWidth * 0.035;
    final verticalOffset = screenHeight * 0.025;
    final verticalSpacing = screenHeight * 0.015;
    final sideInfoFontSize = screenWidth * 0.012;
    final sideInfoTitleFontSize = screenWidth * 0.025;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home_bed.png',
              fit: BoxFit.fill,
              gaplessPlayback: true,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: sideInfoPadding + horizontalOffset,
                    top: verticalSpacing + verticalOffset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "체압분산",
                        style: TextStyle(
                          fontSize: sideInfoTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Body Pressure Distribution Mode\n"
                        "A function that distributes body pressure using\n"
                        "the body pressure sensor built into the keyboard",
                        style: TextStyle(
                          fontSize: sideInfoFontSize,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: sideInfoPadding + horizontalOffset,
                    top: verticalSpacing + verticalOffset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "교대부양",
                        style: TextStyle(
                          fontSize: sideInfoTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Alternating Pressure Mode\n"
                        "A function that controls odd\n"
                        "and even keyboard in a set period of time",
                        style: TextStyle(
                          fontSize: sideInfoFontSize,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
