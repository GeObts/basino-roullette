
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AmericanRoulette {
    enum BetType { Blue, Black, Zero, DoubleZero }
    struct Bet {
        address player;
        BetType betType;
        uint256 amount;
    }

    mapping(address => Bet[]) public bets;
    mapping(address => uint256) public winnings; // Track winnings of each player

    event BetPlaced(address indexed player, BetType betType, uint256 amount);
    event SpinResult(BetType result);
    event WinningsWithdrawn(address indexed player, uint256 amount);

    // Function to place a bet
    function placeBet(BetType _betType) external payable {
        require(msg.value > 0, "Bet amount must be greater than 0");
        bets[msg.sender].push(Bet(msg.sender, _betType, msg.value));
        emit BetPlaced(msg.sender, _betType, msg.value);
    }

    // Function to simulate a spin
    function spinWheel() external {
        BetType result = _generateSpinResult();
        emit SpinResult(result);
        _distributeWinnings(result);
    }

    // Internal function to generate spin result
    function _generateSpinResult() internal view returns (BetType) {
        uint256 result = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 38;
        if (result == 0) return BetType.Zero;
        else if (result == 37) return BetType.DoubleZero;
        else if (result % 2 == 0) return BetType.Blue; // Even numbers are blue
        else return BetType.Black; // Odd numbers are black
    }

    // Internal function to distribute winnings based on spin result
    function _distributeWinnings(BetType result) internal {
        for (uint256 i = 0; i < bets[msg.sender].length; i++) {
            Bet memory bet = bets[msg.sender][i];
            if (bet.bet
