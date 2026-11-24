# windows-sysadmin-toolkit

**MT-DuranBey Windows 10 / 11 & Server CLI Ayar Yöneticisi (20 Ayar)**

Arayüz, sistem, uzak masaüstü (RDP), gizlilik ve performans ayarlarını tek bir komut satırı menüsü üzerinden hızlı ve kayıtlı şekilde uygulayan PowerShell yönetim aracıdır.

## Hızlı Çalıştırma (Yönetici PowerShell)

Yönetici olarak açtığınız **Windows PowerShell** penceresine aşağıdaki komutu yapıştırıp `Enter` tuşuna basın:

irm "https://raw.githubusercontent.com/MT-DuranBey/windows-sysadmin-toolkit/refs/heads/main/baslat.ps1?t=$(Get-Random)" | iex

## Kullanım İpuçları
- Menüden tekil veya virgülle ayrılmış birden fazla ayar seçebilirsiniz (`1,2,10,11`).
- Tüm 20 ayarı tek seferde uygulamak için `A`, çıkmak için `Q` tuşunu kullanabilirsiniz.

## Log Klasörü
- Yapılan işlemler ve durum kayıtları `C:\Logs\MT-DuranBey\` dizinine kaydedilir.
