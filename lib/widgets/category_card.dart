import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      splashColor: theme.primaryColor.withOpacity(0.15),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: 14),
        width: 105,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBubble(icon: icon, isSelected: isSelected),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ICON BUBBLE =================
class _IconBubble extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _IconBubble({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? LinearGradient(
                colors: [primary, primary.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.grey.shade100,
      ),
      child: Icon(
        icon,
        size: 22,
        color: isSelected ? Colors.white : Colors.grey.shade600,
      ),
    );
  }
}
