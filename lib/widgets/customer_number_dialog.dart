import 'package:flutter/material.dart';

Future<int> showCustomerNumberDialog(BuildContext context) async {
  int result = await showDialog(
      context: context, builder: (context) => CustomerNumberDialog());
  return result;
}

//TODO: Consider to use api instead of typing by human.
class CustomerNumberDialog extends StatefulWidget {
  const CustomerNumberDialog({super.key});

  @override
  State<StatefulWidget> createState() => _CustomerNumberDialogState();
}

class _CustomerNumberDialogState extends State<CustomerNumberDialog> {
  final TextEditingController _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var numberInput = TextField(
      controller: _numberController,
    );

    var dialog = AlertDialog(
      content: numberInput,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, 0),
          child: Text('cancel'),
        ),
        FilledButton(
            onPressed: () => Navigator.pop(
                  context,
                  int.tryParse(_numberController.text),
                ),
            child: Text('Confirm'))
      ],
    );
    return dialog;
  }
}
