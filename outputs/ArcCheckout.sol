// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ─────────────────────────────────────────────────────────────────────────────
// ArcCheckout — single-merchant payment contract for Arc Testnet
//
// Arc-specific notes:
//   • USDC is the native gas token on Arc (18 dec native / 6 dec ERC-20)
//   • This contract interacts with the ERC-20 interface (6 decimals)
//   • Arc has deterministic sub-second finality — no re-org risk
//   • Do NOT use block.prevrandao (always 0 on Arc)
//   • Do NOT use SELFDESTRUCT — restricted on Arc
// ─────────────────────────────────────────────────────────────────────────────

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ArcCheckout {
    // ── State ─────────────────────────────────────────────────────────────────
    address public immutable owner;
    address public immutable merchant;
    address public immutable usdc;
    string  public merchantId;
    string  public projectSlug;
    uint256 public paymentCount;

    // ── Reentrancy guard ──────────────────────────────────────────────────────
    // Prevents re-entrant calls on the pay() function.
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
    event PaymentReceived(
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
    constructor(
        address merchant_,
        address usdc_,
        string memory merchantId_,
        string memory projectSlug_
    ) {
        require(merchant_    != address(0), "merchant required");
        require(usdc_        != address(0), "usdc required");
        require(bytes(merchantId_).length  > 0, "merchantId required");
        require(bytes(projectSlug_).length > 0, "projectSlug required");

        owner       = msg.sender;
        merchant    = merchant_;
        usdc        = usdc_;
        merchantId  = merchantId_;
        projectSlug = projectSlug_;

        _guardStatus = _NOT_ENTERED;
    }

    // ── Pay ───────────────────────────────────────────────────────────────────
    // Transfers `amount` USDC (6-decimal ERC-20) from caller to merchant.
    // Caller must have approved this contract for at least `amount` first.
    //
    // @param orderId  Unique order reference from the merchant system
    // @param amount   Amount in USDC ERC-20 units (6 decimals, e.g. 1_000_000 = 1 USDC)
    // @param memo     Human-readable order description
    function pay(
        string calldata orderId,
        uint256 amount,
        string calldata memo
    ) external nonReentrant {
        require(amount > 0,                   "amount must be > 0");
        require(bytes(orderId).length > 0,    "orderId required");
        require(bytes(orderId).length <= 128, "orderId too long");
        require(bytes(memo).length    <= 256, "memo too long");

        // Transfer USDC (ERC-20, 6 decimals) from payer to merchant directly
        // transferFrom reverts on failure — no need to check bool separately
        bool ok = IERC20(usdc).transferFrom(msg.sender, merchant, amount);
        require(ok, "USDC transfer failed");

        paymentCount += 1;

        emit PaymentReceived(
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
