import 'package:flutter/material.dart';
import '../Helpers/Constants/Styling.dart';
import '../responsive_layout.dart';

class MyElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;
  final Icon icon;
  final String label;

  const MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.label,
    this.borderRadius,
    this.width,
    this.height = 44.0,
    this.gradient = const LinearGradient(colors: [Styling.redDark, Styling.orangeDark]),
    this.icon = const Icon(Icons.lock),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton.icon(
        label: Text(label, style: TextStyle(color: Colors.white)),
        icon: icon,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: ResponsiveLayout.isPhone(context) ? Colors.white.withOpacity(0.05) : Colors.transparent,
          shadowColor: ResponsiveLayout.isPhone(context) ? Colors.white.withOpacity(0.05) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
    );
  }
}