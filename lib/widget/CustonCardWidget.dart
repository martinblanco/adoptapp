import 'package:adoptapp/widget/selectorWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomCard extends StatelessWidget {
  CustomCard({this.children});

  final children;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

selectorDouble(String text, String firstText, IconData firstIcon,
    String secondText, IconData secondtIcon) {
  return CustomCard(
    children: [
      Text(
        text,
      ),
      const SizedBox(
        height: 20,
      ),
      TransactionToggle(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                firstIcon,
                size: 30,
              ),
              Text(firstText),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                secondtIcon,
                size: 30,
              ),
              Text(secondText),
            ],
          ),
        ],
      )
    ],
  );
}

selectorTriple(
    String text,
    String firstText,
    IconData firstIcon,
    String secondText,
    IconData secondtIcon,
    String thirdText,
    IconData thirdIcon) {
  return CustomCard(
    children: [
      Text(
        text,
      ),
      const SizedBox(
        height: 20,
      ),
      TransactionToggle(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                firstIcon,
                size: 30,
              ),
              Text(firstText),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                secondtIcon,
                size: 30,
              ),
              Text(secondText),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                thirdIcon,
                size: 30,
              ),
              Text(thirdText),
            ],
          ),
        ],
      )
    ],
  );
}
