import 'package:flutter/material.dart';

/// Shared visual language for TicketFlow screens.
class AppUi {
  static const canvas = Color(0xFFF5F7FB);
  static const ink = Color(0xFF1F2937);
  static const title = Color(0xFF111827);
  static const border = Color(0xFFE5E7EB);
  static const primary = Color(0xFF6750A4);

  static BoxDecoration surface({double radius = 18}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.035),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static InputDecoration input({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: border),
    ),
  );
}

class TicketFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const TicketFlowAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 20,
    title: Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppUi.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.confirmation_number_outlined,
            color: AppUi.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppUi.ink,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    actions: actions,
  );
}

class PageIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageIntro({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppUi.title,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) =>
      Container(padding: padding, decoration: AppUi.surface(), child: child);
}
