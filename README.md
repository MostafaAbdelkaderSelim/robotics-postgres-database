# Robotics PostgreSQL Database (Modular Schema)

مشروع قاعدة بيانات PostgreSQL مُنظّم بشكل معياري لشركة روبوتكس صناعية. يحتوي على جداول الأعمال الأساسية (Core/Sales) وجداول التصنيع والروبوتات (Manufacturing Structure/Execution) والتليمترية ومؤشرات الأداء (Telemetry/KPIs)، بالإضافة إلى العروض (Views)، الدوال/التريجرات (Triggers)، والفهارس (Indexes).

الهدف
- مخطط واضح قابل للصيانة والتوسّع
- تشغيل سريع عبر Docker
- بيانات تجريبية جاهزة (Seed) لعرض النظام عملياً

الرسم التوضيحي للبنية
- ملف الرسم: <mcfile name="dw_architecture.svg" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\dw_architecture.svg"></mcfile>
- الشرح النصي: <mcfile name="data_warehouse_explained.md" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\data_warehouse_explained.md"></mcfile>

التشغيل السريع (Quick Start)
1) باستخدام Docker (الموصى به)
- المتطلبات: Docker Desktop
- من مجلّد المشروع:
  - تشغيل: `docker compose up -d`
- الاتصال:
  - قاعدة البيانات: robotics
  - المستخدم: postgres
  - كلمة المرور: postgres
  - المضيف: localhost
  - المنفذ: 5432
- سيتم تطبيق ملفات SQL تلقائياً من مجلد `database` (بترتيب الأسماء) والـ Seed ضمن الإنشاء الأول للحاوية.

2) باستخدام psql يدويّاً
- سكربت التجميع: <mcfile name="00_all.psql" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\database\00_all.psql"></mcfile>
- نفِّذ بالترتيب داخل السكربت أو مباشرة:
  - 01_extensions.sql
  - 10_core.sql
  - 20_sales.sql
  - 30_manufacturing_structure.sql
  - 31_manufacturing_execution.sql
  - 32_manufacturing_maintenance.sql
  - 33_manufacturing_telemetry.sql
  - 40_views.sql
  - 50_triggers.sql
  - 60_indexes.sql
  - 99_seed.sql (اختياري للبيانات التجريبية)

بنية الملفات
- <mcfolder name="database" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\database"></mcfolder>
  - 01_extensions.sql: تفعيل امتدادات مثل CITEXT
  - 10_core.sql: الجداول الأساسية (departments, employees, customers, products)
  - 20_sales.sql: جداول المبيعات والطلبات والفواتير والمدفوعات
  - 30_manufacturing_structure.sql: المصانع، خطوط الإنتاج، المحطات، الروبوتات، أنواع المهام
  - 31_manufacturing_execution.sql: أوامر العمل والعمليات ومهام الروبوتات
  - 32_manufacturing_maintenance.sql: تذاكر الصيانة وسجلّاتها
  - 33_manufacturing_telemetry.sql: التوقفات، قراءات الحساسات، التنبيهات، الورديات، OEE
  - 40_views.sql: العروض التجميعية (مثل v_order_totals، v_downtime_durations)
  - 50_triggers.sql: الدوال/التريجرات (fn_update_invoice_totals، fn_set_unit_price، fn_validate_payment)
  - 60_indexes.sql: فهارس الأداء (GIN/BRIN/Partial/Composite)
  - 99_seed.sql: بيانات تجريبية للتشغيل الفوري
- <mcfile name="docker-compose.yml" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\docker-compose.yml"></mcfile>: تشغيل Postgres محلياً وتطبيق السكيمات تلقائياً
- <mcfile name=".gitignore" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\.gitignore"></mcfile>: تجاهل الملفات غير الضرورية
- <mcfile name=".gitattributes" path="c:\Users\Mostafa Selim\Downloads\Telegram Desktop\.gitattributes"></mcfile>: توحيد نهايات السطور عبر الأنظمة

أمان وجودة
- الأعمدة الحسّاسة: استخدام TIMESTAMPTZ للوقت، CITEXT للبريد الإلكتروني، INET لعناوين IP، JSONB للقدرات/البيانات
- فهارس الأداء: GIN لحقول JSONB، فهارس جزئية (Partial) للحالات النشطة، مركّبة (Composite) للاستعلامات الشائعة
- الدوال/التريجرات: التحقق من المدفوعات، إعادة احتساب الفواتير، تعيين سعر الوحدة تلقائياً

تحسينات مستقبلية مقترحة
- CI عبر GitHub Actions: إضافة `.github/workflows/ci.yml` لتطبيق المخطط وفحص دخان (Smoke Test) عند كل Push/PR
- ترخيص (LICENSE): MIT أو Apache-2.0
- اختبارات قواعد البيانات: pgtap لتغطية القيود والعلاقات والدوال
- تنسيق SQL: sqlfluff + pre-commit
- إدارة الترحيلات: Sqitch/Flyway
- فصل الصلاحيات: Roles/GRANTs للإنتاج
- تقسيم الجداول الكبيرة: Partitioning لجدول `sensor_readings`، وفهارس BRIN للوقت

اتصال سريع لقاعدة البيانات
- URI: `postgres://postgres:postgres@localhost:5432/robotics`

المساهمة
- نرحّب بالاقتراحات والتحسينات
- افتح Issue أو Pull Request للتطوير