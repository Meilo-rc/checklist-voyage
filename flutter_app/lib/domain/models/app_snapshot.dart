class AppSnapshot {
  const AppSnapshot({
    required this.tripCount,
    required this.libraryOwnerCount,
    required this.libraryItemCount,
    required this.quickListCount,
  });

  final int tripCount;
  final int libraryOwnerCount;
  final int libraryItemCount;
  final int quickListCount;
}
