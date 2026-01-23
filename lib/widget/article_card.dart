import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';

class ArticleCard extends StatefulWidget {
	final String id;
	final String title;
	final String subtitle;
	final String? imageUrl;
	final VoidCallback? onTap;

	const ArticleCard({super.key, required this.id, required this.title, required this.subtitle, this.imageUrl, this.onTap});

	@override
	State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> with SingleTickerProviderStateMixin {
	late final AnimationController _animController;

	@override
	void initState() {
		super.initState();
		_animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), lowerBound: 0.8, upperBound: 1.15);
	}

	@override
	void dispose() {
		_animController.dispose();
		super.dispose();
	}

	Future<void> _toggleBookmark() async {
		await BookmarkService.toggle(widget.id);
		await _animController.forward();
		await _animController.reverse();
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return GestureDetector(
			onTap: widget.onTap,
			child: Card(
				child: Row(
					children: [
						Container(
							width: 110,
							height: 90,
							decoration: BoxDecoration(
								borderRadius: const BorderRadius.only(
									topLeft: Radius.circular(12),
									bottomLeft: Radius.circular(12),
								),
								color: theme.colorScheme.primary.withOpacity(0.1),
								image: widget.imageUrl != null ? DecorationImage(image: NetworkImage(widget.imageUrl!), fit: BoxFit.cover) : null,
							),
							child: widget.imageUrl == null
									? Icon(
											Icons.eco,
											size: 36,
											color: theme.colorScheme.primary,
										)
									: null,
						),
						Expanded(
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Hero(tag: 'article-title-${widget.id}', child: Material(color: Colors.transparent, child: Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)))),
										const SizedBox(height: 6),
										Text(widget.subtitle, style: theme.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
										const SizedBox(height: 8),
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Text('•', style: theme.textTheme.bodySmall),
																								// Listen to global bookmark notifier so UI stays in sync across screens
																								ValueListenableBuilder<Set<String>>(
																									valueListenable: BookmarkService.notifier,
																									builder: (context, set, _) {
																										final isBookmarked = set.contains(widget.id);
																										return ScaleTransition(
																											scale: _animController.drive(Tween(begin: 1.0, end: 1.1)),
																											child: IconButton(
																												onPressed: _toggleBookmark,
																												icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: theme.colorScheme.primary),
																											),
																										);
																									},
																								),
											],
										)
									],
								),
							),
						)
					],
				),
			),
		);
	}
}

