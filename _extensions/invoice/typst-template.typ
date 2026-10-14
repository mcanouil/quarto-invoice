#let parse-date(date) = {
  let cleaned = str(date).replace("\\", "")
  let parts = cleaned.split("-").map(int)
  if parts.len() != 3 {
    panic("Invalid date '" + cleaned + "'. Expected ISO format YYYY-MM-DD.")
  }
  datetime(year: parts.at(0), month: parts.at(1), day: parts.at(2))
}

#let default-labels = (
  title: "Invoice",
  registration: "Registration number",
  vat-number: "VAT number",
  number: "Invoice number",
  issued: "Issued on",
  due: "Payment due date",
  payment-title: "Payment information",
  reference: "Reference",
  reference-note: "To be used as label on your bank transfer to identify the transaction.",
  item-details: "Details",
  item-quantity: "Qty",
  item-unit-price: "Unit price",
  item-vat: "VAT %",
  item-total: "Total excl. VAT",
  total-excl: "Total excl. VAT",
  total-vat: "VAT",
  total-incl: "Total",
  terms: "{sender} sent you this invoice on {date}. The invoice must be paid in under {days} days, otherwise you will have to pay a late fee of {fee} % and a {penalty} penalty for recovery costs. No discount will be granted for early settlement.",
  months: "January, February, March, April, May, June, July, August, September, October, November, December",
  date: "the {day}{ordinal} of {month}, {year}",
  ordinals: "st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st",
)

#let resolve-labels(labels) = {
  let resolved = default-labels
  if labels != none {
    for (key, value) in labels {
      if value != none and value != "" {
        resolved.insert(key, value)
      }
    }
  }
  resolved
}

#let split-list(value) = value.split(",").map(str.trim)

#let fill(template, values) = {
  let out = []
  let cursor = 0
  for match in template.matches(regex("\{([a-z]+)\}")) {
    out += template.slice(cursor, match.start)
    out += values.at(match.captures.at(0), default: match.text)
    cursor = match.end
  }
  out + template.slice(cursor)
}

#let format-date(date, labels) = {
  let day = date.day()
  let ordinals = split-list(labels.ordinals)
  let ordinal = ordinals.at(calc.min(day, ordinals.len()) - 1)
  let months = split-list(labels.months)
  if months.len() != 12 {
    panic("Language key 'invoice-months' must list 12 month names separated by commas, found " + str(months.len()) + ": '" + labels.months + "'.")
  }
  fill(labels.date, (
    day: str(day),
    ordinal: if ordinal == "" { [] } else { super(ordinal) },
    month: months.at(date.month() - 1),
    year: str(date.year()),
  ))
}

#let count-days(x, y) = {
  let duration = y - x
  str(duration.days())
}

