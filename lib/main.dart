import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  void _onNumber(String digit) {
    setState(() {
      if (_waitingForSecondOperand) {
        _display = digit;
        _waitingForSecondOperand = false;
        return;
      }

      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      if (_operator != null && _waitingForSecondOperand) {
        _operator = op;
        return;
      }

      _firstOperand = double.tryParse(_display) ?? 0.0;
      _operator = op;
      _waitingForSecondOperand = true;
    });
  }

  void _onEquals() {
    setState(() {
      if (_operator == null || _firstOperand == null) return;
      final second = double.tryParse(_display) ?? 0.0;
      double result;
      switch (_operator) {
        case '+':
          result = _firstOperand! + second;
          break;
        case '-':
          result = _firstOperand! - second;
          break;
        case '*':
          result = _firstOperand! * second;
          break;
        case '/':
          if (second == 0) {
            _display = 'Error';
            _clearAfterError();
            return;
          }
          result = _firstOperand! / second;
          break;
        default:
          return;
      }

      _display = _trimResult(result);
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_waitingForSecondOperand) return;
      if (_display == 'Error') {
        _clear();
        return;
      }
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _clearAfterError() {
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
  }

  String _trimResult(double value) {
    final asStr = value.toString();
    if (asStr.contains('e')) return value.toStringAsPrecision(10);
    if (asStr.endsWith('.0')) return asStr.substring(0, asStr.length - 2);
    return value.toStringAsPrecision(12).replaceAll(RegExp(r'\.0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final numberButtons = <_CalcButton>[
      _CalcButton(label: '7', onTap: () => _onNumber('7')),
      _CalcButton(label: '8', onTap: () => _onNumber('8')),
      _CalcButton(label: '9', onTap: () => _onNumber('9')),
      _CalcButton(label: '4', onTap: () => _onNumber('4')),
      _CalcButton(label: '5', onTap: () => _onNumber('5')),
      _CalcButton(label: '6', onTap: () => _onNumber('6')),
      _CalcButton(label: '1', onTap: () => _onNumber('1')),
      _CalcButton(label: '2', onTap: () => _onNumber('2')),
      _CalcButton(label: '3', onTap: () => _onNumber('3')),
      _CalcButton(label: '0', onTap: () => _onNumber('0'), isWide: true),
      _CalcButton(label: '=', onTap: _onEquals, isEquals: true),
    ];

    final sideOps = <_CalcButton>[
      _CalcButton(label: '/', onTap: () => _onOperator('/'), isOperator: true),
      _CalcButton(label: '*', onTap: () => _onOperator('*'), isOperator: true),
      _CalcButton(label: '+', onTap: () => _onOperator('+'), isOperator: true),
      _CalcButton(label: '-', onTap: () => _onOperator('-'), isOperator: true),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Calculator')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  alignment: Alignment.bottomRight,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _display,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildTopButton(
                            _CalcButton(label: 'Clear', onTap: _clear, isUtility: true),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _buildTopButton(
                            _CalcButton(label: 'Delete', onTap: _backspace, isUtility: true),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ButtonsGrid(buttons: numberButtons),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ButtonsGrid(buttons: sideOps),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton(_CalcButton b) {
    final ColorScheme scheme = Colors.indigo.colorScheme;
    Color bg = scheme.secondaryContainer;
    Color fg = scheme.onSecondaryContainer;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: b.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          elevation: 2,
        ),
        child: Text(b.label),
      ),
    );
  }
}

class _ButtonsGrid extends StatelessWidget {
  const _ButtonsGrid({required this.buttons});
  final List<_CalcButton> buttons;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 10;
        final int columns = (buttons.any((b) => b.isWide)) ? 3 : 1; 

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _buildWrappedButtons(constraints.maxWidth, spacing, columns),
        );
      },
    );
  }

  List<Widget> _buildWrappedButtons(double maxWidth, double spacing, int columns) {
    final double cellWidth = (maxWidth - spacing * (columns - 1)) / columns;
    const double height = 64;

    return buttons.map((b) {
      double width = cellWidth;
      if (b.isWide) width = cellWidth * 2 + spacing;

      final ColorScheme scheme = Colors.indigo.colorScheme;
      Color bg = scheme.surface;
      Color fg = scheme.onSurface;
      if (b.isOperator) {
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
      }
      if (b.isUtility) {
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
      }
      if (b.isEquals) {
        bg = scheme.primary;
        fg = scheme.onPrimary;
      }

      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: b.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            elevation: 2,
          ),
          child: Text(b.label),
        ),
      );
    }).toList();
  }
}

class _CalcButton {
  final String label;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isUtility;
  final bool isEquals;
  final bool isWide;

  _CalcButton({
    required this.label,
    required this.onTap,
    this.isOperator = false,
    this.isUtility = false,
    this.isEquals = false,
    this.isWide = false,
  });
}

extension on MaterialColor {
  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: this);
}
