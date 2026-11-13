# PenguTunnel v5.4.1 (Offline Fix 1)

<div dir="rtl">

## 🐧 راهنمای نصب سریع و اجرای مستقیم با یک دستور

برای دانلود سریع آخرین هسته هماهنگ‌شده PenguTunnel (`v5.4.1`) و اسکریپت منو (`v5.3.1`) و اجرای فوری آن در سرور، یکی از دستورات زیر را به عنوان روت (`root`) اجرا کنید:

### ۱. دستور اجرای سریع (پیشنهادی):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh)
```
یا با `curl | bash`:
```bash
curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh | bash
```

### ۲. دستور مخصوص سرورهای ایران (در صورت اختلال یا فیلتر GitHub):
```bash
bash <(curl -fsSL https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh)
```

---

### ⚡ میانبر اجرای منو در دفعات بعدی
اسکریپت به صورت خودکار میانبر سراسری `pengu` را ثبت می‌کند. از این پس در هر کجای ترمینال فقط تایپ کنید:
```bash
pengu
```
یا
```bash
pengutunnel
```

---

### 📦 ویژگی‌های این نسخه (v5.4.1 Offline Fix 1):
- **رفع محدودیت لایسنس**: حذف بررسی لایسنس و تایم‌اوت باینری، عدم نیاز به کلید یا ارتباط با سرور سازنده.
- **پایداری کامل Data Plane**: حل مشکل خطای انقضای اثبات لایسنس و خطای `lt2 required but data plane not bound`.
- **فورواردر کرنلی nftables**: هدایت بهینه ترافیک UDP روی کرنل لینوکس از طریق قوانین nftables.
- **دانلود و اجرای کاملاً خودکار**: بررسی معماری سرور (x86_64)، تأیید صحت هش امنیتی باینری (SHA256)، رفع نیازمندی‌ها و بازکردن منوی مدیریتی.
- **حفظ تنظیمات قبلی**: در صورتی که نسخه قبلی پنگوتانل روی سرور داشته باشید، کانفیگ‌ها و کلیدهای PSK حفظ می‌شوند.

---

### 🔐 اعتبارسنجی هش امنیتی (Checksums):
| فایل | الگوریتم | مقدار SHA256 |
|---|---|---|
| `pengutunnel` | SHA-256 | `e70f4c1612e936108bdb17f0d8515342699242cc977b9037ba4a442f0af477fa` |

---

### 🛠 اجرای دستی (آفلاین بدون اینترنت):
اگر بسته زیپ را دانلود کرده‌اید:
```bash
cd PenguTunnel-5.4.1-Offline-Fix1-linux-amd64
sudo bash install.sh
```

برای ارتقای تونل موجود بدون تغییر تنظیمات:
```bash
sudo bash install.sh --repair-existing
```

بررسی یکپارچگی فایل‌ها:
```bash
bash install.sh --check
```

</div>

---

## English Quick Start

Run this single command on your Linux amd64/x86_64 server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh)
```

After installation, simply type `pengu` anywhere in your terminal to open the management menu.
