# FemCastells — App mòbil

App Flutter per a la gestió de colles castelleres, connectada al backend [fempinya4](https://github.com/martinartacho/fempinya4).

> **Fork de** [AssociacioFemPinya/app](https://github.com/AssociacioFemPinya/app)
> Els dos projectes han divergit considerablement. FemCastells és una aplicació independent
> orientada al backend fempinya4 (Laravel 13 + Filament 5). No és compatible per fer merge
> directe amb el repo original.

---

## Stack

| Capa | Tecnologia |
|---|---|
| Framework | Flutter (Dart) |
| Estat | BLoC |
| Navegació | GoRouter |
| HTTP | Dio + Sanctum token |
| Notificacions | Firebase Cloud Messaging |
| Auth local | FlutterSecureStorage |

## Funcionalitats actuals

- Login amb email i contrasenya (Sanctum)
- Recuperació de contrasenya via codi per correu (sense sortir de l'app)
- Home amb notícies de la colla
- Llista d'events i gestió d'assistència
- Rondes (historial d'actuacions amb pinya en WebView)
- Perfil d'usuari
- Menú arc circular accessible des de totes les pantalles
- Suggeriments a l'administrador
- Consentiment GDPR
- Notificacions push (FCM)
- Pantalla de projecció pública de la pinya (per TV/projector)

## Backend

El backend és [femcastells.artacho.org](https://femcastells.artacho.org), basat en [martinartacho/fempinya4](https://github.com/martinartacho/fempinya4).

L'URL base es pot sobreescriure en compilació:

```bash
flutter run --dart-define=API_BASE_URL=https://el-teu-domini.org
```

## Executar en local (dades mock)

```bash
flutter run --dart-define=USE_MOCK_API=true
```

## Compilar APK de release

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

> Les APKs de cada versió estan disponibles a [Releases](../../releases).

## Versions

| Versió | Novetats principals |
|---|---|
| 1.2.0+7 | Recuperació de contrasenya per codi, fix crash Firebase sideloaded |
| 1.1.0+6 | Menú arc, push notifications, auto-login, suggeriments |
| 1.0.2+5 | Fix URL login producció |
| 1.0.1+4 | Icones adaptatives Android |
| 1.0.0+3 | Primera versió funcional connectada a fempinya4 |

## Relació amb AssociacioFemPinya/app

Aquest repo va néixer com a fork de l'app original de FemPinya per adaptar-la al backend fempinya4. Des de llavors ha divergit significativament:

- Connexió a una API diferent (fempinya4 vs FemPinya3)
- Branding FemCastells (logo, colors, nom)
- Funcionalitats pròpies: arc menu, suggeriments, recuperació de contrasenya per codi
- L'upstream té 1 commit que no existeix aquí (`implement notification view #38`), però la funcionalitat equivalent ja existeix via el sistema de notícies

No es preveu sincronitzar amb l'upstream.
