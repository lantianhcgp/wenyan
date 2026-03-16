#!/usr/bin/env python3
# Convert CC-CEDICT (UTF-8 txt) to a simple JSON dictionary
# Output formats supported by the app:
# 1) array of objects: [{"head":"词","gloss":"释义"}, ...]
# 2) key-value mapping: {"词":"释义", ...}
# Usage: python cedict_to_json.py cedict_ts.u8 > cedict.json

import sys
import json

if len(sys.argv) < 2:
    print("Usage: python cedict_to_json.py <cedict file> [--map]", file=sys.stderr)
    sys.exit(1)

path = sys.argv[1]
mode_map = '--map' in sys.argv

entries = []
kv = {}

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        # Format: 傳統 簡體 [pin yin] /sense1/ sense2/
        try:
            head = line.split(' ', 1)[0]
            gloss_part = line.split(']', 1)[-1] if ']' in line else line
            senses = [s for s in gloss_part.split('/') if s]
            gloss = '；'.join(senses).strip()
            if not gloss:
                continue
            if mode_map:
                kv[head] = gloss
            else:
                entries.append({"head": head, "gloss": gloss})
        except Exception:
            continue

if mode_map:
    json.dump(kv, sys.stdout, ensure_ascii=False, indent=2)
else:
    json.dump(entries, sys.stdout, ensure_ascii=False, indent=2)
