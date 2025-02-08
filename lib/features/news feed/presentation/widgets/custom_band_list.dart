import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Callback to be invoked when a band is selected.
typedef BandSelectedCallback = void Function(BandEntity bandEntity);

/// A custom horizontal list of band “cards” that mimics the design of your original
/// [MultiSelectContainer] implementation. Only one item is selectable at a time,
/// and the default selection is "For You".
class CustomBandSelectContainer extends StatefulWidget {
  final List<BandEntity> bandEntities;
  final BandSelectedCallback onSelect;

  const CustomBandSelectContainer({
    Key? key,
    required this.bandEntities,
    required this.onSelect,
  }) : super(key: key);

  @override
  _CustomBandSelectContainerState createState() => _CustomBandSelectContainerState();
}

class _CustomBandSelectContainerState extends State<CustomBandSelectContainer> {
  /// Keep track of the currently selected band.
  /// We set "For You" as the default selection.
  String selectedBandId = "For You";

  @override
  Widget build(BuildContext context) {
    // Ensure "For You" is the first item.
    final List<BandEntity> bands = [
      BandEntity(bandId: "For You", name: "For You"),
      ...widget.bandEntities,
    ];

    return Container(
      alignment: Alignment.centerLeft,
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 12, right: 12),
        scrollDirection: Axis.horizontal,
        itemCount: bands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final BandEntity band = bands[index];
          final bool isSelected = band.bandId == selectedBandId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedBandId = band.bandId!;
              });
              Vibrate.feedback(FeedbackType.selection);
              widget.onSelect(band);
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? DrummTheme.drummPrimaryColor
                    : DrummTheme.primaryItemColor(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                "${band.name}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : DrummTheme.primaryTextColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  wordSpacing: 0.7,
                  fontFamily: DRUMM_FONT_FAMILY,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BandsPlaceHolder extends StatelessWidget {
  const BandsPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
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
}
