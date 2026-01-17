# Sui Move Examples

A collection of Move smart contract examples for the Sui blockchain, demonstrating core concepts and patterns.

## Tech Stack

- **Language**: Move
- **Blockchain**: Sui Network
- **SDK**: Sui CLI

## Examples Included

| Module | Description | Concepts |
|--------|-------------|----------|
| `counter` | Simple counter with increment/decrement | Object creation, state mutation |
| `greeting` | Greeting message with events | String handling, events |
| `escrow` | Peer-to-peer escrow system | Coin handling, shared objects |
| `simple_nft` | Basic NFT minting and transfer | NFT patterns, URL handling |
| `whitelist` | Access control whitelist | Capability pattern, tables |

## Prerequisites

```bash
# Install Sui CLI
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui
```

## Quick Start

```bash
# Clone repository
git clone https://github.com/bimakw/sui-move-examples.git
cd sui-move-examples

# Build
sui move build

# Run tests
sui move test
```

## Project Structure

```
sui-move-examples/
├── sources/
│   ├── counter.move      # Counter example
│   ├── greeting.move     # Greeting with events
│   ├── escrow.move       # Escrow system
│   ├── simple_nft.move   # NFT example
│   └── whitelist.move    # Access control
├── tests/
├── Move.toml
├── LICENSE
└── README.md
```

## Usage Examples

### Counter

```bash
# Create a counter
sui client call --package $PACKAGE_ID --module counter --function create_counter --gas-budget 10000000

# Increment
sui client call --package $PACKAGE_ID --module counter --function increment --args $COUNTER_ID --gas-budget 10000000
```

### Simple NFT

```bash
# Mint NFT
sui client call --package $PACKAGE_ID --module simple_nft --function mint_to_self \
  --args "My NFT" "A cool NFT" "https://example.com/image.png" \
  --gas-budget 10000000
```

### Escrow

```bash
# Create escrow
sui client call --package $PACKAGE_ID --module escrow --function create_escrow \
  --args $BUYER_ADDRESS 1000000000 \
  --gas-budget 10000000

# Deposit funds (as buyer)
sui client call --package $PACKAGE_ID --module escrow --function deposit \
  --args $ESCROW_ID $COIN_ID \
  --gas-budget 10000000

# Confirm receipt (releases funds to seller)
sui client call --package $PACKAGE_ID --module escrow --function confirm_receipt \
  --args $ESCROW_ID \
  --gas-budget 10000000
```

## Key Concepts Demonstrated

### 1. Object Model
- Creating owned objects (`Counter`, `NFT`)
- Shared objects (`Escrow`, `Whitelist`)
- Object deletion and cleanup

### 2. Capability Pattern
- Admin capabilities (`AdminCap` in whitelist)
- Access control without passwords

### 3. Events
- Emitting events for indexing
- Event-driven architecture

### 4. Coin/Balance Handling
- Working with SUI coins
- Balance management in escrow

### 5. Tables
- Dynamic data structures
- Key-value storage

## Deployment

```bash
# Deploy to testnet
sui client publish --gas-budget 100000000

# Save the package ID from output
export PACKAGE_ID=0x...
```

## Testing

```bash
# Run all tests
sui move test

# Run specific test
sui move test counter_tests

# Run with verbose output
sui move test -v
```

## License

MIT License with Attribution - See [LICENSE](LICENSE)

Copyright (c) 2024 Bima Kharisma Wicaksana
