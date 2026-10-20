import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../data/data_sources/fun_facts_data.dart';

/// Interactive Floating Character Guide featuring the cute white cat mascot (`mascot_cat_idle_clean.png`).
/// Features:
/// - Full-screen dim veil (spotlight scrim) when the character is speaking (`_isExpanded`).
/// - Tight bounding-box framing & larger display size so the character is clearly visible.
/// - Soft sticker/silhouette drop-shadow + pedestal aura so the white fur pops against light & dark backgrounds.
/// - Gentle idle breathing/bobbing animation + unread notification badge.
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
  static const String _kMascotAssetPath = 'assets/images/mascot_cat_idle_clean.png';

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  late bool _isDisabled;
  bool _isExpanded = false;
  bool _isVisible = true;
  bool _hasUnreadFact = true;
  late int _currentIndex;
  late List<int> _deckOrder;

  @override
  void initState() {
    super.initState();
    _isDisabled = widget.storageService.getBool(_kStorageKeyDisabled) ?? false;
    _initRotationDeck();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _floatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _initRotationDeck() {
    final shownList = (widget.storageService.getString(_kStorageKeyShownFacts) ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();

    final all = FunFactsData.facts;
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

  /// Public method to cycle to the next fact
  void nextFact() {
    if (!mounted) return;
    setState(() {
      final currentPos = _deckOrder.indexOf(_currentIndex);
      if (currentPos >= 0 && currentPos + 1 < _deckOrder.length) {
        _currentIndex = _deckOrder[currentPos + 1];
      } else {
        _deckOrder = List.generate(FunFactsData.facts.length, (i) => i)..shuffle();
        _currentIndex = _deckOrder.first;
        widget.storageService.setString(_kStorageKeyShownFacts, '');
      }
      _markCurrentAsShown();
      _isVisible = true;
      _hasUnreadFact = !_isExpanded;
    });
    _floatController.forward(from: 0.0);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _hasUnreadFact = false;
      }
    });
    _floatController.forward(from: 0.0);
  }

  void _dismiss() {
    setState(() {
      _isExpanded = false;
      _isVisible = false;
    });
  }

  void _disableForever() {
    setState(() {
      _isDisabled = true;
      _isExpanded = false;
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

    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Thin Dark Spotlight Veil when the character is speaking (_isExpanded)
          IgnorePointer(
            ignoring: !_isExpanded,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleExpanded,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                color: _isExpanded
                    ? Colors.black.withOpacity(isDark ? 0.62 : 0.48)
                    : Colors.transparent,
              ),
            ),
          ),

          // 2. Character + Speech Bubble Layer anchored at bottom-right
          Positioned(
            bottom: 8,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Separate Chat Bubble Popup emerging from the character
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  alignment: Alignment.bottomRight,
                  child: _isExpanded
                      ? _buildExpandedChatBubble(theme, isDark, fact)
                      : _buildCollapsedChatBubble(theme, isDark, fact),
                ),
                const SizedBox(height: 2),
                // Standalone Character Sprite with gentle floating motion
                _buildCharacterSprite(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small, floating mini chat bubble emerging from the cat when collapsed
  Widget _buildCollapsedChatBubble(ThemeData theme, bool isDark, FunFact fact) {
    final bubbleBg = isDark ? const Color(0xFF252538) : Colors.white;
    final borderColor = AppColors.accentPurple;

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Semantics(
            button: true,
            label: 'Did you know fun fact: ${fact.category}. Tap to read.',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleExpanded,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(6),
                    ),
                    border: Border.all(color: borderColor, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(isDark ? 0.35 : 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'Did you know? • ${fact.category}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.unfold_more_rounded,
                        color: AppColors.accentPurple,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Chat bubble tail pointing down to the cat's head
          Padding(
            padding: const EdgeInsets.only(right: 26),
            child: CustomPaint(
              size: const Size(14, 9),
              painter: _BubbleTailPainter(
                fillColor: bubbleBg,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Expanded chat bubble popup coming from the cat character
  Widget _buildExpandedChatBubble(ThemeData theme, bool isDark, FunFact fact) {
    final bubbleBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = AppColors.accentPurple;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 315,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: borderColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bubble Top Bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'DID YOU KNOW? • ${fact.category}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentPurple,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      tooltip: 'Minimize bubble',
                      icon: const Icon(Icons.expand_more_rounded),
                      onPressed: _toggleExpanded,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 19,
                      tooltip: 'Hide guide',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _dismiss,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Optional Korean Word badge
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
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Fun Fact Speech Content
                Text(
                  '"${fact.fact}"',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
                  ),
                ),
                if (fact.detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    fact.detail!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Bubble Footer Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _disableForever,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Don\'t show again',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: nextFact,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text('Next Fact', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: const Size(88, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Speech Bubble Pointer Tail aimed directly at the cat character below
          Padding(
            padding: const EdgeInsets.only(right: 42),
            child: CustomPaint(
              size: const Size(20, 13),
              painter: _BubbleTailPainter(
                fillColor: bubbleBg,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Standalone Cute White Cat Sprite:
  /// - Scaled up & cropped of excess transparent margin so the cat is 2.2x larger.
  /// - Clean transparent sprite with no blurry shadow or dark background behind it.
  Widget _buildCharacterSprite() {
    final double spriteWidth = _isExpanded ? 132 : 114;
    final double spriteHeight = _isExpanded ? 104 : 90;

    return Semantics(
      button: true,
      label: _isExpanded ? 'Minimize cat guide' : 'Expand cat guide fun fact',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleExpanded,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            width: spriteWidth,
            height: spriteHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Crisp Cat Sprite (scaled 1.7x to trim internal PNG transparent padding)
                Transform.scale(
                  scale: 1.7,
                  child: Image.asset(
                    _kMascotAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text('🐱', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),

                // Unread Fun Fact Notification Sparkle Badge when collapsed
                if (!_isExpanded && _hasUnreadFact)
                  Positioned(
                    top: 4,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.45),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the comic speech-bubble tail seamlessly connecting the chat bubble to the character below
class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _BubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Fill triangle overlapping 1.5px into the bubble above so the top seam is invisible
    final fillPath = Path()
      ..moveTo(0, -1.5)
      ..lineTo(size.width, -1.5)
      ..lineTo(size.width * 0.65, size.height)
      ..close();

    // Stroke only the two outer V edges of the tail
    final strokePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(strokePath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor || oldDelegate.borderColor != borderColor;
}
