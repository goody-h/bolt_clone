class DefaultScreenData {
  DefaultScreenData({
    this.isHome,
    this.useDestnaton,
    this.expanded = false,
    this.expandedTransition = false,
  });
  final bool isHome;
  final bool useDestnaton;
  final bool expanded;
  bool get isExanded => !isHome || expanded;
  bool expandedTransition;
}
