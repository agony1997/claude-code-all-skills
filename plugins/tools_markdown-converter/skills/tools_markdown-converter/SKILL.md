---
name: tools_markdown-converter
description: "Comprehensive Markdown format conversion toolkit for converting between Markdown and other formats including HTML, PDF, Word (DOCX), and plain text. When Claude needs to: (1) Convert Markdown to HTML/PDF/DOCX, (2) Convert HTML/PDF/DOCX to Markdown, (3) Generate styled documents from Markdown, (4) Extract content to Markdown format, (5) Batch convert documents, or (6) Markdown轉換、格式互轉、HTML轉換、PDF生成、Word轉換、文檔轉換"
---

# Markdown 轉換器

## 概述

本技能提供全面的 Markdown 轉換功能，可在 Markdown 與多種格式之間進行文件轉換，包括 HTML、PDF、Word（DOCX）及純文字。主要使用 pandoc 作為通用文件轉換器，並搭配額外的 Python 函式庫來滿足特定的轉換需求。

## 何時使用本技能

**當使用者提及以下內容時，務必使用本技能：**
- 將 Markdown 轉換為其他格式（HTML、PDF、DOCX 等）
- 將其他格式轉換為 Markdown
- 從 Markdown 生成帶有樣式的 PDF
- 從 Markdown 建立 Word 文件
- 將內容提取為 Markdown
- 批次轉換文件格式
- 發布 Markdown 文件

**觸發用語包括：**
- "Convert Markdown to HTML/PDF/Word" / "轉換Markdown為HTML/PDF/Word"
- "Convert HTML/PDF/Word to Markdown" / "轉換HTML/PDF/Word為Markdown"
- "Generate PDF from Markdown" / "從Markdown生成PDF"
- "Markdown to DOCX" / "Markdown轉DOCX"
- "Extract to Markdown" / "提取為Markdown"
- "Batch convert Markdown" / "批量轉換Markdown"
- "Publish Markdown documentation" / "發布Markdown文檔"
- "Create HTML from Markdown" / "從Markdown建立HTML"

## 如何使用本技能

### 工作流程概述

本技能依照轉換方向採用系統化的方法：

1. **辨識格式** — 確定來源格式與目標格式
2. **選擇工具** — 選擇 pandoc 或適當的 Python 函式庫
3. **執行轉換** — 使用正確的選項與樣式進行轉換
4. **驗證輸出** — 確認格式與內容的完整性

### 主要工具：pandoc

pandoc 是一款通用文件轉換器，支援多種格式。

#### 安裝

```bash
# Ubuntu/Debian
sudo apt-get install pandoc

# macOS
brew install pandoc

# Windows
choco install pandoc
```

#### 基本用法

```bash
# Convert Markdown to HTML
pandoc input.md -o output.html

# Convert Markdown to PDF
pandoc input.md -o output.pdf

# Convert Markdown to DOCX
pandoc input.md -o output.docx
```

## Markdown 轉換為其他格式

### Markdown 轉 HTML

```bash
# Basic conversion
pandoc input.md -o output.html

# With custom CSS
pandoc input.md -o output.html --css=style.css

# Standalone HTML with embedded CSS
pandoc input.md -o output.html --standalone --css=style.css

# With table of contents
pandoc input.md -o output.html --toc --toc-depth=3

# With syntax highlighting
pandoc input.md -o output.html --highlight-style=tango

# Complete example with all features
pandoc input.md -o output.html \
    --standalone \
    --toc \
    --toc-depth=3 \
    --css=style.css \
    --highlight-style=github \
    --metadata title="Document Title"
```

### Markdown 轉 PDF

```bash
# Basic conversion (requires LaTeX)
pandoc input.md -o output.pdf

# With custom margins
pandoc input.md -o output.pdf \
    -V geometry:margin=1in

# With custom font
pandoc input.md -o output.pdf \
    -V mainfont="Times New Roman" \
    -V fontsize=12pt

# With table of contents
pandoc input.md -o output.pdf \
    --toc \
    --toc-depth=3

# Complete professional PDF
pandoc input.md -o output.pdf \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=3 \
    -V geometry:margin=1in \
    -V mainfont="Arial" \
    -V fontsize=11pt \
    -V documentclass=article \
    --highlight-style=tango \
    --metadata title="Professional Report" \
    --metadata author="John Doe" \
    --metadata date="2024-01-15"
```

