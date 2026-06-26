---
layout: post
title: "Cracking the Flow 2026 Challenge Coin: A Rewst CTF Walkthrough"
short_title: "Flow 2026 Rewst CTF"
date: 2026-06-23 16:00:00 -0500
categories: [security, ctf]
tags: [ctf, rewst, flow-2026, capture-the-flag, conference, walkthrough]
author: Chris Taylor
excerpt: "The CyberDrain CTF at Rewst's Flow 2026 in Nashville was a full clear — all five challenges and the winning run 🏆. Here's the complete walkthrough, dead ends included, starting with a challenge coin."
description: "A full walkthrough of the CyberDrain CTF at Rewst's Flow 2026 in Nashville — five challenges from a hex-stamped challenge coin to an in-person scavenger hunt, with try-it-yourself spoilers for each stage."
image: /assets/images/flow-2026-coin-front.jpg
---

The theme was "follow the breadcrumbs" — a bakery-to-meal progression of five challenges,
10 points each:

> Breadcrumbs → Slice → Loaf → Toast → Lunch (Sandwich)

The mix was wide: two pure-technique stages (stego, HTTP verbs), one multi-layer decode,
one deep read-only cloud-forensics dig — and two that pulled us out of our seats entirely,
a GPS geofence to start and an in-person people-hunt to finish. The dead ends are left in
on purpose; that's where the lessons are.

