import 'package:flutter/material.dart';

class HeadLineLarge extends StatelessWidget {
  final String text;
  const HeadLineLarge({
    super.key,
    this.text = 'Login',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }
}
