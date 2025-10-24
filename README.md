# Bitcoin SIP-010 Token (Clarity + Clarinet)

This project defines a simple SIP-010-compatible fungible token named "Bitcoin" (`BTC`) with 8 decimals, implemented in Clarity and organized as a Clarinet project.

## Structure
- `Clarinet.toml` – Clarinet project config
- `contracts/sip10-trait.clar` – Local copy of the SIP-010 fungible token trait
- `contracts/bitcoin.clar` – Token implementation (owner-controlled mint)

## Prerequisites
- Install Clarinet: https://github.com/hirosystems/clarinet#installation

## Usage
1. Open a terminal in this repo root.
2. Validate contracts:
   - `clarinet check`
3. Start a REPL:
   - `clarinet console`
4. Example calls in the console (replace ST... with your devnet address):
   - Read name: `(contract-call? .bitcoin get-name)`
   - Read symbol: `(contract-call? .bitcoin get-symbol)`
   - Read decimals: `(contract-call? .bitcoin get-decimals)`
   - Read total supply: `(contract-call? .bitcoin get-total-supply)`
   - Mint (only contract owner can mint): `(contract-call? .bitcoin mint 'ST123... u100_000_000)` ; mints 1 BTC (8 decimals)
   - Transfer: `(contract-call? .bitcoin transfer u10_000_000 'ST123... 'ST456... none)` ; transfer 0.1 BTC from sender to recipient
   - Check balance: `(contract-call? .bitcoin get-balance 'ST456...)`

## Notes
- The contract owner is set to the deployer at deployment. Only the owner can mint.
- Decimals are `8`, so 1 BTC = `u100_000_000` base units.
- Update `get-token-uri` in `contracts/bitcoin.clar` to point to your token metadata if desired.
