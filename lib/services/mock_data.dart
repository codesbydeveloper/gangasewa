import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/devotee.dart';
import '../models/pandit.dart';
import '../models/payment_method.dart';
import '../models/puja_service.dart';
import '../models/video_recording.dart';
import '../models/wallet.dart';

class MockData {
  MockData._();

  static final pandit = Pandit(
    id: 'p1',
    name: 'Pandit Rajesh Sharma',
    phone: '9876543221',
    email: 'rajesh.sharma@ganagaseva.in',
    photoUrl: null,
    isVerified: true,
    experienceYears: 18,
    specialization: 'Vedic Rituals & Griha Sanskar',
    languages: const ['Hindi', 'Sanskrit', 'Gujarati', 'English'],
    location: 'Ahmedabad, Gujarat',
    templeAffiliation: 'Shree Somnath Mandir Trust',
    biography:
        'Experienced Vedic Pandit specializing in Satyanarayan Katha, Rudrabhishek, Griha Pravesh and Navgraha Shanti. Dedicated to authentic seva with devotion and precision.',
    gotra: 'Bharadwaj',
    verificationStatus: VerificationStatus.approved,
  );

  static final devotees = [
    const Devotee(
      id: 'd1',
      name: 'Rahul Mehta',
      phone: '9812345678',
      email: 'rahul.mehta@email.com',
      gotra: 'Kashyap',
      nakshatra: 'Rohini',
      rashi: 'Vrishabh',
      familyMembers: ['Anita Mehta', 'Kabir Mehta'],
      address: 'Bodakdev, Ahmedabad',
    ),
    const Devotee(
      id: 'd2',
      name: 'Priya Shah',
      phone: '9823456789',
      email: 'priya.shah@email.com',
      gotra: 'Vashishtha',
      nakshatra: 'Ashwini',
      rashi: 'Mesh',
      familyMembers: ['Vikram Shah', 'Riya Shah'],
      address: 'Satellite, Ahmedabad',
    ),
    const Devotee(
      id: 'd3',
      name: 'Amit Patel',
      phone: '9834567890',
      gotra: 'Gautam',
      nakshatra: 'Punarvasu',
      rashi: 'Mithun',
      familyMembers: ['Neha Patel'],
      address: 'Navrangpura, Ahmedabad',
    ),
    const Devotee(
      id: 'd4',
      name: 'Neha Sharma',
      phone: '9845678901',
      email: 'neha.s@email.com',
      gotra: 'Bharadwaj',
      nakshatra: 'Hasta',
      rashi: 'Kanya',
      familyMembers: ['Suresh Sharma', 'Meera Sharma'],
      address: 'CG Road, Ahmedabad',
    ),
  ];

