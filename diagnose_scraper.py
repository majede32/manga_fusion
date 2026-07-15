import urllib.request
import re
import ssl

# إعداد تجاوز التحقق من الشهادات لتجنب مشاكل بيئة العمل المحلية
ssl_context = ssl._create_unverified_context()

sources = {
    "MangaLek": {
        "url": "https://mangalek.com",
        "user-agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
        "referer": "https://mangalek.com/"
    },
    "Olympus": {
        "url": "https://olympustaff.com",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "referer": "https://olympustaff.com/"
    },
    "3asq": {
        "url": "https://3asq.org",
        "user-agent": "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
        "referer": "https://3asq.org/"
    }
}

print("=" * 60)
print("             أداة تشخيص اتصال مصادر المانجا           ")
print("=" * 60)

for name, info in sources.items():
    print(f"\n[*] جاري فحص مصدر: {name} ...")
    req = urllib.request.Request(
        info["url"],
        headers={"User-Agent": info["user-agent"], "Referer": info["referer"]}
    )
    
    try:
        with urllib.request.urlopen(req, timeout=10, context=ssl_context) as response:
            status = response.status
            html = response.read().decode('utf-8', errors='ignore')
            print(f"  [+] حالة الاتصال (Status Code): {status} (ناجح)")
            
            # فحص إذا كانت الصفحة هي صفحة حماية Cloudflare
            if "cloudflare" in html.lower() or "just a moment" in html.lower():
                print("  [!] تنبيه: الصفحة محمية بـ Cloudflare (تم اكتشاف جدار الحماية)!")
                continue
                
            # فحص الـ Regex الأول
            reg1 = re.compile(r'href="([^"]*?/manga/[^"]*?)".*?title="([^"]*?)".*?src="([^"]*?)"', re.DOTALL)
            matches1 = reg1.findall(html)
            print(f"  [+] الـ Regex الرئيسي وجد: {len(matches1)} عنصر/عناصر")
            if len(matches1) > 0:
                print(f"      - أول عنصر وجد: {matches1[0]}")
                
            # فحص الـ Regex الاحتياطي
            reg2 = re.compile(r'class="post-title".*?href="([^"]*?)">([^<]*?)<.*?src="([^"]*?)"', re.DOTALL)
            matches2 = reg2.findall(html)
            print(f"  [+] الـ Regex الاحتياطي وجد: {len(matches2)} عنصر/عناصر")
            if len(matches2) > 0:
                print(f"      - أول عنصر وجد: {matches2[0]}")
                
            if len(matches1) == 0 and len(matches2) == 0:
                print("  [X] خطأ: لم يتم العثور على أي مانجا! بنية الـ HTML للموقع تغيرت وتحتاج لتحديث الـ Regex.")
                
    except urllib.error.HTTPError as e:
        print(f"  [X] فشل الطلب HTTPError: كود الخطأ {e.code}")
        if e.code in [403, 503]:
            print("      - السبب المحتمل: جدار الحماية الخاص بالموقع (Cloudflare) قام بحظر الطلب.")
    except Exception as e:
        print(f"  [X] خطأ غير متوقع أثناء الاتصال: {e}")

print("\n" + "=" * 60)
