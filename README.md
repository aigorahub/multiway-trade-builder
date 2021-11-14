# multiway-trade-builder

Library for constructing multiway trades as Clarity contracts.

## TODO:

### Python:

- [ ] Add argumenet for contract name
- [ ] Add argumenet for deployment on mainnet or testnet (SIP-009 contract on mainnet: https://explorer.stacks.co/txid/0x80eb693e5e2a9928094792080b7f6d69d66ea9cc881bc465e8d9c5c621bd4d07?chain=mainnet)
- [ ] Make the deal template that will be filled instead of keeping everything in variables inside python script
- [ ] Allow cancellation only once time period `T` has passed


### Contract:

- [ ] Remove `stx-balance` function
- [ ] Create read-only function for checking contract status (in progress/finished/cancelled)
- [ ] Define and use errors:
    - `deal-closed`
	- `cannot-escrow-nft`
	- `cannot-escrow-stx`
	- `sender-already-confirmed`	
- [ ] Rename functions to be easier to understand
    - `trade` -> `confirm-and-escrow`
	- `run-exchange` -> `releas-escrow`
	- `close-the-deal` -> `cancel-escrow`
- [ ] In `confirm-and-escrow` check at the beginning if the deal is closed (if so throw an error)
- [ ] In `confirm-and-escrow` check if the sender already confirmed the trade (if so throw an error)

