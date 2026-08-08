# RelayRace 🌐
### A jailbreak tweak that fixes iCloud Private Relay (Safari, Mail) on iOS.

RelayRace fixes iCloud Private Relay (Safari, Mail) on iOS by patching `networkserviceproxy` so configuration validation can complete normally.

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="RelayRaceIconDark.png">
    <img src="RelayRaceIconLight.png" width="280" alt="RelayRace icon" style="border-radius: 18px;">
  </picture>
</p>

---

## Compatibility & Installation

RelayRace targets iOS/iPadOS **17.0 and later** and supports both **Dopamine/rootless full jailbreaks** (native daemon injection) and **NathanLR** (SysBins patched daemon workaround).

* **Dopamine/rootless full jailbreaks (Recommended)**: Uses native daemon injection via ElleKit into the stock running `networkserviceproxy`. No userspace reboot is required — installation automatically restarts `networkserviceproxy`.
* **NathanLR**: Automatically stages a bundled, prepared iOS 17.0 `networkserviceproxy` binary into `SysBins`. A userspace reboot is required after installation. *(Note: Upgrading to Dopamine is recommended for native injection and improved stability.)*

Download the latest version from **[Releases](https://github.com/shalamand3r/RelayRace/releases)** or **[Add my Sileo Repo](https://shalamand3r.github.io)**.

## Using Your Own `networkserviceproxy` (Semi-Jailbreaks ONLY)

RelayRace includes a prepared `networkserviceproxy` binary that was dumped from an iOS 17.0 device. This binary is used only by the NathanLR fallback; Dopamine uses the stock daemon through ElleKit. If you would rather use your own copy for NathanLR, dump `networkserviceproxy` from the matching iOS/iPadOS firmware, patch it locally, and replace the bundled file before building:

```sh
# Replace the bundled binary with your own dumped copy.
cp /path/to/your/networkserviceproxy tools/macprep/networkserviceproxy.ct

# Patch your daemon copy in place. Do not run this helper on RelayRace.dylib.
tools/macprep/relayrace-ct-bypass-mac -i tools/macprep/networkserviceproxy.ct -r

# Build the package with your patched binary.
make package # cool people use gmake package
```

The resulting `.deb` will include your own patched binary instead of the one shipped in this repo. Make sure the binary comes from an iOS 17.0 device as otherwise RelayRace may not function.

If you want to build the prep helper from source, see [tools/source/README.md](tools/source/README.md).

## Diagnostics

RelayRace emits a small number of runtime status messages to Apple's rotating unified log. It does not create persistent diagnostic files. The messages record whether the dylib loaded into `networkserviceproxy` and whether the bypass methods were patched.

From a terminal, you can watch the unified log with:

```sh
log stream --level info --predicate 'subsystem == "com.shalamand3r.relayrace" OR process == "networkserviceproxy"'
```

You can also connect the device to a Mac, select it in Console, start streaming, and search for `com.shalamand3r.relayrace`.

---
## Credits
- Lars Fröder (opa334) for ChOma / CoreTrust bypass tooling.
- verygenericname for NathanLR and nathanlr_hooks.
---

<p align="center">
  <a href="https://github.com/shalamand3r/RelayRace/releases">
    <img src="https://img.shields.io/github/downloads/shalamand3r/RelayRace/total?style=plastic&logo=github&label=Downloads&color=564eba">
  </a>
</p>
