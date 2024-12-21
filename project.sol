// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationalGameRewards {
    
    address public owner;
    
    struct TreasureHunt {
        uint256 id;
        string name;
        string description;
        uint256 rewardAmount;
        address[] participants;
        mapping(address => bool) rewardsClaimed;
    }

    uint256 public nextHuntId;
    mapping(uint256 => TreasureHunt) public treasureHunts;
    mapping(address => uint256) public userRewards;

    event HuntCreated(uint256 huntId, string name, uint256 rewardAmount);
    event RewardClaimed(address participant, uint256 huntId, uint256 rewardAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextHuntId = 1;
    }

    function createTreasureHunt(string memory name, string memory description, uint256 rewardAmount) external onlyOwner {
        TreasureHunt storage hunt = treasureHunts[nextHuntId];
        hunt.id = nextHuntId;
        hunt.name = name;
        hunt.description = description;
        hunt.rewardAmount = rewardAmount;
        
        emit HuntCreated(nextHuntId, name, rewardAmount);
        nextHuntId++;
    }

    function participateInHunt(uint256 huntId) external {
        require(huntId < nextHuntId, "Treasure hunt does not exist");

        TreasureHunt storage hunt = treasureHunts[huntId];
        hunt.participants.push(msg.sender);
    }

    function claimReward(uint256 huntId) external {
        require(huntId < nextHuntId, "Treasure hunt does not exist");

        TreasureHunt storage hunt = treasureHunts[huntId];
        require(!hunt.rewardsClaimed[msg.sender], "Reward already claimed");
        require(hunt.rewardAmount > 0, "Insufficient reward amount in this hunt");

        userRewards[msg.sender] += hunt.rewardAmount;
        hunt.rewardsClaimed[msg.sender] = true;

        emit RewardClaimed(msg.sender, huntId, hunt.rewardAmount);
    }

    function withdrawRewards() external {
        uint256 amount = userRewards[msg.sender];
        require(amount > 0, "No rewards to withdraw");

        userRewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function fundContract() external payable onlyOwner {}

    function getParticipants(uint256 huntId) external view returns (address[] memory) {
        require(huntId < nextHuntId, "Treasure hunt does not exist");
        return treasureHunts[huntId].participants;
    }
}
