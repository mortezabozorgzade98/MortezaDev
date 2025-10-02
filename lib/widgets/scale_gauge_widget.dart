// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';

class ScaleGaugeWidget extends StatefulWidget {
  const ScaleGaugeWidget({super.key});

  @override
  State<ScaleGaugeWidget> createState() => _ScaleGaugeWidgetState();
}

class _ScaleGaugeWidgetState extends State<ScaleGaugeWidget> {
  RulerPickerController? _rulerPickerController;
  num currentValue = 40;

  final List<RulerRange> ranges = const [
    RulerRange(begin: 0, end: 10, scale: 0.1),
    RulerRange(begin: 10, end: 100, scale: 1),
    RulerRange(begin: 100, end: 1000, scale: 10),
    RulerRange(begin: 1000, end: 10000, scale: 100),
    RulerRange(begin: 10000, end: 100000, scale: 1000),
  ];

  // تابع تبدیل اعداد انگلیسی به فارسی
  String _toPersianNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  @override
  void initState() {
    super.initState();
    _rulerPickerController = RulerPickerController(value: currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // نمایش مقدار انتخاب‌شده با عدد فارسی
          Text(
            'مقدار انتخابی شما:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xff000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _toPersianNumber(currentValue.toInt().toString()),
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Color(0xff8C1007),
              fontFamily: 'YekanBakh',
            ),
          ),

          SizedBox(height: 10),
          // خط‌کش
          RulerPicker(
            controller: _rulerPickerController!,
            rulerBackgroundColor: Color(0xffEEEFE0),
            onBuildRulerScaleText: (index, value) {
              return _toPersianNumber(value.toInt().toString());
            },
            rulerScaleTextStyle: const TextStyle(
              color: Color(0xffC9CDCF),
              fontSize: 16,
              fontFamily: 'YekanBakh',
            ),
            marker: Container(
              height: 40,
              width: 1.5,
              decoration: BoxDecoration(
                color: Color(0xff57564F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
            ranges: ranges,
            scaleLineStyleList: const [
              ScaleLineStyle(
                
                color: Colors.grey,
                width: 1,
                height: 30,
                scale: 0,
              ),
              ScaleLineStyle(
                color: Colors.grey,
                width: 1,
                height: 25,
                scale: 5,
              ),
              ScaleLineStyle(
                color: Colors.grey,
                width: 1,
                height: 15,
                scale: -1,
              ),
            ],
            onValueChanged: (value) {
              setState(() {
                currentValue = value;
              });
            },
            width: MediaQuery.of(context).size.width,
            height: 75,
            rulerMarginTop: 0,
          ),
        ],
      ),
    );
  }
}