### Markdown 轉 Word（DOCX）

```bash
# Basic conversion
pandoc input.md -o output.docx

# With reference document for styling
pandoc input.md -o output.docx --reference-doc=template.docx

# With table of contents
pandoc input.md -o output.docx --toc --toc-depth=3

# With metadata
pandoc input.md -o output.docx \
    --metadata title="Document Title" \
    --metadata author="Author Name" \
    --metadata date="2024-01-15"

# Complete example
pandoc input.md -o output.docx \
    --reference-doc=custom_template.docx \
    --toc \
    --toc-depth=3 \
    --highlight-style=tango \
    --metadata title="Professional Document"
```

### Markdown 轉純文字

```bash
# Convert to plain text
pandoc input.md -o output.txt --to=plain

# With line wrapping
pandoc input.md -o output.txt --to=plain --wrap=auto

# Preserve line breaks
pandoc input.md -o output.txt --to=plain --wrap=preserve
```

## 其他格式轉換為 Markdown

### HTML 轉 Markdown

```bash
# Basic conversion
pandoc input.html -o output.md

# With specific Markdown flavor
pandoc input.html -o output.md --to=gfm  # GitHub Flavored Markdown

# Preserve structure
pandoc input.html -o output.md \
    --to=markdown_strict \
    --wrap=preserve

# With ATX-style headers
pandoc input.html -o output.md --markdown-headings=atx
```

### Word（DOCX）轉 Markdown

```bash
# Basic conversion
pandoc input.docx -o output.md

# With GitHub Flavored Markdown
pandoc input.docx -o output.md --to=gfm

# Extract images
pandoc input.docx -o output.md --extract-media=./images

# With tracked changes
pandoc input.docx -o output.md --track-changes=all
```

### PDF 轉 Markdown

```bash
# Extract text and convert to Markdown
pdftotext input.pdf - | pandoc -f plain -o output.md

# Using Python with pdfplumber
```

```python
import pdfplumber

with pdfplumber.open('input.pdf') as pdf:
    markdown_content = ""
    for i, page in enumerate(pdf.pages, start=1):
        markdown_content += f"## Page {i}\n\n"
        markdown_content += page.extract_text() + "\n\n"

with open('output.md', 'w', encoding='utf-8') as f:
    f.write(markdown_content)
```

### LaTeX 轉 Markdown

```bash
# Convert LaTeX to Markdown
pandoc input.tex -o output.md

# With specific Markdown variant
pandoc input.tex -o output.md --to=gfm
```

## 進階轉換

### Markdown 轉簡報（Reveal.js）

```bash
# Create HTML presentation
pandoc slides.md -o slides.html -t revealjs -s

# With theme
pandoc slides.md -o slides.html -t revealjs -s \
    -V theme=moon

# With incremental bullets
pandoc slides.md -o slides.html -t revealjs -s \
    --incremental
```

### Markdown 轉 EPUB

```bash
# Create EPUB book
pandoc book.md -o book.epub

# With metadata
pandoc book.md -o book.epub \
    --metadata title="Book Title" \
    --metadata author="Author Name" \
    --epub-cover-image=cover.jpg

# With CSS styling
pandoc book.md -o book.epub --css=style.css
```

### 多個 Markdown 檔案合併為單一文件

```bash
# Combine multiple Markdown files
pandoc chapter1.md chapter2.md chapter3.md -o book.pdf

# With separators
pandoc *.md -o combined.html --toc

# Maintain file order
pandoc intro.md main.md conclusion.md -o complete.docx
```

## 基於 Python 的轉換

### 使用 markdown2

```python
import markdown2

# Convert Markdown to HTML
with open('input.md', 'r', encoding='utf-8') as f:
    md_content = f.read()

html = markdown2.markdown(md_content, extras=['tables', 'fenced-code-blocks'])

with open('output.html', 'w', encoding='utf-8') as f:
    f.write(html)
```

### 使用 mistune

```python
import mistune

# Convert Markdown to HTML
with open('input.md', 'r', encoding='utf-8') as f:
    md_content = f.read()

html = mistune.html(md_content)

with open('output.html', 'w', encoding='utf-8') as f:
    f.write(html)
```

### 使用 pypandoc（pandoc 的 Python 封裝）

