// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
//pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IStakingVote.sol";

contract StakingVote is IStakingVote{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    modifier validChairperson(){
        require(msg.sender == chairperson, "Illegal operation");
        _;
    }

    modifier validCandidate(address candidate){
        uint pid = candidatePidMapping[candidate];
        require(pid != 0, "Candidate not exist");
        require(candidates[pid-1].legal,"Not a legitimate candidate");
        _;
    }

    modifier validPaused(){
        require(!paused, "Voting has been suspended");
        _;
    }

//    constructor(address _underlying,
//        uint _lockPeriod,
//        uint _slotCount,
//        uint _voteAddMin,
//        uint _voteSubMin,
//        uint _candidateCountMax,
//        uint _candidateStakingAmount){
//            chairperson = msg.sender;
//            underlying = _underlying;
//            lockPeriod = _lockPeriod;
//            slotCount = _slotCount;
//            voteAddMin = _voteAddMin;
//            voteSubMin = _voteSubMin;
//            candidateCountMax = _candidateCountMax;
//            candidateStakingAmount = _candidateStakingAmount;
//    }

    function initialize(address _underlying,
        uint _lockPeriod,
        uint _slotCount,
        uint _voteAddMin,
        uint _voteSubMin,
        uint _candidateCountMax,
        uint _candidateStakingAmount)
    public initializer {
        chairperson = msg.sender;
        underlying = _underlying;
        lockPeriod = _lockPeriod;
        slotCount = _slotCount;
        voteAddMin = _voteAddMin;
        voteSubMin = _voteSubMin;
        candidateCountMax = _candidateCountMax;
        candidateStakingAmount = _candidateStakingAmount;
    }

    function resetChairperson(address payable newChairperson) external override validChairperson{
        address oldChairperson = chairperson;
        chairperson = newChairperson;
        emit ResetChairperson(oldChairperson, newChairperson);
    }

    function resetPaused(bool _paused) external override validChairperson{
        require(paused != _paused, "Illegal operation");
        paused = _paused;

        emit ResetPaused(!_paused, _paused);
    }

    function resetSlotCount(uint256 _slotCount) external override validChairperson{
        require(slotCount < _slotCount && _slotCount <= slotCountMax, "This slotCount is illegal");
        uint oldSlotCount = slotCount;
        slotCount = _slotCount;

        emit ResetSlotCount(oldSlotCount, _slotCount);
    }

    function resetLockPeriod(uint256 _lockPeriod) external override validChairperson{
        uint256 oldLockPeriod = _lockPeriod;
        lockPeriod = _lockPeriod;

        emit ResetLockPeriod(oldLockPeriod, _lockPeriod);
    }

    function resetVoteAddMin(uint256 _voteAddMin) external override validChairperson{
        uint256 oldVoteAddMin = voteAddMin;
        voteAddMin = _voteAddMin;

        emit ResetVoteAddMin(oldVoteAddMin, _voteAddMin);
    }

    function resetVoteSubMin(uint _voteSubMin) external override validChairperson{
        uint oldVoteSubMin = voteSubMin;
        voteSubMin = _voteSubMin;

        emit ResetVoteSubMin(oldVoteSubMin, _voteSubMin);
    }

    function resetCandidateCountMax(uint _candidateCountMax) external override validChairperson{
        uint oldCandidateCountMax = candidateCountMax;
        candidateCountMax = _candidateCountMax;

        emit ResetCandidateCountMax(oldCandidateCountMax, _candidateCountMax);
    }

    function resetCandidateStakingAmount(uint _candidateStakingAmount) external override validChairperson{
        uint oldCandidateStakingAmount = candidateStakingAmount;
        candidateStakingAmount = _candidateStakingAmount;

        emit ResetCandidateStakingAmount(oldCandidateStakingAmount, _candidateStakingAmount);
    }

    function resetCandidate(address _candidate, bool _legal) external override validChairperson{
        uint pid = candidatePidMapping[_candidate];
        require(pid != 0, "Candidate not exist");
        Candidate storage candidate = candidates[pid-1];
        require(candidate.legal != _legal, "Illegal operation");

        candidate.legal = _legal;
        emit ResetCandidate(_candidate, !_legal, _legal);
    }

    function becomeCandidate() external override validPaused{
        require(candidatesLength() < candidateCountMax, "The maximum number of candidates has been exceeded");

        uint pid = candidatePidMapping[msg.sender];
        require(pid == 0, "Candidate already exists");

        Locker storage candidateLocker = candidateLockerMapping[msg.sender];
        candidateLocker.lockUnderlying = candidateStakingAmount;
        candidateLocker.startBlockNum = block.number;
        candidateLocker.endBlockNum = block.number.add(lockPeriod);

        Candidate memory candidate = Candidate({
            candidate: msg.sender,
            legal: true,
            totalVote: 0
        });
        candidates.push(candidate);
        candidatePidMapping[msg.sender] = candidates.length;

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), candidateStakingAmount);

        emit BecomeCandidate(msg.sender, candidates.length, candidateStakingAmount);
    }

    function voteAdd(address candidate, uint amount) external override validPaused validCandidate(candidate){
        require(amount >= voteAddMin,"Less than the minimum vote");
        vote(candidate, amount, 0);
    }

    function voteSub(address candidate, uint amount) external override{
        require(amount >= voteSubMin,"Less than the minimum vote");
        uint pid = candidatePidMapping[candidate];
        require(pid != 0, "Candidate not exist");
        require(voterMapping[msg.sender].totalVote >= amount
            && candidateVoterMapping[candidate][msg.sender] >= amount,"this user vote to candidate amount is not enough");
        vote(candidate, 0, amount);
    }

    function vote(address _candidate, uint amountIn, uint amountOut) internal{
        require(amountIn == 0 || amountOut == 0,"Illegal operation");

        uint pid = candidatePidMapping[_candidate];
        Candidate storage candidate = candidates[pid-1];

        if(amountIn > 0){
            totalVote = totalVote.add(amountIn);
            totalVoteUnderlying = totalVoteUnderlying.add(amountIn);
            candidate.totalVote = candidate.totalVote.add(amountIn);
            candidateVoterMapping[_candidate][msg.sender] = candidateVoterMapping[_candidate][msg.sender].add(amountIn);
            voterMapping[msg.sender].totalUnderlying = voterMapping[msg.sender].totalUnderlying.add(amountIn);
            voterMapping[msg.sender].totalVote = voterMapping[msg.sender].totalVote.add(amountIn);

            IERC20(underlying).safeTransferFrom(msg.sender, address(this), amountIn);

            emit VoteAdd(_candidate, msg.sender, amountIn);
        }else if(amountOut > 0){
            totalVote = totalVote.sub(amountOut);
            candidate.totalVote = candidate.totalVote.sub(amountOut);
            candidateVoterMapping[_candidate][msg.sender] = candidateVoterMapping[_candidate][msg.sender].sub(amountOut);
            voterMapping[msg.sender].totalVote = voterMapping[msg.sender].totalVote.sub(amountOut);

            if(lockPeriod == 0){
                voterMapping[msg.sender].totalUnderlying = voterMapping[msg.sender].totalUnderlying.sub(amountOut);
                totalVoteUnderlying = totalVoteUnderlying.sub(amountOut);

                IERC20(underlying).safeTransfer(msg.sender, amountOut);
            }else{
                VoterLockerSlot storage slot = voterLockerSlotMapping[msg.sender];
                require(slot.usedSlotCount < slotCount,"Slot count is not enough");
                uint index = slot.pid < slotCount ? slot.pid : 0;

                require(voterLockerMapping[msg.sender][index].lockUnderlying == 0, "The slot's underlying is not empty");
                slot.pid = index.add(1);
                slot.usedSlotCount = slot.usedSlotCount.add(1);

                Locker storage voterLocker = voterLockerMapping[msg.sender][index];
                voterLocker.lockUnderlying = amountOut;
                voterLocker.startBlockNum = block.number;
                voterLocker.endBlockNum = block.number.add(lockPeriod);
            }

            emit VoteSub(_candidate, msg.sender, amountOut);
        }
    }

    function candidateClaimUnderlying() external override{
        uint totalClaim = candidateClaimableUnderlyingBalance(msg.sender);
        require(totalClaim > 0, "There are no assets to claim");

        Locker storage candidateLocker = candidateLockerMapping[msg.sender];
        candidateLocker.lockUnderlying = 0;
        candidateLocker.startBlockNum = block.number;
        candidateLocker.endBlockNum = block.number;

        IERC20(underlying).safeTransfer(msg.sender, totalClaim);

        emit CandidateClaimUnderlying(msg.sender, totalClaim);
    }

    function voterClaimUnderlying() external override{
        VoterLockerSlot storage slot = voterLockerSlotMapping[msg.sender];
        require(slot.usedSlotCount > 0,"There are no assets to claim");

        uint totalClaim;
        for(uint i = 0; i < slotCount; i++){
            Locker storage voterLocker = voterLockerMapping[msg.sender][i];
            if(block.number >= voterLocker.endBlockNum && voterLocker.lockUnderlying >0){
                totalClaim = totalClaim.add(voterLocker.lockUnderlying);
                voterLocker.lockUnderlying = 0;
                voterLocker.startBlockNum = block.number;
                voterLocker.endBlockNum = block.number;
                slot.usedSlotCount = slot.usedSlotCount.sub(1);
            }
        }

        require(totalClaim > 0,"There are no assets to claim");

        voterMapping[msg.sender].totalUnderlying = voterMapping[msg.sender].totalUnderlying.sub(totalClaim);
        totalVoteUnderlying = totalVoteUnderlying.sub(totalClaim);

        IERC20(underlying).safeTransfer(msg.sender, totalClaim);

        emit VoterClaimUnderlying(msg.sender, totalClaim);
    }

    function underlyingBalance() public view override returns(uint){
        return IERC20(underlying).balanceOf(address(this));
    }

    function candidateClaimableUnderlyingBalance(address candidate) public view override returns(uint){
        uint pid = candidatePidMapping[candidate];
        if(pid == 0){
           return 0;
        }

        Locker storage candidateLocker = candidateLockerMapping[candidate];
        if(block.number >= candidateLocker.endBlockNum && candidateLocker.lockUnderlying > 0){
            return candidateLocker.lockUnderlying;
        }

        return 0;
    }

    function voterLockerUnderlyingBalance(address voter) public view override returns(uint,uint){
        VoterLockerSlot storage slot = voterLockerSlotMapping[voter];
        if(slot.usedSlotCount == 0){
            return (0,0);
        }

        uint totalClaimableUnderlying;
        uint totalUnclaimedUnderlying;
        for(uint i = 0; i < slotCount; i++){
            Locker storage voterLocker = voterLockerMapping[voter][i];
            if(block.number >= voterLocker.endBlockNum && voterLocker.lockUnderlying >0){
                totalClaimableUnderlying = totalClaimableUnderlying.add(voterLocker.lockUnderlying);
            }else{
                totalUnclaimedUnderlying = totalUnclaimedUnderlying.add(voterLocker.lockUnderlying);
            }
        }

        return (totalClaimableUnderlying,totalUnclaimedUnderlying);
    }

    function candidateInfo(address _candidate) public view override returns(bool,uint){
        uint pid = candidatePidMapping[_candidate];
        if(pid == 0){
            return (false,0);
        }
        Candidate storage candidate = candidates[pid-1];

        return (candidate.legal,candidate.totalVote);
    }

//    function candidateLockerInfo(address candidate) public view override returns(uint,uint,uint){
//        Locker storage candidateLocker = candidateLockerMapping[candidate];
//        return(candidateLocker.lockUnderlying,candidateLocker.startBlockNum,candidateLocker.endBlockNum);
//    }

//    function voterInfo(address voter) public view override returns(uint,uint){
//        return (voterMapping[voter].totalUnderlying,voterMapping[voter].totalVote);
//    }

//    function candidateVoterInfo(address candidate,address _voter) public view override returns(uint){
//        return candidateVoterMapping[candidate][_voter];
//    }

    function candidatesLength() public view override returns (uint) {
        return candidates.length;
    }

//    function candidatePid(address candidate) public view override returns (uint) {
//        return candidatePidMapping[candidate];
//    }

    function voterViableSlotCount(address voter) public view override returns (uint) {
        VoterLockerSlot storage slot = voterLockerSlotMapping[voter];
        return slotCount.sub(slot.usedSlotCount);
    }
}
