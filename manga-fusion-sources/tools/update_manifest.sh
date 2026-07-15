#!/bin/bash
MANIFEST="config/js_sources_config.json"

echo "🔄 جاري تحديث بصمات SHA-256 للمصادر..."

AZORA_SHA=$(sha256sum sources/azora/source.js | cut -d' ' -f1)
jq --arg sha "$AZORA_SHA" '.sources.azora.script.sha256 = $sha' "$MANIFEST" > tmp.json && mv tmp.json "$MANIFEST"

LEK_SHA=$(sha256sum sources/lekmanga/source.js | cut -d' ' -f1)
jq --arg sha "$LEK_SHA" '.sources.lekmanga.script.sha256 = $sha' "$MANIFEST" > tmp.json && mv tmp.json "$MANIFEST"

CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg time "$CURRENT_TIME" '.last_updated = $time' "$MANIFEST" > tmp.json && mv tmp.json "$MANIFEST"

echo "✅ تم التحديث بنجاح!"
echo "🔑 بصمة أزورا الجديدة: $AZORA_SHA"
echo "🔑 بصمة ليك مانجا الجديدة: $LEK_SHA"
