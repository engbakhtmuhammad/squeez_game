import 'package:flutter/material.dart';
import 'package:squeez_game/theme/app_theme.dart';

/// Reusable Custom Button Widget
/// 
/// A highly customizable button widget that can be used throughout the app
/// with support for custom colors, borders, text, opacity, and sizing.
class CustomButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Text color
  final Color textColor;

  /// Border color
  final Color borderColor;

  /// Border width
  final double borderWidth;

  /// Opacity of the button (0.0 to 1.0)
  final double opacity;

  /// Font size for button text
  final double fontSize;

  /// Font weight for button text
  final FontWeight fontWeight;

  /// Padding inside the button
  final EdgeInsetsGeometry padding;

  /// Border radius
  final double borderRadius;

  /// Button width (optional)
  final double? width;

  /// Button height (optional)
  final double? height;

  /// Whether button is enabled
  final bool enabled;

  /// Shadow elevation
  final double elevation;

  /// Icon to show before text (optional)
  final IconData? iconData;

  /// Icon color
  final Color? iconColor;

  /// Icon size
  final double iconSize;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF1F5D82),
    this.textColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.opacity = 1.0,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
    this.borderRadius = 30.0,
    this.width,
    this.height,
    this.enabled = true,
    this.elevation = 4.0,
    this.iconData,
    this.iconColor,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final base = enabled ? widget.backgroundColor : Colors.grey.shade600;
    return Opacity(
      opacity: widget.opacity,
      child: AnimatedScale(
        scale: _isPressed && enabled ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTapDown:
                enabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel:
                enabled ? () => setState(() => _isPressed = false) : null,
            onTap: enabled ? widget.onPressed : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: AppGradients.button(base),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: widget.borderWidth,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.elevation > 0 && enabled
                    ? [
                        BoxShadow(
                          color: base.withValues(alpha: 0.45),
                          blurRadius: widget.elevation * 2,
                          offset: Offset(0, widget.elevation / 2),
                        ),
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.iconData != null) ...[
                    Icon(
                      widget.iconData,
                      color: widget.iconColor ?? widget.textColor,
                      size: widget.iconSize,
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: enabled ? widget.textColor : Colors.white70,
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
