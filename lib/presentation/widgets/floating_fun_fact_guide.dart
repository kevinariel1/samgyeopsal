import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../data/data_sources/fun_facts_data.dart';

class FloatingFunFactGuide extends StatefulWidget {
  final StorageService storageService;

  const FloatingFunFactGuide({
    super.key,
    required this.storageService,
  });

  @override
  State<FloatingFunFactGuide> createState() => FloatingFunFactGuideState();
}

class FloatingFunFactGuideState extends State<FloatingFunFactGuide>
    with SingleTickerProviderStateMixin {
  static const String _kStorageKeyDisabled = 'guide_fun_facts_disabled_v1';
  static const String _kStorageKeyShownFacts = 'guide_fun_facts_shown_ids_v1';

  late bool _isDisabled;
  bool _isExpanded = false;
  bool _isVisible = true;
  late int _currentIndex;
  late List<int> _deckOrder;

  @override
  void initState() {
    super.initState();
    _isDisabled = widget.storageService.getBool(_kStorageKeyDisabled) ?? false;
    _initRotationDeck();
  }

  void _initRotationDeck() {
    final shownList = (widget.storageService.getString(_kStorageKeyShownFacts) ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();

    final all = FunFactsData.facts;
    // Find unshown fact indices first
    final unshownIndices = <int>[];
    final shownIndices = <int>[];

    for (int i = 0; i < all.length; i++) {
      if (shownList.contains(all[i].id)) {
        shownIndices.add(i);
      } else {
        unshownIndices.add(i);
      }
    }

    if (unshownIndices.isEmpty) {
      // All have been shown! Reshuffle a new cycle
      _deckOrder = List.generate(all.length, (i) => i)..shuffle();
      widget.storageService.setString(_kStorageKeyShownFacts, '');
    } else {
      unshownIndices.shuffle();
      _deckOrder = [...unshownIndices, ...shownIndices];
    }

    _currentIndex = _deckOrder.isNotEmpty ? _deckOrder.first : 0;
    _markCurrentAsShown();
  }

  void _markCurrentAsShown() {
    final currentId = FunFactsData.facts[_currentIndex].id;
    final shownList = (widget.storageService.getString(_kStorageKeyShownFacts) ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();
    shownList.add(currentId);
    widget.storageService.setString(_kStorageKeyShownFacts, shownList.join(','));
  }

  /// Public method to cycle to the next fact (callable from outside, e.g., on lesson complete)
  void nextFact() {
    if (!mounted) return;
    setState(() {
      final currentPos = _deckOrder.indexOf(_currentIndex);
      if (currentPos >= 0 && currentPos + 1 < _deckOrder.length) {
        _currentIndex = _deckOrder[currentPos + 1];
      } else {
        // Recycle deck
        _deckOrder = List.generate(FunFactsData.facts.length, (i) => i)..shuffle();
        _currentIndex = _deckOrder.first;
        widget.storageService.setString(_kStorageKeyShownFacts, '');
      }
      _markCurrentAsShown();
      _isVisible = true;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _dismiss() {
    setState(() {
      _isVisible = false;
    });
  }

  void _disableForever() {
    setState(() {
      _isDisabled = true;
      _isVisible = false;
    });
    widget.storageService.setBool(_kStorageKeyDisabled, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisabled || !_isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fact = FunFactsData.facts[_currentIndex];

    return Positioned(
      bottom: 90, // Above bottom NavigationBar
      right: 16,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: _isExpanded
            ? _buildExpandedCard(theme, isDark, fact)
            : _buildCollapsedPill(theme, isDark, fact),
      ),
    );
  }

  Widget _buildCollapsedPill(ThemeData theme, bool isDark, FunFact fact) {
    return Semantics(
      button: true,
      label: 'Guide fun fact: ${fact.category}. Tap to read more.',
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _toggleExpanded,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentPurple, Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Did you know? • ${fact.category}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.expand_less_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(ThemeData theme, bool isDark, FunFact fact) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.35),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('💡', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DID YOU KNOW?',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentPurple,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      fact.category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: 'Minimize',
                icon: const Icon(Icons.expand_more_rounded),
                onPressed: _toggleExpanded,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: 'Dismiss',
                icon: const Icon(Icons.close_rounded),
                onPressed: _dismiss,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Optional Korean pill
          if (fact.korean != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                fact.korean!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Fact text
          Text(
            fact.fact,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
            ),
          ),
          if (fact.detail != null) ...[
            const SizedBox(height: 6),
            Text(
              fact.detail!,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.3,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _disableForever,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'Don\'t show again',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: nextFact,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Next Fact', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
