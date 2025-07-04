import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/responsive_helper.dart';
import 'main_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  bool _isSettingPin = false;
  String _confirmPin = '';
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final hasPIN = await provider.hasPIN();
    setState(() {
      _isSettingPin = !hasPIN;
    });
  }

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      
      if (_pin.length == 4) {
        _handlePinComplete();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handlePinComplete() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (_isSettingPin) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        if (_pin == _confirmPin) {
          final context = this.context;
          final success = await provider.setPIN(_pin);
          if (success && mounted) {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            }
          } else {
            _showError('El PIN debe tener 4 dígitos');
            _resetPin();
          }
        } else {
          _showError('Los PINs no coinciden');
          _resetPin();
        }
      }
    } else {
      final context = this.context;
      final success = await provider.verifyPIN(_pin);
      if (success && mounted) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      } else {
        final attempts = await provider.getRemainingAttempts();
        _showError('PIN incorrecto. Quedan $attempts intentos');
        setState(() {
          _pin = '';
        });
      }
    }
  }

  void _resetPin() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirming = false;
    });
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSettingPin 
          ? (_isConfirming ? 'Confirmar PIN' : 'Configurar PIN') 
          : 'Introducir PIN'),
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPinIndicator(context),
          SizedBox(height: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 50,
            tablet: 60,
            desktop: 70,
          )),
          _buildPinKeyboard(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Container(
        width: ResponsiveHelper.getCardWidth(context),
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPinIndicator(context),
              SizedBox(height: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 50,
                tablet: 60,
                desktop: 70,
              )),
              _buildPinKeyboard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        child: Container(
          width: 500,
          padding: EdgeInsets.all(40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isSettingPin 
                    ? (_isConfirming ? 'Confirmar PIN' : 'Configurar PIN') 
                    : 'Introducir PIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                _buildPinIndicator(context),
                SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: _buildPinKeyboard(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinIndicator(BuildContext context) {
    final dotSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) => 
        Container(
          margin: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 8.0,
            tablet: 12.0,
            desktop: 16.0,
          )),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length ? Colors.blue : Colors.grey.shade300,
          ),
        )
      ),
    );
  }

  Widget _buildPinKeyboard(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getGridColumns(context);
    final aspectRatio = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 1.5,
      tablet: 1.3,
      desktop: 1.2,
    );
    
    List<Widget> keyboardButtons = [];
    
    for (int i = 1; i <= 9; i++) {
      keyboardButtons.add(_buildNumberButton(i.toString()));
    }
    
    if (crossAxisCount == 3) {
      keyboardButtons.add(_buildNumberButton(''));
      keyboardButtons.add(_buildNumberButton('0'));
      keyboardButtons.add(_buildActionButton(Icons.backspace, _removeDigit));
    } else if (crossAxisCount == 4) {
      keyboardButtons.add(_buildNumberButton(''));
      keyboardButtons.add(_buildNumberButton('0'));
      keyboardButtons.add(_buildActionButton(Icons.backspace, _removeDigit));
      keyboardButtons.add(_buildNumberButton(''));
    }
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: keyboardButtons,
    );
  }

  Widget _buildNumberButton(String number) {
    if (number.isEmpty) return Container();
    
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 24);
    final padding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () => _addDigit(number),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(padding),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Text(
          number, 
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    final iconSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final padding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(padding),
          backgroundColor: Colors.grey[600],
          foregroundColor: Colors.white,
        ),
        child: Icon(
          icon, 
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}