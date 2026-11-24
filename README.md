# PenguTunnel v6.2.1 (Offline Fix 1)

<div dir="rtl">

## 🐧 راهنمای نصب سریع و اجرای مستقیم با یک دستور

برای دانلود سریع آخرین هسته هماهنگ‌شده PenguTunnel (`v6.2.1`) و اسکریپت منو (`v5.4.0`) و اجرای فوری آن در سرور، یکی از دستورات زیر را به عنوان روت (`root`) در ترمینال اجرا کنید:

### ۱. دستور اجرای مستقیم گیت‌هاب (پیشنهادی برای سرورهای خارج با دسترسی مستقیم):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh)
```
یا از طریق پایپ:
```bash
curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh | bash
```

### ۲. اسکریپت اختصاصی CDN کلودفلر / jsDelivr (بدون فیلتر، دانلود مستقیم هسته از CDN بدون لمس گیت‌هاب):
```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/run-cdn.sh)
```
یا از طریق پایپ:
```bash
curl -fsSL https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/run-cdn.sh | bash
```

### ۳. اسکریپت اختصاصی سرورهای داخل ایران / GhProxy (میرور ضد تحریم، دانلود مستقیم هسته از GhProxy):
```bash
bash <(curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run-iran.sh)
```
یا از طریق پایپ:
```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run-iran.sh | bash
```
یا میرور جایگزین (در صورت اختلال موقت پروکسی):
```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/run-iran.sh)
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

### 📦 ویژگی‌های این نسخه (v6.2.1 Offline Fix 1 / Installer v5.4.0):
- **رفع محدودیت لایسنس**: حذف کامل بررسی لایسنس و تایم‌اوت باینری، بدون نیاز به کلید یا ارتباط با سرور سازنده (پچ‌شده توسط CyberPatcher@).
- **فوروارد ترافیک UDP در حالت بدون TUN**: قابلیت فوروارد پورت‌های UDP نظیر WireGuard، Hysteria و TUIC روی تونل بدون نیاز به کارت شبکه TUN (ویژگی جدید هسته 6.2.0+).
- **ابزار اختصاصی تست سلامت مقصد TCP**: دستور تشخیص سریع و مستقیم با `bash install.sh --diagnose-target IPV4 PORT`.
- **پایداری کامل Data Plane**: حل مشکل خطای انقضای اثبات لایسنس و خطای `lt2 required but data plane not bound`.
- **فورواردر کرنلی nftables**: هدایت بهینه ترافیک UDP روی کرنل لینوکس از طریق قوانین nftables.
- **دانلود و اجرای کاملاً خودکار و دوگانه CDN**: بررسی معماری سرور (x86_64)، تأیید صحت هش امنیتی باینری (SHA256)، رفع نیازمندی‌ها و بازکردن منوی مدیریتی با پشتیبانی مستقیم از دو CDN (شبکه ابری jsDelivr و GhProxy ایران).
- **پشتیبانی کامل از سشن‌های تعاملی و پایپینگ**: عملکرد بی‌نقص با `curl | bash`، اتصال خودکار به `/dev/tty` بدون افتادن در لوپ بی‌پایان یا خطا در محیط‌های غیرتعاملی.
- **حفظ تنظیمات قبلی**: در صورتی که نسخه قبلی پنگوتانل روی سرور داشته باشید، کانفیگ‌ها و کلیدهای PSK حفظ می‌شوند.

---

### 🔐 اعتبارسنجی هش امنیتی (Checksums):
| فایل | الگوریتم | مقدار SHA256 |
|---|---|---|
| `pengutunnel` | SHA-256 | `b58e38316553b2fb06bbaeab050f07505e2aa93c563008b4665a6b34e77537f3` |
| `pengutunnel.gz` | SHA-256 | `e7a6e4d78f17574159ee0490a324858fe5e4c5e28760957fa6a6472d58235fec` |

---

### 🛠 اجرای دستی (آفلاین بدون اینترنت):
اگر بسته زیپ را دانلود کرده‌اید:
```bash
cd PenguTunnel-6.2.1-Offline-Fix1-linux-amd64
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

عیب‌یابی پورت و مقصد TCP در سرور خارج:
```bash
bash install.sh --diagnose-target 10.20.0.2 111
```

</div>

---

## English Quick Start

### 1. GitHub Direct (Recommended for servers outside Iran):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run.sh)
```

### 2. Dedicated Cloudflare jsDelivr CDN (Unfiltered & High Speed - downloads directly from CDN):
```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/run-cdn.sh)
```

### 3. Dedicated Iran GhProxy Mirror (For servers inside Iran):
```bash
bash <(curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/run-iran.sh)
```
or via fallback CDN mirror:
```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/run-iran.sh)
```

After installation, simply type `pengu` anywhere in your terminal to open the management menu.
