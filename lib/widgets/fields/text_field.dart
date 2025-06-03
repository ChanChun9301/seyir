import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    super.key,
    required this.ctr,
    required this.text,
    required this.validate,
  });

  final TextEditingController ctr;
  final String text;
  final bool validate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(99, 99, 99, 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      height: 30,
      child: TextField(
        controller: ctr,
        maxLines: 1,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.white38),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.green),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          focusColor: Colors.green[600],
          fillColor: Theme.of(context).colorScheme.primaryContainer,
          errorText: validate ? "Setiri dolduruň!" : null,
          labelText: text,
          // hintText:_phoneNumber.get(1),
          labelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
