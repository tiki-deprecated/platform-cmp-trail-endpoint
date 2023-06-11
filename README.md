![Image](https://img.shields.io/pub/v/tiki_sdk_dart?logo=dart)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
![Image](https://img.shields.io/pub/points/tiki_sdk_dart?logo=dart)
![Image](https://img.shields.io/github/license/tiki/tiki-sdk-dart)

###  [🍍 Console](https://console.mytiki.com) &nbsp; ⏐ &nbsp; [📚 Docs](https://docs.mytiki.com)

# TIKI SDK —build the new data economy

The core implementation (**pure dart**) of TIKI's decentralized infrastructure plus abstractions to simplify the tokenization and application of data ownership, consent, and rewards. For new projects, we recommend one of our platform-specific SDKs. Same features. Much easier to implement.

- **🤖 Android: [tiki-sdk-android](https://github.com/tiki/tiki-sdk-android)**
- **🍎 iOS: [tiki-sdk-ios](https://github.com/tiki/tiki-sdk-ios)**
- **🦋 Flutter: [tiki-sdk-flutter](https://github.com/tiki/tiki-sdk-flutter)**



### [🎬 How to get started ➝](https://docs.mytiki.com/docs/tiki-sdk-dart-getting-started)
- **[API Reference ➝](https://docs.mytiki.com/reference/tiki-sdk-dart-tiki-sdk)**
- **[Dart Docs ➝](https://pub.dev/documentation/tiki_sdk_dart/latest/)**

###  Basic Architecture

We leverage a novel blockchain-inspired data structure to create immutable, decentralized records of data ownership, consent grants, and rewards.

Unlike typical shared-state ⛓️ blockchains, TIKI operates on no consensus model, pushing scope responsibility to the application layer —kind of like shared cloud storage.

The structure enables tokenization at the edge (no cost, high speed). Read more about it [here](https://github.com/tiki/tiki-sdk-dart/blob/main/WHITEPAPER.md).

✨ Highlights:
- No compute costs
- No backend changes
- Data remains private (never sent to a TIKI server)
- No P2P networking
- Fast AF and horizontally scalable (benchmarked on iPhones at 20,000 TPS)
- Immutable backup for 10+ yrs. via TIKI's L0 Storage service.

#### Node

Manages transaction creation, block packaging, backups, chain validation, and key management. Basically, all the blockchain stuff.

#### Ownership and Consent

A cache layer (SQLite) on top of the chain data structure. Simplifies the execution of actions such as tokenization, consent modification, and consent application.

#### SStorage (L0 Storage)

The client-side interface for TIKI's L0 Storage service. A free, long-term (10 yrs.), immutable backup service. Learn more about it [here](https://github.com/tiki/l0-storage).

### Why Dart?
🎯 Dart compiles to both machine code for native mobile/desktop apps and JS for web.

The vast majority of data origination and person-to-business exchange happens at the edge (web/mobile). Plus, edge execution can offer significant privacy and performance advantages.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://harshit933.github.io"><img src="https://avatars.githubusercontent.com/u/90508384?v=4?s=100" width="100px;" alt="Harshit"/><br /><sub><b>Harshit</b></sub></a><br /><a href="https://github.com/tiki/core/commits?author=Harshit933" title="Tests">⚠️</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!