```python
import pypandoc

# Convert Markdown to HTML
pypandoc.convert_file('input.md', 'html', outputfile='output.html')

# Convert Markdown to PDF
pypandoc.convert_file('input.md', 'pdf', outputfile='output.pdf',
                      extra_args=['--pdf-engine=xelatex'])

# Convert Markdown to DOCX
pypandoc.convert_file('input.md', 'docx', outputfile='output.docx')

# Convert HTML to Markdown
pypandoc.convert_file('input.html', 'md', outputfile='output.md')

# Convert with options
pypandoc.convert_file('input.md', 'html', outputfile='output.html',
                      extra_args=['--toc', '--css=style.css', '--standalone'])
```

### 使用 html2text 將 HTML 轉為 Markdown

```python
import html2text

# Convert HTML to Markdown
with open('input.html', 'r', encoding='utf-8') as f:
    html_content = f.read()

h = html2text.HTML2Text()
h.ignore_links = False
h.ignore_images = False
markdown = h.handle(html_content)

with open('output.md', 'w', encoding='utf-8') as f:
    f.write(markdown)
```

## 批次轉換

### 批次將 Markdown 轉為 HTML

```bash
# Convert all Markdown files in directory
for file in *.md; do
    pandoc "$file" -o "${file%.md}.html" --standalone --css=style.css
done
```

```python
import os
import subprocess
from pathlib import Path

def batch_md_to_html(input_dir, output_dir):
    """Convert all Markdown files to HTML"""
    Path(output_dir).mkdir(exist_ok=True)

    for filename in os.listdir(input_dir):
        if filename.endswith('.md'):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename.replace('.md', '.html'))

            subprocess.run([
                'pandoc',
                input_path,
                '-o', output_path,
                '--standalone',
                '--css=style.css'
            ])
            print(f"Converted: {filename}")

batch_md_to_html('markdown_files', 'html_files')
```

### 批次將 Markdown 轉為 PDF

```python
import os
import subprocess
from pathlib import Path

def batch_md_to_pdf(input_dir, output_dir):
    """Convert all Markdown files to PDF"""
    Path(output_dir).mkdir(exist_ok=True)

    for filename in os.listdir(input_dir):
        if filename.endswith('.md'):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename.replace('.md', '.pdf'))

            subprocess.run([
                'pandoc',
                input_path,
                '-o', output_path,
                '--pdf-engine=xelatex',
                '--toc',
                '-V', 'geometry:margin=1in'
            ])
            print(f"Converted: {filename}")

batch_md_to_pdf('docs', 'pdf_output')
```

### 批次轉換為多種格式

```python
import os
import subprocess

def convert_to_multiple_formats(input_file):
    """Convert single Markdown file to HTML, PDF, and DOCX"""
    base_name = input_file.replace('.md', '')

    # To HTML
    subprocess.run(['pandoc', input_file, '-o', f'{base_name}.html',
                   '--standalone', '--toc'])

    # To PDF
    subprocess.run(['pandoc', input_file, '-o', f'{base_name}.pdf',
                   '--pdf-engine=xelatex', '--toc'])

    # To DOCX
    subprocess.run(['pandoc', input_file, '-o', f'{base_name}.docx',
                   '--toc'])

    print(f"Converted {input_file} to HTML, PDF, and DOCX")

# Convert all Markdown files
for file in os.listdir('.'):
    if file.endswith('.md'):
        convert_to_multiple_formats(file)
```

## 自訂樣式與範本

### 建立自訂 HTML 範本

```html
<!-- template.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$title$</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1, h2, h3 { color: #333; }
        code { background: #f4f4f4; padding: 2px 5px; }
        pre { background: #f4f4f4; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
$body$
</body>
</html>
```

```bash
# Use custom template
pandoc input.md -o output.html --template=template.html
```

### 建立自訂 CSS

```css
/* style.css */
body {
    font-family: 'Georgia', serif;
    max-width: 900px;
    margin: 0 auto;
    padding: 40px;
    color: #333;
    line-height: 1.8;
}

h1 {
    color: #2c3e50;
    border-bottom: 2px solid #3498db;
    padding-bottom: 10px;
}

h2 {
    color: #34495e;
    margin-top: 30px;
}

code {
    background-color: #f8f8f8;
    border: 1px solid #ddd;
    padding: 2px 6px;
    border-radius: 3px;
}

pre {
    background-color: #f8f8f8;
    border: 1px solid #ddd;
    padding: 15px;
    overflow-x: auto;
    border-radius: 5px;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 12px;
    text-align: left;
}

th {
    background-color: #3498db;
    color: white;
}
```

