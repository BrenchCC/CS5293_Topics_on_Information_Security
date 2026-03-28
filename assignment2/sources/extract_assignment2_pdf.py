import argparse
import re
from pathlib import Path

import pdfplumber


def parse_args():
    """Parse command line arguments.

    Args:
        None.
    """
    parser = argparse.ArgumentParser(
        description = "Extract text from a PDF file into a Markdown document."
    )
    parser.add_argument(
        "--input",
        type = Path,
        required = True,
        help = "Path to the source PDF file."
    )
    parser.add_argument(
        "--output",
        type = Path,
        required = True,
        help = "Path to the generated Markdown file."
    )
    return parser.parse_args()


def normalize_page_text(text):
    """Normalize extracted page text for Markdown output.

    Args:
        text: Raw text extracted from one PDF page.
    """
    if not text:
        return "_No extractable text found on this page._"

    normalized_lines = [line.rstrip() for line in text.splitlines()]
    return "\n".join(normalized_lines).strip()


def remove_page_footer(
    lines,
    page_index
):
    """Remove standalone footer page numbers from extracted lines.

    Args:
        lines: Page text split into lines.
        page_index: One-based page index from the PDF.
    """
    filtered_lines = list(lines)

    while filtered_lines and not filtered_lines[-1].strip():
        filtered_lines.pop()

    if filtered_lines and filtered_lines[-1].strip() == str(page_index):
        filtered_lines.pop()

    return filtered_lines


def dedent_lines(lines):
    """Reduce common left padding while keeping relative indentation.

    Args:
        lines: Page text split into lines.
    """
    indents = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue

        indent = len(line) - len(line.lstrip())
        if indent > 0:
            indents.append(indent)

    if not indents:
        return [line.strip() for line in lines]

    common_indent = min(indents)
    dedented_lines = []

    for line in lines:
        if not line.strip():
            dedented_lines.append("")
            continue

        removable_indent = min(
            common_indent,
            len(line) - len(line.lstrip())
        )
        dedented_lines.append(line[removable_indent:].rstrip())

    return dedented_lines


def starts_code_block(line):
    """Heuristically identify whether a line starts a code block.

    Args:
        line: One normalized line of extracted text.
    """
    stripped = line.strip()
    if not stripped:
        return False

    code_patterns = [
        r"^(#include|extern\s+char|void\s+\w+|int\s+\w+|char\s+\*?\w+|while\s*\(|if\s*\(|for\s*\()",
        r"^(\/\*|\/\/|\$ |% )",
        r"^[{}]$",
        r"^[A-Za-z_]\w*\[[^\]]+\]\s*=",
        r"^[A-Za-z_]\w*\s*=",
        r".*;\s*$",
    ]

    return any(re.match(pattern, stripped) for pattern in code_patterns)


def clean_heading_title(title):
    """Remove table-of-contents leaders and trailing page numbers.

    Args:
        title: Heading text extracted from a PDF line.
    """
    cleaned = re.sub(r"\s*(?:\.\s*){3,}\d+\s*$", "", title).strip()
    cleaned = re.sub(r"\s+\d+\s*$", "", cleaned).strip()
    return re.sub(r"\s{2,}", " ", cleaned)


def format_regular_line(line):
    """Convert a plain extracted line into Markdown-friendly text.

    Args:
        line: One normalized line of extracted text.
    """
    stripped = line.strip()
    if not stripped:
        return ""

    stripped = stripped.replace("•", "-")

    heading_patterns = [
        (r"^(\d+\.\d+\.\d+)\s+(.*)$", "####"),
        (r"^(\d+\.\d+)\s+(.*)$", "###"),
        (r"^(\d+)\s+(.*)$", "##"),
    ]

    for pattern, prefix in heading_patterns:
        match = re.match(pattern, stripped)
        if match:
            section_id = match.group(1)
            title = clean_heading_title(match.group(2))
            return f"{prefix} {section_id} {title}"

    if stripped == "Contents":
        return "## Contents"

    if stripped == "What to Report.":
        return "### What to Report"

    if re.match(r"^Step\s+\d+\.", stripped):
        return f"**{stripped}**"

    if re.match(r"^[-*]\s+", stripped):
        return stripped

    if re.match(r"^\d+\.\s+", stripped):
        return stripped

    return re.sub(r"\s{2,}", " ", stripped)


def format_page_text(
    text,
    page_index
):
    """Convert one page of extracted text into readable Markdown.

    Args:
        text: Raw text extracted from one PDF page.
        page_index: One-based page index from the PDF.
    """
    if not text:
        return "_No extractable text found on this page._"

    normalized_text = normalize_page_text(text)
    lines = normalized_text.splitlines()
    lines = remove_page_footer(
        lines = lines,
        page_index = page_index
    )
    lines = dedent_lines(lines)

    formatted_lines = []
    in_code_block = False
    previous_blank = False

    for line in lines:
        stripped = line.strip()

        if not stripped:
            if in_code_block:
                formatted_lines.append("```")
                in_code_block = False

            if not previous_blank:
                formatted_lines.append("")
            previous_blank = True
            continue

        line_is_code = starts_code_block(line)

        if not in_code_block and line_is_code:
            formatted_lines.append("```c")
            in_code_block = True

        if in_code_block:
            formatted_lines.append(stripped)
        else:
            formatted_lines.append(format_regular_line(line))

        previous_blank = False

    if in_code_block:
        formatted_lines.append("```")

    while formatted_lines and not formatted_lines[-1].strip():
        formatted_lines.pop()

    return "\n".join(formatted_lines)


def extract_pdf_to_markdown(
    input_path,
    output_path
):
    """Extract PDF text page by page and save it as Markdown.

    Args:
        input_path: Source PDF path.
        output_path: Destination Markdown path.
    """
    output_path.parent.mkdir(
        parents = True,
        exist_ok = True
    )

    sections = [
        "# Assignment 2 Extracted Source",
        "",
        f"- Source PDF: `{input_path}`",
        ""
    ]

    with pdfplumber.open(str(input_path)) as pdf:
        sections.append(f"- Total pages: {len(pdf.pages)}")
        sections.append("")

        for page_index, page in enumerate(
            pdf.pages,
            start = 1
        ):
            page_text = page.extract_text(
                x_tolerance = 1,
                y_tolerance = 3,
                layout = True
            )
            sections.append(f"## Page {page_index}")
            sections.append("")
            sections.append(
                format_page_text(
                    text = page_text,
                    page_index = page_index
                )
            )
            sections.append("")

    output_path.write_text(
        "\n".join(sections).rstrip() + "\n",
        encoding = "utf-8"
    )


if __name__ == "__main__":
    args = parse_args()
    extract_pdf_to_markdown(
        input_path = args.input,
        output_path = args.output
    )
