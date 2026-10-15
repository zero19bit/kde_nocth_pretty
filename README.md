<div align="center">

<h1>✦ Notch</h1>

<p><strong>Your music. Your time. Your everyday controls.</strong><br>
موسیقی، زمان و کنترل‌های روزمره؛ همگی دم دست.</p>

<p>A compact panel widget for KDE Plasma 6.<br>
یک ویجت جمع‌وجور برای پنل KDE Plasma 6.</p>

<p>
<img alt="Version 0.8.1" src="https://img.shields.io/badge/version-0.8.1-7C6FF6?style=flat-square">
<img alt="KDE Plasma 6" src="https://img.shields.io/badge/KDE_Plasma-6-1D99F3?style=flat-square">
<img alt="Built with QML" src="https://img.shields.io/badge/built_with-QML-41CD52?style=flat-square">
</p>

<p><a href="#english">English</a> · <a href="#persian">فارسی</a></p>

</div>

---

## A little pill, plenty inside · کوچک، ولی پرکار

| | English | فارسی |
|---|---|---|
| 🎵 | **Media** — multiple players, cover art, playback, seeking and volume | **رسانه** — چند پخش‌کننده، کاور، کنترل پخش، جابه‌جایی آهنگ و صدا |
| 🗓️ | **Three calendars** — Jalali, Gregorian and Hijri, with optional extra dates | **سه تقویم** — شمسی، میلادی و قمری، با نمایش اختیاری تاریخ‌های دیگر |
| 🎛️ | **Quick controls** — Wi-Fi, Bluetooth, output volume, mic mute and brightness | **کنترل‌های سریع** — وای‌فای، بلوتوث، صدای خروجی، میکروفن و روشنایی |
| ⏱️ | **Focus timer** — editable presets, pause, resume and a completion notification | **تایمر تمرکز** — زمان‌های قابل تنظیم، مکث، ادامه و اعلان پایان |
| 📊 | **System stats** — CPU, RAM, supported CPU temperature, battery and network rates | **آمار سیستم** — پردازنده، رم، دمای CPU در سخت‌افزارهای پشتیبانی‌شده، باتری و سرعت شبکه |
| ✨ | **Your layout** — optional modules, glass styling, adjustable width and a scrollable popup | **چیدمان دلخواه** — ماژول‌های انتخابی، ظاهر شیشه‌ای، عرض قابل تنظیم و پنجرهٔ اسکرول‌پذیر |

<a id="english"></a>

## English

Notch puts frequently used desktop controls in a small panel pill. Click it to open your music, calendar, focus timer and system controls. Choose the modules you use and tune the panel’s appearance in the widget settings.

### 🚀 Install or update

**Requires KDE Plasma 6.** Extract the release ZIP, open a terminal in the folder containing `metadata.json` and `install.sh`, then run:

```sh
sh install.sh
```

The script installs Notch for your user or upgrades an existing installation. It uses `kpackagetool6`; it does not install system dependencies. A build step is not required.

After a first installation, add **Notch** through Plasma’s **Add Widgets** interface.

**After upgrading:** close Notch’s settings window and reload Plasma before changing newly added settings:

```sh
systemctl --user restart plasma-plasmashell.service
```

This briefly reloads the desktop shell and panels. If your session does not use that systemd user service, log out and log in again. Saved widget settings are retained.

<details>
<summary><strong>Manual installation</strong></summary>

Run from the extracted package folder:

```sh
# First installation
kpackagetool6 --type Plasma/Applet --install .

# Upgrade an existing installation
kpackagetool6 --type Plasma/Applet --upgrade .
```

The package ID stays `org.oziro.notch` across these releases.

</details>

### 🖱️ A few useful gestures

| Action | Result |
|---|---|
| Click the panel pill | Open or close the popup |
| Hover over the pill while media is available | Reveal previous, play/pause and next controls |
| Middle-click while media is available | Play or pause the selected player |
| Scroll over the pill while media is available | Adjust the selected player’s volume |
| Swipe the media carousel or click its dots | Switch between players |
| Click **امروز** in the calendar | Return to the current month |

The popup has separate controls for **system output volume** and **player volume**.

### 🗓️ Pick your calendar

Open **Notch Settings → Layout & Features → Clock & calendar**.

1. Set **Primary calendar** to **Jalali**, **Gregorian** or **Hijri (civil)**.
2. Use **Also show below the primary date** to add other dates.
3. Enable **Show date** under **Panel pill** if you want the date in the panel.
4. Click **Apply**.

The primary choice controls the main date, the panel date and the default monthly calendar. Extra-date options avoid displaying the same calendar twice.

The selector inside the monthly calendar changes the calendar you are browsing for that view. Your saved primary choice remains in Settings. Browsing another month is preserved when the date rolls over; the **Today** view follows the current month.

