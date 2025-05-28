// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
// import 'package:flutter_quill/flutter_quill.dart';

class TextArea extends StatefulWidget {
  const TextArea({
    super.key,
    required this.descCtr,
  });

  final TextEditingController descCtr;

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  // QuillController _controller = QuillController.basic();
  // HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:const  BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(99, 99, 99, 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // HtmlEditor(
          //     controller: controller, //required

          //     htmlEditorOptions: HtmlEditorOptions(
          //       hint: "Your text here...",

          //       mobileContextMenu: ContextMenu(),
          //       //initalText: "text content initial, if any",
          //     ),
          //     otherOptions: OtherOptions(
          //       decoration: BoxDecoration(color: Colors.white),
          //       height: 400,
          //     ),
          //     htmlToolbarOptions: HtmlToolbarOptions(defaultToolbarButtons: [
          //       StyleButtons(),
          //       ParagraphButtons(lineHeight: false, caseConverter: false)
          //     ]))
          // Expanded(
          //   child: QuillEditor.basic(
          //     // controller: _controller,
          //     configurations:
          //         QuillEditorConfigurations(controller: _controller),
          //   ),
          // ),
          TextField(
            controller: widget.descCtr,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
                fontFamily: 'Bricolage'),
            maxLines: 10,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 20, right: 20),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 2, color: Colors.white38),
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 2, color: Colors.green),
                  borderRadius: BorderRadius.circular(8)),
              filled: true,
              focusColor: Colors.white38,
              fillColor: Theme.of(context).colorScheme.primaryContainer,
              labelText: "Maglumatlary...",
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
