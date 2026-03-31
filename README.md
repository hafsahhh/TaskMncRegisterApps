# RegisterMnCApps
Aplikasi iOS untuk pendaftaran anggota (member) secara offline dan online yang dibangun dengan prinsip Clean Architecture menggunakan pola MVVM, RxSwift, dan SnapKit.

# Fitur Utama
Authentication: Login dan Sign Up terintegrasi dengan API.
Profile Management: Melihat data pengguna dan pengaturan akun.
Home : Draft data calon anggota yang disimpan secara lokal sebelum diunggah.
Data Sync: Mengunggah data draft secara massal (bulk upload) ke server verifikator.

# Tech Stack
UI Framework: UIKit.
Layouting: SnapKit.
Reactive Programming: RxSwift & RxCocoa.
Networking: URLSession terintegrasi dengan RxSwift.
Security: KeychainManager
Architecture: MVVM (Model-View-ViewModel).

# Cara menjalankan RegisterMnCApps.
1. Pastikan Anda telah menginstal CocoaPods.
2. Buka terminal di folder project dan jalankan:
   Bash
   pod install
   Buka file RegisterMnCApps.xcworkspace.
3. Pilih simulator atau perangkat fisik, lalu tekan Cmd + R.

# Video
https://drive.google.com/drive/u/1/home