**Infrastructure in play:** `cipp.ms` (a CTF link shortener with planted API endpoints —
not the real [CIPP](https://cipp.app)), `engine.rewst.io` ([Rewst](https://rewst.io)
webhooks), a live M365 tenant (`7ngn50.onmicrosoft.com`), and a Hudu shared vault. A
recurring trick across challenges is HTTP-verb tampering (`OPTIONS` / wrong-verb oracles).

Each challenge below keeps the puzzle visible — the clue, the artifact, the prompt — with
the walkthrough and flag tucked behind a **Show the solution** toggle. Read along and try
each one yourself before you reveal the answer.

## 1 — Breadcrumbs 🪙→🍞

It all started with this — a challenge coin styled like a vinyl record, the Rewst rooster
staring back at me. Both faces were busy with `cipp` branding and a ring of cryptic
characters stamped around the rim.

![Flow 2026 challenge coin — front, showing the FLOW 2026 wordmark, the CIPP double-chevron logo, and codes around the rim](/assets/images/flow-2026-coin-front.jpg)

*The front of the Flow 2026 challenge coin.*

![Flow 2026 challenge coin — back, "Hosted by Rewst," the Rewst rooster mascot, and "Nashville, Tennessee"](/assets/images/flow-2026-coin-back.jpg)

*The back: "Hosted by Rewst — Nashville, Tennessee."*

Those rim markings aren't just decoration — they point somewhere. Work out where before
opening it up.

<details markdown="1">
<summary>Show the solution — decode the rim</summary>

### Decoding the rim

| Hex | ASCII |
|-----|-------|
| `68 65 6C 6C 6F` | `hello` |
| `2E 6D 73` | `.ms` |

With the `cipp` logo → **`cipp.ms/hello`**.

```powershell
function Decode-Hex($hex) {
    ($hex -split '\s+' | ForEach-Object { [char][convert]::ToInt32($_, 16) }) -join ''
}
Decode-Hex "68 65 6C 6C 6F"   # hello
Decode-Hex "2E 6D 73"         # .ms
```

**Rabbit hole #1 — the musical notes.** We spent real time trying to treat the musical
notes wrapping the vinyl record as a cipher (mapping notes to letters/pitches, counting
beats, etc.). They were pure Nashville / "Music City" decoration — the only real data on
the coin was the hex.

</details>

### The landing page was a GPS / geofence challenge

*This stage you can read along with but can't really replay — it only unlocked by
physically standing in the right spot, so it stays in the open.*

The decoded link landed on a page with an unlocked padlock and "Follow the
breadcrumbs..." — but it was gated on physical location. The CTFd riddle laid out the
three steps literally:

> First, be somewhere. Then, see something. Then, look beneath what you see.

![The geofenced "Location Challenge" page on a phone — a locked padlock, a compass arrow labeled "gps heading," "23 m," and "Head west — your position updates automatically."](/assets/images/geofence.jpg)

*The geofence gate: locked until our GPS reached the spot, with a live compass and distance ("23 m," head west) nudging us there.*

- **First, be somewhere** = the page only releases the image once your device's GPS is at
  the right spot. Getting there was an actual walk: we started on the wrong floor of the
  hotel and wandered into areas we probably shouldn't have (restricted), then at ground
  level it pushed us outside and across the road — the intended spot turned out to be the
  hotel's bar/restaurant built into a bridge over the road, not the road itself.
  - **Detours on arrival (wasted time):** the first time we reached the spot, the page
    redirected us to the CTF site to set up an account and never showed the image — so we
    burned time guessing before going back and pulling the image on the second pass. Then
    we wasted more time typing in things we could literally see in the image before
    accepting that it needed deeper inspection.
  - **Tooling snag:** GPS resolved fine on the phone but the laptop wouldn't geolocate, so
    we unlocked and downloaded the bread image on the phone, then transferred it to the
    laptop for analysis.
- **Then, see something / look beneath** = the bread image → the payload hidden beneath
  its pixels.

![Flow 2026 bread image — a sliced loaf on a cutting board engraved with the CyberDrain logo, the flow wordmark, and the Rewst rooster; the steganography payload is hidden in its pixels](/assets/images/bread.png)

*The bread image, unlocked at the geofenced spot — something was hidden beneath the pixels.*

Back to the keyboard: the flag is hidden in the bread image itself. Want to pull it out
yourself before the reveal?

<details markdown="1">
<summary>Show the solution — extract the hidden flag</summary>

### The bread image (steganography)

- **Metadata decoy:** XMP `dc:description = ItCantBeThatEasyToFind` (a taunt — real data
  is in the pixels).
- **No appended data** after PNG `IEND`; EXIF only GIMP boilerplate.
- **LSB stego:** payload in the least-significant bits of the RGB channels, row-major,
  MSB-first.

```powershell
Add-Type -AssemblyName System.Drawing
$bmp  = [System.Drawing.Bitmap]::FromFile((Resolve-Path 'bread.png'))
$bits = [System.Collections.Generic.List[int]]::new()

# Read the LSB of each R,G,B channel, row-major (top-left to bottom-right)
for ($y = 0; $y -lt $bmp.Height; $y++) {
  for ($x = 0; $x -lt $bmp.Width; $x++) {
    $p = $bmp.GetPixel($x, $y)
    foreach ($c in @($p.R, $p.G, $p.B)) { $bits.Add($c -band 1) }
  }
}
$bmp.Dispose()

# Pack the bits MSB-first into bytes, then keep the printable run
$bytes = for ($i = 0; $i + 8 -le $bits.Count; $i += 8) {
  $b = 0; for ($j = 0; $j -lt 8; $j++) { $b = ($b -shl 1) -bor $bits[$i + $j] }
  [byte]$b
}
$text = -join ($bytes | ForEach-Object { [char]$_ })
[regex]::Match($text, 'FLAG=[\x20-\x7e]+').Value
```

🚩 **Flag:** `FLAG=94c960b2-08c4-4184-b532-0aeba6e49142` — this unlocked **Slice**.

</details>

## 2 — Slice 🍞🔪

A Rewst custom-trigger URL, with the riddle:

> A slice, broken in two. Each half, transformed. Follow the crumbs back to the source.

```text
https://engine.rewst.io/webhooks/custom/trigger/WmpBMVl6SXdPREZrTnpnMkxXVTNaV0V0WmpNMk55MW1aVEF5TFdRNU1tUmxPVEV3/s6789s77-7ppr-4o10-9or6-89o99s2n36np
```

Two path segments, each encoded differently — work them back to the source, then fire the
trigger the right way. Give it a try before the reveal.

<details markdown="1">
<summary>Show the solution — decode both halves and fire the trigger</summary>

"Broken in two" = the two path segments; "each half transformed" = a different encoding
each.

### Segment 1 — base64 twice, then full reversal

```powershell
function FromB64($s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))}
$l1 = FromB64 'WmpBMVl6SXdPREZrTnpnMkxXVTNaV0V0WmpNMk55MW1aVEF5TFdRNU1tUmxPVEV3'
$l2 = FromB64 $l1          # f05c2081d786-e7ea-f367-fe02-d92de910  (grouped 12-4-4-4-8 = mirrored GUID)
$hex = ($l2 -replace '-','')
$rev = -join ($hex.ToCharArray()[($hex.Length-1)..0])
$guid1 = '{0}-{1}-{2}-{3}-{4}' -f $rev.Substring(0,8),$rev.Substring(8,4),$rev.Substring(12,4),$rev.Substring(16,4),$rev.Substring(20,12)
$guid1   # 019ed29d-20ef-763f-ae7e-687d1802c50f
```

### Segment 2 — ROT13

**Tell:** only `s/p/r/o/n` letters and no `a-f` — exactly where `a-f` land under ROT13
(`a→n, b→o, c→p, e→r, f→s`). Digits untouched.

```powershell
function Rot13([string]$s){
  -join ($s.ToCharArray() | ForEach-Object {
    if ($_ -match '[a-z]') {[char]((([int]$_ - 97 + 13) % 26) + 97)}
    elseif ($_ -match '[A-Z]') {[char]((([int]$_ - 65 + 13) % 26) + 65)}
    else {$_}
  })
}
Rot13 's6789s77-7ppr-4o10-9or6-89o99s2n36np'   # f6789f77-7cce-4b10-9be6-89b99f2a36ac
```

### Confirming via server response (verb oracle)

| Candidate (segment 1) | Transform | Server | Verdict |
|-----------------------|-----------|--------|---------|
| `d92de910-fe02-f367-e7ea-f05c2081d786` | segment-order reversal | "Could not find trigger" | wrong |
| `019ed29d-20ef-763f-ae7e-687d1802c50f` | full character reversal | `405 Method Not Allowed` | correct |

A bad ID → "trigger not found"; a real trigger with the wrong verb → `405`.

**Reconstructed trigger:**

```text
https://engine.rewst.io/webhooks/custom/trigger/019ed29d-20ef-763f-ae7e-687d1802c50f/f6789f77-7cce-4b10-9be6-89b99f2a36ac
```

**Final step:** fired the reconstructed trigger with the correct verb (`OPTIONS` →
`Allow` header reveals the set, then the right method) → challenge completed.

```powershell
$url = 'https://engine.rewst.io/webhooks/custom/trigger/019ed29d-20ef-763f-ae7e-687d1802c50f/f6789f77-7cce-4b10-9be6-89b99f2a36ac'
Invoke-RestMethod -Uri $url -Method Get
(Invoke-WebRequest -Uri $url -Method Options).Headers['Allow']
```

</details>

## 3 — Loaf 🍞

> Somewhere on this server lives a very particular loaf. It responds to requests — all
> kinds of requests — but it only gives up the flag to someone who knows all their
> options. Literally.

Target: `https://cipp.ms/api/loaf`

It answers every kind of request — but only one verb gives up the flag. What does it
*allow*? Try it before opening the solution.

<details markdown="1">
<summary>Show the solution — the right verb and the flag</summary>

A normal request → `401`. "Knows all their options, literally" = the HTTP `OPTIONS`
method.

```powershell
# A normal GET is rejected:
Invoke-WebRequest -Uri 'https://cipp.ms/api/loaf' -Method Get      # 401 Unauthorized

# "knows all their options, literally" = the OPTIONS verb:
(Invoke-WebRequest -Uri 'https://cipp.ms/api/loaf' -Method Options).Content
# {"message":"You've discovered the secret ingredient! 🍞 Your flag is: 5afe274d-...
#  The loaf also rises with these verbs ... GET, POST, PUT, PATCH, and DELETE!"}
```

🚩 **Flag:** `5afe274d-02cb-4cb5-af80-458edd5fcb67`

Same verb-tampering idea as the Slice webhook oracle — a recurring motif.

</details>

## 4 — Toast 🍞🔥 — M365 Incident Response

> Something went wrong in the tenant. The logs are loud — too loud. Someone left the
> bread in too long, and then tried to cover their tracks. You have the keys to look
> around, but not to touch. Find what was installed. Find what was shared. Find out how
> the toast got made.

A read-only Unified Audit Log investigation of a compromised tenant, with the real events
buried under generated noise.

**How we ran it (timeline):** the earlier challenges we'd knocked out before the
conference started and over lunch. We started working on Toast, then got pulled into our
first conference session. Honestly, a CTF is the last place we'd normally reach for AI —
solving it yourself is all the fun, not handing it off — but stuck in a talk with the
challenge still open, we gave agents a shot for the first time.

The first attempt — turning the agents loose on the whole recon/search task to run on
their own while we sat in the talk — went nowhere: checking on them at the first session
break showed no real progress, just agents tripping over their own security guardrails and
bailing partway through. We made our changes — scoping the asks down and steering them more
directly instead of letting them run on their own — and headed back into the next session.
That pulled back noticeably better information, but they still kept hitting those
"cybersecurity" refusals. It was enough reconnaissance to get us oriented, though, and we
finished the actual investigation ourselves.

Want to dig in yourself before the reveal?

<details markdown="1">
<summary>Show the investigation — access, findings, and the flag</summary>

### Getting in (read-only)

- A **Hudu shared vault** exposed the login:
  `CyberDrainCTF@7ngn50.onmicrosoft.com` / `Salad-Fan-Airways-Bankable`, tenant `7ngn50`,
  with the TOTP fetched on demand from Hudu's turbo-stream endpoints
  (`/fetch_asset_password`, `/otp_shared_access`).
- ROPC failed (`AADSTS50076`, MFA) → used the **device-code flow** (Graph CLI client
  `14d82eec-…`) and completed the MFA/browser step with **Playwright**, minting the TOTP
  at login.
- The token had no `AuditLog.Read.All` but did have `Exchange.Manage`.
- **Pivot:** exchanged the `offline_access` refresh token for an **Exchange Online** token
  and called the EXO REST admin API (`adminapi/beta/<tid>/InvokeCommand`) to run
  `Search-UnifiedAuditLog` — no module install, all reads.

### Findings (signal vs. noise)

**Attacker accounts:** `justin.timberlake` and `TonyStark` (display name
"Kelvin Tegelaar").

**Installed** — two admin-consented (`OnBehalfOfAll`) look-alike OAuth apps:

- **CIPP-SSO** (`8ec85a6e-…`), reply URL `cippvi4md.azurewebsites.net`, secret added.
- **Microsoft CoPilot for Sharepoint** (`c90f6378-…`), reply URL `engine.rewst.io`,
  tagged `HideApp`, self-added owner.

**Shared** — `copilot_for_sharepoint_magic.py` shared org-wide, plus `ohno.html`
ransomware note mass-dropped to 38+ SharePoint sites.

**Covered tracks** — `HideApp`, both files recycled, audit log flooded with noise.

### Recovering the deleted payload (the hard part)

The `.py` was deleted and ACL-walled (direct REST `403`; Graph `/shares` blocked —
`Files.Read` not consented; recycle bin `403`; SP Search `401`). The breadcrumb:
`ohno.html` (read as inert text from our own OneDrive) is a joke ransomware note linking
to `https://cipp.ms/totallynotamaliciouslink`, which `302`-redirects to the tokenized
org sharing link for the `.py`. `curl` got `401`, but the authenticated browser session
redeemed the org-`View` link (same-origin `fetch()`) and read the file:

```text
# FLAG: BringingSexyBackWithCopilot
```

The script was a Graph "SharePointMirrorTool" — an app-only client-credentials crawler
using `cryptography.fernet` to mirror + encrypt SharePoint content: the exfil/ransomware
payload behind the fake "CoPilot" app.

🚩 **Flag:** `BringingSexyBackWithCopilot`

**Attack chain:** register look-alike OAuth apps → admin-consent + secrets + `HideApp` →
upload/share the mirror-encrypt tool org-wide → drop ransomware notes across 38+ sites →
anti-forensics (hide app, recycle files, flood logs).

</details>

## 5 — Lunch (Sandwich) 🥪 — "Find Cooper" (in person)

*Like the geofence, this one can't be replayed from a keyboard — it was a physical
scavenger hunt on the conference floor, so it stays in the open.*

The finale was just two words — **Find Cooper** — and at first we read it exactly like the
challenges before it: as something technical. Toast had just trained us to comb a tenant,
so our first move was hunting M365 for a user — or any record — matching "Cooper," with
the bread-to-Sandwich theme and Rewst's rooster mascot keeping our heads in Rewst/rooster
pun territory the whole time. Nothing turned up in the tenant.

So we widened the search: if "Cooper" wasn't a user in M365, maybe it was an actual person
at Rewst. That reframing was the unlock — and we realized we already knew her: **Ashley
Cooper, Rewst's VP of Community**. (We even had to double-check that Cooper was her last
name.) That personal-network edge was the only reason we got moving; without it,
just getting started here would have been very hard, maybe impossible. A good reminder
that not every CTF stage is solved at a keyboard — some are solved by talking to the
people in the room.

