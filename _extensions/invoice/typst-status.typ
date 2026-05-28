// Invoice Format - Status Badge
// Render a payment-status badge for the invoice header.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let _status-styles = (
  paid: (label: "Paid", fill: rgb("#d1f7d6"), stroke: rgb("#2f8a3c")),
  unpaid: (label: "Unpaid", fill: rgb("#fff4d6"), stroke: rgb("#b88600")),
  overdue: (label: "Overdue", fill: rgb("#fadcdc"), stroke: rgb("#a72020")),
  draft: (label: "Draft", fill: luma(230), stroke: luma(120)),
  cancelled: (label: "Cancelled", fill: luma(230), stroke: luma(120)),
)

#let status-badge(status, fontsize: 12pt) = {
  if status == none { return none }
  let key = lower(str(status))
  if key == "" or key == "none" { return none }
  if not (key in _status-styles) {
    panic("Unknown invoice status: '" + key + "'. Expected one of: paid, unpaid, overdue, draft, cancelled.")
  }
  let style = _status-styles.at(key)
  box(
    fill: style.fill,
    stroke: 0.6pt + style.stroke,
    radius: 3pt,
    inset: (x: 6pt, y: 3pt),
    text(style.stroke, weight: "bold", size: fontsize * 0.85, upper(style.label)),
  )
}
