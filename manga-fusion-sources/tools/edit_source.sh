#!/bin/bash

# الاستخدام: ./tools/edit_source.sh [source_name] [code_snippet]
SOURCE=$1
CODE=$2

if [ -z "$SOURCE" ] || [ -z "$CODE" ]; then
    echo "خطأ: يجب تحديد اسم المصدر والكود."
    exit 1
fi

FILE="sources/$SOURCE/source.js"

if [ ! -f "$FILE" ]; then
    echo "خطأ: الملف $FILE غير موجود."
    exit 1
fi

# كتابة الكود الجديد في الملف
echo "$CODE" > "$FILE"

echo "✅ تم تحديث كود $SOURCE بنجاح!"
# تحديث البصمة فوراً بعد التعديل
./tools/update_manifest.sh