  static DateTime _todayAt(int h, [int m = 0]) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, h, m);
  }

  static List<Booking> get bookings {
    final now = DateTime.now();
    return [
      Booking(
        id: 'b1',
        bookingNumber: 'GS-10254',
        pujaName: 'Satyanarayan Katha',
        pujaType: 'Home Puja',
        devotee: devotees[0],
        scheduledAt: _todayAt(10, 0),
        duration: const Duration(hours: 2),
        location: 'Bodakdev, Ahmedabad',
        address: '12, Shanti Villa, Bodakdev',
        amount: 5500,
        platformFee: 275,
        status: BookingStatus.upcoming,
        samagri: const ['Banana', 'Tulsi', 'Panchamrit', 'Kalash', 'Coconut'],
        specialInstructions: 'Please bring sacred books for Katha.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Booking(
        id: 'b2',
        bookingNumber: 'GS-10255',
        pujaName: 'Ganesh Puja',
        pujaType: 'Home Puja',
        devotee: devotees[1],
        scheduledAt: _todayAt(16, 30),
        duration: const Duration(hours: 1, minutes: 30),
        location: 'Satellite, Ahmedabad',
        amount: 3500,
        platformFee: 175,
        status: BookingStatus.inProgress,
        samagri: const ['Modak', 'Durva', 'Red flowers', 'Ladoo'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 'b3',
        bookingNumber: 'GS-10256',
        pujaName: 'Rudrabhishek',
        pujaType: 'Temple Puja',
        devotee: devotees[2],
        scheduledAt: now.add(const Duration(days: 1, hours: 8)),
        duration: const Duration(hours: 2),
        location: 'Somnath Temple',
        amount: 7500,
        platformFee: 375,
        status: BookingStatus.accepted,
        samagri: const ['Bel Patra', 'Milk', 'Gangajal', 'Rudraksha'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'b4',
        bookingNumber: 'GS-10257',
        pujaName: 'Griha Pravesh',
        pujaType: 'Home Ceremony',
        devotee: devotees[3],
        scheduledAt: now.add(const Duration(days: 2, hours: 9)),
        duration: const Duration(hours: 3),
        location: 'CG Road, Ahmedabad',
        amount: 12000,
        platformFee: 600,
        status: BookingStatus.pending,
        samagri: const ['Havan samagri', 'Kalash', 'Mango leaves', 'Cow dung cakes'],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Booking(
        id: 'b5',
        bookingNumber: 'GS-10240',
        pujaName: 'Navgraha Puja',
        pujaType: 'Home Puja',
        devotee: devotees[0],
        scheduledAt: now.subtract(const Duration(days: 2)),
        duration: const Duration(hours: 2, minutes: 30),
        location: 'Bodakdev, Ahmedabad',
        amount: 8500,
        platformFee: 425,
        status: BookingStatus.completed,
        samagri: const ['Navgraha idols', 'Til', 'Jaggery'],
        videoId: 'v1',
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 'b6',
        bookingNumber: 'GS-10238',
        pujaName: 'Maha Mrityunjaya Jaap',
        pujaType: 'Special Jaap',
        devotee: devotees[1],
        scheduledAt: now.subtract(const Duration(days: 5)),
        duration: const Duration(hours: 1),
        location: 'Online / Live',
        amount: 4500,
        platformFee: 225,
        status: BookingStatus.completed,
        videoId: 'v2',
        createdAt: now.subtract(const Duration(days: 8)),
        completedAt: now.subtract(const Duration(days: 5)),
      ),
      Booking(
        id: 'b7',
        bookingNumber: 'GS-10230',
        pujaName: 'Lakshmi Puja',
        pujaType: 'Home Puja',
        devotee: devotees[2],
        scheduledAt: now.subtract(const Duration(days: 10)),
        duration: const Duration(hours: 1, minutes: 30),
        location: 'Navrangpura',
        amount: 4000,
        platformFee: 200,
        status: BookingStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  static const wallet = Wallet(
    availableBalance: 72450,
    pendingBalance: 12500,
    totalEarnings: 486200,
    thisMonthEarnings: 48500,
    monthGrowthPercent: 12.5,
  );

  static List<WalletTransaction> get transactions {
    final now = DateTime.now();
    return [
      WalletTransaction(
        id: 't1',
        title: 'Puja Completed',
        description: 'Navgraha Puja — Rahul Mehta',
        bookingId: 'GS-10240',
        date: now.subtract(const Duration(days: 2, hours: 3)),
        amount: 8500,
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        paymentMethod: 'UPI',
        settlementDate: now.subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 't2',
        title: 'Withdrawal',
        description: 'To HDFC Bank •••• 4521',
        date: now.subtract(const Duration(days: 3)),
        amount: 20000,
        type: TransactionType.withdrawal,
        status: TransactionStatus.completed,
        paymentMethod: 'Bank Transfer',
        settlementDate: now.subtract(const Duration(days: 2)),
      ),
      WalletTransaction(
        id: 't3',
        title: 'Puja Completed',
        description: 'Maha Mrityunjaya Jaap — Priya Shah',
        bookingId: 'GS-10238',
        date: now.subtract(const Duration(days: 5)),
        amount: 4500,
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        paymentMethod: 'UPI',
      ),
      WalletTransaction(
        id: 't4',
        title: 'Platform Fee',
        description: 'Service fee deduction',
        bookingId: 'GS-10238',
        date: now.subtract(const Duration(days: 5)),
        amount: 225,
        type: TransactionType.debit,
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: 't5',
        title: 'Pending Settlement',
        description: 'Satyanarayan Katha',
        bookingId: 'GS-10254',
        date: now.subtract(const Duration(hours: 6)),
        amount: 5225,
        type: TransactionType.credit,
        status: TransactionStatus.pending,
        paymentMethod: 'UPI',
      ),
      WalletTransaction(
        id: 't6',
        title: 'Refund',
        description: 'Cancelled booking GS-10230',
        bookingId: 'GS-10230',
        date: now.subtract(const Duration(days: 9)),
        amount: 400,
        type: TransactionType.refund,
        status: TransactionStatus.completed,
      ),
    ];
  }

  static List<VideoRecording> get videos {
    final now = DateTime.now();
    return [
      VideoRecording(
        id: 'v1',
        bookingId: 'b5',
        bookingNumber: 'GS-10240',
        pujaName: 'Navgraha Puja',
        devoteeName: 'Rahul Mehta',
        duration: const Duration(minutes: 42, seconds: 15),
        recordedAt: now.subtract(const Duration(days: 2)),
        uploadStatus: VideoUploadStatus.uploaded,
        uploadProgress: 1,
        isPrivate: true,
      ),
      VideoRecording(
        id: 'v2',
        bookingId: 'b6',
        bookingNumber: 'GS-10238',
        pujaName: 'Maha Mrityunjaya Jaap',
        devoteeName: 'Priya Shah',
        duration: const Duration(minutes: 28, seconds: 40),
        recordedAt: now.subtract(const Duration(days: 5)),
        uploadStatus: VideoUploadStatus.uploaded,
        uploadProgress: 1,
        isPrivate: true,
      ),
      VideoRecording(
        id: 'v3',
        bookingId: 'b2',
        bookingNumber: 'GS-10255',
        pujaName: 'Ganesh Puja',
        devoteeName: 'Priya Shah',
        duration: const Duration(minutes: 12, seconds: 5),
        recordedAt: now.subtract(const Duration(hours: 1)),
        uploadStatus: VideoUploadStatus.local,
        uploadProgress: 0,
        isPrivate: true,
      ),
    ];
  }

  static final paymentMethods = [
    const PaymentMethod(
      id: 'pm1',
      type: PaymentMethodType.bankAccount,
      displayName: 'HDFC Bank',
      maskedDetail: '•••• 4521',
      isPrimary: true,
      accountHolder: 'Rajesh Sharma',
      bankName: 'HDFC Bank',
      ifsc: 'HDFC0001234',
      branch: 'Bodakdev',
    ),
    const PaymentMethod(
      id: 'pm2',
      type: PaymentMethodType.upi,
      displayName: 'UPI',
      maskedDetail: 'raje****@upi',
      isPrimary: false,
      upiId: 'rajeshsharma@upi',
    ),
  ];

  static final services = [
    const PujaService(
      id: 's1',
      name: 'Satyanarayan Katha',
      description: 'Complete Satyanarayan Katha with prasad distribution guidance.',
      category: 'Katha',
      duration: Duration(hours: 2),
      price: 5500,
      requiredSamagri: ['Banana', 'Tulsi', 'Panchamrit', 'Kalash'],
      isActive: true,
    ),
    const PujaService(
      id: 's2',
      name: 'Rudrabhishek',
      description: 'Traditional Rudrabhishek for Lord Shiva.',
      category: 'Abhishek',
      duration: Duration(hours: 2),
      price: 7500,
      requiredSamagri: ['Bel Patra', 'Milk', 'Gangajal'],
      isActive: true,
    ),
    const PujaService(
      id: 's3',
      name: 'Ganesh Puja',
      description: 'Ganesh sthapana and aarti for new beginnings.',
      category: 'Puja',
      duration: Duration(hours: 1, minutes: 30),
      price: 3500,
      isActive: true,
    ),
    const PujaService(
      id: 's4',
      name: 'Griha Pravesh',
      description: 'Vastu-aligned Griha Pravesh ceremony.',
      category: 'Sanskar',
      duration: Duration(hours: 3),
      price: 12000,
      isActive: true,
    ),
    const PujaService(
      id: 's5',
      name: 'Navgraha Puja',
      description: 'Navgraha shanti for planetary balance.',
      category: 'Shanti',
      duration: Duration(hours: 2, minutes: 30),
      price: 8500,
      isActive: false,
    ),
  ];

  static List<AppNotification> get notifications {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'New puja booking received',
        body: 'Griha Pravesh from Neha Sharma — GS-10257',
        category: NotificationCategory.booking,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'n2',
        title: 'Payment of ₹8,500 credited',
        body: 'Navgraha Puja settlement completed',
        category: NotificationCategory.payment,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'n3',
        title: 'Video upload completed',
        body: 'Recording for GS-10240 is ready',
        category: NotificationCategory.video,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'Booking starts in 30 minutes',
        body: 'Satyanarayan Katha with Rahul Mehta',
        category: NotificationCategory.booking,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      AppNotification(
        id: 'n5',
        title: 'Profile verified',
        body: 'Your Pandit profile is now verified',
        category: NotificationCategory.system,
        createdAt: now.subtract(const Duration(days: 15)),
        isRead: true,
      ),
    ];
  }
}
