class FinanceHistory {
  final Map<String, String> history;

  FinanceHistory({required this.history});

  FinanceHistory copyWith({
    Map<String, String>? history,
  }) {
    return FinanceHistory(
      history: history ?? this.history,
    );
  }
}