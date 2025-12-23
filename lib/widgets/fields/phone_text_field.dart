import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneTextFieldCustom extends StatelessWidget {
  const PhoneTextFieldCustom({
    super.key,
    required this.ctr,
    required this.validate,
  });

  final TextEditingController ctr;
  final bool validate;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
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
      width: w / 2.2,
      height: 50,
      child: TextField(
        controller: ctr,
        maxLines: 1,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12,
          fontFamily: 'Bricolage',
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [LengthLimitingTextInputFormatter(11)],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          prefixIcon: Icon(
            CupertinoIcons.phone,
            size: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
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
          errorText: validate ? "Telefon belgini dolduruň!" : null,
          labelText: 'Telefon belgi',
          hintText: '993',
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
