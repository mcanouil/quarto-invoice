# Invoice Format Template (Typst)

This is a Quarto template that assists you in creating PDF invoices via Typst.

## Creating a New Invoice

You can use this as a template to create an invoice.
To do this, use the following command:

```bash
quarto use template mcanouil/quarto-invoice
```

This will install the extension and create an example qmd file that you can use as a starting place for your invoice.

## Installation For Existing Document

You may also use this format with an existing Quarto project or document.
From the Quarto project or document directory, run the following command to install this format:

```bash
quarto add mcanouil/quarto-invoice@1.4.0
```

## Usage

To use the format, you can use the format name `invoice-typst`.
For example:

```bash
quarto render template.qmd --to invoice-typst
```

or in your document front matter:

```yaml
format:
  invoice-typst:
    lang: en
    region: UK
    papersize: a4
    margin:
      x: 2.5cm
      y: 2.5cm
    mainfont: "Alegreya Sans"
    fontsize: 12pt
```

### Structured Items

Define line items as a YAML array under `invoice.items` and the template renders an auto-generated totals table.
The excluding-VAT subtotal, VAT, and grand total are computed from `quantity`, `unit-price`, and `vat`.

```yaml
invoice:
  number: INV-2026-001
  issued: 2026-05-01
  due: 2026-05-31
  reference: ACME-2026-001
  currency: GBP
  items:
    - description: Strategy workshop
      details: Two-day on-site facilitation.
      quantity: 2
      unit-price: 1500
      vat: 20
    - description: Follow-up report
      quantity: 1
      unit-price: 850
      vat: 20
```

When `invoice.items` is omitted, the body of the document is rendered in place of the table.
This keeps backward compatibility with hand-crafted Typst tables.

### Currency

Set `invoice.currency` to an ISO 4217 code (for example `EUR`, `USD`, `GBP`, `CHF`, `JPY`).
Amounts are formatted with locale-aware decimal and thousand separators based on `lang`.
Codes without a built-in symbol are emitted as the code itself followed by a space.

### Date Validation

The `invoice.due` date must be on or after `invoice.issued`.
A render-time error is raised if the dates are inverted, instead of silently producing a nonsensical document.

### Brand Integration

The template honours [`_brand.yml`](https://posit-dev.github.io/brand-yml/) for typography and heading colour:

```yaml
brand:
  typography:
    fonts:
      - family: Alegreya Sans
        source: google
        weight: [400, 700]
        style: [normal, italic]
    base:
      family: "Alegreya Sans"
      size: 12pt
    headings:
      family: "Alegreya Sans"
      color: dodgerblue
```

A self-contained brand example is provided under [`examples/`](examples/) (see `examples/_brand.yml` and `examples/template-brand.qmd`).

## Example

Here is the source code for a minimal example: [template.qmd](template.qmd).

You can view a preview of the rendered template here: [Invoice Template](https://m.canouil.dev/quarto-invoice/index.pdf).
