//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./TrainCharacter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Attack is TrainCharacter {
    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeMath for uint16;

    uint randNonce = 0;
    uint attackVictoryProb = 70;

    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus);
    }

    function attack(uint _characterId, uint _targetCharId) external {
        Character storage myCharacter = characters[_characterId];
        Character storage enemyCharacter = characters[_targetCharId];
        uint rand = randMod(100);
        if(rand <= attackVictoryProb) {
            myCharacter.winCount = SafeCast.toUint16(myCharacter.winCount.add(1));
            myCharacter.level = SafeCast.toUint32(myCharacter.level.add(1));
            enemyCharacter.lossCount = SafeCast.toUint16(enemyCharacter.lossCount.add(1));
            trainAndIncrement(_characterId, enemyCharacter.identifier, "Character");
        } else {
            myCharacter.lossCount = SafeCast.toUint16(myCharacter.lossCount.add(1));
            enemyCharacter.winCount = SafeCast.toUint16(enemyCharacter.winCount.add(1));
            triggerCooldown(myCharacter);
        }
    }


}