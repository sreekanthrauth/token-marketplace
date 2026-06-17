// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Note: The following contract is a simplified version of a token marketplace for demonstration purposes. It allows users to buy and sell GLD tokens at a dynamic price based on market demand. The contract owner can also withdraw excess tokens and accumulated Ether.
// This contract is currently under development.
// Compilation issues related to OpenZeppelin version compatibility
// will be resolved in a future update.

contract TokenMarketPlace is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public tokenPrice = 2e16 wei; // 0.02 ether per GLD token
    uint256 public sellerCount = 1;
    uint256 public buyerCount = 1;

    IERC20 public gldToken;

    event TokenPriceUpdated(uint256 newPrice);
    event TokenBought(address indexed buyer, uint256 amount, uint256 totalCost);
    event TokenSold(address indexed seller, uint256 amount, uint256 totalEarned);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event CalculateTokenPrice(uint256 priceToPay);

    constructor(address _gldToken) Ownable(msg.sender){
        gldToken = IERC20(_gldToken);
    }

    // Updated logic for token price calculation with safeguards
    function tokenPriceCalculator() public {

        // Calculate the market demand ratio with a smoothing factor to prevent drastic changes
        uint256 marketDemandRatio = buyerCount.mul(1e18).div(sellerCount);
        console.log("marketDemandRatio",marketDemandRatio);

        // Introduce a smoothing factor to avoid abrupt changes
        uint256 smoothingFactor = 1e18; // Can be adjusted based on the desired sensitivity
        uint256 adjustedRatio = marketDemandRatio.add(smoothingFactor).div(2);
        console.log("adjustedRatio",adjustedRatio);

        // Adjust the token price based on the adjusted market demand ratio
        uint256 newTokenPrice = tokenPrice.mul(adjustedRatio).div(1e18);
        console.log("newTokenPrice",newTokenPrice);

        // Set a minimum price to prevent it from dropping too low
        uint256 minimumPrice = 1e15; // 0.001 ether as minimum price
        if(newTokenPrice < minimumPrice){
            tokenPrice = minimumPrice;
        } else {
            tokenPrice = newTokenPrice;
        }
    }

    // Buy tokens from the marketplace
    function buyGLDToken(uint256 _amountOfToken) public payable {
        
    }

    function calculateTokenPrice(uint _amountOfToken) public returns(uint){
        require(_amountOfToken>0,"Amount Of Token > 0");
        tokenPriceCalculator();
        
        uint amountToPay = _amountOfToken.mul(tokenPrice).div(1e18);
        console.log("amountToPay",amountToPay);
        return amountToPay;
    }

    // Sell tokens back to the marketplace
    function sellGLDToken(uint256 amountOfToken) public {
        
    }

    // Owner can withdraw excess tokens from the contract
    function withdrawTokens(uint256 amount) public onlyOwner {
    
    }

    // Owner can withdraw accumulated Ether from the contract
    function withdrawEther(uint256 amount) public onlyOwner {
        
    }
}


    //buyerCount = 5 
    //sellerCount = 1
    //markedDemand ratio =
    //buyerCount.mul(1e18).div(sellerCount) = 5*10^18 /1 = 5*10^18
    //adjustedRatio = (5*10^18 + 1*10^18)/2 = (6 * 10^18)/2 = 3 * 10^18
    // newTokenPrice = //(2 * 10^16 * 3 * 10^18) / 10^18 = (6 * 10^34)/10^18 = 6*10^16 wei = 0.06 ether
