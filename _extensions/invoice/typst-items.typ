// Invoice Format - Items Table
// Render a structured items list as a Typst table with totals.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let _coerce-number(value, default: 0) = {
  if value == none { return default }
  if type(value) == int or type(value) == float { return float(value) }
  let cleaned = str(value)
  if cleaned.trim() == "" { return default }
  float(cleaned)
}

#let _item-totals(items) = {
  let total-excl = 0.0
  let total-vat = 0.0
  for item in items {
    let quantity = _coerce-number(item.at("quantity", default: 1), default: 1)
    let unit-price = _coerce-number(item.at("unit-price", default: 0), default: 0)
    let vat-rate = _coerce-number(item.at("vat", default: 0), default: 0)
    let line-excl = quantity * unit-price
    let line-vat = line-excl * vat-rate / 100
    total-excl = total-excl + line-excl
    total-vat = total-vat + line-vat
  }
  (excluding-vat: total-excl, vat: total-vat, total: total-excl + total-vat)
}

#let items-table(
  items,
  format-money,
  labels: (
    details: "Details",
    quantity: "Qty",
    unit-price: "Unit price",
    vat: "VAT %",
    total: "Total excl. VAT",
    total-excl: "Total excl. VAT",
    total-vat: "VAT",
    total-incl: "Total",
  ),
) = {
  if items == none or items.len() == 0 {
    return none
  }

  let header-fill = luma(240)
  let footer-fill = luma(240)
  let cells = ()

  cells.push(table.cell(fill: header-fill, [*#labels.details*]))
  cells.push(table.cell(fill: header-fill, [*#labels.quantity*]))
  cells.push(table.cell(fill: header-fill, [*#labels.unit-price*]))
  cells.push(table.cell(fill: header-fill, [*#labels.vat*]))
  cells.push(table.cell(fill: header-fill, [*#labels.total*]))

  for item in items {
    let description = item.at("description", default: "")
    let details = item.at("details", default: none)
    let quantity = _coerce-number(item.at("quantity", default: 1), default: 1)
    let unit-price = _coerce-number(item.at("unit-price", default: 0), default: 0)
    let vat-rate = _coerce-number(item.at("vat", default: 0), default: 0)
    let line-excl = quantity * unit-price

    let body = if details != none and str(details).trim() != "" {
      [*#description* \ _#details _]
    } else {
      [*#description*]
    }

    let quantity-display = if calc.rem(quantity, 1) == 0 {
      str(int(quantity))
    } else {
      str(quantity)
    }

    cells.push(body)
    cells.push(quantity-display)
    cells.push(format-money(unit-price))
    cells.push(str(int(vat-rate)) + " %")
    cells.push(format-money(line-excl))
  }

  let totals = _item-totals(items)
  let total-row(label, value, fill) = (
    [], [],
    table.cell(fill: fill, colspan: 2, align: left + horizon)[*#label*],
    table.cell(fill: fill)[#format-money(value)],
  )

  cells.push(table.hline(stroke: 0.5pt + luma(180)))
  cells += total-row(labels.total-excl, totals.excluding-vat, luma(240))
  cells += total-row(labels.total-vat, totals.vat, white)
  cells += (
    [], [],
    table.cell(fill: luma(220), colspan: 2, align: left + horizon)[#text(size: 1.1em)[*#labels.total-incl*]],
    table.cell(fill: luma(220))[#text(size: 1.1em)[*#format-money(totals.total)*]],
  )

  table(
    columns: (1fr, auto, auto, auto, auto),
    rows: 36pt,
    inset: 5pt,
    align: (left + horizon, right + horizon, right + horizon, right + horizon, right + horizon),
    stroke: none,
    ..cells,
  )
}
