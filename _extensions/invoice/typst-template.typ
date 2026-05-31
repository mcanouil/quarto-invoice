#let parse-date(date) = {
  let cleaned = str(date).replace("\\", "")
  let parts = cleaned.split("-").map(int)
  if parts.len() != 3 {
    panic("Invalid date '" + cleaned + "'. Expected ISO format YYYY-MM-DD.")
  }
  datetime(year: parts.at(0), month: parts.at(1), day: parts.at(2))
}

#let format-date(date) = {
  let day = date.day()
  let ord = super(if 10 < day and day < 20 {
    "th"
  } else if calc.rem(day, 10) == 1 {
    "st"
  } else if calc.rem(day, 10) == 2 {
    "nd"
  } else if calc.rem(day, 10) == 3 {
    "rd"
  } else {
    "th"
  })
  [the #day#ord of #date.display("[month repr:long]"), #date.year()]
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
  body
) = {

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
    title: "Invoice " + invoice.at("number").replace("\\", "") + " - " + recipient.at("name").replace("\\", ""),
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
        "Registration number: " + sender.at("registration").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "vat" in sender and sender != none and sender.at("vat") != "" {
        "VAT number: " + sender.at("vat").replace("\\", "")
      } else {
        hide("a")
      }

      v(fontsize * 1)

      if "number" in invoice and invoice != none and invoice.at("number") != "" {
        "Invoice number: " + invoice.at("number").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "issued" in invoice and invoice != none {
        "Issued on: " + invoice.at("issued").replace("\\", "")
        linebreak()
      } else {
        hide("a")
      }

      if "due" in invoice and invoice != none {
        "Payment due date: " + invoice.at("due").replace("\\", "")
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

    let auto-table = items-table(invoice-items, money)
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
      heading(level: 3, "Payment information")
      v(fontsize * 0.5)
      "BIC: " + bank.at("bic").replace("\\", "")
      linebreak()
      "IBAN: " + bank.at("iban").replace("\\", "")
      linebreak()
      "Reference: " + strong(invoice.at("reference").replace("\\", ""))
      linebreak()
      text(luma(100), emph("To be used as label on your bank transfer to identify the transaction."))
      linebreak()
    } else {
      hide("a")
    }

    v(fontsize * 2)

    text(luma(100),
      emph(
        sender.at("name").replace("\\", "")
          + " sent you this invoice on "
          + format-date(issued)
          + ". The invoice must be paid in under "
          + count-days(issued, due)
          + " days, otherwise you will have to pay a late fee of "
          + str(invoice-fee)
          + " % and a "
          + penalty-display
          + " penalty for recovery costs. "
          + "No discount will be granted for early settlement."
      )
    )
  })
}
