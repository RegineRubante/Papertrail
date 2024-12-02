import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextButton myButton(String label) {
  return TextButton(
    onPressed: () {},
    child: Text(
      label,
      style: const TextStyle(color: Color.fromARGB(255, 6, 6, 6)),
    ),
  );
}

Container myButton2(BuildContext context, String label, VoidCallback onTap) {
  return Container(
    height: 50,
    width: 200,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 0, 53, 107),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Container myTextform(
    IconData icon, String label, bool obscure, bool isPassword, VoidCallback onVisible, {required TextEditingController controller, List<TextInputFormatter>? inputFormatters, required String? Function(dynamic value) validator}) {
  return Container(
    height: 60,
    width: 400,
    child: TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: onVisible,
              )
            : null,
      ),
    ),
  );
}

GestureDetector logoWidget(String fName, double height, double width) {
  return GestureDetector(
    child: Image.asset(
      fName,
      height: height,
      width: width,
    ),
  );
}
