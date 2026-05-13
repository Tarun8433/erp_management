import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CustomButtonType { primary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final String? assetIcon;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
    this.assetIcon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    switch (type) {
      case CustomButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? colorScheme.primary,
            foregroundColor: textColor ?? colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: _buildContent(textColor ?? colorScheme.onPrimary, textStyle),
        );
      case CustomButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _buildContent(textColor ?? colorScheme.onSurface, textStyle),
        );
      case CustomButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color ?? colorScheme.primary,
          ),
          child: _buildContent(textColor ?? colorScheme.primary, textStyle),
        );
    }
  }

  Widget _buildContent(Color contentColor, TextStyle? baseStyle) {
    final style = baseStyle?.copyWith(color: contentColor);
    
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (assetIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAssetIcon(contentColor),
          const SizedBox(width: 12),
          Text(
            text,
            style: style,
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: contentColor, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: style,
          ),
        ],
      );
    }

    return Text(
      text,
      style: style,
    );
  }

  Widget _buildAssetIcon(Color contentColor) {
    if (assetIcon!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetIcon!,
        width: 24,
        height: 24,
        //colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        assetIcon!,
        width: 24,
        height: 24,
        color: contentColor, // Applies tint if needed, can be removed if original color is desired
      );
    }
  }
}
