import 'package:drumm_app/config/routes/router_constants.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/core/util/article_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ArticleDrummButton extends StatelessWidget {
  final ArticleEntity article;
  final List<BandEntity> bands;
  const ArticleDrummButton(
      {super.key, required this.article, required this.bands});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
          //color: DrummTheme.primarySelectedItemColor(context).withAlpha(5),
          borderRadius: BorderRadius.circular(24)),
      child: Image.asset('images/audio-waves.png',
          color: DrummTheme.primaryTextColor(context), fit: BoxFit.contain),
    );
  }
}

class ArticleDrummButtonLoading extends StatelessWidget {
  ArticleDrummButtonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
          color: DrummTheme.primaryItemBackground(context),
          borderRadius: BorderRadius.circular(24)),
    );
  }
}
