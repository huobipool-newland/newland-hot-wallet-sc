// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./StakingVote.sol";
contract StakingVoteLens {

    struct BasicMetadata {
        address chairperson;
        address underlying;
        bool paused;
        uint lockPeriod;
        uint totalUnderlying;
        uint totalVoteUnderlying;
        uint totalVote;
        uint voteAddMin;
        uint voteSubMin;
        uint slotCount;
        uint slotCountMax;
        uint candidateCountMax;
        uint candidateStakingAmount;
    }

    function getBasicInfo(StakingVote stakingVote) public view returns(BasicMetadata memory){
        return BasicMetadata({
            chairperson: stakingVote.chairperson(),
            underlying: stakingVote.underlying(),
            paused: stakingVote.paused(),
            lockPeriod: stakingVote.lockPeriod(),
            totalUnderlying: stakingVote.underlyingBalance(),
            totalVoteUnderlying: stakingVote.totalVoteUnderlying(),
            totalVote: stakingVote.totalVote(),
            voteAddMin: stakingVote.voteAddMin(),
            voteSubMin: stakingVote.voteSubMin(),
            slotCount: stakingVote.slotCount(),
            slotCountMax: stakingVote.slotCountMax(),
            candidateCountMax: stakingVote.candidateCountMax(),
            candidateStakingAmount: stakingVote.candidateStakingAmount()
        });
    }

    struct CandidateMetadata {
        uint totalVoteUnderlying;
        uint totalVote;
        bool candidateLegal;
        uint candidateTotalVote;
        uint candidateLockUnderlying;
        uint candidateStartBlockNum;
        uint candidateEndBlockNum;
    }

    function getCandidateInfo(StakingVote stakingVote, address candidate) public view returns(CandidateMetadata memory){
        (bool _candidateLegal, uint _candidateTotalVote)  = stakingVote.candidateInfo(candidate);
        (uint _candidateLockUnderlying, uint _candidateStartBlockNum, uint _candidateEndBlockNum)  = stakingVote.candidateLockerMapping(candidate);

        return CandidateMetadata({
            totalVoteUnderlying: stakingVote.totalVoteUnderlying(),
            totalVote: stakingVote.totalVote(),
            candidateLegal: _candidateLegal,
            candidateTotalVote: _candidateTotalVote,
            candidateLockUnderlying: _candidateLockUnderlying,
            candidateStartBlockNum: _candidateStartBlockNum,
            candidateEndBlockNum: _candidateEndBlockNum
        });
    }

    struct VoterMetadata {
        uint totalVoteUnderlying;
        uint totalVote;
        uint voterTotalUnderlying;
        uint voterTotalVote;
        uint voterClaimableUnderlying;
        uint voterUnclaimedUnderlying;
    }

    function getVoterInfo(StakingVote stakingVote, address voter) public view returns(VoterMetadata memory){
        (uint _voterTotalUnderlying, uint _voterTotalVote) = stakingVote.voterMapping(voter);
        (uint _voterClaimableUnderlying, uint _voterUnclaimedUnderlying) = stakingVote.voterLockerUnderlyingBalance(voter);

        return VoterMetadata({
            totalVoteUnderlying: stakingVote.totalVoteUnderlying(),
            totalVote: stakingVote.totalVote(),
            voterTotalUnderlying: _voterTotalUnderlying,
            voterTotalVote: _voterTotalVote,
            voterClaimableUnderlying: _voterClaimableUnderlying,
            voterUnclaimedUnderlying: _voterUnclaimedUnderlying
        });
    }

    struct CandidateVoterMetadata {
        uint totalVoteUnderlying;
        uint totalVote;
        uint candidateVoterTotalVote;
        bool candidateLegal;
        uint candidateTotalVote;
        uint voterTotalUnderlying;
        uint voterTotalVote;
    }

    function getCandidateVoterInfo(StakingVote stakingVote, address candidate, address voter) public view returns(CandidateVoterMetadata memory){
        uint _candidateVoterTotalVote = stakingVote.candidateVoterMapping(candidate, voter);
        (bool _candidateLegal, uint _candidateTotalVote)  = stakingVote.candidateInfo(candidate);
        (uint _voterTotalUnderlying, uint _voterTotalVote) = stakingVote.voterMapping(voter);

        return CandidateVoterMetadata({
            totalVoteUnderlying: stakingVote.totalVoteUnderlying(),
            totalVote: stakingVote.totalVote(),
            candidateVoterTotalVote: _candidateVoterTotalVote,
            candidateLegal: _candidateLegal,
            candidateTotalVote: _candidateTotalVote,
            voterTotalUnderlying: _voterTotalUnderlying,
            voterTotalVote: _voterTotalVote
        });
    }

    struct VoterSlotMetadata {
        uint slotCount;
        uint usedSlotCount;
    }

    function getVoterSlotInfo(StakingVote stakingVote, address voter) public view returns(VoterSlotMetadata memory){
        (, uint _usedSlotCount) = stakingVote.voterLockerSlotMapping(voter);

        return VoterSlotMetadata({
            slotCount: stakingVote.slotCount(),
            usedSlotCount: _usedSlotCount
        });
    }
}
