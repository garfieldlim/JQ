import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          width: 25,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CircleAvatar(
            backgroundColor: const Color(
                0xff969d7b), 
            child: Image.asset('web/assets/logo2.png'), 
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
                0xff969d7b),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Lottie.asset(
            'web/assets/typing.json',
            width: 40, 
            fit: BoxFit.contain,
          ),
        ),
        
      ],
    );
  }
}
