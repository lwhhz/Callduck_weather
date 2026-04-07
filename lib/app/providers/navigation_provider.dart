import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationController extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setPageIndex(int index) {
    state = index;
  }
}

final navigationControllerProvider = NotifierProvider<NavigationController, int>(() {
  return NavigationController();
});
