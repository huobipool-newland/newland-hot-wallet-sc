// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import '@openzeppelin/contracts/proxy/Initializable.sol';

contract StakingVoteStorage is Initializable{

    struct Voter{
        // @notice Total assets pledged by a voter
        uint totalUnderlying;
        // @notice The total number of votes cast by voters
        uint totalVote;
    }

    struct Candidate{
        // @notice Address of the candidate
        address candidate;
        // @notice The legal status of a candidate. "true" indicates legal, "false" indicates illegal
        bool legal;
        // @notice The candidate received a total of votes
        uint totalVote;
    }

    struct Locker{
        // @notice Number of assets locked up
        uint lockUnderlying;
        // @notice Start lock block number
        uint startBlockNum;
        // @notice End lock block number
        uint endBlockNum;
    }

    struct VoterLockerSlot{
        // @notice Point to the locker position.The starting value is 1
        uint pid;
        // @notice The number of slots in use
        uint usedSlotCount;
    }

    // @notice Maximum number of slots
    uint public constant slotCountMax = 50;

    // @notice The administrator address of the contract
    address payable public chairperson;
    // @notice The address of the underlying(HPT)
    address public underlying;

    // @notice To mark whether voting has been suspended
    bool public paused;

    uint256 public totalVote;
    /**
     * @notice The total amount of voting pledged assets.
     *  Including unclaimed pledge assets after the withdrawal of votes
     */
    uint256 public totalVoteUnderlying;
    // @notice Minimum number of votes
    uint256 public voteAddMin;
    // @notice Maximum number of votes
    uint256 public voteSubMin;
    // @notice Minimum number of candidates
    uint256 public candidateCountMax;
    // @notice How much money you have to pledge to become a candidate
    uint256 public candidateStakingAmount;
    // @notice The number of slots
    uint public slotCount;
    // @notice Lock period,record block number
    uint public lockPeriod;

    // @notice Candidate array,store all candidate
    Candidate[] public candidates;

    // @notice Mapping of candidate's address to candidate array positions
    mapping(address => uint) public candidatePidMapping;
    // @notice Mapping of candidate's address and voter's address to the number of votes
    mapping(address => mapping(address => uint)) public candidateVoterMapping;
    // @notice Mapping of candidate's address to Locker
    mapping(address => Locker) public candidateLockerMapping;
    // @notice Mapping of voter's address to Locker
    mapping(address => Voter) public voterMapping;
    // @notice Mapping of voter's address and voter's address to Locker
    mapping(address => mapping(uint => Locker)) public voterLockerMapping;
    // @notice Mapping of voter's address to VoterLockerSlot
    mapping(address => VoterLockerSlot) public voterLockerSlotMapping;

}
