# 🔒 Firebase Firestore Güvenlik Kuralları

## ⚠️ ÖNEMLI: Bu kuralları Firebase Console'da ayarlayın!

### Adımlar:
1. Firebase Console'a gidin: https://console.firebase.google.com/
2. Projenizi seçin: `servisciler-c8666`
3. Sol menüden **Firestore Database** seçin
4. Üst menüden **Rules** (Kurallar) sekmesine tıklayın
5. Aşağıdaki kuralları yapıştırın ve **Publish** (Yayınla) butonuna basın

---

## 📋 Güvenlik Kuralları (Geliştirme İçin)

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Parents koleksiyonu - Veli giriş ve email ekleme izni
    match /parents/{parentId} {
      // Herkes okuyabilir ve yazabilir (geliştirme için)
      allow read, write: if true;
    }
    
    // Students koleksiyonu - Öğrenci bilgileri
    match /students/{studentId} {
      // Herkes okuyabilir ve yazabilir (geliştirme için)
      allow read, write: if true;
    }
    
    // Diğer tüm koleksiyonlar
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🔐 Üretim İçin Güvenli Kurallar (İleride Kullanın)

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Parents koleksiyonu
    match /parents/{parentId} {
      // Sadece kendi verilerini okuyabilir
      allow read: if request.auth != null && request.auth.uid == parentId;
      // Kayıt için yazma izni
      allow create: if true;
      // Sadece kendi verilerini güncelleyebilir
      allow update: if request.auth != null && request.auth.uid == parentId;
    }
    
    // Students koleksiyonu
    match /students/{studentId} {
      // Okul admini veya ilgili veli okuyabilir
      allow read: if request.auth != null;
      // Sadece okul admini yazabilir
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## ✅ Kurallari Yayınladıktan Sonra

Uygulamayı yeniden başlatın:
```
flutter run -d windows
```

Artık "permission-denied" hatası olmayacak! 🎉

