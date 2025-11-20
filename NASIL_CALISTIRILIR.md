# 🚀 Uygulamayı Çalıştırma Rehberi

## ⚠️ ÖNEMLİ: Firebase Yapılandırması Devre Dışı

Uygulama şu anda Firebase olmadan çalışıyor. Veriler **geçici olarak bellekte** tutuluyor.

## 🎯 Hızlı Başlangıç

### 1. Tüm Processları Durdur

Terminal'de şu komutu çalıştır:

```powershell
cd "C:\Users\canas\OneDrive\Belgeler\GitHub\servisciler"
taskkill /F /IM dart.exe
taskkill /F /IM flutter.exe  
taskkill /F /IM java.exe
```

### 2. Build Klasörünü Temizle

```powershell
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
```

### 3. Paketleri Güncelle

```powershell
flutter pub get
```

### 4. Uygulamayı Çalıştır

```powershell
flutter run
```

VEYA

VS Code'da **F5** tuşuna bas

## 🔧 Sorun Giderme

### Problem: "Unable to delete directory" Hatası

**Çözüm:**
```powershell
# 1. VS Code'u kapat
# 2. PowerShell'i Yönetici olarak aç
# 3. Şu komutları çalıştır:
cd "C:\Users\canas\OneDrive\Belgeler\GitHub\servisciler"
taskkill /F /IM dart.exe
taskkill /F /IM java.exe
Start-Sleep -Seconds 3
Remove-Item -Path "build" -Recurse -Force
flutter pub get
flutter run
```

### Problem: Uygulama Flutter Logosu'nda Takılı Kalıyor

**Çözüm:** Firebase yapılandırması eksik olabilir. Şu anda Firebase devre dışı, bu normal.

### Problem: OneDrive Dosyaları Kilitledi

**Çözüm:**
```powershell
# OneDrive'ı geçici olarak duraklat
# Sağ alttaki OneDrive ikonuna sağ tık > Pause syncing > 2 hours
# Sonra build klasörünü temizle
```

## 📱 Test Kullanıcıları (Geçici - Bellekte)

Uygulama şu anda Firebase olmadan çalışıyor:

- **Okul Girişi**: Herhangi bir kullanıcı adı/şifre
- **Veli Girişi**: Herhangi bir kullanıcı adı/şifre  
- **Şoför Girişi**: Herhangi bir kullanıcı adı/şifre

## 🎨 Mevcut Özellikler

✅ Karşılama ekranı
✅ Okul, Veli, Şoför giriş ekranları
✅ Okul yönetim paneli
✅ Öğrenci listesi ve ekleme
✅ Servis listesi ve ekleme
✅ Şoför listesi ve ekleme
✅ Servis detay ekranı
✅ Şoför detay ekranı
✅ Öğrenci atama ekranı
✅ Şoföre servis atama ekranı

## 📊 Örnek Veriler

Uygulama başlatıldığında otomatik olarak yüklenir:
- 75 Örnek Öğrenci
- 12 Örnek Servis
- 16 Örnek Şoför

## 🔜 Firebase'i Etkinleştirme (İleride)

`lib/main.dart` dosyasında yorum satırlarını kaldırın:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

Detaylı Firebase kurulum için `FIREBASE_SETUP.md` dosyasına bakın.

## 💡 İpuçları

1. **İlk çalıştırma uzun sürebilir** (2-3 dakika) - bu normaldir
2. **Hot reload** için kodu değiştirdikten sonra `r` tuşuna basın
3. **Hot restart** için `R` tuşuna basın (büyük harf)
4. **Konsolu temizlemek** için `c` tuşuna basın

## 🐛 Hata Bulursanız

1. `flutter doctor` çalıştırın
2. Tüm bağımlılıkların yüklü olduğundan emin olun
3. Android SDK ve emulator'ün çalıştığından emin olun

## 🎉 Başarılar!

Uygulama artık çalışmaya hazır! Herhangi bir sorun yaşarsanız yukarıdaki sorun giderme adımlarını takip edin.

