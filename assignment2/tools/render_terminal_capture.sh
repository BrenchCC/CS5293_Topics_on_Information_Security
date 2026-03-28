#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $0 <input.txt> <output.png> [title]" >&2
    exit 1
fi

input_file="$1"
output_file="$2"
title="${3:-Terminal Capture}"
chrome_bin="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [[ ! -f "$input_file" ]]; then
    echo "Input file not found: $input_file" >&2
    exit 1
fi

if [[ ! -x "$chrome_bin" ]]; then
    echo "Google Chrome not found at: $chrome_bin" >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
html_file="$tmp_dir/capture.html"
line_count="$(wc -l < "$input_file" | tr -d " ")"
height=$((line_count * 28 + 220))

if (( height < 900 )); then
    height=900
fi

if (( height > 6000 )); then
    height=6000
fi

escaped_text="$(
    perl -0pe "s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g" "$input_file"
)"

cat > "$html_file" <<EOF
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${title}</title>
    <style>
        :root {
            --bg-top: #0f172a;
            --bg-bottom: #111827;
            --panel: rgba(15, 23, 42, 0.92);
            --panel-border: rgba(148, 163, 184, 0.22);
            --text: #e5eefb;
            --muted: #94a3b8;
            --accent: #22c55e;
            --shadow: rgba(15, 23, 42, 0.35);
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 40px;
            background:
                radial-gradient(circle at top left, rgba(34, 197, 94, 0.18), transparent 28%),
                radial-gradient(circle at top right, rgba(56, 189, 248, 0.14), transparent 28%),
                linear-gradient(160deg, var(--bg-top), var(--bg-bottom));
            color: var(--text);
            font-family: "SF Pro Display", "Segoe UI", sans-serif;
        }

        .frame {
            width: 1500px;
            margin: 0 auto;
            overflow: hidden;
            border: 1px solid var(--panel-border);
            border-radius: 24px;
            background: var(--panel);
            box-shadow: 0 28px 70px var(--shadow);
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 24px;
            border-bottom: 1px solid rgba(148, 163, 184, 0.16);
            background: rgba(2, 6, 23, 0.72);
        }

        .traffic {
            display: flex;
            gap: 10px;
        }

        .dot {
            width: 12px;
            height: 12px;
            border-radius: 999px;
        }

        .red { background: #fb7185; }
        .yellow { background: #fbbf24; }
        .green { background: #22c55e; }

        .title {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 0.02em;
        }

        .subtitle {
            color: var(--muted);
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.14em;
        }

        .content {
            padding: 26px;
        }

        pre {
            margin: 0;
            padding: 24px;
            white-space: pre-wrap;
            word-break: break-word;
            border-radius: 18px;
            background: rgba(2, 6, 23, 0.92);
            border: 1px solid rgba(148, 163, 184, 0.12);
            color: var(--text);
            font-size: 22px;
            line-height: 1.55;
            font-family: "SF Mono", "JetBrains Mono", "Menlo", monospace;
        }

        .footer {
            padding: 0 26px 24px;
            color: var(--muted);
            font-size: 14px;
        }

        .accent {
            color: var(--accent);
        }
    </style>
</head>
<body>
    <div class="frame">
        <div class="topbar">
            <div class="traffic">
                <span class="dot red"></span>
                <span class="dot yellow"></span>
                <span class="dot green"></span>
            </div>
            <div class="title">${title}</div>
            <div class="subtitle">CS 5293 Assignment 2</div>
        </div>
        <div class="content">
            <pre>${escaped_text}</pre>
        </div>
        <div class="footer">
            Rendered from <span class="accent">$(basename "$input_file")</span>
        </div>
    </div>
</body>
</html>
EOF

"$chrome_bin" \
    --headless \
    --disable-gpu \
    --hide-scrollbars \
    --window-size="1600,${height}" \
    --screenshot="$output_file" \
    "file://$html_file" >/dev/null 2>&1

rm -rf "$tmp_dir"
