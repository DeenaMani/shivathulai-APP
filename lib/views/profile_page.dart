import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shivathuli/services/FontSizeProvider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => FontSizeSettingsSheet(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          '''நமச்சிவாய வாஅழ்க! நாதன் தாள் வாழ்க!
இமமப் பபாழுதும் என் பநஞ்சில் நீங்காதான் தாள் வாழ்க!
ககாகழி ஆண்ட குருமணி தன் தாள் வாழ்க!
ஆகமம் ஆகிநின்று அண்ணிப்பான் தாள் வாழ்க!
ஏகன், அகநகன், இமைவன், அடி வாழ்க! 1
கவகம் பகடுத்து ஆண்ட கவந்தன் அடி பவல்க!
பிைப்பு அறுக்கும் பிஞ்ஞகன் தன் பபய் கழல்கள் பவல்க!
புைத்தார்க்குச் கசகயான் தன் பூம் கழல்கள் பவல்க!
கரம் குவிவார் உள் மகிழும் ககான் கழல்கள் பவல்க!
சிரம் குவிவார் ஓங்குவிக்கும் சீகரான் கழல் பவல்க! ''',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class FontSizeSettingsSheet extends StatefulWidget {
  @override
  State<FontSizeSettingsSheet> createState() => _FontSizeSettingsSheetState();
}

class _FontSizeSettingsSheetState extends State<FontSizeSettingsSheet> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = context.read<FontSizeProvider>().textScale;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Font Size Setting (உரையின் அளவு)'),
          Slider(
            value: _sliderValue,
            min: 0.8,
            max: 1.8,
            divisions: 10,
            label: _sliderValue.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FontSizeProvider>().updateTextScale(_sliderValue);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
