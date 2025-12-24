import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Function() onPressed;

  CustomIconButton({required this.icon,required this.label,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: label,
          icon: icon,
          onPressed: onPressed,
          padding: EdgeInsets.only(bottom: 10),
        ),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 10, height: -1.0)),
      ],
    );
  }
}