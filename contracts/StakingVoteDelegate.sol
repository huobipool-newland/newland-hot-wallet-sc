// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./interfaces/StakingInterfaces.sol";
import "./StakingVote.sol";

contract StakingVoteDelegate is StakingVote,StakingDelegateInterface{

    /**
     * @notice Construct an empty delegate
     */
    constructor() {}

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) public override{
        // Shh -- currently unused
        data;
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }
        require(msg.sender == chairperson, "only the chairperson may call _becomeImplementation");
    }

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() public override{
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }
        require(msg.sender == chairperson, "only the chairperson may call _resignImplementation");
    }
}
