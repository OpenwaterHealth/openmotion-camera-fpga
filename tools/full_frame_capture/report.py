"""Build an HTML report embedding display previews of all captured frames.
Raw data stays in the lossless .npy/.png files; previews are normalized 8-bit.

Usage: python report.py --captures captures --out captures/report.html
"""
import argparse
import base64
import io
import json
from pathlib import Path

import numpy as np
from PIL import Image


def preview_b64(npy_path: Path, max_w=480):
    img = np.load(npy_path).astype(np.float64)
    stats = dict(min=int(img.min()), max=int(img.max()),
                 mean=round(float(img.mean()), 2))
    lo, hi = np.percentile(img, [1, 99.5])
    disp = np.clip((img - lo) / max(hi - lo, 1) * 255, 0, 255).astype(np.uint8)
    im = Image.fromarray(disp, mode="L")
    im = im.resize((max_w, int(max_w * img.shape[0] / img.shape[1])))
    buf = io.BytesIO()
    im.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode(), stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--captures", default="captures")
    ap.add_argument("--out", default="captures/report.html")
    a = ap.parse_args()
    root = Path(a.captures)
    scenes = [d for d in ["dark", "laser"] if (root / d / "meta.json").exists()]
    html = ["<!doctype html><meta charset='utf-8'>",
            "<title>Open-Motion 16-camera full-frame capture</title>",
            "<style>body{font-family:sans-serif;margin:24px;background:#111;color:#eee}",
            ".grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}",
            ".card{background:#1c1c1c;padding:8px;border-radius:8px}",
            ".card img{width:100%;image-rendering:pixelated}",
            "td,th{padding:2px 10px;text-align:right}h2{margin-top:40px}",
            "a{color:#7ab8ff}.warn{color:#f80}</style>"]
    for scene in scenes:
        meta = json.loads((root / scene / "meta.json").read_text())
        html.append(f"<h1>Scene: {scene}</h1>")
        html.append(
            f"<p>Captured {meta['captured_at']} — {meta['width']}x{meta['height']}, "
            f"{meta['bit_depth']}-bit lossless ({meta.get('scaling', '')}); previews "
            f"are 1-99.5 percentile normalized.</p><div class='grid'>")
        for key in sorted(meta["cameras"]):
            m = meta["cameras"][key]
            b64, st = preview_b64(root / scene / f"{key}.npy")
            miss = len(m["missing_lines"])
            warn = f"<div class='warn'>{miss} lines missing</div>" if miss else ""
            temp = m["temperature_c_median"]
            temp_s = f"{temp:.1f} °C" if temp is not None else "temp n/a"
            html.append(
                f"<div class='card'><b>{key}</b> — {temp_s}<br>"
                f"min {st['min']} / max {st['max']} / mean {st['mean']}{warn}"
                f"<img src='data:image/png;base64,{b64}'>"
                f"<div><a href='{scene}/{key}.png'>png</a> · "
                f"<a href='{scene}/{key}.npy'>npy</a></div></div>")
        html.append("</div>")
    Path(a.out).write_text("\n".join(html), encoding="utf-8")
    print(f"report -> {a.out}")


if __name__ == "__main__":
    main()
