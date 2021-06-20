import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8), BlendMode.dstATop),
          image: AssetImage(TimeOfDay.now().hour > 18
              ? 'images/night.PNG'
              : 'images/day.PNG'),
        ),
      ),
    );
  }
}
