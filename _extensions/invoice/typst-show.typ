#show: invoice.with(
$if(title)$
  title: "$title$",
  $if(description)$
    description: "$description$",
  $endif$
$endif$
$if(logo)$
  logo: "$logo$",
$elseif(brand.logo)$
  logo: ("$brand.logo$",),
$endif$
$if(sender)$
  sender: (
    name: "$sender.name$",
    address: (
      street: "$sender.address.street$",
      zip: "$sender.address.zip$",
      city: "$sender.address.city$",
      state: "$sender.address.state$",
      country: "$sender.address.country$"
    ),
    email: "$sender.email$",
    registration: "$sender.registration$",
    vat: "$sender.vat$",
    exempted: "$sender.exempted$"
  ),
$endif$
$if(recipient)$
  recipient: (
    name: "$recipient.name$",
    address: (
      street: "$recipient.address.street$",
      zip: "$recipient.address.zip$",
      city: "$recipient.address.city$",
      state: "$recipient.address.state$",
      country: "$recipient.address.country$"
    )
  ),
$endif$
$if(invoice)$
  invoice: (
    number: "$invoice.number$",
    issued: "$invoice.issued$",
    due: "$invoice.due$",
    reference: "$invoice.reference$",
    fee: $if(invoice.fee)$$invoice.fee$$else$2.28$endif$,
    penalty: $if(invoice.penalty)$"$invoice.penalty$"$else$"€40"$endif$,
$if(invoice.currency)$
    currency: "$invoice.currency$",
$endif$
$if(invoice.items)$
    items: (
$for(invoice.items)$
      (
        description: "$it.description$",
$if(it.details)$
        details: "$it.details$",
$endif$
        quantity: $if(it.quantity)$$it.quantity$$else$1$endif$,
        unit-price: $if(it.unit-price)$$it.unit-price$$else$0$endif$,
        vat: $if(it.vat)$$it.vat$$else$0$endif$,
      ),
$endfor$
    ),
$endif$
  ),
$endif$
$if(bank)$
  bank: (
    iban: "$bank.iban$",
    bic: "$bank.bic$"
  ),
$endif$
  labels: (
    title: [`$quarto.language.invoice-title$`].text,
    registration: [`$quarto.language.invoice-registration$`].text,
    vat-number: [`$quarto.language.invoice-vat-number$`].text,
    number: [`$quarto.language.invoice-number$`].text,
    issued: [`$quarto.language.invoice-issued$`].text,
    due: [`$quarto.language.invoice-due$`].text,
    payment-title: [`$quarto.language.invoice-payment-title$`].text,
    reference: [`$quarto.language.invoice-reference$`].text,
    reference-note: [`$quarto.language.invoice-reference-note$`].text,
    item-details: [`$quarto.language.invoice-item-details$`].text,
    item-quantity: [`$quarto.language.invoice-item-quantity$`].text,
    item-unit-price: [`$quarto.language.invoice-item-unit-price$`].text,
    item-vat: [`$quarto.language.invoice-item-vat$`].text,
    item-total: [`$quarto.language.invoice-item-total$`].text,
    total-excl: [`$quarto.language.invoice-total-excl$`].text,
    total-vat: [`$quarto.language.invoice-total-vat$`].text,
    total-incl: [`$quarto.language.invoice-total-incl$`].text,
    terms: [`$quarto.language.invoice-terms$`].text,
    months: [`$quarto.language.invoice-months$`].text,
    date: [`$quarto.language.invoice-date$`].text,
    ordinals: [`$quarto.language.invoice-ordinals$`].text,
  ),
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$elseif(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$elseif(brand.typography.base.size)$
  fontsize: $brand.typography.base.size$,
$endif$
$if(title)$
$if(brand.typography.headings.family)$
  heading-family: $brand.typography.headings.family$,
$endif$
$if(brand.typography.headings.weight)$
  heading-weight: $brand.typography.headings.weight$,
$endif$
$if(brand.typography.headings.style)$
  heading-style: "$brand.typography.headings.style$",
$endif$
$if(brand.typography.headings.color)$
  heading-color: $brand.typography.headings.color$,
$endif$
$if(brand.typography.headings.line-height)$
  heading-line-height: $brand.typography.headings.line-height$,
$endif$
$endif$
)
