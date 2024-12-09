#let parse-date(date) = {
  let date = date.replace("\\", "")
  let date = str(date).split("-").map(int)
  datetime(year: date.at(0), month: date.at(1), day: date.at(2))
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
  penalty: "€40",
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  lang: "en",
  region: "UK",
  font: "Alegreya Sans",
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  fontsize: 12pt,
  title-size: 1.5em,
  body
) = {

  show heading: it => [
    #set par(leading: heading-line-height)
    #set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
    #it.body
  ]

  let issued = parse-date(invoice.at("issued"))
  if "penalty" in invoice and invoice != none {
    let penalty = invoice.at("penalty", default: "€40")
  } else {
    let penalty = "€40"
  }
  if "fee" in invoice and invoice != none {
    let fee = invoice.at("fee", default: 2.28)
  } else {
    let fee = 2.28
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
        emph(description.replace("\\", ""))
      }
    }

    body

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
          + count-days(issued, parse-date(invoice.at("due")))
          + " days, otherwise you will have to pay a late fee of "
          + str(fee)
          + " % and a "
          + str(penalty)
          + " penalty for recovery costs. "
          + "No discount will be granted for early settlement."
      )
    )
  })
}
