class Payment {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String? cardLast4;
  final String? transactionId;
  final String status;
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.cardLast4,
    this.transactionId,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      cardLast4: json['card_last_4'],
      transactionId: json['transaction_id'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'card_last_4': cardLast4,
      'transaction_id': transactionId,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helpers
  String get displayAmount => '\$${amount.toStringAsFixed(2)}';
  
  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'cash': return '💵 Efectivo';
      case 'card': return '💳 Tarjeta';
      case 'yappy': return '📱 Yappy';
      case 'nequi': return '📱 Nequi';
      case 'bank_transfer': return '🏦 Transferencia';
      case 'paypal': return '💰 PayPal';
      default: return '💳 $paymentMethod';
    }
  }
  
  String get statusDisplay {
    switch (status) {
      case 'completed': return '✅ Completado';
      case 'pending': return '⏳ Pendiente';
      case 'failed': return '❌ Fallido';
      case 'refunded': return '↩️ Reembolsado';
      default: return status;
    }
  }
}
