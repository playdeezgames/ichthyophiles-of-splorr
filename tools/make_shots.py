#!/usr/bin/env python3
"""Makes assets/screenshots/ from the real web build: each scene is the built page with a save
seeded into localStorage (times relative to the moment it loads), captured by headless Chrome.
Run through tools/make_shots.sh, which builds first."""
import http.server
import json
import os
import shutil
import socketserver
import subprocess
import sys
import tempfile
import threading

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "build", "web")
OUT = os.path.join(ROOT, "assets", "screenshots")
SIZE = (800, 600)
KEY = "ichthyophiles-of-splorr-save"

D, H, M = "86400000", "3600000", "60000"


def fish(name, born, food="0", hunger="0", fed="0", doomed="0", death=0, died="0", starved=0, overfed=0, best="0"):
    """A save; the time fields are JS expressions in terms of `now`, D, H and M."""
    return {"name": name, "born": born, "food": food, "hunger": hunger, "fed": fed, "doomed": doomed,
            "death": death, "died": died, "starved": starved, "overfed": overfed, "best": best}


SCENES = [
    ("01-no-fish", None, None),
    ("02-just-right", fish("Wanda", "now-(2*D+5*H+31*M)", food="Math.round(0.6*D)", fed="now-(9*H)",
                           starved=2, overfed=1, best="4*D+11*H+2*M"), None),
    ("03-fish-have-ribs", fish("Gill Bates", "now-(4*D+3*H+12*M)", hunger="Math.round(2.5*D)", fed="now-Math.round(3.5*D)",
                               starved=5, overfed=3, best="6*D+5*H+41*M"), None),
    ("04-doomed", fish("Admiral Snack", "now-(1*D+2*H)", food="5*D-20*M", fed="now-20*M", doomed="now-20*M",
                       starved=1, overfed=2, best="3*D+7*H+12*M"), None),
    ("05-starved", fish("Bubbles", "now-(8*D+3*H+12*M)", hunger="5*D", fed="now-(6*D+3*H+12*M)",
                        death=1, died="now-(3*H+12*M)", starved=4, overfed=2, best="5*D+1*H+3*M"), None),
    ("06-reset", fish("Sir Swims-a-Lot", "now-(1*D+4*H)", food="Math.round(0.4*D)", fed="now-(2*H)",
                      starved=4, overfed=2, best="5*D+1*H+3*M"), "Reset"),
]


def seed_script(s, click):
    js = ["localStorage.clear();"]
    if s is not None:
        js.append("const now=Date.now(), D=%s, H=%s, M=%s;" % (D, H, M))
        js.append(
            "localStorage.setItem(%s, JSON.stringify({version:1, has_fish:true, death:%d, name:%s, "
            "born_ms:%s, updated_ms:now, food_ms:%s, hunger_ms:%s, fed_ms:%s, doomed_ms:%s, died_ms:%s, "
            "starved:%d, overfed:%d, best_ms:%s}));"
            % (json.dumps(KEY), s["death"], json.dumps(s["name"]), s["born"], s["food"], s["hunger"],
               s["fed"], s["doomed"], s["died"] if s["death"] else "0", s["starved"], s["overfed"], s["best"]))
        if s["death"]:
            # a dead fish was last brought up to date when it died
            js.append("{const v=JSON.parse(localStorage.getItem(%s)); v.updated_ms=v.died_ms; "
                      "localStorage.setItem(%s, JSON.stringify(v));}" % (json.dumps(KEY), json.dumps(KEY)))
    if click:
        js.append("addEventListener('load',()=>setTimeout(()=>{[...document.querySelectorAll('button')]"
                  ".find(b=>b.textContent===%s).click();},300));" % json.dumps(click))
    return "<script>" + "".join(js) + "</script>"


def main():
    chrome = shutil.which("google-chrome") or shutil.which("chromium") or shutil.which("chromium-browser")
    if not chrome:
        sys.exit("no Chrome found")
    page = open(os.path.join(WEB, "index.html"), encoding="utf-8").read()
    work = tempfile.mkdtemp(prefix="fish-shots-")
    for f in os.listdir(WEB):
        shutil.copy(os.path.join(WEB, f), work)
    for name, s, click in SCENES:
        with open(os.path.join(work, name + ".html"), "w", encoding="utf-8") as fh:
            fh.write(page.replace("<head>", "<head>" + seed_script(s, click), 1))

    class Quiet(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *a, **k):
            super().__init__(*a, directory=work, **k)

        def log_message(self, *a):
            pass

    with socketserver.TCPServer(("127.0.0.1", 0), Quiet) as httpd:
        port = httpd.server_address[1]
        threading.Thread(target=httpd.serve_forever, daemon=True).start()
        os.makedirs(OUT, exist_ok=True)
        for name, _, _ in SCENES:
            profile = tempfile.mkdtemp(prefix="fish-chrome-")
            out = os.path.join(OUT, name + ".png")
            subprocess.run([chrome, "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
                            "--user-data-dir=" + profile, "--window-size=%d,%d" % SIZE,
                            "--virtual-time-budget=4000", "--screenshot=" + out,
                            "http://127.0.0.1:%d/%s.html" % (port, name)],
                           check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            shutil.rmtree(profile, ignore_errors=True)
            print("wrote", os.path.relpath(out, ROOT))
        httpd.shutdown()
    shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    main()
