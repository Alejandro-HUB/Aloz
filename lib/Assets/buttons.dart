import 'package:flutter/material.dart';
import '../Helpers/Constants/Styling.dart';
import '../Helpers/Constants/responsive_layout.dart';

class GradientButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Icon icon;
  final String label;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.gradient,
    this.borderRadius,
    this.width,
    this.height = 44.0,
    this.icon = const Icon(Icons.lock),
  });

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
        label: Text(label, style: TextStyle(color: Styling.primaryColor)),
        icon: icon,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ResponsiveLayout.isPhone(context)
              ? Styling.primaryColor.withOpacity(0.05)
              : Colors.transparent,
          shadowColor: ResponsiveLayout.isPhone(context)
              ? Styling.primaryColor.withOpacity(0.05)
              : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
    );
  }
}
