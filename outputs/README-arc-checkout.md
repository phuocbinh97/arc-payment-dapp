# Arc USDC Checkout Kit

This kit gives you a unique Arc Testnet footprint:

- `ArcCheckout.sol`: your own checkout contract.
- `arc-usdc-checkout.html`: browser UI for approving USDC and paying through your contract.

## Deploy With Remix

1. Open https://remix.ethereum.org.
2. Create a new file named `ArcCheckout.sol`.
3. Paste the contents of `ArcCheckout.sol` from this folder.
4. Compile with Solidity `0.8.24` or newer.
5. Connect Remix to MetaMask using `Injected Provider`.
6. Make sure MetaMask is on Arc Testnet:
   - RPC: `https://rpc.testnet.arc.network`
   - Chain ID: `5042002`
   - Native token: `USDC`
   - Explorer: `https://testnet.arcscan.app`
7. Deploy `ArcCheckout` with:
   - `merchant_`: your receiving wallet address
   - `usdc_`: `0x3600000000000000000000000000000000000000`
   - `merchantId_`: a unique name, for example `yourname-arc-checkout`
   - `projectSlug_`: a unique project slug, for example `arc-usdc-checkout-yourname`
8. Copy the deployed contract address.
9. Open the checkout app and paste the contract address into `Checkout contract`.

## Payment Flow

The app sends two wallet transactions:

1. `USDC.approve(checkoutContract, amount)`
2. `ArcCheckout.pay(orderId, amount, memo)`

The contract emits `PaymentReceived`, which makes the activity easy to identify on ArcScan as your own project.