Ashley didn't have a word herself — finding her just sent us off after more Rewsters. She
pointed us to three sources, each holding a single word of the phrase: two Rewst employees
and the hotel reception desk.

| Stop | Word |
|------|------|
| Ashley Cooper | *(no word — directs you to the three below)* |
| Reception desk | "its" |
| Jesse Heldabrand | "pronounced" |
| George Smith | "no op" |

🚩 **Phrase / answer:** "It's pronounced no-op"

**How we found them:** Reception was the easy handoff. For Jesse and George we tried to
put faces to names with their LinkedIn photos — that worked for George, but Jesse didn't
have a photo, so we asked around and found out they had a session on the schedule. We
tracked Jesse down by spotting that presentation and crashing the talk — but Jesse didn't
actually know their word, so we grabbed a selfie as proof and later got it ("pronounced")
from Ashley. We then bumped into George Smith on the way back to tell Ashley that Jesse
didn't have a word.

A fitting finale for a Rewst/automation crowd — the eternal argument over whether a no-op
(no-operation) is said "no-op" or "nope." 😄

## Techniques used across the CTF

- **Encoding/decoding:** ASCII-hex, single & double base64, ROT13, full-string reversal,
  mirrored-GUID recognition.
- **Steganography:** PNG LSB extraction (RGB, row-major, MSB-first); metadata as decoy.
- **HTTP verb tampering:** `OPTIONS` to reveal hidden responses; `405` vs "not found" as
  an oracle for valid-but-wrong-verb endpoints (Loaf and Slice).
