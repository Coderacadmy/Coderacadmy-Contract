// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Auction {

    function hashPacked(
        string memory title,
        string memory description,
        string memory accessType,
        string memory tokenType,
        string memory tokenListing,
        string memory distribution
        )
        public pure returns (bytes32){
            return keccak256(
                abi.encodePacked(
                    title,
                    description,
                    accessType,
                    tokenType,
                    tokenListing,
                    distribution
                ));
    }
}
