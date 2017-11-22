pragma solidity ^0.4.16;

import "./Destructible.sol";
import "./GreenToken.sol";

contract GreenCrowdsale is Destructible {
    GreenToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    
    // uint public price = 0.0007427866085 * 1 ether;   // 85,420.46 ether / 115,000,000 token
    uint public salePeriod = 10 days;
    
    uint public totalAmountRaised = 0;

    event FundTransfer (address _backer, uint _amount, bool _isContribution);

// StateMachine <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    enum Stages {
        NotStarted,
        InProgress,
        Finished
    }

    uint startTime = 0;                   // public for dev
    Stages stage = Stages.NotStarted;     // public for dev

    modifier atStage (Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    modifier transitionNext () {
        _;
        stage = Stages(uint(stage) + 1);
    }
    
    modifier timedTransitions () {
        require(stage > Stages.NotStarted);
        uint diff = now - startTime;
        if (diff >= salePeriod && stage != Stages.Finished) {
            stage = Stages.Finished;
        }
        _;
    }
// StateMachine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    function GreenCrowdsale (address _addressOfTokenUsedAsReward)
    {
        require(_addressOfTokenUsedAsReward != 0x0);
        tokenReward = GreenToken(_addressOfTokenUsedAsReward);
    }

    function () payable 
    timedTransitions 
    atStage(Stages.InProgress) 
    {
        uint amount = msg.value;

        totalAmountRaised += amount;
        balanceOf[msg.sender] += amount;
        tokenReward.transfer(msg.sender, amount / calculatePrice());
        
        FundTransfer(msg.sender, amount, true);
    }
    
    function calculatePrice () internal constant returns (uint price) {
        if (totalAmountRaised <= 26400.00) {
            return 0.002933333333 * 1 ether;
        } else if (totalAmountRaised > 26400.00 * 1 ether && totalAmountRaised <= 41066.67 * 1 ether) {
            return 0.003666666667 * 1 ether;
        } else if (totalAmountRaised > 41066.67 * 1 ether && totalAmountRaised <= 48400.00 * 1 ether) {
            return 0.004888888889 * 1 ether;
        } else if (totalAmountRaised > 48400.00 * 1 ether && totalAmountRaised <= 58490.75 * 1 ether) {
            return 0.007333333333 * 1 ether;
        } else {
            return 1 ether; // ?????????????
        }
    }
    
    function startPresale ()
    onlyOwner
    atStage(Stages.NotStarted)
    transitionNext 
    {
        startTime = now;
    }
    
    function minutesToEnd () constant returns (uint _time) {
        require(stage > Stages.NotStarted && stage < Stages.Finished);
        uint endTime = startTime + salePeriod;
        uint toEndTime = endTime - now;
        return toEndTime <= salePeriod ? toEndTime / 1 minutes : 0;
    }
    
    function amountLeft () constant returns (uint _balance) {
        return this.balance;
    }
    
    function safeWithdrawal ()
    onlyOwner
    timedTransitions
    atStage(Stages.Finished)
    {
        uint amountRaised = this.balance;
        owner.transfer(amountRaised);
        tokenReward.transfer(owner, tokenReward.balanceOf(this));
        
        FundTransfer(owner, amountRaised, false);
    }
}

