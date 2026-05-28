// Invoice Format - Currency Helpers
// Format monetary amounts using ISO 4217 currency codes.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let _currency-symbols = (
  EUR: "€",
  USD: "$$",
  GBP: "£",
  JPY: "¥",
  CHF: "CHF",
  CAD: "CA$$",
  AUD: "A$$",
  NZD: "NZ$$",
  CNY: "¥",
  INR: "₹",
  SEK: "kr",
  NOK: "kr",
  DKK: "kr",
  PLN: "zł",
  CZK: "Kč",
  BRL: "R$$",
  MXN: "MX$$",
  ZAR: "R",
  SGD: "S$$",
  HKD: "HK$$",
  KRW: "₩",
  RUB: "₽",
  TRY: "₺",
  ILS: "₪",
  AED: "د.إ",
  THB: "฿",
)

// Currencies where the symbol follows the amount.
#let _suffix-currencies = ("SEK", "NOK", "DKK", "PLN", "CZK", "CHF")

#let currency-symbol(code) = {
  if code == none { return "" }
  let key = upper(str(code))
  if key in _currency-symbols { _currency-symbols.at(key) } else { key + " " }
}

// Locale-aware decimal/thousand separators.
// Returns (thousand, decimal).
#let _locale-separators(lang) = {
  let lang-key = lower(str(lang))
  if lang-key in ("de", "es", "it", "nl", "pt", "pl") {
    (".", ",")
  } else if lang-key in ("fr", "cs", "sv", "no", "da", "fi") {
    (" ", ",")
  } else {
    (",", ".")
  }
}

#let format-amount(value, lang: "en", region: "UK", decimals: 2) = {
  if value == none { return "" }
  let _ = region
  let n = float(value)
  let separators = _locale-separators(lang)
  let thousand = separators.at(0)
  let decimal = separators.at(1)
  let negative = n < 0
  let absolute = calc.abs(n)
  let factor = calc.pow(10, decimals)
  let rounded = calc.round(absolute * factor) / factor
  let integer-part = calc.floor(rounded)
  let fractional-part = rounded - integer-part
  let integer-string = str(integer-part)
  let grouped = ""
  let digits = integer-string.clusters()
  let count = digits.len()
  for index in range(count) {
    if index > 0 and calc.rem(count - index, 3) == 0 {
      grouped = grouped + thousand
    }
    grouped = grouped + digits.at(index)
  }
  let decimal-string = ""
  if decimals > 0 {
    let scaled = calc.round(fractional-part * factor)
    let raw = str(scaled)
    while raw.clusters().len() < decimals {
      raw = "0" + raw
    }
    decimal-string = decimal + raw
  }
  let sign = if negative { "-" } else { "" }
  sign + grouped + decimal-string
}

#let format-money(value, currency: "EUR", lang: "en", region: "UK", decimals: 2) = {
  let amount = format-amount(value, lang: lang, region: region, decimals: decimals)
  let symbol = currency-symbol(currency)
  let code = upper(str(currency))
  if code in _suffix-currencies {
    amount + " " + symbol
  } else {
    symbol + amount
  }
}
