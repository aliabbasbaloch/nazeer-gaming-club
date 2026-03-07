import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

enum SnookerBall {
  yellow,
  green,
  brown,
  blue,
  pink,
  black,
  red,
}

extension SnookerBallExtension on SnookerBall {
  int get points {
    switch (this) {
      case SnookerBall.yellow:
        return AppConstants.yellowPoints;
      case SnookerBall.green:
        return AppConstants.greenPoints;
      case SnookerBall.brown:
        return AppConstants.brownPoints;
      case SnookerBall.blue:
        return AppConstants.bluePoints;
      case SnookerBall.pink:
        return AppConstants.pinkPoints;
      case SnookerBall.black:
        return AppConstants.blackPoints;
      case SnookerBall.red:
        return AppConstants.redPoints;
    }
  }
  
  Color get color {
    switch (this) {
      case SnookerBall.yellow:
        return AppColors.ballYellow;
      case SnookerBall.green:
        return AppColors.ballGreen;
      case SnookerBall.brown:
        return AppColors.ballBrown;
      case SnookerBall.blue:
        return AppColors.ballBlue;
      case SnookerBall.pink:
        return AppColors.ballPink;
      case SnookerBall.black:
        return AppColors.ballBlack;
      case SnookerBall.red:
        return AppColors.ballRed;
    }
  }
  
  String get displayName {
    switch (this) {
      case SnookerBall.yellow:
        return 'Yellow';
      case SnookerBall.green:
        return 'Green';
      case SnookerBall.brown:
        return 'Brown';
      case SnookerBall.blue:
        return 'Blue';
      case SnookerBall.pink:
        return 'Pink';
      case SnookerBall.black:
        return 'Black';
      case SnookerBall.red:
        return 'Red';
    }
  }
}