**About Hijri dates:** Notch uses the calculated **Islamic civil** calendar. Local moon-sighting dates can differ. Use **Hijri day adjustment** from **−2 to +2** to match your local calendar; a positive value advances the displayed Hijri date. Days change at midnight in your system’s time zone.

The previous Jalali/Gregorian preference from version 0.7 is kept until you choose a primary calendar.

### ⏱️ Make room for focus

Start a session with one of the three presets. Change their durations in Settings, pause when needed, and resume when ready. The timer uses an end time to catch up after sleep or delayed processing and sends a desktop notification when the session ends.

### 🔌 Requirements

Plasma’s QML components, **Kirigami**, **KCMUtils** and **Plasma5Support** must be available. Individual features use these utilities:

| Feature | Utility or service |
|---|---|
| Package installation | `kpackagetool6` |
| Media | `playerctl` |
| Wi-Fi | NetworkManager / `nmcli` |
| Bluetooth | BlueZ / `bluetoothctl` |
| Output audio and microphone | WirePlumber / `wpctl` |
| Brightness | PowerDevil with `qdbus6`, or `brightnessctl` |
| Focus notifications | `notify-send` |
| System settings shortcuts | `kcmshell6` and the corresponding settings modules |
| Memory stats | `free` |

Availability also depends on your hardware and session. For example, brightness needs a controllable display backend, and CPU temperature needs a recognized CPU sensor.

### 🛠️ Troubleshooting

**Apply stays disabled or a new calendar setting does not persist**  
Close the settings window, reload Plasma using the command above, and reopen Settings. Plasma may still have the previous release’s configuration keys in memory. Version 0.8.1 also explicitly notifies the settings dialog when the new date options change.

**A control fails**  
Check the utility for that feature in the requirements table. Control-command errors appear in the popup. Wi-Fi, Bluetooth, audio and brightness also depend on the relevant system service and device permissions.

**Brightness or CPU temperature is unavailable**  
Notch displays an unavailable state when it cannot find a supported backend or CPU sensor. It does not substitute a GPU or drive temperature for CPU temperature.

**Network speed looks high with a VPN or virtual interfaces**  
The displayed rate sums non-loopback interfaces. Traffic present on both a tunnel and its physical interface can be counted in that total.

### 🧪 Development and checks

Run the bundled logic tests with **Node.js 18+**:

```sh
node tests/check.cjs
```

Node.js is only needed for these development tests. The widget itself runs in Plasma.

The bundled suite covers 16 test groups, including control parsing, media identity and selection, network counter changes, focus timing and calendar conversion. Hijri dates were also compared with ICU and Qt’s Islamic civil calendar during release checks.

Additional checks covered QML syntax and an offscreen Qt Quick configuration-host simulation, including Apply notifications, Cancel and saving/reopening calendar choices. KDE components were replaced with test doubles in that simulation; a full live Plasma and hardware integration test remains separate.

### 📦 What changed

**0.8.1:** explicit change notifications for the new date settings, calendar-setting aliases and clearer upgrade/reload instructions.

**0.8:** three calendars; a panel-date option; scrollable popup; focus pause/resume; corrections to brightness, CPU usage, sensor selection, battery duration and metadata parsing; stable media cards during updates; refreshed control states and reduced polling while the popup is closed.

---

<a id="persian"></a>

## فارسی

Notch کنترل‌های پرکاربرد دسکتاپ را در یک ویجت کوچک روی پنل کنار هم می‌گذارد. با یک کلیک به موسیقی، تقویم، تایمر تمرکز و کنترل‌های سیستم دسترسی داری. از تنظیمات هم می‌توانی ماژول‌ها و ظاهر پنل را مطابق سلیقه‌ات تغییر بدهی.

### 🚀 نصب و به‌روزرسانی

**به KDE Plasma 6 نیاز داری.** فایل ZIP را استخراج کن؛ در پوشه‌ای که `metadata.json` و `install.sh` داخل آن است، ترمینال را باز کن و اجرا کن:

```sh
sh install.sh
```

اسکریپت با `kpackagetool6` ویجت را برای حساب خودت نصب می‌کند یا نصب قبلی را به‌روزرسانی می‌کند. وابستگی‌های سیستم را نصب نمی‌کند و نیازی هم به بیلدکردن پروژه نیست.

در نصب اولیه، از بخش **Add Widgets / افزودن ویجت‌ها**، ویجت **Notch** را به پنل اضافه کن.

**بعد از به‌روزرسانی:** پنجرهٔ تنظیمات Notch را ببند و قبل از تغییر گزینه‌های جدید، Plasma را دوباره بارگذاری کن:

