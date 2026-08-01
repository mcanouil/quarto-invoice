# Invoice Format For Quarto

A Quarto format for invoices: sender, recipient, line items, VAT, and bank details, rendered to PDF through Typst.

The totals table is computed from the line items, so the arithmetic is not yours to keep in step.

## Creating a New Invoice

```bash
quarto use template mcanouil/quarto-invoice@2.0.1
```

## Installation For Existing Document

```bash
quarto add mcanouil/quarto-invoice@2.0.1
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-invoice/>: every option, the line items and how the totals are computed, currency handling, the date validation, brand integration, and an invoice rendered by the site itself.

[`template.qmd`](template.qmd) is a complete starting point you can copy.

## Licence

[MIT](https://github.com/mcanouil/quarto-invoice?tab=MIT-1-ov-file#readme).
