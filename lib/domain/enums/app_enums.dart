enum AppRole { user, provider }

enum Gender { male, female, other }

enum JobStatus { newRequest, underReview, accepted, inProgress, completed, cancelled }

enum BookingStatus { booked, pending, completed, cancelled }

enum PaymentMethod { card, mobileTransfer }

enum TransactionType { credit, debit }

enum TransactionStatus { pending, complete, failed }

enum NotificationType {
  message,
  jobOffer,
  upcomingBooking,
  bookingConfirmed,
  paymentReceived,
  serviceUpdate
}

String enumToString(Object e) => e.toString().split('.').last;

T enumFromString<T>(List<T> values, String raw, T fallback) {
  for (final v in values) {
    if (enumToString(v as Object) == raw) return v;
  }
  return fallback;
}
