# Task 02: Phishing Email Analysis — iCloud Storage Scam

## Samples Used
Two real phishing emails, both variants of the same "iCloud storage" scam pattern
encountered repeatedly while working in Apple customer support. Screenshots are in
[screenshots/](/Day-2/phish1.png); a text transcription is in
[`sample-phishing-email.txt`](./sample-phishing-email.txt).

## Phishing Indicators Found

**1. Character-substitution obfuscation (Sample 2)**
Subject line reads "Your **!Cloud !D** has been locked" — the letter "i" is
replaced with "!". This isn't a typo; it's a known technique to evade spam
filters that flag keywords like "iCloud" or "ID," while still reading as
those words to a human skimming the subject line.

**2. Manufactured urgency**
Both samples lean hard on urgency and loss aversion: "Urgent Attention
Required," a hard deadline ("Fix it before Mon, 13 Jan 2025"), and outright
threats ("Your photos and videos will be Deleted!!"). Real Apple
communications don't use this tone.

**3. Fabricated "proof" to build false credibility**
Sample 1 includes a fake usage bar reading "50GB Used / 50GB Total" and
Sample 2 includes a fake "Order details" block (Subscription ID, Product,
Expiration Date) — mimicking the look of a legitimate receipt/invoice to
seem more official than a plain text scam would.

**4. No personalization**
Neither sample addresses the recipient by name — both use generic framing.
Legitimate account-specific notices from Apple are tied to the account
directly, not a mass-template greeting.

**5. Direct funnel to payment info**
Both samples end in a single CTA aimed at payment: "Update my payment
details" / "Update your information to restore access." The real goal of
both emails is harvesting card data, not actually helping with storage.

**6. Odd sign-off**
"Thank you for trusting us... iCloud® Customer Service Team." Apple doesn't
sign off this way, and the stray ® placement reads like it was inserted to
look official rather than because it's how Apple actually formats
communications.

**7. Channel mismatch (the biggest tell)**
Apple does not email customers about iCloud storage — it's an **in-device
notification only** (Settings → [Name] → iCloud). Any email claiming
otherwise is disqualified on that basis alone, regardless of how convincing
the rest of it looks.

## Guidance Given to Affected Customers (real-world practice)
- Never click the link in the email — go directly to Settings → iCloud instead
- Check the sender's actual address, not just the display name or branding
- Manage/purchase storage upgrades only through Settings, never through an email link
- Apple does not email about storage — only in-app/device notifications

## Hands-On Phishing Tooling Experience
Beyond identifying phishing as a target, I've also built and documented phishing
campaigns from the attacker side using **GoPhish** and **Zphisher** as lab work,
covered in my broader security portfolio:
[github.com/saadmaster-sec/Cybersecurity-journey](https://github.com/saadmaster-sec/Cybersecurity-journey)
