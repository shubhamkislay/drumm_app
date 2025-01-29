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

typedef void BandSelectedCallback(BandEntity bandEntity);

class BandSelectionList extends StatelessWidget {
  BandSelectedCallback onSelect;
  BandSelectionList({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    List<MultiSelectCard<dynamic>> mulList = [];
    BandEntity forYouBand = BandEntity(bandId: "For You", name: "For You");
    List<BandEntity> bands = [];
    bands.add(forYouBand);

    return BlocProvider<RemoteBandsBloc>(
        create: (providerContext) => s1()..add(GetCurrentUserBands()),
        child: BlocBuilder<RemoteBandsBloc, RemoteBandsState>(
          builder: (context, state) {
            if (state is RemoteBandsFetched) {
              bands.addAll(state.bands ?? []);

              for (var element in bands) {
                mulList.add(getBandCard(element));
              }

              return Container(
                alignment: Alignment.centerLeft,
                height: 32,
                child: BandSelectContainer(
                    onSelect: onSelect, bandsCards: mulList),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 32,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 0 ?70:128,
                    decoration: BoxDecoration(
                        color: DrummTheme.primaryItemColor(context),
                        borderRadius: BorderRadius.circular(16)
                    ),
                  );
                },
              ),
            );
          },
        ));
  }

  getBandCard(BandEntity element) {
    return MultiSelectCard(
      value: element,
      selected: (element.bandId == "For You"),
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
