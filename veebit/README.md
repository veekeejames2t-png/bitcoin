# Veebit — Clarity Smart Contract

Veebit is a simple name registry on Stacks. Users can register a unique name by paying a fee (in microSTX). The contract stores a mapping between names and owners and supports admin-controlled fee updates and withdrawals.

## Features
- Register a unique name up to 32 bytes (buff 32)
- Query name owner and a principal’s registered name
- Admin can set the registration fee and withdraw accumulated fees
- One-time initialize to set the admin (first caller becomes admin)

## Requirements
- Clarinet (v3.7.0 or newer)

Verify Clarinet:

```bash
clarinet --version
```

## Project structure
- contracts/veebit.clar — main contract
- Clarinet.toml — project and contract configuration

## Usage

### 1) Check contract syntax

```bash
cd veebit
clarinet check
```

### 2) Open a console session

```bash
clarinet console
```

Within the console you can use predefined wallets like `deployer`, `wallet_1`, etc.

### 3) Initialize admin (one-time)
The first caller becomes admin. Run once as `deployer` (or your chosen admin):

```clarity
(contract-call? .veebit initialize)
```

Confirm admin:

```clarity
(contract-call? .veebit get-admin)
```

### 4) Register a name
Names are `buff 32`. For example, to register "alice":

```clarity
;; "alice" as UTF-8 bytes
(contract-call? .veebit register 0x616c696365)
```

You can inspect the current fee:

```clarity
(contract-call? .veebit get-fee)
```

### 5) Resolve name or principal

- Resolve owner of a name:

```clarity
(contract-call? .veebit resolve 0x616c696365) ;; => principal or none
```

- Get name for a principal:

```clarity
(contract-call? .veebit name-of 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
```

### 6) Admin operations
- Set registration fee (microSTX):

```clarity
(contract-call? .veebit set-fee u250000) ;; 0.25 STX
```

- Withdraw STX from the contract to a recipient principal:

```clarity
(contract-call? .veebit withdraw u1000000 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
```

## Notes
- Registration requires the caller to pay the current fee; the contract transfers STX from the caller to the contract principal during `register`.
- A principal can own at most one name. Names are immutable once registered in this simple example.
- If you need mutability (changing names) or ASCII strings instead of raw `buff`, consider extending the contract accordingly.
