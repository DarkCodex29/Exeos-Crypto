# Escáner Crypto

Aplicación Flutter para escaneo de códigos QR y visualización de precios de criptomonedas con soporte multiplataforma para Android y Windows.

## Características

### Android/iOS

- **Escáner QR**: Escanea códigos QR usando la cámara del dispositivo
- **Entrada Manual**: Introduce códigos manualmente si es necesario
- **Visualización de Criptomonedas**: Muestra información de criptomonedas desde la API de CoinGecko
- **Autenticación PIN**: PIN seguro de 4 dígitos con máximo 3 intentos
- **Diseño Responsive**: Optimizado para dispositivos móviles

### Windows (Arquitectura de Bandeja del Sistema)

- **Proceso de Bandeja del Sistema**: Se ejecuta en segundo plano con icono en la bandeja del sistema
- **Menú Contextual**: Click derecho en el icono muestra la opción "Mostrar UI"
- **Flujo PIN**: Al hacer clic en "Mostrar UI" se abre la autenticación PIN
- **UI Completa**: Después del PIN, acceso a la interfaz completa del escáner de criptomonedas
- **Controles de Ventana**: La ventana PIN incluye botones minimizar, maximizar, cerrar

## Arquitectura

### Móvil (Android/iOS)

- Proceso único: PIN → Pantalla Principal
- Flujo estándar de aplicación móvil

### Windows

- Ejecutable único con integración de bandeja del sistema
- Proceso de bandeja en segundo plano con ventana oculta
- Click en icono de bandeja → Abre autenticación PIN
- PIN → Pantalla Principal (misma funcionalidad que móvil)

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada Android/iOS
├── tray_main.dart           # Punto de entrada bandeja del sistema Windows
├── models/
│   └── cryptocurrency.dart  # Modelo de datos de criptomoneda
├── providers/
│   └── app_provider.dart    # Gestión de estado
├── screens/
│   ├── pin_screen.dart      # Autenticación PIN
│   ├── main_screen.dart     # Interfaz principal de la aplicación
│   └── qr_scanner_screen.dart # Escáner de códigos QR
├── services/
│   ├── api_service.dart     # Integración API CoinGecko
│   └── auth_service.dart    # Servicio de autenticación PIN
├── utils/
│   └── responsive_helper.dart # Utilidades de diseño responsive
└── widgets/
    └── crypto_skeleton.dart  # Widget de esqueleto de carga
```

## Instalación

### Prerequisitos

- Flutter SDK (3.0.0 o superior)
- Dart SDK (3.0.0 o superior)
- Android SDK (para compilaciones Android)
- Visual Studio Build Tools (para compilaciones Windows)

### Configuración

1. Clonar el repositorio:

```bash
git clone https://github.com/DarkCodex29/Exeos-Crypto
cd Exeos-Crypto
```

2. Instalar dependencias:

```bash
flutter pub get
```

3. Habilitar Windows desktop (si compilas para Windows):

```bash
flutter config --enable-windows-desktop
```

## Compilación y Ejecución

### Android

```bash
# Desarrollo
flutter run -d android

# APK de producción
flutter build apk --release
```

### iOS

```bash
# Desarrollo
flutter run -d ios

# Producción
flutter build ios --release
```

### Windows

```bash
# Desarrollo (Bandeja del Sistema)
flutter run -d windows --target lib/tray_main.dart

# Desarrollo (Flujo Móvil)
flutter run -d windows --target lib/main.dart

# Compilación de Producción
build.bat
# o
./build.sh
```

El script de compilación crea `crypto_scanner.exe` con funcionalidad de bandeja del sistema.

## Uso

### Android/iOS

1. Ejecutar la aplicación
2. Configurar PIN de 4 dígitos (primera vez)
3. Introducir PIN para acceder a la pantalla principal
4. Usar escáner QR o entrada manual
5. Ver información de criptomonedas

### Windows

1. Ejecutar `crypto_scanner.exe`
2. La aplicación se inicia en la bandeja del sistema (buscar icono en área de notificación)
3. Click derecho en icono de bandeja → "Mostrar UI"
4. Introducir PIN (configurar en primer uso)
5. Acceder a la interfaz completa del escáner de criptomonedas
6. Cerrar ventana para volver a la bandeja

## Integración de API

Usa la API pública de CoinGecko:

- **Endpoint**: `https://api.coingecko.com/api/v3/coins/markets`
- **No requiere clave API**
- **Límite de velocidad**: 50 solicitudes/minuto

## Dependencias

### Principales

- `flutter` - Framework
- `provider` - Gestión de estado
- `http` - Solicitudes HTTP
- `shared_preferences` - Almacenamiento local

### Específicas para Móvil

- `mobile_scanner` - Escaneo de códigos QR

### Específicas para Windows

- `window_manager` - Gestión de ventanas
- `tray_manager` - Integración de bandeja del sistema

### UI/Responsive

- `responsive_helper` - Utilidades responsive personalizadas

## Características de Seguridad

- Autenticación PIN de 4 dígitos
- Máximo 3 intentos de PIN
- Almacenamiento local seguro
- Validación de entrada
- Manejo de errores

## Pruebas

```bash
# Ejecutar todas las pruebas
flutter test

# Análisis estático
flutter analyze
```

## Desarrollo

### Ejecutar Diferentes Targets

```bash
# Flujo Android/iOS en Windows (para pruebas)
flutter run -d windows --target lib/main.dart

# Flujo de bandeja del sistema Windows
flutter run -d windows --target lib/tray_main.dart
```

### Scripts de Compilación

- `build.bat` - Script batch de Windows
- `build.sh` - Script shell Unix

Ambos crean un ejecutable único `crypto_scanner.exe` con funcionalidad de bandeja.

## Solución de Problemas

### Problemas de Windows

- **Icono de bandeja no visible**: Verificar configuración del área de notificación de Windows
- **Fallo en compilación**: Asegurar que Visual Studio Build Tools estén instalados
- **Flutter no encontrado**: Agregar Flutter al PATH del sistema

### Problemas Generales

- **Permisos de cámara**: Conceder acceso a la cámara para escaneo QR
- **Errores de red**: Verificar conexión a internet para llamadas a la API
- **PIN bloqueado**: Esperar tiempo de espera o reinstalar aplicación

## Detalles Técnicos

### Implementación de Bandeja del Sistema

- Usa el paquete `tray_manager` para soporte de bandeja multiplataforma
- Ventana oculta de 1x1 píxel mantiene el contexto de Flutter
- Redimensionamiento dinámico de ventana para diferentes estados de UI
- Limpieza adecuada al salir de la aplicación

### Diseño Responsive

- Puntos de ruptura: Móvil (<600px), Tablet (600-1200px), Escritorio (>1200px)
- Diseños adaptativos y dimensionamiento de componentes
- Ajustes de UI específicos por plataforma

### Gestión de Estado

- Patrón Provider para estado reactivo
- Persistencia de estado de autenticación
- Caché de datos de API y manejo de errores

## Autor

**Gianpierre Mio**

- GitHub: [@DarkCodex29](https://github.com/DarkCodex29)
- Proyecto: [Exeos-Crypto](https://github.com/DarkCodex29/Exeos-Crypto)

## Licencia

Este proyecto es para propósitos de demostración técnica.