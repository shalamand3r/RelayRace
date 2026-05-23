# RelayRace Tool Source

Bundled source for rebuilding the Mac-side prep helper, included for convenience.

The ChOma source here is third-party code used by the helper. It is not original RelayRace code; the upstream license is included in `choma/LICENSE`.

The prebuilt helper at `../macprep/relayrace-ct-bypass-mac` is x86_64 macOS. It works on Intel Macs and should work on Apple Silicon through Rosetta. Build from source if you want a local copy for your own machine.

## Build

From the repository root:

```sh
tools/source/build-relayrace-ct-bypass-mac.sh
```

Install OpenSSL first if it is missing:

```sh
brew install openssl@3
```

By default the script uses:

- `/usr/local/opt/openssl@3` on Intel Macs
- `/opt/homebrew/opt/openssl@3` on Apple Silicon Macs

Override it if needed:

```sh
OPENSSL_PREFIX=/path/to/openssl@3 tools/source/build-relayrace-ct-bypass-mac.sh
```

## Patch a Binary

```sh
tools/macprep/relayrace-ct-bypass-mac -i path/to/networkserviceproxy -o path/to/networkserviceproxy.ct
```

Use `-r` to patch in place.
