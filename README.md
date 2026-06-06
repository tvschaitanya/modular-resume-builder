# JSON to Resume

A simple Python tool that turns your resume data into a clean, professional PDF.

---

## Why use this?

You open Word or Google Docs to update one bullet point. Twenty minutes later you're fixing a spacing issue on page two, realigning a date that shifted, and wondering why the margins look different than before. The content took two minutes — the formatting took the rest.

This tool takes a different approach — your content lives in a plain JSON file, the layout is handled separately and never changes. Update your experience, run one command, get a clean PDF every time.

---

## AI-assisted tailoring

`AI-Guide.md` at the root contains a prompt you can drop into any AI — Claude, ChatGPT, whatever you use. It understands the project structure, the JSON schema, and ATS requirements for 2026 tech roles.

The intended flow: give the AI the guide + your master `resume.json` + the job description → it runs a keyword gap analysis and outputs a tailored `resume.json` ready to drop into `data/` and build.

---

`data/` is a working directory — treat it like a temp folder, not a source of truth.

Your master `resume.json` should live somewhere outside this repo — a private gist, a personal vault, iCloud, wherever you keep things you don't want to lose. If you ever nuke this project or do a fresh clone, your data should be completely unaffected.

The intended workflow is: pull from your master copy → drop into `data/` → build → take the PDF. This repo is the renderer, not the storage layer.

---

## How it works

- Write your resume content in `data/resume.json`
- Write your contact info in `data/contact.json`
- Run the build script
- Get a timestamped HTML and PDF in `output/`

---

## Setup

Only one requirement — [uv](https://docs.astral.sh/uv/getting-started/installation/). Everything else including Python, dependencies, and Playwright's Chromium browser is handled automatically by `quick-run.sh`.

---

## Usage

```bash
./quick-run.sh
```

Or manually:

```bash
uv run src/build.py
```

Output:

```
HTML → output/resume_Jun-05-2026_02-30-45-PM.html
PDF  → output/resume_Jun-05-2026_02-30-45-PM.pdf
```

---

## Project structure

```
.
├── data/
│   ├── contact.json        # Name, email, phone, LinkedIn, GitHub, website
│   └── resume.json         # Summary, skills, experience, education, certifications
├── src/
│   └── build.py            # Core build logic
├── styles/
│   └── resume.css          # Design tokens — only edit variables here
├── templates/
│   └── resume.html.jinja   # HTML template
├── output/                 # Generated files (gitignored)
├── quick-run.sh                  # Quick launch script
├── Sample-Resume.pdf       # Sample output for reference
├── AI-Guide.md             # Prompt guide for AI-assisted resume tailoring
└── pyproject.toml          # Dependency config — no need to edit
```

---

## Customizing content

- Edit `data/resume.json` to update resume content
- Edit `data/contact.json` to update personal details
- `section_order` controls which sections appear and in what order
- Remove a section from `section_order` to hide it without deleting the data

```json
"section_order": ["summary", "skills", "experience", "education"]
```

---

## Customizing styles

- All visual settings are CSS variables at the top of `styles/resume.css`
- Only edit the variables block — never touch the class rules below it
- Switch to sans-serif by changing one line:

```css
--font-body: Arial, Helvetica, sans-serif;
```

---

## Custom templates

- Modify `templates/resume.html.jinja` and `styles/resume.css` to create your own design
- No need to touch `build.py` — build logic is completely separate from presentation

---

## PDF page format

Default is `Letter` (US). To use `A4`, edit `PDF_CONFIG` in `src/build.py`:

```python
PDF_CONFIG = {
    "format": "A4",
    ...
}
```

---

## HTML preview

- The generated HTML in `output/` is fully self-contained with inlined CSS
- Open it in any browser to preview without needing the project files
- Written as UTF-8 so it renders correctly on all operating systems including Windows

---

## ATS compatibility

- The PDF is text-based, not image-based
- Single column layout with standard fonts
- Verify by opening the PDF and copying text — if it copies cleanly, the text layer is intact
- Does not guarantee full ATS compatibility as parsing behavior varies across systems
