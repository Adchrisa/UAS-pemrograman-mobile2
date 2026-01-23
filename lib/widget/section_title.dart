import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
	final String title;
	final String? actionText;
	final VoidCallback? onAction;

	const SectionTitle({super.key, required this.title, this.actionText, this.onAction});

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Row(
						children: [
							Container(
								width: 8,
								height: 28,
								decoration: BoxDecoration(
									color: theme.colorScheme.primary,
									borderRadius: BorderRadius.circular(6),
								),
							),
							const SizedBox(width: 12),
							Text(
								title,
								style: theme.textTheme.titleLarge,
							),
						],
					),
					if (actionText != null)
						GestureDetector(
							onTap: onAction,
							child: Text(
								actionText!,
								style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
							),
						),
				],
			),
		);
	}
}

