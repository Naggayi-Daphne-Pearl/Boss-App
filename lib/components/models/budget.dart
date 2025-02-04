class Budget {
  final String category;
  double limit;
  final double spent;
  final String currency;

  Budget({
    required this.category,
    required this.limit,
    this.spent = 0.0,
    this.currency = 'UGX',
  });
}
