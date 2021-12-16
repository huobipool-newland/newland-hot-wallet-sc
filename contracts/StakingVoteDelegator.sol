pragma solidity ^0.7.4;

import "./interfaces/StakingInterfaces.sol";
import "./interfaces/IStakingVote.sol";

contract StakingVoteDelegator is IStakingVote,StakingDelegatorInterface{

    constructor(address _underlying,
        uint _lockPeriod,
        uint _slotCount,
        uint _voteAddMin,
        uint _voteSubMin,
        uint _candidateCountMax,
        uint _candidateStakingAmount,
        address _implementation,
        bytes memory _becomeImplementationData) {
        // Set the proper admin now that initialization is done
        chairperson = msg.sender;
        // First delegate gets to initialize the delegator (i.e. storage contract)
        delegateTo(_implementation, abi.encodeWithSignature("initialize(address,uint256,uint256,uint256,uint256,uint256,uint256)",
            _underlying,
            _lockPeriod,
            _slotCount,
            _voteAddMin,
            _voteSubMin,
            _candidateCountMax,
            _candidateStakingAmount));
        // New implementations always get set via the settor (post-initialize)
        _setImplementation(_implementation, false,_becomeImplementationData);
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public override{
        require(msg.sender == chairperson, "StakingVoteDelegator==_setImplementation: Caller must be admin");
        if (allowResign) {
            delegateToImplementation(abi.encodeWithSignature("_resignImplementation()"));
        }
        address oldImplementation = implementation;
        implementation = implementation_;
        delegateToImplementation(abi.encodeWithSignature("_becomeImplementation(bytes)", becomeImplementationData));

        emit NewImplementation(oldImplementation, implementation);
    }

    function resetChairperson(address payable newChairperson) external override{
        newChairperson;
        delegateAndReturn();
    }

    function resetPaused(bool _paused) external override{
        _paused;
        delegateAndReturn();
    }

    function resetSlotCount(uint256 _slotCount) external override{
        _slotCount;
        delegateAndReturn();
    }

    function resetLockPeriod(uint _lockPeriod) external override{
        _lockPeriod;
        delegateAndReturn();
    }

    function resetVoteAddMin(uint _voteAddMin) external override{
        _voteAddMin;
        delegateAndReturn();
    }

    function resetVoteSubMin(uint _voteSubMin) external override{
        _voteSubMin;
        delegateAndReturn();
    }

    function resetCandidateCountMax(uint _candidateCountMax) external override{
        _candidateCountMax;
        delegateAndReturn();
    }

    function resetCandidateStakingAmount(uint _candidateStakingAmount) external override{
        _candidateStakingAmount;
        delegateAndReturn();
    }

    function resetCandidate(address _candidate, bool _legal) external override{
        _candidate;_legal;
        delegateAndReturn();
    }

    function becomeCandidate() external override{
        delegateAndReturn();
    }

    function voteAdd(address candidate, uint amount) external override{
        candidate;amount;
        delegateAndReturn();
    }

    function voteSub(address candidate, uint amount) external override{
        candidate;amount;
        delegateAndReturn();
    }

    function candidateClaimUnderlying() external override{
        delegateAndReturn();
    }

    function voterClaimUnderlying() external override{
        delegateAndReturn();
    }

    function underlyingBalance() public view override returns(uint){
        delegateToViewAndReturn();
    }

    function candidateClaimableUnderlyingBalance(address candidate) external view override returns(uint){
        candidate;
        delegateToViewAndReturn();
    }

    function voterLockerUnderlyingBalance(address voter) external view override returns(uint,uint){
        voter;
        delegateToViewAndReturn();
    }

    function candidateInfo(address _candidate) public view override returns(bool,uint){
        _candidate;
        delegateToViewAndReturn();
    }

    function candidatesLength() public view override returns (uint) {
        delegateToViewAndReturn();
    }

    function voterViableSlotCount(address voter) external view override returns (uint){
        voter;
        delegateToViewAndReturn();
    }

    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
	    assembly {
            if eq(success, 0) {
                revert(add(returnData, mload(0x20)), returndatasize())
            }
        }
        return returnData;
    }

    /**
     * @notice Delegates execution to the implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param data The raw data to delegatecall
     * @return The returned bytes from the delegatecall
     */
    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }

    function delegateToViewAndReturn() private view returns (bytes memory) {
        (bool success, ) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", msg.data));

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
        //returndatacopy(0, 0, returndatasize())

            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(add(free_mem_ptr,0x40), returndatasize()) }
        }
    }

    /**
     * @notice Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     *  There are an additional 2 prefix uints from the wrapper returndata, which we ignore since we make an extra hop.
     * @param data The raw data to delegatecall
     * @return The returned bytes from the delegatecall
     */
    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", data));
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return abi.decode(returnData, (bytes));
    }

    function delegateAndReturn() private returns (bytes memory) {
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    /**
     * @notice Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     */
    fallback() external payable{
        require(msg.value == 0,"StakingVoteDelegator:fallback: cannot send value to fallback");

        // delegate all other functions to current implementation
        delegateAndReturn();
    }

}
