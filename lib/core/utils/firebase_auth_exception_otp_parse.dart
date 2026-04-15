class FirebaseAuthExceptionOtpParse {
  static String parseExceptionCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan credential yang berbeda';
      case 'invalid-credential':
        return 'Credential tidak valid';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'user-disabled':
        return 'User dinonaktifkan';
      case 'user-not-found':
        return 'User tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-verification-code':
        return 'Kode verifikasi tidak valid';
      case 'invalid-verification-id':
        return 'ID verifikasi tidak valid';
      case 'session-expired':
        return 'Kode OTP sudah kadaluarsa';
      default:
        return 'Terjadi kesalahan';
    }
  }
}
