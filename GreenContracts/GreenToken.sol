pragma solidity ^0.4.8;

import "./BaseToken.sol";

contract GreenToken is BaseToken {
    string public name = "GreenToken";
    uint8 public decimals = 3;
    string public symbol = "GREEN";
    string public version = '0.1';

    function GreenToken(
        uint256 _initialAmount
        ) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
    }
}