#let invoice(
  logo: none,
  title: none,
  description: none,
  sender: none,
  recipient: none,
  invoice: none,
  bank: none,
  fee: 2.28,
  penalty: 40,
  currency: "EUR",
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  lang: "en",
  region: "UK",
  font: "Alegreya Sans",
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-decoration: none,
  heading-color: black,
  heading-line-height: 0.65em,
  fontsize: 12pt,
  title-size: 1.5em,
  labels: none,
  body
) = {
  let labels = resolve-labels(labels)

  show heading: it => {
    set par(leading: heading-line-height)
    set text(weight: heading-weight, style: heading-style, fill: heading-color)
    if heading-family != none {
      set text(font: heading-family)
      it.body
    } else {
      it.body
    }
  }

  let issued = parse-date(invoice.at("issued"))
  let due = parse-date(invoice.at("due"))
  if due < issued {
    panic(
      "Invoice 'due' date (" + invoice.at("due") + ") must be on or after 'issued' date (" + invoice.at("issued") + ")."
    )
  }

  let invoice-currency = invoice.at("currency", default: currency)
  let invoice-fee = _coerce-number(invoice.at("fee", default: fee), default: fee)
  let invoice-penalty-raw = invoice.at("penalty", default: penalty)
  let invoice-items = invoice.at("items", default: none)

  let money(value) = format-money(
    value,
    currency: invoice-currency,
    lang: lang,
    region: region,
  )

  let penalty-display = if type(invoice-penalty-raw) == int or type(invoice-penalty-raw) == float {
    money(invoice-penalty-raw)
  } else {
    str(invoice-penalty-raw).replace("\\", "")
  }

  set document(
    title: labels.title + " " + invoice.at("number").replace("\\", "") + " - " + recipient.at("name").replace("\\", ""),
    author: sender.at("name").replace("\\", ""),
    date: issued
  )
  set page(
    paper: paper,
    margin: margin,
  )
  set par(justify: true)
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize,
  )

  grid(
    columns: (50%, 50%),
    align(left, {
      heading(level: 2, sender.at("name").replace("\\", ""))

      if "address" in sender and sender != none {
        v(fontsize * 0.5)
        emph(sender.at("address").at("street").replace("\\", ""))
        linebreak()
        sender.at("address").at("zip").replace("\\", "") + " " + sender.at("address").at("city").replace("\\", "")
        if "state" in sender.at("address") and not sender.at("address").at("state") in (none, "") {
          ", " + sender.at("address").at("state").replace("\\", "")
        } else {
          ""
        }
        linebreak()
        sender.at("address").at("country").replace("\\", "")
      }

      v(fontsize * 0.1)

      if "email" in sender and sender != none {
        link("mailto:" + sender.at("email").replace("\\", ""))
      } else {
        hide("a")
      }
    }),
    align(right, {
      heading(level: 2, recipient.at("name").replace("\\", ""))

      if "address" in recipient and recipient != none {
        v(fontsize * 0.5)
        emph(recipient.at("address").at("street").replace("\\", ""))
        linebreak()
        recipient.at("address").at("zip").replace("\\", "") + " " + recipient.at("address").at("city").replace("\\", "")
        if "state" in recipient.at("address") and not recipient.at("address").at("state") in (none, "") {
          ", " + recipient.at("address").at("state").replace("\\", "")
        } else {
          ""
        }
        linebreak()
        recipient.at("address").at("country").replace("\\", "")
      }
    })
  )

  v(fontsize * 1)

  grid(
    columns: (50%, 50%),
    align(left, {
      if "registration" in sender and sender != none and sender.at("registration") != "" {
        labels.registration + ": " + sender.at("registration").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "vat" in sender and sender != none and sender.at("vat") != "" {
        labels.vat-number + ": " + sender.at("vat").replace("\\", "")
      } else {
        hide("a")
      }

      v(fontsize * 1)

      if "number" in invoice and invoice != none and invoice.at("number") != "" {
        labels.number + ": " + invoice.at("number").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "issued" in invoice and invoice != none {
        labels.issued + ": " + invoice.at("issued").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "due" in invoice and invoice != none {
        labels.due + ": " + invoice.at("due").replace("\\", "")
      } else {
        hide("a")
      }
    }),
    align(center, {
      if logo != "none" and logo != none {
        image(logo, width: 3cm)
      } else {
        hide("a")
      }
    })
  )

  align(horizon, {
    if title != none {
      heading(level: 1, title.replace("\\", ""))
      if description != none {
        emph(description.replace("\\", "").replace("---", "\u{2014}").replace("--", "\u{2013}"))
      }
    }

    let auto-table = items-table(invoice-items, money, labels)
    if auto-table != none {
      auto-table
    } else {
      body
    }

    align(right, if "exempted" in sender and sender != none and sender.exempted != "none" and sender.exempted != none {
      text(luma(100), emph(sender.at("exempted").replace("\\", "")))
    } else {
      hide("a")
    })
  })

  align(bottom, {
    if "bic" in bank and "iban" in bank and bank != none {
      heading(level: 3, labels.payment-title)
      v(fontsize * 0.5)
      "BIC: " + bank.at("bic").replace("\\", "")
      linebreak()
      "IBAN: " + bank.at("iban").replace("\\", "")
      linebreak()
      labels.reference + ": " + strong(invoice.at("reference").replace("\\", ""))
      linebreak()
      text(luma(100), emph(labels.reference-note))
      linebreak()
    } else {
      hide("a")
    }

    v(fontsize * 2)

    text(luma(100),
      emph(fill(labels.terms, (
        sender: sender.at("name").replace("\\", ""),
        date: format-date(issued, labels),
        days: count-days(issued, due),
        fee: str(invoice-fee),
        penalty: penalty-display,
      )))
    )
  })
}
