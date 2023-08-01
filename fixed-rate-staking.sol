// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FixedStaking is ERC20 {
    event staked(uint indexed amount, address user);
    event unstaked(uint indexed amount, address user);
    event claimed(uint indexed rewards, address user);

    mapping(address user => uint amount) public userStakedAmount;
    mapping(address user => uint timeStamp) private stakedFromTimeStamp;

    constructor() ERC20("Fixed Rate Staking", "FRS") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function stake(uint amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        if (userStakedAmount[msg.sender] > 0) {
            claim();
        }
        stakedFromTimeStamp[msg.sender] = block.timestamp;
        userStakedAmount[msg.sender] += amount;

        emit staked(amount, msg.sender);
    }

    function unstake(uint amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            userStakedAmount[msg.sender] >= amount,
            "Insufficient staked balance"
        );
        claim();
        userStakedAmount[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);

        emit unstaked(amount, msg.sender);
    }

    function claim() public {
        require(userStakedAmount[msg.sender] > 0, "Nothing to claim");
        uint secondsStaked = block.timestamp - stakedFromTimeStamp[msg.sender];
        uint rewards = (userStakedAmount[msg.sender] * secondsStaked) / 3.154e7; // 365.25 * 24 * 60 * 60 = 3.154e7 seconds in a year
        _mint(msg.sender, rewards);
        stakedFromTimeStamp[msg.sender] = block.timestamp;

        emit claimed(rewards, msg.sender);
    }
}
