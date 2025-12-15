//validation helpers - reusable rules for forms (login / signup)

class Validator {

  //check if email is empty + valid format
  static String? validateEmail(String? value) {
    final email = (value ?? "").trim();

    //email required
    if (email.isEmpty) {
      return "Email is required";
    }

    //email format check
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email";
    }
    return null;
  }

  //check if password is empty + minimum length
  static String? validatePassword(String? value) {
    final password = value ?? "";

    //password required
    if (password.isEmpty) {
      return "Password is required";
    }

    //firebase requires at least 6 characters
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  //check confirm password field
  static String? validateConfirmPassword({
    required String? confirmValue,
    required String passwordValue,
  }) {
    final confirm = confirmValue ?? "";

    //confirm password required
    if (confirm.isEmpty) {
      return "Please confirm your password";
    }

    //passwords must match
    if (confirm != passwordValue) {
      return "Passwords do not match";
    }
    return null;
  }
}
