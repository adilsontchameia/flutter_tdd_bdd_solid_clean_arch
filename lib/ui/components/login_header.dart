import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240.0,
      margin: const EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).primaryColorDark,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0.0, 0.0),
            spreadRadius: 0.0,
            blurRadius: 4.0,
            color: Colors.black,
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(80.0),
        ),
      ),
      child: const Image(
        image: AssetImage('assets/logo.png'),
      ),
    );
  }
}
