import 'package:flutter/material.dart';

class SliderDialog extends StatefulWidget {
  final String title;
  final int divisions;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double>? onChanged;
  final Stream<double>? stream;

  const SliderDialog({
    Key? key,
    required this.title,
    required this.divisions,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.stream,
    required BuildContext context,
  }) : super(key: key);

  @override
  _SliderDialogState createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    widget.stream?.listen((value) {
      setState(() {
        _currentValue = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: widget.onChanged,
          ),
          Text('Current Value: $_currentValue'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  required double value,
  required ValueChanged<double>? onChanged,
  required Stream<double>? stream,
}) {
  showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return SliderDialog(
        title: title,
        divisions: divisions,
        min: min,
        max: max,
        value: value,
        onChanged: onChanged,
        stream: stream, context: context,
      );
    },
  );
}
