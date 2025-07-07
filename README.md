# 🏆 Mortal Contracts — Smart Contracts for Tournament Platform (EVM, Solidity)



## 📄 Specification

### 🎯 Purpose

This project contains a set of smart contracts for managing a tournament platform. Players can buy tickets for tournaments using ETH, purchase ticket bundles, and claim free tickets. The contracts are designed to be secure, gas-efficient, and easily integrable with a backend service.

---

### 1. `TournamentTicket.sol`

A contract where players can **buy a ticket for a tournament using ETH**. Only after buying the ticket will their points be counted in the leaderboard. The contract supports multiple concurrent tournaments and keeps a history of participants for each.

#### ⚙️ Logic Overview

- The system can manage multiple tournaments, each identified by a unique ID (e.g., `"season1"`, `"s2025_06"`).
- The admin sets the active tournament by calling `startNewTournament(id)`.
- To participate in the **current** tournament, a player must pay a fixed ETH amount.
- The contract is designed to be gas-efficient, avoiding loops over large arrays. Participant lists are accessed via pagination (`getParticipantsCount` and `getParticipant`).
- When a new tournament becomes active, tickets for previous tournaments remain in the contract's history but are not valid for the current one.
- ETH from ticket sales is sent to a designated treasury address.

#### 📌 Key Functions

##### Admin

| Function | Description |
|---------|-------------|
| `startNewTournament(string memory id)` | Sets a new tournament ID. Reverts if the ID already exists. |
| `setTicketPrice(uint256 priceInWei)` | Sets the ticket price in ETH. |
| `setTreasury(address payable treasuryAddr)` | Sets the treasury address. |
| `withdraw()` | Manually withdraws ETH from the contract to the treasury. |

##### User

| Function | Description |
|---------|-------------|
| `buyTicket()` | Pays for a ticket for the **current** tournament. |
| `hasTicket(address user)` → `bool` | Checks if the user has a valid ticket for the **current** tournament. |
| `getCurrentTournamentId()` → `string` | Returns the current tournament ID. |
| `getParticipantsCount()` → `uint256` | Returns the number of participants for the current tournament. |
| `getParticipant(uint256 index)` → `address` | Returns a participant's address by index for the current tournament. |

---

### 2. `ClaimLogger.sol`

A simple contract to protect against spam when distributing free tickets.

#### ⚙️ Logic Overview

This contract uses a "proof-of-action" mechanism for spam protection, using the blockchain as a verifier.

1.  **On-Chain Action:** A user calls the `claim()` function. This transaction requires no funds (other than gas) and emits a `Claimed(user, timestamp)` event.
2.  **Backend Request:** After the transaction is confirmed, the frontend sends a request to the backend to issue the ticket.
3.  **Backend Verification:** The backend verifies that a recent `Claimed` event was emitted by this user. If so, the backend issues a ticket in its own database.

This approach keeps ticket logic off-chain, using the blockchain as a cheap way to guard against automated requests.

---

### 3. `TicketBundle.sol`

A separate contract for bulk ticket purchases, allowing admins to create and manage ticket packages.

#### ⚙️ Logic Overview

1.  **Admin Setup:** An admin calls `setPackage()` to define a package's ID, ticket count, and price. Admins can also deactivate packages.
2.  **Listing Packages:** A frontend application can call `getAllPackages()` to retrieve a list of all available ticket packages.
3.  **User Purchase:** A user calls `buyPackage(packageId)`, sending the required ETH.
4.  **On-Chain Record & Security:** The contract records the purchase and forwards the ETH to the treasury. The `buyPackage` function is protected against **re-entrancy attacks** using OpenZeppelin's `ReentrancyGuard`.
5.  **Backend Validation:** A backend service can query the contract using `getPurchaseCount(user, packageId)` to verify the purchase and credit tickets to the user's account off-chain.

#### 📌 Key Functions

| Function | Description |
|---------|-------------|
| `setPackage(uint256, uint256, uint256, bool)` | Creates or updates a ticket package. |
| `removePackage(uint256)` | Deactivates a package and hides it from the public list. |
| `setTreasury(address payable)` | Sets the treasury address. |
| `buyPackage(uint256)` | Pays for a ticket package. Protected against re-entrancy. |
| `getAllPackages()` | Returns details for all available packages. |
| `getPurchaseCount(address, uint256)` | Checks how many times a user has bought a specific package. |

---

### 🛡 Security

| Check | Detail |
|-------|--------|
| 🔒 Double Buy | A user cannot buy more than one ticket per tournament. |
| 🔒 Re-entrancy | `TicketBundle.buyPackage` is protected with `ReentrancyGuard`. |
| 🔒 Gas Limits | Loops over unbounded arrays are avoided to prevent out-of-gas errors. |
| 🔒 Admin Access | Critical functions are restricted to the `owner`. |
| 🔒 Ticket Validity | Tickets are tied to a specific tournament ID. |

<details>
<summary>Foundry Documentation</summary>

# 🛠 Foundry

**Foundry is a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat, DappTools).
- **Cast**: Swiss army knife for sending transactions, querying data, etc.
- **Anvil**: Local Ethereum node, like Ganache or Hardhat Network.
- **Chisel**: Solidity REPL (experimental).

---

## 📚 Documentation

📖 https://book.getfoundry.sh/

---

## 🔧 Usage

### 🧱 Build

```bash
forge build
```

### 🧪 Run Tests

```bash
forge test -vvv
```

### 🎨 Format Code

```bash
forge fmt
```

### ⛽ Gas Snapshots

```bash
forge snapshot
```

### 🧪 Local Node

```bash
anvil
```

### 🚀 Deploy

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### 🔧 Cast Commands

```bash
cast <subcommand>
```

### 🆘 Help

```bash
forge --help
anvil --help
cast --help
```
</details>

---

## 📁 Structure

```
.
├── lib
│   ├── forge-std
│   └── openzeppelin-contracts
├── script
│   ├── Counter.s.sol
│   ├── Deploy.s.sol
│   ├── DeployClaimLogger.s.sol
│   └── DeployTicketBundle.s.sol
├── src
│   ├── ClaimLogger.sol
│   ├── Counter.sol
│   ├── TicketBundle.sol
│   └── TournamentTicket.sol
├── test
│   ├── ClaimLogger.t.sol
│   ├── Counter.t.sol
│   ├── TicketBundle.t.sol
│   └── TournamentTicket.t.sol
├── foundry.toml
└── README.md
```
