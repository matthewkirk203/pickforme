import 'dart:math';

import 'package:flutter/material.dart';

import '../data/activities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _tabIndex = 0;

  // Pick flow state
  Category? _selectedCategory;
  Activity? _picked;
  bool _isPicking = false;
  int _revealTick = 0;
  final Random _random = Random();

  // Acceptance state
  Activity? _accepted;

  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _selectCategory(Category c) {
    setState(() {
      _selectedCategory = c;
      _picked = null;
      _accepted = null;
    });
    _pickAnother();
  }

  Future<void> _pickAnother() async {
    final cat = _selectedCategory;
    if (cat == null) return;
    final pool = activitiesFor(cat.name);
    if (pool.isEmpty) return;

    setState(() {
      _isPicking = true;
      _picked = null;
    });

    // Brief "spinning" delay for an engaging reveal.
    await Future.delayed(const Duration(milliseconds: 1100));

    if (!mounted) return;
    final choice = pool[_random.nextInt(pool.length)];
    setState(() {
      _picked = choice;
      _isPicking = false;
      _revealTick++;
    });
    _revealController.forward(from: 0);
  }

  void _accept() {
    setState(() {
      _accepted = _picked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great choice! Enjoy: "${_picked!.title}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onBrowseActivityTap(Activity a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use this activity?'),
        content: Text(a.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Use this'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _accepted = a);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great choice! Enjoy: "${a.title}"'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _backToCategories() {
    setState(() {
      _selectedCategory = null;
      _picked = null;
      _isPicking = false;
      _accepted = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick For Me'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _tabIndex == 0 ? _buildPickTab(context) : _buildAllTab(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'Pick',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'View All',
          ),
        ],
      ),
    );
  }

  Widget _buildPickTab(BuildContext context) {
    if (_selectedCategory != null) {
      return _buildReveal(context);
    }
    return _buildCategories(context);
  }

  Widget _buildCategories(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a category and we\'ll pick one activity for you.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final c = categories[i];
              return _CategoryCard(
                category: c,
                onTap: () => _selectCategory(c),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReveal(BuildContext context) {
    final cat = _selectedCategory!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _backToCategories,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to categories'),
            ),
          ),
          const SizedBox(height: 8),
          // Category header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.icon, color: cat.color, size: 32),
              const SizedBox(width: 10),
              Text(
                cat.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cat.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Reveal card
          _RevealCard(
            isPicking: _isPicking,
            activity: _picked,
            category: cat,
            tick: _revealTick,
            controller: _revealController,
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (!_isPicking && _picked != null) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAnother,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Pick Another'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _accept,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept this Activity'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_isPicking)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Picking something great for you...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          if (_accepted != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.celebration_rounded,
                        color: Theme.of(context).colorScheme.onSecondaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Accepted: "${_accepted!.title}"',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'All Activities',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Browse the full catalog. Tap any activity to pick it.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        for (final c in categories) ...[
          _CategorySection(
            category: c,
            onActivityTap: (a) => _onBrowseActivityTap(a),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name} category. ${category.description}',
      child: Material(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, size: 40, color: category.color),
                ),
                const SizedBox(height: 14),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.isPicking,
    required this.activity,
    required this.category,
    required this.tick,
    required this.controller,
  });

  final bool isPicking;
  final Activity? activity;
  final Category category;
  final int tick;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: isPicking
          ? _SpinningCard(key: const ValueKey('spinning'), category: category)
          : (activity == null
              ? _EmptyCard(key: const ValueKey('empty'), category: category)
              : _ActivityCard(
                  key: ValueKey('activity-$tick-${activity!.title}'),
                  activity: activity!,
                  category: category,
                  animation: anim,
                )),
    );
  }
}

class _SpinningCard extends StatefulWidget {
  const _SpinningCard({super.key, required this.category});
  final Category category;

  @override
  State<_SpinningCard> createState() => _SpinningCardState();
}

class _SpinningCardState extends State<_SpinningCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.category.color.withValues(alpha: 0.1),
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _c,
                child: Icon(Icons.autorenew_rounded,
                    size: 64, color: widget.category.color),
              ),
              const SizedBox(height: 16),
              Text(
                'Thinking...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.category.color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({super.key, required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Tap "Pick Another" to begin',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    super.key,
    required this.activity,
    required this.category,
    required this.animation,
  });

  final Activity activity;
  final Category category;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Card(
        color: category.color.withValues(alpha: 0.12),
        child: SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category.icon, size: 48, color: category.color),
                const SizedBox(height: 16),
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, this.onActivityTap});

  final Category category;
  final ValueChanged<Activity>? onActivityTap;

  @override
  Widget build(BuildContext context) {
    final items = activitiesFor(category.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, color: category.color, size: 24),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final a in items)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.circle, size: 10, color: category.color),
              title: Text(a.title),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              minVerticalPadding: 8,
              onTap: onActivityTap == null ? null : () => onActivityTap!(a),
            ),
          ),
      ],
    );
  }
}