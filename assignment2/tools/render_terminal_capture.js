const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

async function main() {
    const [, , inputFile, outputFile, ...titleParts] = process.argv;
    const title = titleParts.length > 0 ? titleParts.join(" ") : "Terminal Capture";

    if (!inputFile || !outputFile) {
        console.error("Usage: node render_terminal_capture.js <input.txt> <output.png> [title]");
        process.exit(1);
    }

    const rawText = fs.readFileSync(inputFile, "utf8");
    const lineCount = Math.max(rawText.split("\n").length, 1);
    const viewportHeight = Math.min(Math.max(lineCount * 28 + 220, 900), 6000);

    const escapeHtml = (value) => value
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;");

    const html = `<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${escapeHtml(title)}</title>
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
            <div class="title">${escapeHtml(title)}</div>
            <div class="subtitle">CS 5293 Assignment 2</div>
        </div>
        <div class="content">
            <pre>${escapeHtml(rawText)}</pre>
        </div>
        <div class="footer">
            Rendered from <span class="accent">${escapeHtml(path.basename(inputFile))}</span>
        </div>
    </div>
</body>
</html>`;

    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({
        viewport: { width: 1600, height: viewportHeight },
        deviceScaleFactor: 1.5
    });

    await page.setContent(html, { waitUntil: "load" });
    await page.screenshot({
        path: outputFile,
        fullPage: true
    });
    await browser.close();
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
