import 'package:drumm_app/config/injection_container.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_bloc.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_event.dart';
import 'package:drumm_app/core/features/get%20bands/presentation/bloc/remote/remote_bands_state.dart';
import 'package:drumm_app/features/news%20feed/presentation/widgets/band_select_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

typedef void BandSelectedCallback(BandEntity bandEntity);

class BandSelectionList extends StatelessWidget {
  BandSelectedCallback onSelect;
  RemoteBandsState state;
  List<BandEntity> bands;

  String? selectBandEntityId = "For You";
  BandSelectionList(
      {super.key,
      required this.onSelect,
      required this.bands,
      required this.state});

  @override
  Widget build(BuildContext context) {
    List<MultiSelectCard<dynamic>> mulList = [];
    BandEntity forYouBand = BandEntity(bandId: "For You", name: "For You");
    List<BandEntity> bands = [];
    bands.add(forYouBand);

    if (state is RemoteBandsFetched) {
      bands.addAll(state.bands ?? []);

      for (var element in bands) {
        mulList.add(getBandCard(element));
      }

      return Container(
        alignment: Alignment.centerLeft,
        height: 38,
        child: BandSelectContainer(
            onSelect: (bandEntity) {
              selectBandEntityId = bandEntity.bandId;
              onSelect(bandEntity);
            },
            bandsCards: mulList),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 32,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Shimmer(
                child: Container(
                  height: 32,
                  width: index == 0 ? 70 : 128,
                  decoration: BoxDecoration(
                      color: DrummTheme.primaryItemColor(context),
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  getBandCard(BandEntity element) {
    return MultiSelectCard(
      value: element,
      selected: (element.bandId == selectBandEntityId),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 32,
        child: Text(
          "${element.name}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
