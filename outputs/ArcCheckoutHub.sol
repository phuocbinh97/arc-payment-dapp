// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Hub {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ArcCheckoutHub {
    address public immutable owner;
    address public immutable usdc;
    string public projectSlug;
    uint256 public paymentCount;

    event MerchantPaymentReceived(
        string indexed projectSlug,
        string indexed merchantId,
        string orderId,
        address indexed payer,
        address merchant,
        uint256 amount,
        string memo,
        uint256 paymentNumber
    );

    constructor(address usdc_, string memory projectSlug_) {
        require(usdc_ != address(0), "usdc required");
        owner = msg.sender;
        usdc = usdc_;
        projectSlug = projectSlug_;
    }

    function payToMerchant(
        address merchant,
        string calldata merchantId,
        string calldata orderId,
        uint256 amount,
        string calldata memo
    ) external {
        require(merchant != address(0), "merchant required");
        require(amount > 0, "amount required");
        require(bytes(merchantId).length > 0, "merchant id required");

        bool ok = IERC20Hub(usdc).transferFrom(msg.sender, merchant, amount);
        require(ok, "usdc transfer failed");

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
