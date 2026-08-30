# Task 02: Analyze a Phishing Email Sample

## Objective
Identify phishing characteristics in a suspicious email sample and produce a report listing the indicators found.

## 🛠 Tools Used
- Manual analysis (sender address, links, language, formatting)
- Real-world pattern recognition from prior Apple customer support experience

## Methodology
1. Sourced two real phishing email samples — both variants of an "iCloud storage" scam pattern encountered repeatedly while working in Apple customer support
2. Preserved original screenshots and transcribed the text content for reference
3. Broke down each email for sender legitimacy, urgency tactics, formatting inconsistencies, and the actual destination of any call-to-action
4. Cross-checked claims in the email against how Apple actually communicates (in-device notifications only, never email, for storage issues)
5. Documented findings as a structured indicators report

## Results
Full breakdown in [`header-analysis-report.md`](/Day-2/Header-analysis.md), including a subtle character-substitution obfuscation technique ("!Cloud !D" instead of "iCloud ID") used to slip past spam filters.



## Screenshots
### icloud suspended email

![phish1](/Day-2/phish1.png)

### Payment Update for icloud email

![phish2](/Day-2/phish2.png)

## Related Experience
Beyond identifying phishing as a target, I've also built and documented phishing campaigns from the attacker side using **GoPhish** and **Zphisher** as lab work in my broader security portfolio: [Cybersecurity-journey](https://github.com/saadmaster-sec/Cybersecurity-journey)
