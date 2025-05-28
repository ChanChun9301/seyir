// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CircularContainer extends StatelessWidget {
  final Widget child;

  const CircularContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      padding: EdgeInsets.symmetric(horizontal: height(context) / 42.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CircularContainerMain extends StatelessWidget {
  const CircularContainerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width(context),
        height: height(context),
        padding: EdgeInsets.symmetric(horizontal: height(context) / 42.2),
        child: Center(
            child: CupertinoActivityIndicator(
          radius: 30,
          color: Theme.of(context).colorScheme.primary,
        )));
  }
}
