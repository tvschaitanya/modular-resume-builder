from pathlib import Path
from datetime import datetime
import json
from jinja2 import Environment, FileSystemLoader
from playwright.sync_api import sync_playwright

# ── Paths ──────────────────────────────────────────────────────────────────
ROOT      = Path(__file__).parent.parent
DATA      = ROOT / "data"
TEMPLATES = ROOT / "templates"
STYLES    = ROOT / "styles"
OUTPUT    = ROOT / "output"

# ── Config ─────────────────────────────────────────────────────────────────
PDF_CONFIG = {
    "format": "Letter",
    "margin": {"top": "0.4in", "bottom": "0.4in", "left": "0.4in", "right": "0.4in"},
    "print_background": True,
}

# ── Jinja Filters ──────────────────────────────────────────────────────────
def fmt_date(val: str) -> str:
    """MM-YYYY → Mon YYYY. Passes 'Present' through."""
    if not val or val.strip().lower() == "present":
        return "Present"
    try:
        return datetime.strptime(val.strip(), "%m-%Y").strftime("%b %Y")
    except ValueError:
        return val

def clean_url(val: str) -> str:
    """Strip https://, http://, www. for display."""
    for prefix in ("https://www.", "http://www.", "https://", "http://"):
        if val.startswith(prefix):
            return val[len(prefix):]
    return val

FILTERS = {
    "fmt_date":  fmt_date,
    "clean_url": clean_url,
}

# ── Core ───────────────────────────────────────────────────────────────────
def _load_json(filename: str) -> dict:
    path = DATA / filename
    if not path.exists():
        raise FileNotFoundError(f"Missing data file: {path}")
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in '{filename}': {e}") from e

def load_data() -> tuple[dict, dict]:
    return _load_json("contact.json"), _load_json("resume.json")

def build_html(contact: dict, resume: dict) -> str:
    env = Environment(loader=FileSystemLoader(str(TEMPLATES)), autoescape=False)
    env.filters.update(FILTERS)
    css = (STYLES / "resume.css").read_text()
    return env.get_template("resume.html.jinja").render(contact=contact, resume=resume, css=css)

def export_pdf(html: str, out: Path) -> None:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        try:
            page = browser.new_page()
            page.set_content(html, wait_until="networkidle")
            page.pdf(path=str(out), **PDF_CONFIG)
        finally:
            browser.close()

def main() -> None:
    OUTPUT.mkdir(exist_ok=True)

    contact, resume = load_data()
    html            = build_html(contact, resume)

    stamp    = datetime.now().strftime("%b-%d-%Y_%I-%M-%S-%p")
    html_out = OUTPUT / f"resume_{stamp}.html"
    pdf_out  = OUTPUT / f"resume_{stamp}.pdf"

    html_out.write_text(html, encoding="utf-8")
    print(f"HTML → {html_out}  (open in browser to preview)")

    export_pdf(html, pdf_out)
    print(f"PDF  → {pdf_out}")

if __name__ == "__main__":
    main()