* Tournament Entry contract on Core Testnet: https://scan.test2.btcs.network/address/0x65e86F9364C65e0A0AF78542b634226B706A42d2#code
* Tickets bundles contract on Core testnet: https://scan.test2.btcs.network/address/0x24686e2FED75806e4155D15174D7e2D523a22e25#code
* Free tickets claim contract on Core Testnet: https://scan.test2.btcs.network/address/0x9528A8962A817584632019b80786eF8A1008DD12#code 

# 🏆 TournamentTicket — ETH Tournament Access via Smart Contract (EVM, Solidity)

## 📄 Specification

### 🎯 Purpose

Implement a smart contract where players can **buy a ticket for a tournament using ETH**. Only after buying the ticket their points will be counted in the leaderboard. Tickets are valid only for the current tournament.

---

### ⚙️ Logic Overview

- The tournament has a unique ID (e.g. `"season1"`, `"s2025_06"`).
- To participate, a player must pay a fixed ETH amount (e.g. `0.01 ether`).
- Without a ticket, the player can fight, but their score won't enter the leaderboard.
- When a new tournament starts, all previous tickets are invalidated.
- ETH from ticket sales is sent to a designated treasury address.

---

### 📌 Key Functions

#### 🔹 Admin

| Function | Description |
|---------|-------------|
| `startNewTournament(string memory id)` | Sets a new tournament ID and clears previous tickets |
| `setTicketPrice(uint256 priceInWei)` | Sets the ticket price in ETH |
| `setTreasury(address payable treasuryAddr)` | Sets the treasury address |
| `withdraw()` | (Optional) Manually withdraws ETH from the contract to treasury |

#### 🔹 User

| Function | Description |
|---------|-------------|
| `buyTicket()` | Pays for a tournament ticket (`msg.value == ticketPrice`) |
| `hasTicket(address user)` → `bool` | Checks if the user has a valid ticket |
| `getCurrentTournamentId()` → `string` | Returns current tournament ID |

---

### 💰 Payment Logic

- `ticketPrice` is set in **wei**.
- On `buyTicket()`:
  - Checks that `msg.value == ticketPrice`
  - Checks that the user hasn't bought a ticket yet
  - ETH is sent to the treasury address

---

### 🛡 Security

| Check | Detail |
|-------|--------|
| 🔒 Double buy | Forbidden — triggers `revert` |
| 🔒 Invalid ETH amount | Any deviation triggers `revert` |
| 🔒 Admin access | Only `owner` can call admin functions |
| 🔒 Ticket reset | All previous tickets become invalid when a new tournament starts |

---

### 🎁 Free Ticket Claim (Spam Protection)

To distribute free tickets (e.g., for completing tasks or as part of promotional events), a "proof-of-action" mechanism is used for spam protection. This allows for issuing tickets in an off-chain database, using the blockchain only as a verifier.

**Logic:**
1.  **On-Chain Action:** A user calls the `claim()` function in the `ClaimLogger.sol` contract. This transaction requires no funds (other than gas fees) and emits a `Claimed(user, timestamp)` event.
2.  **Backend Request:** After the transaction is confirmed, the frontend sends a request to the backend to issue the ticket.
3.  **Backend Verification:** The backend verifies that a recent `Claimed` event was emitted by this user. If the event is found, the backend issues a ticket in its own database.

This approach keeps all ticket logic off-chain (for now), using the blockchain as a reliable and cheap method to protect against automated requests.

---

### 🎟️ Ticket Bundles (Paid Packages)

To allow for bulk ticket purchases, a separate `TicketBundle.sol` contract is used. It enables admins to create and manage ticket packages that users can buy directly.

**Logic:**
1.  **Admin Setup:** An admin calls `setPackage()` to define a package's ID, ticket count, and price. Admins can also deactivate and hide packages using `removePackage()`.
2.  **Listing Packages:** A frontend application can call `getAllPackages()` to retrieve a complete list of all available ticket packages and display them to users.
3.  **User Purchase:** A user calls the `buyPackage(packageId)` function, sending the exact amount of ETH required for that package.
4.  **On-Chain Record:** The contract records the purchase, linking the user's address to the package ID. The ETH is forwarded to the treasury.
5.  **Backend Validation:** A backend service can query the contract using `getPurchaseCount(user, packageId)` to verify the purchase and credit the corresponding number of tickets to the user's account off-chain.

This system provides a flexible way to sell tickets in bundles, with on-chain verification for backend systems.

#### 🔹 Key Functions (`TicketBundle.sol`)

| Function | Description |
|---------|-------------|
| `setPackage(uint256, uint256, uint256, bool)` | Creates or updates a ticket package. |
| `removePackage(uint256)` | Deactivates a package and hides it from the public list. |
| `setTreasury(address payable)` | Sets the treasury address. |
| `buyPackage(uint256)` | Pays for a ticket package. |
| `getAllPackages()` | Returns details for all available packages. |
| `getPurchaseCount(address, uint256)` | Checks how many times a user has bought a specific package. |

---

### 🧪 Test Cases

| Test | Expected behavior |
|------|--------------------|
| ✅ `buyTicket()` | Purchase succeeds, `hasTicket(user)` → `true` |
| 🚫 Re-buy ticket | `revert` |
| 🚫 Wrong `msg.value` | `revert` |
| ✅ `startNewTournament()` | Resets all ticket states |
| ✅ Treasury receives ETH | ETH successfully transferred |

---

### 📝 Interface (ABI)

```solidity
function buyTicket() external payable;
function hasTicket(address user) external view returns (bool);
function getCurrentTournamentId() external view returns (string memory);

function startNewTournament(string memory id) external onlyOwner;
function setTicketPrice(uint256 priceInWei) external onlyOwner;
function setTreasury(address payable treasuryAddr) external onlyOwner;
function withdraw() external onlyOwner;
```

---

### 🚀 Optional Improvements (Post-MVP)

| Idea | Value |
|------|-------|
| `event TicketPurchased(address user, string tournamentId)` | Easy frontend sync |
| NFT-based tickets | Tradable visual tickets |
| Time-based restriction | Tournament start/end timestamps |
| Ticket cap | Bot protection / participant limit |

---

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

---

## 📁 Structure

```
.
├── src/                     # Contracts
│   └── TournamentTicket.sol
├── test/                    # Test suite
│   └── TournamentTicket.t.sol
├── script/                  # Deployment scripts
│   └── Deploy.s.sol
├── foundry.toml            # Foundry config
└── README.md               # This file
```
