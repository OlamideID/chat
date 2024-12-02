import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/Animation - 1730069741511.json',
        height: 150, width: 150);
  }
}
