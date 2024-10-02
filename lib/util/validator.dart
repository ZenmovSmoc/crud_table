class Validator {
  Validator();
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a valid password';
    } else if (value.length < 10) {
      return 'Invalid password, please enter more than 10 characters';
    } else if (!value.contains(RegExp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z])'))) {
      return 'Invalid password, must contain at least one uppercase, lowercase alphabets and mixed alphanumeric characters';
    }
    return null;
  }

  static bool validateEmail(String? email) {
    if (email == null) return false;
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
