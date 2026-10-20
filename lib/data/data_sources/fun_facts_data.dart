class FunFact {
  final String id;
  final String category;
  final String? korean;
  final String fact;
  final String? detail;

  const FunFact({
    required this.id,
    required this.category,
    this.korean,
    required this.fact,
    this.detail,
  });
}

class FunFactsData {
  static const List<FunFact> facts = [
    FunFact(
      id: 'fact_1',
      category: 'King Sejong 👑',
      korean: '세종대왕',
      fact: 'Hangul was created in 1443 by King Sejong the Great to give common people an easy writing system so everyone could read and write.',
      detail: 'Before Hangul, Koreans used complex Chinese characters (Hanja) that only the elite could afford to study.',
    ),
    FunFact(
      id: 'fact_2',
      category: 'Scientific Design 🔬',
      korean: '훈민정음',
      fact: 'The basic consonant shapes (ㄱ, ㄴ, ㅁ, ㅅ, ㅇ) literally depict the shape of the mouth, tongue, and throat when pronouncing them!',
      detail: 'For example, ㄴ mimics the tongue tip touching the upper gums, while ㄱ mimics the tongue blocking the throat.',
    ),
    FunFact(
      id: 'fact_3',
      category: 'Cosmic Vowels 🌌',
      korean: '천지인 (Cheon-Ji-In)',
      fact: 'Original Hangul vowels were built from 3 cosmic elements: • (Sun/Heaven), ㅡ (Flat Earth), and ㅣ (Upright Human).',
      detail: 'By combining Heaven, Earth, and Humanity, King Sejong could spell every sound in the universe.',
    ),
    FunFact(
      id: 'fact_4',
      category: 'National Holiday 🎈',
      korean: '한글날 (Hangul Day)',
      fact: 'Korea is one of the only countries in the world with an official national holiday celebrating its alphabet!',
      detail: 'South Korea celebrates Hangul Day on October 9th, and North Korea celebrates Choson-gul Day on January 15th.',
    ),
    FunFact(
      id: 'fact_5',
      category: 'Speed Learning ⚡',
      fact: 'A famous proverb about Hangul says: "A wise person can learn it before morning; a fool can learn it in ten days."',
      detail: 'Because it was designed logically from scratch, Hangul is praised by linguists as the easiest alphabet to learn.',
    ),
    FunFact(
      id: 'fact_6',
      category: 'Syllable Blocks 🧱',
      korean: '글자 (Geulja)',
      fact: 'Hangul letters are never written in a single long line. Instead, they are packed into compact syllable squares!',
      detail: 'Each syllable block always contains at least one initial consonant and one vowel (e.g., ㅎ + ㅏ + ㄴ = 한).',
    ),
    FunFact(
      id: 'fact_7',
      category: 'UNESCO Praise 🏛️',
      korean: '유네스코',
      fact: 'UNESCO established the "King Sejong Literacy Prize" in 1989 to reward global efforts fighting illiteracy.',
      detail: 'UNESCO also inscribed the 1446 document explaining Hangul (Hunminjeongeum Haerye) on its Memory of the World Register.',
    ),
    FunFact(
      id: 'fact_8',
      category: 'Silent Circle ⭕',
      korean: '이응 (ㅇ)',
      fact: 'The circular letter ㅇ is completely silent when placed at the beginning of a syllable (like 아), acting as a placeholder.',
      detail: 'However, when placed at the bottom (Batchim) of a syllable (like 앙), it makes the "ng" nasal ringing sound!',
    ),
    FunFact(
      id: 'fact_9',
      category: 'Twin Consonants 👯',
      korean: '쌍자음 (Ssang-jaeum)',
      fact: 'The 5 double consonants (ㄲ, ㄸ, ㅃ, ㅆ, ㅉ) are pronounced with high vocal tension and no breath puff.',
      detail: 'The prefix "쌍" (ssang) simply means "pair" or "twin" in Korean.',
    ),
    FunFact(
      id: 'fact_10',
      category: 'Polite Language 🙏',
      korean: '존댓말 (Jondaetmal)',
      fact: 'Korean has built-in grammatical levels of politeness and respect depending on your relationship with the listener.',
      detail: 'Adding "-요" (-yo) to verbs is the friendly, polite way to speak to strangers, coworkers, and elders.',
    ),
    FunFact(
      id: 'fact_11',
      category: 'Korean Rice Culture 🍚',
      korean: '밥 먹었어? (Have you eaten?)',
      fact: 'In Korea, asking "Did you eat rice?" is a warm greeting equivalent to asking "How are you doing today?"',
      detail: 'It stems from historically tough times when having enough food to eat was the greatest wish for loved ones.',
    ),
    FunFact(
      id: 'fact_12',
      category: 'Two Counting Systems 🔢',
      korean: '숫자 (Numbers)',
      fact: 'Korean uses two different number systems: Native Korean for counting things and hours, and Sino-Korean for money, minutes, and phone numbers.',
      detail: 'For example, 3 o\'clock is "세 시" (Native 3), but 3 minutes is "삼 분" (Sino 3)!',
    ),
    FunFact(
      id: 'fact_13',
      category: 'Sound Words 🎶',
      korean: '의성어 (Onomatopoeia)',
      fact: 'Korean has over 8,000 mimetic and sound words describing everything from twinkling stars (반짝반짝) to bubbling stew (보글보글).',
      detail: 'Korean onomatopoeia is one of the richest in world linguistics, adding vivid color to daily speech.',
    ),
    FunFact(
      id: 'fact_14',
      category: 'Stroke Addition ✍️',
      korean: '가획의 원리',
      fact: 'Aspirated consonants (strong air puffs) are made simply by adding a stroke to basic letters: ㄱ becomes ㅋ, ㄷ becomes ㅌ, ㅂ becomes ㅍ!',
      detail: 'The extra horizontal line visually signals the burst of air escaping your lips.',
    ),
    FunFact(
      id: 'fact_15',
      category: 'Word Order 🔄',
      korean: 'SOV Structure',
      fact: 'Unlike English (Subject-Verb-Object), Korean sentences place the verb at the very end (Subject-Object-Verb).',
      detail: 'Instead of "I drink water", in Korean you say "I water drink" (저는 물을 마셔요).',
    ),
    FunFact(
      id: 'fact_16',
      category: 'Global Hangul 🌏',
      korean: '찌아찌아족',
      fact: 'The Cia-Cia tribe on Buton Island in Indonesia adopted Hangul in 2009 to preserve their spoken native language from going extinct.',
      detail: 'Because their language had no native alphabet, Hangul was chosen as the most phonetic and accurate tool.',
    ),
    FunFact(
      id: 'fact_17',
      category: 'No Tone Required 🗣️',
      korean: '성조 없음',
      fact: 'Unlike Mandarin Chinese or Vietnamese, standard Korean is not a tonal language! Pitch changes do not change the meaning of words.',
      detail: 'This makes Korean pronunciation much more straightforward for learners transitioning from European languages.',
    ),
    FunFact(
      id: 'fact_18',
      category: 'Modern Slang ✨',
      korean: '대박 (Daebak)',
      fact: 'The iconic Korean word "대박" (Daebak) originally referred to hitting a giant jackpot or huge gourd of riches in folklore.',
      detail: 'Today, everyone uses it to express amazement, excitement, or disbelief: "Awesome! / No way!"',
    ),
    FunFact(
      id: 'fact_19',
      category: 'Writing Direction 📖',
      korean: '가로쓰기 & 세로쓰기',
      fact: 'Historical Hangul was originally written vertically from top to bottom, right to left. Today, it is written horizontally like English.',
      detail: 'The transition to horizontal writing (가로쓰기) gained widespread adoption throughout the 20th century.',
    ),
    FunFact(
      id: 'fact_20',
      category: 'Compact Wonder 📏',
      fact: 'With only 14 basic consonants and 10 basic vowels, Hangul can combine into 11,172 possible syllable blocks!',
      detail: 'All 11,172 blocks are encoded into the modern Unicode Hangul Syllables block (U+AC00 to U+D7A3).',
    ),
    FunFact(
      id: 'fact_21',
      category: 'Age Calculation 🎂',
      korean: '만 나이 (International Age)',
      fact: 'In 2023, South Korea officially adopted the international age system, making everyone in Korea 1 to 2 years younger overnight!',
      detail: 'Previously, babies were considered 1 year old on the day they were born and gained a year every New Year\'s Day.',
    ),
    FunFact(
      id: 'fact_22',
      category: 'Spicy Kimchi History 🌶️',
      korean: '김치 (Kimchi)',
      fact: 'Ancient kimchi was white and mild! Red chili peppers weren\'t introduced to Korea until Portuguese traders arrived in the 16th century.',
      detail: 'Before chili peppers, traditional kimchi was fermented with salt, radishes, and wild garlic.',
    ),
  ];
}
