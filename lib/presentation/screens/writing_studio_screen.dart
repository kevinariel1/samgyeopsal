import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/hangul_tracing_widget.dart';

class WritingStudioScreen extends StatefulWidget {
  const WritingStudioScreen({super.key});

  @override
  State<WritingStudioScreen> createState() => _WritingStudioScreenState();
}

class _WritingStudioScreenState extends State<WritingStudioScreen> {
  static const Map<String, List<String>> characterGroups = {
    'Basic Consonants': ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'],
    'Basic Vowels': ['ㅏ', 'ㅓ', 'ㅗ', 'ㅜ', 'ㅡ', 'ㅣ', 'ㅑ', 'ㅛ', 'ㅐ', 'ㅔ', 'ㅘ', 'ㅝ', 'ㅟ', 'ㅢ'],
    'Double Consonants': ['ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ'],
    'Syllable Blocks': ['가', '나', '다', '라', '산'],
  };

  String _selectedGroup = 'Basic Consonants';
  String _selectedCharacter = 'ㄱ';
  bool _showGuides = true;
  final Set<String> _masteredCharacters = {};
  bool _isTracingActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentList = characterGroups[_selectedGroup] ?? ['ㄱ'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Studio ✍️'),
        actions: [
          Row(
            children: [
              const Text(
                'Guides',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _showGuides,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _showGuides = val),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: _isTracingActive ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: characterGroups.keys.map((group) {
                  final isSelected = group == _selectedGroup;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        group,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedGroup = group;
                            _selectedCharacter = characterGroups[group]!.first;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Character selector bar
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: currentList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final char = currentList[idx];
                  final isSelected = char == _selectedCharacter;
                  final isMastered = _masteredCharacters.contains(char);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selectedCharacter = char),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isMastered
                                ? AppColors.success.withOpacity(0.14)
                                : theme.cardTheme.color),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isMastered ? AppColors.success : AppColors.lightCardBorder),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            char,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : (isMastered ? AppColors.success : null),
                            ),
                          ),
                          if (isMastered && !isSelected)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            HangulTracingWidget(
              key: ValueKey('studio_${_selectedCharacter}_$_showGuides'),
              character: _selectedCharacter,
              showGuides: _showGuides,
              showGrid: _showGuides,
              freehandMode: !_showGuides,
              onTracingActive: (active) {
                setState(() => _isTracingActive = active);
              },
              onCompleted: () {
                setState(() {
                  _masteredCharacters.add(_selectedCharacter);
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Session Stamps Collected: ${_masteredCharacters.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
