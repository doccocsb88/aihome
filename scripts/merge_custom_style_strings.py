#!/usr/bin/env python3
"""Merge CustomStylePopupView strings into all Localizable.strings files."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCALIZABLE = ROOT / "AIHome" / "AIHome" / "Resources" / "Localizable"

LOCALE_FILES = [
    "en-US.lproj/Localizable.strings",
    "en.lproj/Localizable.strings",
    "ar-SA.lproj/Localizable.strings",
    "de-DE.lproj/Localizable.strings",
    "de.lproj/Localizable.strings",
    "es-ES.lproj/Localizable.strings",
    "es.lproj/Localizable.strings",
    "fr-FR.lproj/Localizable.strings",
    "fr.lproj/Localizable.strings",
    "hi.lproj/Localizable.strings",
    "id.lproj/Localizable.strings",
    "it.lproj/Localizable.strings",
    "ja.lproj/Localizable.strings",
    "ko.lproj/Localizable.strings",
    "ms.lproj/Localizable.strings",
    "pt-BR.lproj/Localizable.strings",
    "ru.lproj/Localizable.strings",
    "th.lproj/Localizable.strings",
    "tr.lproj/Localizable.strings",
]

ENGLISH: dict[str, str] = {
    "interior.custom_style.title": "Custom Style",
    "interior.custom_style.apply": "Apply",
    "interior.custom_style.placeholder": (
        "Describe your dream interior style\n"
        "(e.g. Modern Japanese Zen with\ndark wood accents)..."
    ),
    "interior.custom_style.character_count": "%d/150",
}

TRANSLATIONS: dict[str, dict[str, str]] = {
    "ar-SA": {
        "interior.custom_style.title": "نمط مخصص",
        "interior.custom_style.apply": "تطبيق",
        "interior.custom_style.placeholder": (
            "صف أسلوب الديكور الداخلي الذي تحلم به\n"
            "(مثال: Zen ياباني حديث مع\nلمسات خشب داكن)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "de": {
        "interior.custom_style.title": "Individueller Stil",
        "interior.custom_style.apply": "Anwenden",
        "interior.custom_style.placeholder": (
            "Beschreiben Sie Ihren Traum-Innenstil\n"
            "(z. B. Modern Japanese Zen mit\ndunklen Holzakzenten)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "es": {
        "interior.custom_style.title": "Estilo personalizado",
        "interior.custom_style.apply": "Aplicar",
        "interior.custom_style.placeholder": (
            "Describe el estilo de interior de tus sueños\n"
            "(p. ej., Zen japonés moderno con\nacentos de madera oscura)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "fr": {
        "interior.custom_style.title": "Style personnalisé",
        "interior.custom_style.apply": "Appliquer",
        "interior.custom_style.placeholder": (
            "Décrivez le style d'intérieur de vos rêves\n"
            "(ex. : Zen japonais moderne avec\ndes accents en bois foncé)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "hi": {
        "interior.custom_style.title": "कस्टम स्टाइल",
        "interior.custom_style.apply": "लागू करें",
        "interior.custom_style.placeholder": (
            "अपनी सपनों की इंटीरियर शैली का वर्णन करें\n"
            "(जैसे, गहरे लकड़ी के एक्सेंट के साथ\nमॉडर्न जापानी ज़ेन)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "id": {
        "interior.custom_style.title": "Gaya Kustom",
        "interior.custom_style.apply": "Terapkan",
        "interior.custom_style.placeholder": (
            "Jelaskan gaya interior impian Anda\n"
            "(mis. Modern Japanese Zen dengan\naksen kayu gelap)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "it": {
        "interior.custom_style.title": "Stile personalizzato",
        "interior.custom_style.apply": "Applica",
        "interior.custom_style.placeholder": (
            "Descrivi lo stile d'interni dei tuoi sogni\n"
            "(es. Modern Japanese Zen con\naccenti in legno scuro)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "ja": {
        "interior.custom_style.title": "カスタムスタイル",
        "interior.custom_style.apply": "適用",
        "interior.custom_style.placeholder": (
            "理想のインテリアスタイルを説明してください\n"
            "（例：ダークウッドのアクセントが効いた\nモダン・ジャパニーズ・禅）..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "ko": {
        "interior.custom_style.title": "맞춤 스타일",
        "interior.custom_style.apply": "적용",
        "interior.custom_style.placeholder": (
            "꿈꾸는 인테리어 스타일을 설명해 주세요\n"
            "(예: 어두운 나무 포인트가 있는\n모던 재팬디 Zen)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "ms": {
        "interior.custom_style.title": "Gaya Tersuai",
        "interior.custom_style.apply": "Guna",
        "interior.custom_style.placeholder": (
            "Terangkan gaya dalaman impian anda\n"
            "(cth. Modern Japanese Zen dengan\naksen kayu gelap)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "pt-BR": {
        "interior.custom_style.title": "Estilo personalizado",
        "interior.custom_style.apply": "Aplicar",
        "interior.custom_style.placeholder": (
            "Descreva o estilo de interior dos seus sonhos\n"
            "(ex.: Zen japonês moderno com\ndetalhes em madeira escura)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "ru": {
        "interior.custom_style.title": "Свой стиль",
        "interior.custom_style.apply": "Применить",
        "interior.custom_style.placeholder": (
            "Опишите интерьер вашей мечты\n"
            "(например, Modern Japanese Zen с\nакцентами из тёмного дерева)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "th": {
        "interior.custom_style.title": "สไตล์กำหนดเอง",
        "interior.custom_style.apply": "ใช้",
        "interior.custom_style.placeholder": (
            "อธิบายสไตล์การตกแต่งภายในที่คุณฝัน\n"
            "(เช่น Modern Japanese Zen พร้อม\nไม้สีเข้มเป็นจุดเด่น)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
    "tr": {
        "interior.custom_style.title": "Özel Stil",
        "interior.custom_style.apply": "Uygula",
        "interior.custom_style.placeholder": (
            "Hayalinizdeki iç mekan stilini açıklayın\n"
            "(ör. koyu ahşap detaylarla Modern Japon Zen)..."
        ),
        "interior.custom_style.character_count": "%d/150",
    },
}


def locale_key(path: str) -> str:
    folder = Path(path).parts[0].replace(".lproj", "")
    if folder in {"en-US", "en"}:
        return "en"
    if folder in {"de-DE", "de"}:
        return "de"
    if folder in {"es-ES", "es"}:
        return "es"
    if folder in {"fr-FR", "fr"}:
        return "fr"
    return folder


def escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def format_block(terms: dict[str, str]) -> str:
    lines = ["\n/* Custom style popup */"]
    for key, value in terms.items():
        lines.append(f'"{key}" = "{escape(value)}";')
    return "\n".join(lines) + "\n"


def merge_file(relative_path: str) -> None:
    file_path = LOCALIZABLE / relative_path
    content = file_path.read_text(encoding="utf-8")

    for key in ENGLISH:
        content = re.sub(rf'^"{re.escape(key)}" = ".*";\n', "", content, flags=re.MULTILINE)
    content = re.sub(r"\n?/\* Custom style popup \*/\n", "\n", content)

    locale = locale_key(relative_path)
    terms = ENGLISH if locale == "en" else TRANSLATIONS.get(locale, ENGLISH)
    block = format_block(terms)

    match = re.search(r'"interior\.design_style\.art_deco" = "[^"]+";\n', content)
    if not match:
        raise RuntimeError(f"Could not locate art_deco anchor in {relative_path}")

    insert_at = match.end()
    content = content[:insert_at] + block + content[insert_at:]
    file_path.write_text(content, encoding="utf-8")
    print(f"updated {relative_path}")


def main() -> None:
    for relative_path in LOCALE_FILES:
        merge_file(relative_path)
    print(f"done: {len(ENGLISH)} keys x {len(LOCALE_FILES)} locales")


if __name__ == "__main__":
    main()
