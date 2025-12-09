import 'package:flutter/material.dart';
import '/login/LoginScreen.dart';
import '/utils/getData.dart';
import '/widgets/text.dart';

void showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const BigText(text: 'Duýduruş!'),
        content: const SmallText(text: "Telefon belgiňizi giriziň."),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

showPostDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    title: const BigText(text: 'Duýduruş!'),
    content: const SmallText(text: "Maglumatlary doly giriziň!"),
    actions: [okButton],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showPhoneNumberDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    },
  );
  AlertDialog alert = AlertDialog(
    title: const BigText(text: 'Duýduruş!'),
    content: const SmallText(text: "Telefon belgiňizi doly giriziň."),
    actions: [okButton],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showDeleteDialog(BuildContext context, String query, String id) {
  Widget okButton = TextButton(
    child: const Text("Hawa"),
    onPressed: () {
      deleteData(query, id);
      Navigator.pop(context);
    },
  );
  Widget noButton = TextButton(
    child: const Text("Ýok"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    title: const BigText(text: 'Duýduruş!'),
    content: const SmallText(text: "Siz çyndan hem öçürmek isleýärsiňizmi?"),
    actions: [okButton, noButton],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const BigText(text: 'Ýalňyşlyk'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          content: SmallText(text: message),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}

final snackBarFunc = SnackBar(
  content: const Row(
    children: [
      Icon(Icons.check_circle, color: Colors.green),
      SizedBox(width: 10),
      Text('Haryt üstünlikli goşuldy!', style: TextStyle(color: Colors.black)),
    ],
  ),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  dismissDirection: DismissDirection.startToEnd,
  showCloseIcon: true,
  backgroundColor: Colors.white,
  duration: const Duration(seconds: 2),
  closeIconColor: Colors.grey,
  behavior: SnackBarBehavior.floating,
  margin: const EdgeInsets.all(20),
  elevation: 0,
  padding: const EdgeInsets.all(20),
);
