// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ─────────────────────────────────────────────────────────────────────────────
// ArcCheckoutHub — shared payment hub for multiple merchants on Arc Testnet
//
// Arc-specific notes:
//   • USDC is the native gas token on Arc (18 dec native / 6 dec ERC-20)
//   • This contract uses the USDC ERC-20 interface (6 decimals)
//   • Arc has deterministic sub-second finality — no re-org risk
//   • Do NOT use block.prevrandao (always 0 on Arc)
//   • Do NOT use SELFDESTRUCT — restricted on Arc
//
// Hub model: one shared contract routes payments to many merchant wallets.
// Each merchant provides their own wallet address via the frontend URL params.
// Funds go directly from payer → merchant wallet — this contract holds nothing.
// ─────────────────────────────────────────────────────────────────────────────

interface IERC20Hub {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ArcCheckoutHub {
    // ── State ─────────────────────────────────────────────────────────────────
    address public immutable owner;
    address public immutable usdc;
    string  public projectSlug;
    uint256 public paymentCount;

    // ── Reentrancy guard ──────────────────────────────────────────────────────
    uint256 private _guardStatus;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    modifier nonReentrant() {
        require(_guardStatus != _ENTERED, "reentrant call");
        _guardStatus = _ENTERED;
        _;
        _guardStatus = _NOT_ENTERED;
    }

    // ── Events ────────────────────────────────────────────────────────────────
    event MerchantPaymentReceived(
        string  indexed projectSlug,
        string  indexed merchantId,
        string          orderId,
        address indexed payer,
        address         merchant,
        uint256         amount,
        string          memo,
        uint256         paymentNumber
    );

    // ── Constructor ───────────────────────────────────────────────────────────
    constructor(address usdc_, string memory projectSlug_) {
        require(usdc_        != address(0), "usdc required");
        require(bytes(projectSlug_).length > 0, "projectSlug required");

        owner       = msg.sender;
        usdc        = usdc_;
        projectSlug = projectSlug_;

        _guardStatus = _NOT_ENTERED;
    }

    // ── Pay to merchant ───────────────────────────────────────────────────────
    // Routes USDC payment from caller directly to the specified merchant wallet.
    // No funds are held by this contract — it is a pure routing layer.
    // Caller must have approved this contract for at least `amount` first.
    //
    // @param merchant    Merchant wallet address to receive the payment
    // @param merchantId  Merchant identifier (slug) for indexing/analytics
    // @param orderId     Unique order reference from the merchant system
    // @param amount      Amount in USDC ERC-20 units (6 decimals)
    // @param memo        Human-readable order description
    function payToMerchant(
        address merchant,
        string calldata merchantId,
        string calldata orderId,
        uint256 amount,
        string calldata memo
    ) external nonReentrant {
        require(merchant                  != address(0), "merchant required");
        require(amount                     > 0,          "amount must be > 0");
        require(bytes(merchantId).length   > 0,          "merchantId required");
        require(bytes(merchantId).length  <= 64,         "merchantId too long");
        require(bytes(orderId).length      > 0,          "orderId required");
        require(bytes(orderId).length     <= 128,        "orderId too long");
        require(bytes(memo).length        <= 256,        "memo too long");

        // Transfer USDC (ERC-20, 6 decimals) from payer directly to merchant
        bool ok = IERC20Hub(usdc).transferFrom(msg.sender, merchant, amount);
        require(ok, "USDC transfer failed");

        paymentCount += 1;

        emit MerchantPaymentReceived(
            projectSlug,
            merchantId,
            orderId,
            msg.sender,
            merchant,
            amount,
            memo,
            paymentCount
        );
    }
}
