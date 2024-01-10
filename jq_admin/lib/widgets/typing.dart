import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 25,
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: CircleAvatar(
            backgroundColor: Color(
                0xff969d7b), 
            child: Image.asset('web/assets/logo2.png'), 
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(
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
