# Configuración de Firebase para GEJ App

## 📋 Pasos para configurar Firebase

### 1. Instalar FlutterFire CLI

Primero, instala la herramienta de línea de comandos de FlutterFire:

```bash
dart pub global activate flutterfire_cli
```

Asegúrate de que la ruta de pub global esté en tu PATH.

### 2. Crear un proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto" o selecciona uno existente
3. Sigue el asistente de configuración:
   - Ingresa el nombre del proyecto (ej: "gej-app")
   - Acepta los términos y condiciones
   - (Opcional) Habilita Google Analytics

### 3. Configurar Firebase en tu proyecto Flutter

Ejecuta este comando desde la raíz de tu proyecto:

```bash
flutterfire configure
```

Este comando:
- Te pedirá iniciar sesión con tu cuenta de Google
- Mostrará tus proyectos de Firebase disponibles
- Te permitirá seleccionar las plataformas (Android, iOS, Web, etc.)
- Generará automáticamente el archivo `firebase_options.dart`
- Actualizará la configuración necesaria para cada plataforma

### 4. Habilitar servicios de Firebase

En Firebase Console, habilita los siguientes servicios:

#### Authentication:
1. Ve a "Authentication" en el menú lateral
2. Haz clic en "Comenzar"
3. Habilita "Correo electrónico/Contraseña" en la pestaña "Sign-in method"

#### Cloud Firestore:
1. Ve a "Firestore Database" en el menú lateral
2. Haz clic en "Crear base de datos"
3. Selecciona "Comenzar en modo de prueba" (o configura reglas personalizadas)
4. Elige la ubicación del servidor más cercana

### 5. Inicializar Firebase en tu app

Actualiza tu archivo `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEJ App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
```

### 6. Configurar reglas de Firestore (Opcional pero recomendado)

En Firebase Console, ve a Firestore Database > Reglas y actualiza:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso solo a usuarios autenticados
    match /cities/{city}/members/{member} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. Instalar dependencias

Ejecuta:

```bash
flutter pub get
```

## 🚀 Uso de los servicios

### AuthService

```dart
import 'package:gej_app/services/auth_service.dart';

final authService = AuthService();

// Iniciar sesión
await authService.signInWithEmailPassword(email, password);

// Registrar usuario
await authService.registerWithEmailPassword(email, password);

// Cerrar sesión
await authService.signOut();

// Estado del usuario
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario conectado: ${user.email}');
  } else {
    print('Usuario desconectado');
  }
});
```

### FirestoreService

```dart
import 'package:gej_app/services/firestore_service.dart';

final firestoreService = FirestoreService();

// Agregar miembro
await firestoreService.addMember(
  cityName: 'Santiago',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  phone: '+56912345678',
);

// Obtener miembros (Stream)
firestoreService.getMembers('Santiago').listen((snapshot) {
  for (var doc in snapshot.docs) {
    print(doc.data());
  }
});

// Actualizar miembro
await firestoreService.updateMember(
  cityName: 'Santiago',
  memberId: 'docId',
  name: 'Juan Pérez',
  email: 'juan.nuevo@example.com',
  phone: '+56987654321',
);

// Eliminar miembro
await firestoreService.deleteMember(
  cityName: 'Santiago',
  memberId: 'docId',
);
```

## 📁 Estructura de Firestore

```
cities/
  ├── Santiago/
  │   └── members/
  │       ├── {memberId}/
  │       │   ├── name: "Juan Pérez"
  │       │   ├── email: "juan@example.com"
  │       │   ├── phone: "+56912345678"
  │       │   ├── createdAt: Timestamp
  │       │   └── updatedAt: Timestamp
  │       └── ...
  ├── Valdivia/
  ├── Villarrica/
  └── Paine/
```

## 🔒 Seguridad

- Nunca compartas tu archivo `google-services.json` (Android) o `GoogleService-Info.plist` (iOS)
- Configura reglas de seguridad apropiadas en Firestore
- Usa variables de entorno para información sensible
- Habilita autenticación de dos factores en tu cuenta de Firebase

## 📚 Recursos adicionales

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

## ⚠️ Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Asegúrate de llamar `Firebase.initializeApp()` antes de `runApp()`
- Verifica que `firebase_options.dart` existe

### Error de compilación en Android
- Asegúrate de tener `google-services.json` en `android/app/`
- Verifica que el plugin de Google Services esté en `android/build.gradle`

### Error de compilación en iOS
- Asegúrate de tener `GoogleService-Info.plist` en `ios/Runner/`
- Ejecuta `pod install` en la carpeta `ios/`
