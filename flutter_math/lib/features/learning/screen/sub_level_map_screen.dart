import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // SENSOR BARU
import 'package:flutter_math/features/learning/provider/learning_provider.dart'; // SENSOR BARU
import 'package:flutter_math/features/learning/screen/level_play_screen.dart';

class SubLevelMapScreen extends ConsumerWidget {
  // UBAH MENJADI CONSUMERWIDGET
  final String topicTitle;
  final int topicOrderIndex;

  // actualUserLevel DIHAPUS dari constructor karena akan kita watch secara live!
  const SubLevelMapScreen({
    Key? key,
    required this.topicTitle,
    required this.topicOrderIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TAMBAHKAN WIDGETREF

    // --- PASANG RADAR AKTIF RIVERPOD DI SINI ---
    final unlockedLevelAsyncValue = ref.watch(unlockedLevelProvider);
    final int actualUserLevel = ref.watch(
          unlockedLevelProvider,
        );    // -------------------------------------------

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          topicTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        itemCount: 100,
        itemBuilder: (context, index) {
          final int localLevel = index + 1;
          final int globalLevelOfButton =
              ((topicOrderIndex - 1) * 100) + localLevel;

          final bool isLocked = globalLevelOfButton > actualUserLevel;
          final bool isActive = globalLevelOfButton == actualUserLevel;
          final bool isPassed = globalLevelOfButton < actualUserLevel;

          Alignment alignment;
          if (index % 4 == 0) {
            alignment = Alignment.centerLeft;
          } else if (index % 4 == 1 || index % 4 == 3) {
            alignment = Alignment.center;
          } else {
            alignment = Alignment.centerRight;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Align(
              alignment: alignment,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isLocked) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LevelPlayScreen(level: globalLevelOfButton),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Level ini masih terkunci! Selesaikan level di bawahnya.",
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: isLocked
                          ? Colors.grey[400]
                          : (isActive ? Colors.orange[400] : Colors.green),
                      child: isLocked
                          ? const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 28,
                            )
                          : (isPassed
                                ? const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 32,
                                  )
                                : Text(
                                    '$globalLevelOfButton',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Level $globalLevelOfButton',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
