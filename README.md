# Arc Payment DApp

A USDC payment checkout hub built on Arc Testnet. Any shop can accept USDC payments by integrating a few lines of JavaScript — no backend required.

**Live demo:** https://phuocbinh97.github.io/arc-payment-dapp/outputs/arc-usdc-checkout.html

---

## How it works

```
Shop page → creates order → redirects to checkout → customer pays with USDC → on-chain receipt on ArcScan
```

The checkout page acts as a shared hub. Each merchant provides their own wallet address, so payments go directly to them — no middleman.

---

## Smart Contract

| | |
|---|---|
| **Contract** | `ArcCheckout.sol` |
| **Hub contract address** | `0xc7cb4f5ace70a4febc3b260591832af72563e988` |
| **Network** | Arc Testnet (Chain ID: 5042002 / 0x4CEF52) |
| **RPC** | https://rpc.testnet.arc.network |
| **Explorer** | https://testnet.arcscan.app |
| **Gas token** | USDC |

---

## Pages

| File | Description |
|---|---|
| `outputs/arc-usdc-checkout.html` | Main checkout page — customers pay here |
| `outputs/deploy-arc-checkout.html` | Deploy your own contract via browser |

---

## Integrate into your shop

Any shop can redirect customers to this checkout page with the following code:

```javascript
// Call this function when the customer clicks "Pay"
function redirectToCheckout(amount, orderId, memo) {
  const url = new URL('https://phuocbinh97.github.io/arc-payment-dapp/outputs/arc-usdc-checkout.html');

  url.searchParams.set('amount',     amount);               // invoice amount in USDC
  url.searchParams.set('order',      orderId);              // unique order ID
  url.searchParams.set('memo',       memo);                 // order note / description
  url.searchParams.set('merchant',   'YOUR_WALLET_ADDRESS');// ← your merchant wallet
  url.searchParams.set('merchantId', 'YOUR_SHOP_ID');       // ← your shop slug
  url.searchParams.set('contract',   '0xc7cb4f5ace70a4febc3b260591832af72563e988'); // shared hub contract
  url.searchParams.set('mode',       'hub');                // required for hub mode

  window.location.href = url.toString();
}
```

### URL parameters

| Parameter | Required | Description |
|---|---|---|
| `amount` | ✅ | Payment amount in USDC (e.g. `1.50`) |
| `order` | ✅ | Unique order ID (e.g. `shop-001-1234567`) |
| `memo` | ✅ | Order description shown to customer |
| `merchant` | ✅ | Your wallet address — funds go here |
| `merchantId` | ✅ | Your shop slug (e.g. `my-shop`) |
| `contract` | ✅ | Hub contract address (use the one above) |
| `mode` | ✅ | Must be `hub` |

### Example

```javascript
redirectToCheckout(
  '5.00',
  'myshop-order-' + Date.now(),
  'Coffee x2, Matcha latte x1',
);
```

---

## Payment flow

1. **Approve USDC** — customer allows the checkout contract to spend the exact invoice amount
2. **Confirm payment** — transaction is sent through the hub contract on Arc
3. **Get receipt** — view the confirmed transaction on ArcScan

---

## Run locally

No build tools required. Just serve the `outputs/` folder with any static server:

```bash
# Python
cd outputs
python -m http.server 8765

# Then open
# http://127.0.0.1:8765/arc-usdc-checkout.html
```

---

## Get testnet USDC

Before paying, get Arc Testnet USDC from the Circle Faucet:
https://faucet.circle.com

---

## License

## Author

Built by [phuocbinh97](https://github.com/phuocbinh97)

- 🐦 Twitter: [@phuocbinh97](https://x.com/phuocbinh97)
- 💬 Discord: phuocbinh97
- 🌐 Website: https://your-website.com
MIT