- **Cloud identity:** secrets from a shared vault (Hudu); device-code auth + Playwright
  for interactive MFA without admin; OAuth scope pivoting via `offline_access`
  refresh-token exchange (Graph → Exchange Online).
- **M365 forensics:** EXO REST admin API → `Search-UnifiedAuditLog`; separating planted
  noise from real events; share-link redemption via browser session cookies where API
  tokens were ACL-denied; reading suspicious files as inert text (no render/execute).

## Defender takeaways

- Alert on **OnBehalfOfAll** admin consent to non-vetted apps — especially ones
  impersonating your own tooling (CIPP/Rewst look-alikes) or with odd reply URLs
  (`*.azurewebsites.net`, third-party callbacks).
- **HideApp** / hidden service principals and freshly-added app secrets are strong
  persistence signals.
- Org-wide ("People in your org") sharing links + identical files fanned across many
  sites = exfil/ransomware staging.
- **Audit-log flooding is itself an IOC** — a spike of low-value events often masks a few
  high-value ones.
- **Deleted ≠ gone** — recycle bins, sharing links, and short-link redirects can still
  surface "covered" artifacts.

## Retrospective notes

**What went well**

- Breadcrumbs & Loaf fell fast once the "look beneath" / "options, literally" wording was
  read as instructions rather than flavor text.
