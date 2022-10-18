//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./GameCharacter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

interface KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract TrainCharacter is GameCharacters {
    using SafeMath for uint256;
    using SafeMath for uint32;

    uint levelUpFee = 0.001 ether;

    KittyInterface kittyContract;
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    modifier levelStatus(uint _level, uint _characterId) {
        require(characters[_characterId].level >= _level, "Level of characte");
        _;
    }

    modifier onlyOwnerOf(uint _characterId) {
        require(msg.sender == charcterOwner[_characterId]);
        _;
    }

    function trainAndIncrement(uint _characterId, uint _targetCharId, string memory _species) internal onlyOwnerOf(_characterId) {
        uint newCharacterId;
        require(msg.sender == charcterOwner[_characterId]);
        Character storage myCharacter = characters[_characterId];
        require(charIsReady(myCharacter));
        _targetCharId = _targetCharId % characterModulus;
        newCharacterId = (myCharacter.identifier + _targetCharId)/2;
        if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newCharacterId = newCharacterId - newCharacterId % 100 + 99;
        }
        createCharacter("Noname", newCharacterId);
        triggerCooldown(myCharacter);
    }

    //interacting with cryptokitties contract
    function feedOnKitty(uint _characterId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        trainAndIncrement(_characterId, kittyDna, "kitty");
    }

    function triggerCooldown(Character storage _char) internal {
        _char.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function charIsReady(Character storage _char) internal view returns(bool) {
       return (_char.readyTime <= block.timestamp);
    }

    function changeCharName(uint _characterId, string calldata _newName) external levelStatus(2, _characterId) onlyOwnerOf(_characterId) {
        require(msg.sender == charcterOwner[_characterId], "You don't own this  character");
        characters[_characterId].name = _newName;
    }

    function getCharactersByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerCharacterCount[_owner]);
        uint counter = 0;
        for(uint i =0; i<= characters.length; ++i) {
            if(charcterOwner[i] == _owner) {
                result[counter] = i;
                counter = counter.add(1);
            }
        }
        return result; 
    }

    function levelUpOnPay(uint _characterId) external payable {
        require(msg.value == levelUpFee);
        characters[_characterId].level = SafeCast.toUint32(characters[_characterId].level.add(1));
    }
    
    function withdraw() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }


}