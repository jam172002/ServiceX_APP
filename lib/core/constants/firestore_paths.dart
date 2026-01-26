class FirestorePaths {
  FirestorePaths._();

  static const users = 'users';
  static const providers = 'providers';
  static const categories = 'categories';
  static const jobRequests = 'job_requests';
  static const bookings = 'bookings';
  static const chatRooms = 'chat_rooms';
  static const messages = 'messages'; // subcollection under chat_rooms/{roomId}/messages
  static const wallets = 'wallets';
  static const transactions = 'transactions';
  static const paymentCards = 'payment_cards';
  static const notifications = 'notifications';

  static String userDoc(String userId) => '$users/$userId';
  static String providerDoc(String providerId) => '$providers/$providerId';
  static String categoryDoc(String categoryId) => '$categories/$categoryId';
  static String jobDoc(String jobId) => '$jobRequests/$jobId';
  static String bookingDoc(String bookingId) => '$bookings/$bookingId';
  static String chatRoomDoc(String roomId) => '$chatRooms/$roomId';
  static String walletDoc(String userId) => '$wallets/$userId';
  static String transactionDoc(String txId) => '$transactions/$txId';
  static String paymentCardDoc(String cardId) => '$paymentCards/$cardId';
  static String notificationDoc(String notifId) => '$notifications/$notifId';

  static String chatRoomMessagesCol(String roomId) => '$chatRooms/$roomId/$messages';
}
