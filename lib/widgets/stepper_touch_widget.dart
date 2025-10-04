import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stepper_touch/stepper_touch.dart';

class CustomStepCounter extends StatelessWidget {
  const CustomStepCounter({super.key});

  @override
  Widget build(BuildContext context) {

    return StepperTouch(
      initialValue: 0,
      
      buttonsColor: Colors.white,
      counterColor: Color(0xff6D72FE),
      dragButtonColor: Colors.white,
      direction: Axis.horizontal, 
      withSpring: false,
      onChanged: (int value) => log('new value $value'),
    );
  }
}