```sh
systemctl --user restart plasma-plasmashell.service
```

پنل و پوستهٔ دسکتاپ برای چند لحظه دوباره بارگذاری می‌شوند. اگر نشست تو از این سرویس systemd استفاده نمی‌کند، یک‌بار از حساب کاربری خارج شو و دوباره وارد شو. تنظیمات ذخیره‌شدهٔ ویجت حفظ می‌شوند.

<details>
<summary><strong>نصب دستی</strong></summary>

از داخل پوشهٔ استخراج‌شدهٔ بسته، یکی از دستورهای زیر را اجرا کن:

نصب اولیه:

```sh
kpackagetool6 --type Plasma/Applet --install .
```

به‌روزرسانی نصب قبلی:

```sh
kpackagetool6 --type Plasma/Applet --upgrade .
```

شناسهٔ بسته در این نسخه‌ها همچنان `org.oziro.notch` است.

</details>

### 🖱️ چند حرکت دم‌دستی

| حرکت | نتیجه |
|---|---|
| کلیک روی ویجت پنل | باز یا بسته‌شدن پنجره |
| بردن نشانگر روی ویجت، وقتی رسانه‌ای موجود است | نمایش دکمه‌های قبلی، پخش/مکث و بعدی |
| کلیک وسط، وقتی رسانه‌ای موجود است | پخش یا مکث پخش‌کنندهٔ انتخاب‌شده |
| چرخاندن اسکرول روی ویجت، وقتی رسانه‌ای موجود است | تغییر صدای همان پخش‌کننده |
| جابه‌جایی کارت‌های رسانه یا کلیک روی نقطه‌های زیر آن‌ها | انتخاب پخش‌کنندهٔ دیگر |
| کلیک روی «امروز» در تقویم | برگشتن به ماه جاری |

داخل پنجره، **صدای خروجی سیستم** و **صدای پخش‌کننده** کنترل‌های جداگانه دارند.

### 🗓️ تقویمت را انتخاب کن

برو به **تنظیمات Notch ← Layout & Features ← Clock & calendar**.

۱. از **Primary calendar / تقویم اصلی** یکی از حالت‌های **شمسی**، **میلادی** یا **قمری** را انتخاب کن.

۲. در بخش **Also show below the primary date**، تاریخ‌های دیگری را که می‌خواهی هم‌زمان ببینی فعال کن.

۳. برای دیدن تاریخ در پنل، گزینهٔ **Show date / نمایش تاریخ در پنل** را در بخش **Panel pill** روشن کن.

۴. **Apply** را بزن.

تقویم اصلی، تاریخ بالای پنجره، تاریخ پنل و حالت پیش‌فرض تقویم ماهانه را تعیین می‌کند. تاریخ تکراری دوبار نشان داده نمی‌شود.

منوی داخل تقویم ماهانه برای جابه‌جایی تقویم در همان نماست؛ انتخاب اصلی ذخیره‌شده در تنظیمات باقی می‌ماند. اگر در حال مرور ماه دیگری باشی، با تغییر روز به ماه جاری پرتاب نمی‌شوی؛ حالت «امروز» هم ماه جاری را دنبال می‌کند.

**دربارهٔ تاریخ قمری:** محاسبه بر پایهٔ **تقویم قمری مدنی (Islamic civil)** است. تاریخ رؤیت محلی هلال ممکن است متفاوت باشد. گزینهٔ **Hijri day adjustment / اصلاح روز قمری** از **۲− تا ۲+ روز** کمک می‌کند آن را با تقویم محلی هماهنگ کنی؛ عدد مثبت، تاریخ قمری را جلو می‌برد. روز در نیمه‌شبِ منطقهٔ زمانی سیستم عوض می‌شود.

انتخاب قبلی شمسی یا میلادی در نسخهٔ ۰٫۷ هم تا وقتی تقویم اصلی تازه‌ای انتخاب نکنی حفظ می‌شود.

### ⏱️ وقت تمرکز

با یکی از سه زمان پیشنهادی شروع کن؛ مدت هرکدام را هم می‌توانی در تنظیمات عوض کنی. هرجا لازم شد مکث کن و بعد ادامه بده. تایمر بر اساس زمان پایان محاسبه می‌شود تا خواب سیستم یا تأخیر پردازش باعث عقب‌ماندن شمارش نشود. پایان جلسه هم با اعلان دسکتاپ خبر داده می‌شود.

### 🔌 پیش‌نیازها

اجزای QML مربوط به Plasma، همراه با **Kirigami**، **KCMUtils** و **Plasma5Support** باید در دسترس باشند. هر قابلیت از ابزار مربوط به خودش استفاده می‌کند:

