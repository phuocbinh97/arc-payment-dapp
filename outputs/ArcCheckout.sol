// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ArcCheckout {
    address public immutable owner;
    address public immutable merchant;
    address public immutable usdc;
    string public merchantId;
    string public projectSlug;
    uint256 public paymentCount;

    event PaymentReceived(
        string indexed projectSlug,
        string indexed merchantId,
        string orderId,
        address indexed payer,
        address merchant,
        uint256 amount,
        string memo,
        uint256 paymentNumber
    );

    constructor(address merchant_, address usdc_, string memory merchantId_, string memory projectSlug_) {
        require(merchant_ != address(0), "merchant required");
        require(usdc_ != address(0), "usdc required");
        owner = msg.sender;
        merchant = merchant_;
        usdc = usdc_;
        merchantId = merchantId_;
        projectSlug = projectSlug_;
    }

    function pay(string calldata orderId, uint256 amount, string calldata memo) external {
        require(amount > 0, "amount required");

        bool ok = IERC20(usdc).transferFrom(msg.sender, merchant, amount);
        require(ok, "usdc transfer failed");

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
