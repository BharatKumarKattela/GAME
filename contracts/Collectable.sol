// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Attack.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CharacterCollectable is Attack, IERC721 {
    using SafeMath for uint256;

    mapping (uint => address) characterApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function balanceOf(address _owner) external view returns(uint256) {
        return(ownerCharacterCount[_owner]);
    }

    function ownerOf(uint _tokenId) external view returns (address) {
        return(charcterOwner[_tokenId]);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function transfer(address _from, address _to, uint _tokenId) private {
        require(_to != address(0), "Cannot tracnfer to Null Address");
        ownerCharacterCount[_to] = ownerCharacterCount[_to].add(1);
        ownerCharacterCount[_from] = ownerCharacterCount[_from].sub(1);
        charcterOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);

    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(charcterOwner[_tokenId] == msg.sender || characterApprovals[_tokenId] == msg.sender);
        transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external onlyOwnerOf(_tokenId) {
        characterApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function getApproved(uint _tokenId) external view returns (address) {
        require(charcterOwner[_tokenId] != address(0), "token doesn't exist");
        return characterApprovals[_tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external {
        transfer(_from, _to, _tokenId);
        require(_to.code.length == 0 || IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") == IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata data) external {
        transfer(_from, _to, _tokenId);
        require(_to.code.length == 0 || IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) == IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }
}