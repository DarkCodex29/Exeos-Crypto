import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/crypto_skeleton.dart';
import 'qr_scanner_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadCryptocurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Escáner Crypto'),
            actions: [
              if (!Platform.isWindows)
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    provider.logout();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
            ],
          ),
          body: ResponsiveWidget(
            mobile: _buildMobileLayout(context, provider),
            tablet: _buildTabletLayout(context, provider),
            desktop: _buildDesktopLayout(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppProvider provider) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        children: [
          _buildInputCard(context),
          SizedBox(height: 20),
          Expanded(
            child: _buildCryptoList(provider, context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppProvider provider) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: ResponsiveHelper.isLandscape(context)
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildInputCard(context),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildCryptoList(provider, context),
                ),
              ],
            )
          : Column(
              children: [
                _buildInputCard(context),
                SizedBox(height: 20),
                Expanded(
                  child: _buildCryptoList(provider, context),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppProvider provider) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: _buildInputCard(context),
          ),
          SizedBox(width: 32),
          Expanded(
            child: _buildCryptoList(provider, context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final cardWidth = ResponsiveHelper.getCardWidth(context);
    
    return SizedBox(
      width: ResponsiveHelper.isDesktop(context) ? null : cardWidth,
      child: Card(
        elevation: ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 2.0,
          tablet: 4.0,
          desktop: 8.0,
        ),
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Introducir Código',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ResponsiveHelper.isMobile(context)
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _processCode(_codeController.text),
                            child: Text('Enviar'),
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openQRScanner(),
                            icon: Icon(Icons.qr_code_scanner),
                            label: Text('Escanear QR'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _processCode(_codeController.text),
                            child: Text('Enviar'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openQRScanner(),
                            icon: Icon(Icons.qr_code_scanner),
                            label: Text('Escanear QR'),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoList(AppProvider provider, BuildContext context) {
    if (provider.isLoading) {
      final columns = ResponsiveHelper.getCryptoListColumns(context);
      return CryptoSkeleton(
        itemCount: 3,
        isGridView: columns > 1,
      );
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: ResponsiveHelper.getResponsiveValue(
                context,
                mobile: 64.0,
                tablet: 80.0,
                desktop: 96.0,
              ),
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadCryptocurrencies(),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final columns = ResponsiveHelper.getCryptoListColumns(context);
    
    if (columns == 1) {
      return ListView.builder(
        itemCount: provider.cryptocurrencies.length,
        itemBuilder: (context, index) {
          final crypto = provider.cryptocurrencies[index];
          return _buildCryptoCard(crypto, context);
        },
      );
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 1.0,
            tablet: 1.2,
            desktop: 1.5,
          ),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.cryptocurrencies.length,
        itemBuilder: (context, index) {
          final crypto = provider.cryptocurrencies[index];
          return _buildCryptoCard(crypto, context);
        },
      );
    }
  }

  Widget _buildCryptoCard(crypto, BuildContext context) {
    final avatarRadius = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);
    final priceFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    
    return Card(
      elevation: ResponsiveHelper.getResponsiveValue(
        context,
        mobile: 2.0,
        tablet: 4.0,
        desktop: 6.0,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        )),
        child: ResponsiveHelper.isDesktop(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: NetworkImage(crypto.image),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crypto.name,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              crypto.symbol.toUpperCase(),
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${crypto.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: crypto.priceChangePercentage24h >= 0 
                            ? Colors.green 
                            : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : ListTile(
                leading: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: NetworkImage(crypto.image),
                ),
                title: Text(
                  crypto.name,
                  style: TextStyle(fontSize: titleFontSize),
                ),
                subtitle: Text(
                  crypto.symbol.toUpperCase(),
                  style: TextStyle(fontSize: subtitleFontSize),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${crypto.currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: crypto.priceChangePercentage24h >= 0 
                          ? Colors.green 
                          : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _processCode(String code) {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor introduce un código')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Procesando código: $code')),
    );
    
    Provider.of<AppProvider>(context, listen: false).loadCryptocurrencies();
  }

  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );
    
    if (result != null) {
      _codeController.text = result;
    }
  }
}