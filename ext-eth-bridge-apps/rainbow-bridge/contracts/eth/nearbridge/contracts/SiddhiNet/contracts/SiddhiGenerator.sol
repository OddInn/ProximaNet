// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./ERC721Mintable.sol";
import "./SkillVerifier.sol";

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable {

    SquareVerifier private _verifier;

    constructor() public {
        _verifier = new SquareVerifier();
    }
    
    struct Solution {
        uint index;
        address addr;
    }

    Solution[] private _solutions;
    uint private _solutionCount = 0;

    mapping(bytes32 => bool) private _uniqueSolutions;

    event SolutionAdded(
        uint a,
        uint b
    );

    function _addSolution(uint first, uint second) internal {
        _solutions.push(Solution({
            index: _solutionCount++,
            addr: msg.sender
        }));
        emit SolutionAdded(first, second);
    }

    function _hashSolution(
        uint[2] memory a,
        uint[2] memory a_p,
        uint[2][2] memory b,
        uint[2] memory b_p,
        uint[2] memory c,
        uint[2] memory c_p,
        uint[2] memory h,
        uint[2] memory k,
        uint[2] memory input
    ) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            a, a_p,
            b, b_p,
            c, c_p,
            h, k, input    
        ));
    }

    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mint(
        uint[2] calldata a,
        uint[2] calldata a_p,
        uint[2][2] calldata b,
        uint[2] calldata b_p,
        uint[2] calldata c,
        uint[2] calldata c_p,
        uint[2] calldata h,
        uint[2] calldata k,
        uint[2] calldata input,
        address to, 
        uint256 tokenId
    ) external onlyOwner() returns(bool) {
        bytes32 solutionHash = _hashSolution(a, a_p, b, b_p, c, c_p, h, k, input);
        
        require(!_uniqueSolutions[solutionHash], "This proof has been submitted before");
        
        bool result = _verifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
        require(!result, "you have provide an incorrect proof");

        super._mint(to, tokenId);

        _uniqueSolutions[solutionHash] = true;
        _addSolution(input[0], input[1]);
        return true;
    }
}
  
