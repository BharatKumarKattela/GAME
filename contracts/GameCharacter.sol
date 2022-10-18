//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract GameCharacters is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeMath for uint16;

    // Creating New Game Character
    event NewCharacter(uint CharacterId, string name, uint Id);

    uint characterIDLength = 16;
    uint characterModulus = 10**characterIDLength;
    uint cooldownTime = 1 days;


    // stuct to store different properties of game character
    struct Character {
        string name;
        uint identifier;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Array of Character strucct
    Character[] public characters;

    //mapping for character ownership
    mapping(uint => address) public charcterOwner;
    mapping(address => uint) ownerCharacterCount;

    // fucntions
    //
    function createCharacter(string memory _name, uint _identifier) internal {
        characters.push(Character(_name, _identifier, 1, uint32(block.timestamp + cooldownTime), 0, 0));
        uint _characterId = characters.length-1;
        charcterOwner[_characterId] = msg.sender;
        ownerCharacterCount[msg.sender] = ownerCharacterCount[msg.sender].add(1);
        emit NewCharacter(_characterId, _name, _identifier);
    }

    function genrateCharIdentifier(string memory _str) private view returns(uint) {
        uint random = uint(keccak256(abi.encodePacked(_str)));
        return(random % characterModulus);
    }

    function createRandChar(string memory _name) public {
       require(ownerCharacterCount[msg.sender] == 0, "You have already created your character");
       uint randIdendifier = genrateCharIdentifier(_name);
       createCharacter(_name, randIdendifier);
    }


}