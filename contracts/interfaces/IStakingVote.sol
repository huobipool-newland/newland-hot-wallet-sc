// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "../StakingVoteStorage.sol";

abstract contract IStakingVote is StakingVoteStorage{

    event ResetChairperson(address indexed oldChairperson, address indexed newChairperson);
    event ResetPaused(bool oldPaused, bool newPaused);
    event ResetSlotCount(uint oldSlotCount, uint newSlotCount);
    event ResetLockPeriod(uint oldLockPeriod, uint newLockPeriod);
    event ResetVoteAddMin(uint oldVoteAddMin, uint newVoteAddMin);
    event ResetVoteSubMin(uint oldVoteSubMin, uint newVoteSubMin);
    event ResetCandidateCountMax(uint oldCandidateCountMax, uint newCandidateCountMax);
    event ResetCandidateStakingAmount(uint oldCandidateStakingAmount, uint newCandidateStakingAmount);
    event ResetCandidate(address indexed candidate, bool oldLegal, bool newLegal);
    event BecomeCandidate(address indexed candidate, uint number, uint stakingAmount);
    event VoteAdd(address indexed candidate, address indexed voter, uint amount);
    event VoteSub(address indexed candidate, address indexed voter, uint amount);
    event CandidateClaimUnderlying(address indexed candidate, uint amount);
    event VoterClaimUnderlying(address indexed voter, uint amount);

    function resetChairperson(address payable newChairperson) external virtual;
    function resetPaused(bool _paused) external virtual;
    function resetSlotCount(uint256 _slotCount) external virtual;
    function resetLockPeriod(uint _lockPeriod) external virtual;
    function resetVoteAddMin(uint _voteAddMin) external virtual;
    function resetVoteSubMin(uint _voteSubMin) external virtual;
    function resetCandidateCountMax(uint _candidateCountMax) external virtual;
    function resetCandidateStakingAmount(uint _candidateStakingAmount) external virtual;
    function resetCandidate(address _candidate, bool _legal) external virtual;
    function becomeCandidate() external virtual;
    function voteAdd(address candidate, uint amount) external virtual;
    function voteSub(address candidate, uint amount) external virtual;
    function candidateClaimUnderlying() external virtual;
    function voterClaimUnderlying() external virtual;

    function underlyingBalance() external view virtual returns(uint);
    function candidateClaimableUnderlyingBalance(address candidate) external view virtual returns(uint);
    function voterLockerUnderlyingBalance(address voter) external view virtual returns(uint,uint);
    function candidateInfo(address candidate) external view virtual returns(bool,uint);
//    function candidateLockerInfo(address candidate) external view virtual returns(uint,uint,uint);
//    function voterInfo(address voter) external view virtual returns(uint,uint);
//    function candidateVoterInfo(address candidate,address voter) external view virtual returns(uint);
    function candidatesLength() external view virtual returns (uint);
//    function candidatePid(address candidate) external view virtual returns (uint);
    function voterViableSlotCount(address voter) external view virtual returns (uint);
}
