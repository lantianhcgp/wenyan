#!/usr/bin/env python3
import sqlite3, os, gzip, io, sys, re, urllib.request

CEDICT_URL = os.environ.get('CEDICT_URL', 'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz')
OUT_PATH = os.environ.get('OUT_DB', 'assets/db/dictionary.db')

re_line = re.compile(r"^(?P<trad>[^ ]+) (?P<simp>[^ ]+) \[(?P<pinyin>[^\]]+)\] /(?P<defs>.+)/$")

def fetch_text(url: str) -> str:
    with urllib.request.urlopen(url, timeout=60) as resp:
        data = resp.read()
    try:
        buf = gzip.decompress(data)
    except Exception:
        buf = data
    return buf.decode('utf-8', errors='ignore')


def parse_entries(text: str):
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        m = re_line.match(line)
        if not m:
            continue
        trad = m.group('trad')
        simp = m.group('simp')
        defs = m.group('defs').strip('/')
        gloss = '；'.join([d.strip() for d in defs.split('/') if d.strip()])
        if gloss:
            yield trad, gloss
            if simp != trad:
                yield simp, gloss


def build_sqlite(pairs, out_path: str):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    if os.path.exists(out_path):
        os.remove(out_path)
    conn = sqlite3.connect(out_path)
    cur = conn.cursor()
    cur.execute('CREATE TABLE IF NOT EXISTS entries (head TEXT PRIMARY KEY, gloss TEXT)')
    cur.execute('CREATE INDEX IF NOT EXISTS idx_head ON entries(head)')
    batch = []
    n = 0
    for head, gloss in pairs:
        batch.append((head, gloss))
        if len(batch) >= 5000:
            cur.executemany('INSERT OR REPLACE INTO entries(head, gloss) VALUES (?, ?)', batch)
            conn.commit()
            n += len(batch)
            batch = []
    if batch:
        cur.executemany('INSERT OR REPLACE INTO entries(head, gloss) VALUES (?, ?)', batch)
        conn.commit()
        n += len(batch)
    conn.close()
    return n


def main():
    print(f"Downloading CC-CEDICT from {CEDICT_URL}…", file=sys.stderr)
    text = fetch_text(CEDICT_URL)
    print("Parsing entries…", file=sys.stderr)
    pairs = list(parse_entries(text))
    print(f"Parsed {len(pairs)} entries (including both trad/simp). Building SQLite…", file=sys.stderr)
    n = build_sqlite(pairs, OUT_PATH)
    print(f"Done. {n} entries written to {OUT_PATH}")

if __name__ == '__main__':
    main()
