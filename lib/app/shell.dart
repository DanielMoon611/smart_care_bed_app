import 'package:flutter/material.dart';
import '../ui/panel/panel.dart';

class ControlPanelShell extends StatelessWidget {
  final Widget child;
  const ControlPanelShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const ControlPanel(),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}