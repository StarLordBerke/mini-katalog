# 🛍️ Mini Katalog - Apple Store Inspired E-Commerce App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![UI/UX](https://img.shields.io/badge/UI%2FUX-Apple%20Store%20Design-black?style=for-the-badge)

</div>

---

## 📱 Proje Hakkında
Harici hiçbir ek paket (dependency) kullanılmadan, tamamen çekirdek Flutter bileşenleriyle sıfırdan geliştirilmiş **Apple Store esintili modern bir mini katalog mobil uygulamasıdır**. 

Dinamik JSON veri ayrıştırması, akıcı Hero geçiş animasyonları, global sepet yönetimi ve güvenli ödeme modalı ile hem tasarımı hem de mimari yapısıyla güçlü bir mobil portfolyo projesidir.

---

## 🚀 Öne Çıkan Özellikler

* **Zero External Packages (Sıfır Ekstra Paket):** Maksimum kararlılık ve performans için tamamen çekirdek Flutter yapılarıyla inşa edildi.
* **Dinamik JSON Ayrıştırma (`jsonDecode`):** Ürün verileri sahte bir API simülasyonu üzerinden dinamik olarak parse edilerek modellendi.
* **Akıcı Hero Animasyonları:** Keşfet sayfasındaki ürün kartlarından detay sayfasına geçerken görsellerin akıcı bir şekilde uçarak büyümesini sağlayan modern UX dokunuşu.
* **Global State Yönetimi:** Sayfalar arası senkronize çalışan, uygulama hafızasında yaşayan global sepet yapısı.
* **Etiket (Badge) Sistemi:** Ürünlerin özelliklerini belirten dinamik etiketler ve Wrap tabanlı esnek yerleşim.
* **Hata Korumalı Görseller (Fallback UI):** İnternet kaynaklı kırık veya kopuk linklerde uygulamanın çökmesini önleyen akıllı yedek ikon mekanizması.
* **Güvenli Ödeme Modalı (Secure Checkout):** Sepet sayfasından tetiklenen, kullanıcıyı yönlendiren ve sipariş sonrası sepeti başarıyla sıfırlayan şık pop-up penceresi.

---

## 🛠️ Mimari ve Teknik Yapı

```text
lib/
│
├── main.dart             # Tüm uygulama mimarisi, model sınıfları ve ekran bileşenleri
