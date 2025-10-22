import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Util'),
        actions: [
          DropdownButton(
            items: [
              DropdownMenuItem(child: Text("Map")),
              DropdownMenuItem(child: Text("Ml Kit")),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
