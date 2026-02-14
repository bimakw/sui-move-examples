# Sui Move Examples

Move smart contract examples for the Sui blockchain: counter, greeting, escrow, simple NFT, and access-control whitelist.

## Building & Testing

```bash
sui move build
sui move test
```

Deploy with `sui client publish --gas-budget 100000000`.

## What's Included

| Module | What it shows |
|--------|--------------|
| counter | Object creation, state mutation |
| greeting | String handling, events |
| escrow | Coin handling, shared objects |
| simple_nft | NFT patterns, URL handling |
| whitelist | Capability pattern, tables |

## License

MIT with attribution — see [LICENSE](LICENSE).