```bash
# Use custom CSS
pandoc input.md -o output.html --css=style.css --standalone
```

### 建立 Word 範本

```bash
# Generate reference document
pandoc -o reference.docx --print-default-data-file reference.docx

# Modify reference.docx in Word (change fonts, styles, etc.)

# Use custom template
pandoc input.md -o output.docx --reference-doc=reference.docx
```

## 文件發布工作流程

### 產生靜態文件網站

```bash
# Convert all docs to HTML with navigation
mkdir -p site
for file in docs/*.md; do
    filename=$(basename "$file" .md)
    pandoc "$file" -o "site/${filename}.html" \
        --standalone \
        --toc \
        --css=../style.css \
        --template=template.html
done
```

### 建立 PDF 文件

```bash
# Combine all documentation into single PDF
pandoc docs/*.md -o documentation.pdf \
    --toc \
    --toc-depth=3 \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V mainfont="Arial" \
    -V fontsize=11pt \
    --highlight-style=tango
```

### 匯出為多種格式

```python
import subprocess

def export_documentation(source_dir, output_base):
    """Export documentation to HTML, PDF, and DOCX"""

    # HTML version
    subprocess.run([
        'pandoc', f'{source_dir}/*.md',
        '-o', f'{output_base}.html',
        '--standalone', '--toc', '--css=style.css'
    ], shell=True)

    # PDF version
    subprocess.run([
        'pandoc', f'{source_dir}/*.md',
        '-o', f'{output_base}.pdf',
        '--toc', '--pdf-engine=xelatex'
    ], shell=True)

    # DOCX version
    subprocess.run([
        'pandoc', f'{source_dir}/*.md',
        '-o', f'{output_base}.docx',
        '--toc'
    ], shell=True)

export_documentation('docs', 'documentation')
```

## 最佳實踐

### 轉換品質
- 使用 pandoc 以獲得最佳的格式相容性
- 指定 metadata（中繼資料）如標題、作者、日期，以獲得更好的輸出
- 使用參考文件以確保樣式一致
- 在目標格式的檢視器中測試輸出結果

### 撰寫適合轉換的 Markdown
- 使用標準 Markdown 語法以獲得最佳相容性
- 使用 ATX 樣式標題（# ## ###）而非 Setext 樣式
- 在各元素之間加入空行
- 使用帶有語言標示的圍欄式程式碼區塊（fenced code blocks）

### 樣式與格式設定
- 建立自訂範本以維持一致的品牌風格
- 使用 CSS 設定 HTML 輸出的樣式
- 使用參考文件設定 Word/PDF 的樣式
- 測試不同的 CSS/主題

### 效能
- 使用批次腳本處理多個檔案
- 注意 PDF 生成時的檔案大小
- 在加入 Markdown 之前先壓縮圖片
- 使用適當的 PDF 引擎（xelatex 用於 Unicode）

### 錯誤處理
- 在轉換前驗證 Markdown 語法
- 檢查是否有遺失的圖片或參照
- 先以範例內容進行測試
- 妥善處理特殊字元

## 快速參考

| 轉換方向 | 指令 |
|----------|------|
| MD → HTML | `pandoc input.md -o output.html --standalone` |
| MD → PDF | `pandoc input.md -o output.pdf --pdf-engine=xelatex` |
| MD → DOCX | `pandoc input.md -o output.docx` |
| HTML → MD | `pandoc input.html -o output.md` |
| DOCX → MD | `pandoc input.docx -o output.md` |
| MD → HTML（含 CSS） | `pandoc input.md -o output.html --css=style.css -s` |
| MD → PDF（含目錄） | `pandoc input.md -o output.pdf --toc` |
| 多個 MD → PDF | `pandoc *.md -o output.pdf --toc` |

## 關鍵字

**英文關鍵字：**
markdown converter, markdown to html, markdown to pdf, markdown to word, html to markdown, pdf to markdown, docx to markdown, document conversion, pandoc, markdown transformation, format conversion, documentation publishing

**中文關鍵詞：**
Markdown轉換, Markdown轉HTML, Markdown轉PDF, Markdown轉Word, HTML轉Markdown, PDF轉Markdown, DOCX轉Markdown, 文檔轉換, 格式轉換, 文檔發布
