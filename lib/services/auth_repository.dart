import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/pandit.dart';
import 'mock_data.dart';

enum AuthStep { splash, onboarding, login, verified }

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool hasSeenOnboarding;
  final String? phone;
  final Pandit? pandit;
  final String? error;
  final bool isNewUser;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.hasSeenOnboarding = false,
    this.phone,
    this.pandit,
    this.error,
    this.isNewUser = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? hasSeenOnboarding,
    String? phone,
    Pandit? pandit,
    String? error,
    bool? isNewUser,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      phone: phone ?? this.phone,
      pandit: pandit ?? this.pandit,
      error: clearError ? null : (error ?? this.error),
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class AuthRepository extends StateNotifier<AuthState> {
  AuthRepository(this._storage) : super(const AuthState()) {
    _bootstrap();
  }

  final FlutterSecureStorage _storage;
  static const _keyAuth = 'gs_auth';
  static const _keyOnboarding = 'gs_onboarding';
  static const _keyPhone = 'gs_phone';

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    try {
      final onboarding = await _storage.read(key: _keyOnboarding);
      final auth = await _storage.read(key: _keyAuth);
      final phone = await _storage.read(key: _keyPhone);
      state = state.copyWith(
        isLoading: false,
        hasSeenOnboarding: onboarding == '1',
        isAuthenticated: auth == '1',
        phone: phone,
        pandit: auth == '1' ? MockData.pandit : null,
      );
    } catch (_) {
      // Secure storage can fail on some web/desktop setups; continue as guest.
      state = state.copyWith(isLoading: false, hasSeenOnboarding: false);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _storage.write(key: _keyOnboarding, value: '1');
    } catch (_) {}
    state = state.copyWith(hasSeenOnboarding: true);
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true, phone: phone);
    await Future.delayed(const Duration(milliseconds: 800));
    if (phone.length != 10) {
      state = state.copyWith(isLoading: false, error: 'Enter a valid 10-digit mobile number');
      return false;
    }
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (otp != AppConstants.mockOtp) {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Use 123456 for demo.');
      return false;
    }
    final isNew = state.phone != MockData.pandit.phone;
    try {
      await _storage.write(key: _keyAuth, value: '1');
      await _storage.write(key: _keyPhone, value: state.phone);
    } catch (_) {}
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      isNewUser: isNew,
      pandit: isNew
          ? MockData.pandit.copyWith(
              phone: state.phone ?? '',
              name: '',
              isVerified: false,
              verificationStatus: VerificationStatus.pending,
            )
          : MockData.pandit,
    );
    return true;
  }

  Future<void> completeProfileSetup(Pandit pandit) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 700));
    state = state.copyWith(
      isLoading: false,
      pandit: pandit.copyWith(
        verificationStatus: VerificationStatus.pending,
        isVerified: false,
      ),
      isNewUser: false,
    );
  }

  Future<void> approveVerification() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final p = state.pandit;
    if (p == null) return;
    state = state.copyWith(
      pandit: p.copyWith(
        isVerified: true,
        verificationStatus: VerificationStatus.approved,
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: _keyAuth);
    } catch (_) {}
    state = AuthState(hasSeenOnboarding: state.hasSeenOnboarding);
  }
}

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRepositoryProvider =
    StateNotifierProvider<AuthRepository, AuthState>((ref) {
  return AuthRepository(ref.watch(secureStorageProvider));
});
