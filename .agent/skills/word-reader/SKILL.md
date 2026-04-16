---
name: Word Document Reader
description: A skill to read and extract content from Microsoft Word (.docx) files, including text, tables, and metadata.
---

# Word Document Reader Skill

This skill provides the ability to read and extract structured information from Word documents.

## Prerequisites
- Python 3.x
- `python-docx` library (installed via `pip install python-docx`)

## Usage

Use the provided Python script to extract content.

### Extract Text and Tables
```bash
python .agent/skills/word-reader/scripts/read_docx.py path/to/document.docx
```

### Script details
The script `read_docx.py` will:
1. Extract all paragraphs.
2. Extract all tables with their structure preserved.
3. Output the result in a format easy for the AI to parse.
