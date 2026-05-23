# RelayRace 🌐
### A jailbreak tweak that fixes iCloud Private Relay (Safari, Mail) on iOS 17.0.

RelayRace fixes an iOS 17.0 bug where iCloud Private Relay fails to activate. While the system fetches a config from `mask-api.icloud.com`, it gets rejected by a local security check. By injecting into a prepared copy of the `networkserviceproxy` daemon, RelayRace bypasses this validation failure since it allows the patched daemon to route traffic.

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="RelayRaceIconDark.png">
    <img src="RelayRaceIconLight.png" width="280" alt="RelayRace icon" style="border-radius: 18px;">
  </picture>
</p>

---

## Compatibility & Installation

I have only seen this issue affect users on iOS/iPadOS 17.0, therefore **RelayRace only supports NathanLR on iOS 17.0.** Also, the bundled `networkserviceproxy` executable was pulled from a device running this version. A userspace reboot is **required** after installation. 

Download the latest version from **[Releases](https://github.com/shalamand3r/RelayRace/releases)** or **[Add my Sileo Repo](https://shalamand3r.github.io)**.

---

<p align="center">
  <a href="https://github.com/shalamand3r/RelayRace/releases">
    <img src="https://img.shields.io/github/downloads/shalamand3r/RelayRace/total?style=plastic&logo=github&label=Downloads&color=564eba">
  </a>
</p>
