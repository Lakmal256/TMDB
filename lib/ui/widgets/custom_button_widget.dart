import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.padding,
      required this.height,
      required this.text,
      required this.icon,
      this.isBig = false});

  final VoidCallback onPressed;
  final double padding;
  final double height;
  final String text;
  final Icon? icon;
  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          minimumSize: MaterialStateProperty.all(Size.fromHeight(height)),
          backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 4)],
              Text(
                text,
                style: isBig
                    ? Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.normal,
                        )
                    : Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.normal,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
