class EncryptionHelper {
  // Simple Caesar cipher for demonstration (shift by 3)
  // In a real app, use a package like 'encrypt' with AES.
  
  static String encrypt(String text) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      buffer.writeCharCode(charCode + 3);
    }
    return buffer.toString();
  }

  static String decrypt(String text) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      buffer.writeCharCode(charCode - 3);
    }
    return buffer.toString();
  }
}
