import 'package:flutter/material.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:provider/provider.dart';

class RankWidget extends StatelessWidget {
  const RankWidget({
    super.key,
    required this.elo,
    required this.rank,
    required this.showBar,
    required this.height,
    required this.width,
  });

  final int elo;
  final int rank;
  final bool showBar;
  final double height;
  final double width;

  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<ThemeManager>(context);

    final isDark = themeManager.themeMode == ThemeMode.dark;
    List<String> elos = [
      "Iron 1",
      "Iron 2",
      "Iron 3",
      "Bronze 1",
      "Bronze 2",
      "Bronze 3",
      "Silver 1",
      "Silver 2",
      "Silver 3",
      "Gold 1",
      "Gold 2",
      "Gold 3",
      "Diamond 1",
      "Diamond 2",
      "Diamond 3",
      "Ascendant 1",
      "Ascendant 2",
      "Ascendant 3",
      "Immortal 1",
      "Immortal 2",
      "Immortal 3",
      "Radiant"
    ];

    int index = (elo < 2200) ? (elo) ~/ 100 : 22;
    index = (index<1)? 1 : index ; 
    String image = "assets/icon/$index.png";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          image,
          height: height,
          width: width,
        ),
        if (showBar)
          Center(
              child: Text(
            elos[index - 1],
            style: TextStyle(fontSize: 30, color: isDark ? Colors.white : Colors.black87),
          )),
          if(showBar)
        const SizedBox(
          height: 20,
        ),
        if (index < 22 && showBar)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (elo % 100) / 100,
              backgroundColor: isDark ?Colors.white.withValues(alpha: 0.2) :const Color.fromARGB(255, 168, 168, 168),
              valueColor:  AlwaysStoppedAnimation<Color>(isDark ? Colors.white : Colors.black87),
              minHeight: 10,
            ),
          ),
        if (index < 22 && showBar)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "Elo Progress",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                Text("${elo % 100}/100",
                    style:  TextStyle(color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        if (index > 21 && showBar)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Top #$rank",
                  style: const TextStyle(color: Colors.white, fontSize: 30)),
            ],
          )
      ],
    );
  }
}
