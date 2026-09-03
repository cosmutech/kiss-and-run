import 'dart:math';

class FunnyDialogues {
  static final _random = Random();

  static const List<String> successfulKiss = [
    "Smooth. Very smooth.",
    "That actually worked?!",
    "Risky move, playboy!",
    "Calculated charm +100",
    "Stealing hearts in broad daylight!",
    "Legendary rizz!",
    "You got the magic touch!",
  ];

  static const List<String> slapped = [
    "Worth it? Absolutely.",
    "You knew this would happen.",
    "RUN BRO, RUN!!",
    "Instant cartoon concussion!",
    "That left a red handprint!",
    "Oof! Five across the eyes!",
    "Your cheek is on fire!",
  ];

  static const List<String> policeAlert = [
    "Okay... that was a bad idea.",
    "Sirens in the distance!",
    "Most wanted in town!",
    "Put your sneakers in turbo mode!",
    "Flashing blue and red lights!",
  ];

  static const List<String> chainReaction = [
    "HOW DID THIS HAPPEN?!",
    "Total domino effect!",
    "The whole street is after you!",
    "Absolute cartoon mayhem!",
    "Hot dog cart down! I repeat, down!",
    "Massive crowd chaos!!",
  ];

  static const List<String> caught = [
    "You should've run faster!",
    "Busted! Game over, Romeo!",
    "Detained for excessive charm!",
    "Tackled into the flower bed!",
    "Handcuffs never looked so funny!",
    "Caught red-handed (and red-cheeked)!",
  ];

  static const List<String> escaped = [
    "Clean getaway! Phew!",
    "Shook 'em off completely!",
    "Master of evasion!",
    "Lost them in the alley!",
    "Cardio pays off!",
  ];

  static String getRandom(List<String> list) {
    return list[_random.nextInt(list.length)];
  }
}
