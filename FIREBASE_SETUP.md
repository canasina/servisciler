# Firebase Kurulum Rehberi

Bu proje Firebase kullanmaktadır. Firebase'i projenizde kullanabilmek için aşağıdaki adımları takip edin.

## 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add project" butonuna tıklayın
3. Proje adını girin (örn: "servisciler")
4. Google Analytics'i etkinleştirin (isteğe bağlı)
5. Projeyi oluşturun

## 2. Android Uygulaması Ekleme

1. Firebase Console'da projenizi açın
2. Android simgesine tıklayın
3. Android paket adını girin: `com.example.servisciler` (veya kendi paket adınız)
4. `google-services.json` dosyasını indirin
5. İndirdiğiniz dosyayı `android/app/` klasörüne kopyalayın (zaten mevcut)

## 3. Firebase Options Dosyasını Güncelleme

`lib/firebase_options.dart` dosyasını açın ve aşağıdaki değerleri Firebase Console'dan alınan değerlerle değiştirin:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',              // Firebase Console'dan alın
  appId: 'YOUR_APP_ID_HERE',                // Firebase Console'dan alın
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',  // Firebase Console'dan alın
  projectId: 'YOUR_PROJECT_ID_HERE',        // Firebase Console'dan alın
  storageBucket: 'YOUR_STORAGE_BUCKET_HERE', // Firebase Console'dan alın
);
```

### Firebase Console'dan Değerleri Alma:

1. Firebase Console'da projenizi açın
2. Sol menüden "Project Settings" (Proje Ayarları) seçin
3. "Your apps" bölümünde Android uygulamanızı seçin
4. "SDK setup and configuration" bölümünden Config snippet'i kopyalayın
5. Bu değerleri `firebase_options.dart` dosyasına yapıştırın

## 4. Firebase Servislerini Etkinleştirme

### Authentication (Kimlik Doğrulama)

1. Firebase Console'da "Authentication" bölümüne gidin
2. "Get Started" butonuna tıklayın
3. "Sign-in method" sekmesine gidin
4. "Email/Password" seçeneğini etkinleştirin

### Firestore Database

1. Firebase Console'da "Firestore Database" bölümüne gidin
2. "Create database" butonuna tıklayın
3. "Start in test mode" seçeneğini seçin (geliştirme için)
4. Konum seçin (örn: europe-west3)
5. "Enable" butonuna tıklayın

## 5. Güvenlik Kuralları (Opsiyonel)

Firestore güvenlik kurallarını aşağıdaki gibi ayarlayabilirsiniz:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kimlik doğrulaması yapılmış kullanıcılara izin ver
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Öğrenciler koleksiyonu
    match /students/{studentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Servisler koleksiyonu
    match /services/{serviceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Şoförler koleksiyonu
    match /drivers/{driverId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 6. Test Kullanıcısı Oluşturma

1. Firebase Console'da "Authentication" bölümüne gidin
2. "Users" sekmesine gidin
3. "Add user" butonuna tıklayın
4. Test kullanıcısı oluşturun:
   - Email: `test@example.com`
   - Password: `test123456`

## 7. Uygulamayı Çalıştırma

```bash
flutter clean
flutter pub get
flutter run
```

## Notlar

- Firebase Authentication ve Firestore kullanımı için internet bağlantısı gereklidir
- Test modunda Firestore güvenlik kuralları herkesin veri okumasına/yazmasına izin verir
- Üretim ortamına geçerken mutlaka güvenlik kurallarını sıkılaştırın
- `google-services.json` dosyası hassas bilgiler içerir, bu dosyayı asla public repository'lere yüklemeyin

## Sorun Giderme

### Google Services hatası

Eğer "google-services.json not found" hatası alırsanız:
- Dosyanın `android/app/` klasöründe olduğundan emin olun
- `flutter clean` ve `flutter pub get` komutlarını çalıştırın

### Firebase initialization hatası

Eğer uygulama başlatılırken Firebase hatası alırsanız:
- `firebase_options.dart` dosyasındaki değerlerin doğru olduğundan emin olun
- Internet bağlantınızı kontrol edin
- Firebase Console'da Android uygulamasının doğru şekilde eklendiğinden emin olun

