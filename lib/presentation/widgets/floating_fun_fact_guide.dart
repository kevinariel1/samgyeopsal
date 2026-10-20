import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../data/data_sources/fun_facts_data.dart';

/// Interactive Floating Character Guide featuring the cute white cat mascot (`mascot_cat_idle_clean.png`).
/// Behavior:
/// - **Idle State**: No text bubble shown! The cat peeks discreetly from the right edge of the screen.
/// - **Periodic & Manual Trigger**: Every 5 minutes (or whenever the user taps the peeking cat),
///   the cat slides out into full view, a thin dark spotlight veil dims the background,
///   and the speech bubble pops open with a new fun fact.
/// - **Dismissal**: Tapping anywhere on the dark veil or tapping the 'X' button closes the bubble,
///   fades out the veil, retracts the cat back to its peeking position, and resets the 5-minute timer.
class FloatingFunFactGuide extends StatefulWidget {
  final StorageService storageService;
  final Duration promptInterval;

  const FloatingFunFactGuide({
    super.key,
    required this.storageService,
    this.promptInterval = const Duration(minutes: 5),
  });

  @override
  State<FloatingFunFactGuide> createState() => FloatingFunFactGuideState();
}

class FloatingFunFactGuideState extends State<FloatingFunFactGuide>
    with SingleTickerProviderStateMixin {
  static const String _kStorageKeyDisabled = 'guide_fun_facts_disabled_v1';
  static const String _kStorageKeyShownFacts = 'guide_fun_facts_shown_ids_v1';
  static const String _kMascotAssetPath = 'assets/images/mascot_cat_idle_clean.png';

  late final AnimationController _hopController;
  late final Animation<double> _hopAnimation;
  Timer? _periodicTimer;

  late bool _isDisabled;
  bool _isExpanded = false;
  late int _currentIndex;
  late List<int> _deckOrder;

  @override
  void initState() {
    super.initState();
    _isDisabled = widget.storageService.getBool(_kStorageKeyDisabled) ?? false;
    _initRotationDeck();

    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _hopAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _hopController, curve: Curves.easeOutCubic),
    );

    if (!_isDisabled) {
      _startPeriodicTimer();
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _hopController.dispose();
    super.dispose();
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer(widget.promptInterval, () {
      if (!mounted || _isDisabled) return;
      if (!_isExpanded) {
        _advanceFactIndex();
        setState(() {
          _isExpanded = true;
        });
        _hopController.forward(from: 0.0);
      }
      _startPeriodicTimer();
    });
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

  void _advanceFactIndex() {
    final currentPos = _deckOrder.indexOf(_currentIndex);
    if (currentPos >= 0 && currentPos + 1 < _deckOrder.length) {
      _currentIndex = _deckOrder[currentPos + 1];
    } else {
      _deckOrder = List.generate(FunFactsData.facts.length, (i) => i)..shuffle();
      _currentIndex = _deckOrder.first;
      widget.storageService.setString(_kStorageKeyShownFacts, '');
    }
    _markCurrentAsShown();
  }

  /// Public method to cycle to the next fact and show the bubble
  void nextFact() {
    if (!mounted || _isDisabled) return;
    setState(() {
      _advanceFactIndex();
      _isExpanded = true;
    });
    _hopController.forward(from: 0.0);
    _startPeriodicTimer();
  }

  /// Called when tapping the peeking cat or toggling the bubble
  void _onTapCat() {
    if (_isExpanded) {
      _closeBubble();
    } else {
      setState(() {
        _isExpanded = true;
      });
      _hopController.forward(from: 0.0);
      _startPeriodicTimer();
    }
  }

  /// Closes the speech bubble, fades out the dark veil, and slides the cat back to peeking mode
  void _closeBubble() {
    setState(() {
      _isExpanded = false;
    });
    _startPeriodicTimer();
  }

  void _disableForever() {
    _periodicTimer?.cancel();
    setState(() {
      _isDisabled = true;
      _isExpanded = false;
    });
    widget.storageService.setBool(_kStorageKeyDisabled, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisabled) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fact = FunFactsData.facts[_currentIndex];

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Thin Dark Spotlight Veil when the character is speaking (_isExpanded)
          // Tapping anywhere on this veil closes the speech bubble and retracts the cat.
          IgnorePointer(
            ignoring: !_isExpanded,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeBubble,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                color: _isExpanded
                    ? Colors.black.withOpacity(isDark ? 0.62 : 0.48)
                    : Colors.transparent,
              ),
            ),
          ),

          // 2. Character + Speech Bubble Layer
          // When idle (!_isExpanded), the cat peeks from the right edge (right: -36) with NO bubble.
          // When speaking (_isExpanded), the cat slides out (right: 12) and shows the speech bubble.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: 12,
            right: _isExpanded ? 12 : -36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Speech Bubble Popup (ONLY rendered when _isExpanded is true)
                if (_isExpanded)
                  _buildExpandedChatBubble(theme, isDark, fact),
                // Standalone Character Sprite (peeking when idle, full view when speaking)
                _buildCharacterSprite(),
              ],
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
      padding: const EdgeInsets.only(right: 4, bottom: 2),
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
                // Bubble Top Bar with Close 'X' button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'DID YOU KNOW? • ${fact.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentPurple,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _closeBubble,
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
                    Flexible(
                      child: TextButton(
                        onPressed: _disableForever,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Don\'t show again',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: nextFact,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text('Next Fact', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(76, 34),
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
  /// - Peeks discreetly from the right screen edge when idle (`!_isExpanded`), tilted slightly left.
  /// - Slides out to full size when speaking (`_isExpanded`).
  /// - Clean transparent sprite with no blurry shadow or dark background behind it.
  Widget _buildCharacterSprite() {
    final double spriteWidth = _isExpanded ? 132 : 100;
    final double spriteHeight = _isExpanded ? 104 : 80;

    return Semantics(
      button: true,
      label: _isExpanded ? 'Close cat guide' : 'Tap peeking cat for a Korean fun fact',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTapCat,
        child: AnimatedBuilder(
          animation: _hopAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _hopAnimation.value),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: spriteWidth,
            height: spriteHeight,
            child: Transform.rotate(
              // Slight playful tilt when peeking from the right edge; upright when speaking
              angle: _isExpanded ? 0.0 : -0.18,
              child: Transform.scale(
                scale: 1.7,
                child: Image.asset(
                  _kMascotAssetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
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
