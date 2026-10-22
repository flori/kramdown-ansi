| A | B |
|---|---|
| 1 | 2 |

## Case 00 — Table at Document Start

## Case 01 — Column Count Mismatch

Header has 3 columns, data rows have 5 and 1.

| A | B | C |
|:-:|:-:|:-:|
| 1 | 2 | 3 | 4 | 5 |
| only-one |
| a | b | c | d |

## Case 02 — No Leading / Trailing Pipes

GFM allows omitting the outer `|`. Renderer must still split on inner pipes.

| A | B | C
|:-:|:-:|:-:
| 1 | 2 | 3
| 4 | 5 | 6

## Case 03 — Escaped Pipe in Cell

`\|` should render as a literal `|`, not split the column.

| Col | Value |
|:----|:------|
| `a\|b` | 1 |
| `x \| y` | 2 |
| no-escape-but-literal | pipe |

## Case 04 — Empty Cells

| A | B | C |
|:-:|:-:|:-:|
|  |  |  |
| left |  | right |
|  | mid |  |
|    |   |     |

## Case 05 — Single-Column Table

| Only |
|:-----|
| one |
| two |
| three |

## Case 06 — Header + Alignment Only (No Data Rows)

not a table

| X | Y | Z |
|:-:|:-:|:-:|

## Case 07 — Back-to-Back Tables (No Blank Line)

| T1a | T1b |
|:----|:----|
| a | b |
| T2a | T2b |
|:----|:----|
| c | d |

## Case 08 — Full-Width / Variable-Width Unicode

CJK, emoji (double-width), combining marks — column widths will *lie*.

| Char | Width | Note |
|:-----|:------|:-----|
| `你` | 2 cells | CJK |
| `💜` | 2 cells | Emoji |
| `e\u0301` | 1+0 | Combining acute |
| `☝` | 2 cells | DBCS symbol |
| `|` | 1 cell | Looks like a pipe, isn't |

## Case 09 — Markdown *Inside* Cells

Bold, italic, code, links, strikethrough, nested.

| Cell | Renders |
|:-----|:--------|
| `**bold**` | **bold** |
| `*it*` | *it* |
| `` `code` `` | `code` |
| `[link](https://x)` | [link](https://x) |
| `~~gone~~` | ~~gone~~ |
| `**_both_**` | **_both_** |

## Case 10 — Alignment Row Has Wrong Column Count

| A | B | C |
|:-:|:-:|

## Case 11 — Table Split by Blank Line

| A | B |
|:-:|:-:|
| 1 | 2 |

| A | B |
|:-:|:-:|
| 3 | 4 |

## Case 12 — Excessive Whitespace Padding

|   A   |   B   |   C   |
| :---: | :---: | :---: |
|      1      |      2      |      3      |

## Case 13 — `<br>` and HTML in Cells

| Cell | Content |
|:-----|:--------|
| br | line1<br>line2 |
| html | `<span>inline</span>` |
| both | **bold** <br> *italic* |

## Case 14 — Pipe at Both Ends, Nothing Between

|  |
|:-:|
|  |

## Case 15 — One Data Row, 10 Columns

| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:--:|
| a | b | c | d | e | f | g | h | i | j |

## Case 16 — Alignment Row with Mixed/Invalid Markers

| A | B | C |
|:--|--:|---|
| l | r | d |

## Case 17 — Table at Document Start, Glued to Following Header

| a | b |
|---|---|
| 1 | 2 |
# next section

## Case 18 — Table Glued to Preceding Header

# heading
| a | b |
|---|---|
| 1 | 2 |

## Case 19 — Single Column, No Trailing Pipe on Header

| a table
|-|
|hi|

## Case 20 — Not a Table: Single Pipe Line

|not a table

## Case 21 — Not a Table: Header + Sep, No Body, Missing Closing Pipe

|not a table
|-|

## Case 22 — Table After Code Block, Glued

```
some code
```
| a | b |
|---|---|
| 1 | 2 |

## Case 23 — Table After List Item, Glued

- item one
- item two
| a | b |
|---|---|
| 1 | 2 |

## Case 24 — No Leading Pipe on Separator

| a | b |
:---|---:
| 1 | 2 |

## Case 25 — No Leading Pipe on Body Row

| a | b |
|---|---|
1 | 2

## Case 26 — Indented Table Inside Ordered List

1. **Flatten it.**

   | Service | Sub | Value |
   |:--------|:----|:------|
   | `ollama_chat` | `kramdown-ansi` | 🟢 |

## Case 27 — Not a table just a pipe in a sentence

a | b

---

| Case | What It Stresses |
|:-----|:-----------------|
| 01 | Column count validation / overflow / underflow |
| 02 | Pipe-stripping logic (leading/trailing optional) |
| 03 | Escape sequence handling (`\|`) |
| 04 | Empty-string cell rendering, border alignment |
| 05 | Single-column edge (degenerate table) |
| 06 | Zero data rows — does it draw a header-only box? |
| 07 | Consecutive tables — does the second become data of the first? |
| 08 | Unicode width calculation for column sizing |
| 09 | Inline markdown rendering *inside* a table cell |
| 10 | Alignment row with fewer columns than header |
| 11 | Blank line splitting one table into two |
| 12 | Whitespace normalization / trimming |
| 13 | Raw HTML + `<br>` in cell context |
| 14 | Cell with only whitespace — empty or not? |
| 15 | Very wide table — does it wrap or overflow? |
| 16 | Non-standard alignment markers |
| 17 | Table at doc start, glued to following header |
| 18 | Table glued to preceding header (no blank before) |
| 19 | Single col, missing closing pipe on header |
| 20 | Not a table: single pipe line |
| 21 | Not a table: header + sep, no body, missing pipe |
| 22 | Table after code block, no blank between |
| 23 | Table after list item, no blank between |
| 24 | No leading pipe on separator row |
| 25 | No leading pipe on body row |
| 26 | Indented table inside ordered list item |
| 27 | Not a table just a pipe in a sentence |
