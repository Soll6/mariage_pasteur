import 'dart:ui';

const List<String> availableDrinks = [
  'REGAB',
  '33 EXPORT',
  'CASTEL BEER',
  'BEAUFORT LAGER',
  'Heineken',
  '1664 Kronenbourg',
  'Royal Dutch',
  'CHILL',
  'GUINNESS',
  'DJINO PAMPLEMOUSSE',
  'DJINO COCKTAIL',
  'DJIND ORANGE',
  'DJIND POMME',
  'IMPERIAL TONIC',
  'COCA-COLA',
  'YOUZOU',
  'ORANGINA',
  'SUMOL',
  'ANDZA',
  'DOPPEL MUNICH',
  'SOMBREROS',
  'RACINES',
  'BOOSTER ZOMBIE',
  'BOOSTER BANANA',
  'BOOSTER WHISKY',
  'BOOSTER RHUM GINGER',
  'BOOSTER GIN TONIC',
];

const List<Color> drinkColors = [
  Color(0xFFE57373), // REGAB
  Color(0xFFF06292), // 33 EXPORT
  Color(0xFFBA68C8), // CASTEL BEER
  Color(0xFF9575CD), // BEAUFORT LAGER
  Color(0xFF7986CB), // Heineken
  Color(0xFF64B5F6), // 1664 Kronenbourg
  Color(0xFF4FC3F7), // Royal Dutch
  Color(0xFF4DD0E1), // CHILL
  Color(0xFF4DB6AC), // GUINNESS
  Color(0xFF81C784), // DJINO PAMPLEMOUSSE
  Color(0xFFAED581), // DJINO COCKTAIL
  Color(0xFFFFD54F), // DJIND ORANGE
  Color(0xFFFFB74D), // DJIND POMME
  Color(0xFFFF8A65), // IMPERIAL TONIC
  Color(0xFFA1887F), // COCA-COLA
  Color(0xFFE0E0E0), // YOUZOU
  Color(0xFFFF7043), // ORANGINA
  Color(0xFFEF5350), // SUMOL
  Color(0xFFAB47BC), // ANDZA
  Color(0xFF5C6BC0), // DOPPEL MUNICH
  Color(0xFF26A69A), // SOMBREROS
  Color(0xFF66BB6A), // RACINES
  Color(0xFFFFCA28), // BOOSTER ZOMBIE
  Color(0xFFFFA726), // BOOSTER BANANA
  Color(0xFF8D6E63), // BOOSTER WHISKY
  Color(0xFFEF5350), // BOOSTER RHUM GINGER
  Color(0xFF42A5F5), // BOOSTER GIN TONIC
];

Color getDrinkColor(String drinkName) {
  final index = availableDrinks.indexOf(drinkName);
  if (index == -1) return const Color(0xFF9E9E9E);
  return drinkColors[index % drinkColors.length];
}