- Toast was the centerpiece: the cleanest part was recognizing that the win condition was
  read-only forensics, then engineering read access (device-code + Playwright MFA, the
  Graph→EXO scope pivot) without ever "touching" the tenant.
- The move that actually cracked Toast's flag was refusing to brute the ACL and instead
  following the breadcrumb in the artifact — the joke ransomware note's `cipp.ms/...` link
  302'd straight to the file's org-share token, which the browser session could redeem.

**Where it tried to trick us (the good part)**

- **The Cooper red herring.** The bread-to-Sandwich theme and Rewst's rooster mascot kept
  us reading "Find Cooper" as technical — combing M365 for a matching record — when Cooper
  was a person in the room all along.
- **Audit-log flooding.** The tenant deliberately buried ~12 real events under thousands
  of noise records; the skill was triaging signal (singletons, the two attacker
  identities) out of the noise.
- **Metadata decoy** in the bread PNG (`ItCantBeThatEasyToFind`) tried to pull us off the
  real LSB payload.
- **The musical notes** on the challenge coin baited a music-cipher rabbit hole — they
  were just Music-City flavor.
- **The GPS geofence** made Breadcrumbs a physical event: we wandered the hotel (wrong
  floor, restricted areas, then outside across the road to the bridge) before the page
  would reveal the image, and the laptop's missing GPS forced a phone→laptop handoff to
  get the file onto an analysis machine.