| قابلیت | ابزار یا سرویس |
|---|---|
| نصب بسته | `kpackagetool6` |
| رسانه | `playerctl` |
| وای‌فای | NetworkManager / `nmcli` |
| بلوتوث | BlueZ / `bluetoothctl` |
| صدای خروجی و میکروفن | WirePlumber / `wpctl` |
| روشنایی | PowerDevil همراه `qdbus6`، یا `brightnessctl` |
| اعلان پایان تمرکز | `notify-send` |
| میان‌بر تنظیمات سیستم | `kcmshell6` و ماژول تنظیمات مربوط |
| آمار حافظه | `free` |

دسترس‌پذیری قابلیت‌ها به سخت‌افزار و نشست هم بستگی دارد؛ مثلاً روشنایی به یک روش کنترل پشتیبانی‌شده و دمای CPU به سنسور شناخته‌شده نیاز دارد.

### 🛠️ اگر چیزی کار نکرد

**Apply فعال نمی‌شود یا انتخاب تقویم جدید ذخیره نمی‌شود**  
پنجرهٔ تنظیمات را ببند، Plasma را با دستور بالاتر دوباره بارگذاری کن و دوباره تنظیمات را باز کن. ممکن است فهرست کلیدهای نسخهٔ قبلی هنوز در حافظه باشد. در نسخهٔ ۰٫۸٫۱، تغییر گزینه‌های تاریخ به‌صورت صریح هم به پنجرهٔ تنظیمات اعلام می‌شود.

**یکی از کنترل‌ها کار نمی‌کند**  
ابزار همان قابلیت را در جدول پیش‌نیازها بررسی کن. خطای فرمان کنترل داخل پنجره نمایش داده می‌شود. سرویس مربوط و مجوز دسترسی به دستگاه هم در کارکرد وای‌فای، بلوتوث، صدا و روشنایی نقش دارند.

**روشنایی یا دمای CPU در دسترس نیست**  
وقتی روش کنترل روشنایی یا سنسور CPU پشتیبانی‌شده پیدا نشود، وضعیت ناموجود نمایش داده می‌شود. دمای GPU یا دیسک به‌جای دمای CPU نشان داده نمی‌شود.

**با VPN یا رابط مجازی، سرعت شبکه بیشتر از انتظار است**  
سرعت نمایش‌داده‌شده مجموع رابط‌های غیر loopback است؛ ترافیکی که هم روی تونل و هم روی رابط فیزیکی دیده می‌شود، ممکن است در این مجموع دوبار حساب شود.

### 🧪 توسعه و آزمون

برای اجرای تست‌های منطق، **Node.js نسخهٔ ۱۸ یا جدیدتر** لازم است:

```sh
node tests/check.cjs
```

Node.js فقط برای اجرای تست‌های توسعه لازم است؛ خود ویجت داخل Plasma اجرا می‌شود.

مجموعهٔ همراه بسته ۱۶ گروه آزمون دارد: از خواندن دادهٔ کنترل‌ها و حفظ انتخاب پخش‌کننده تا تغییر شمارنده‌های شبکه، تایمر تمرکز و تبدیل تقویم‌ها. در بررسی‌های انتشار، تاریخ قمری با ICU و تقویم قمری مدنی Qt هم تطبیق داده شده است.

ساختار QML و یک شبیه‌سازی میزبان تنظیمات در Qt Quick نیز بررسی شده‌اند؛ از جمله اعلان تغییر برای Apply، لغو تغییرات و ذخیره و بازگشایی انتخاب تقویم. در این شبیه‌سازی، اجزای KDE جایگزین آزمایشی داشته‌اند؛ تست کامل روی Plasma و سخت‌افزار واقعی مرحله‌ای جداست.

### 📦 تغییرات نسخه‌ها

**۰٫۸٫۱:** اعلان صریح تغییر گزینه‌های جدید تاریخ، اتصال انتخاب تقویم به تنظیمات و راهنمای روشن‌تر به‌روزرسانی و بارگذاری مجدد Plasma.

**۰٫۸:** سه تقویم، نمایش تاریخ پنل، پنجرهٔ اسکرول‌پذیر و مکث/ادامهٔ تمرکز؛ اصلاح روشنایی، مصرف CPU، انتخاب سنسور دما، زمان باتری و خواندن اطلاعات رسانه؛ حفظ کارت‌های پخش هنگام به‌روزرسانی، تازه‌سازی وضعیت کنترل‌ها و کاهش تناوب بررسی‌ها وقتی پنجره بسته است.

---

<div align="center">

<p><strong>Made by Oziro · ساختهٔ Oziro</strong></p>
<p>Keep your desktop close. ✦<br>چیزهایی که لازم داری، دم دستت باشند.</p>

</div>
