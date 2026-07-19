import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

IconData amenityIcon(String code) {
  switch (code) {
    case 'PrivateBathroom':
      return PhosphorIcons.shower();
    case 'Bathub':
    case 'SpaTub':
      return PhosphorIcons.bathtub();
    case 'Terrace':
      return PhosphorIcons.umbrella();
    case 'Balcony':
      return PhosphorIcons.doorOpen();
    case 'PrivatePool':
      return PhosphorIcons.swimmingPool();
    case 'View':
    case 'SeaView':
      return PhosphorIcons.mountains();
    case 'AC':
      return PhosphorIcons.snowflake();
    case 'Kitchen':
      return PhosphorIcons.cookingPot();
    case 'CoffeeMachine':
      return PhosphorIcons.coffee();
    case 'WashingMachine':
      return PhosphorIcons.tShirt();
    case 'SoundProof':
      return PhosphorIcons.speakerSimpleX();
    case 'Breakfast':
      return PhosphorIcons.forkKnife();
    default:
      return PhosphorIcons.checkCircle();
  }
}
