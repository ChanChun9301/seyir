import 'package:flutter/material.dart';
import '/utils/constants.dart';

class Itemcard extends StatelessWidget {
  const Itemcard({
    super.key,
    required this.context,
    required this.child,
  });

  final BuildContext context;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
