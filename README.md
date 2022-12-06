# Sample Hardhat Project

This project demonstrates how an incorrect use of delegatecall can be exploited to steal ownership of a smart contract.
The test written demonstrates that. If you want to run the test clone the repo, install dependencies with npm install and run the test using npx hardhat test.

Let's quickly analyze the difference between call and delegatecall.

Using call method, the code which is being called run in the context of the external contract/function. This means that when the following line executes

lib.call(abi.encodeWithSignature("setFavouriteNumber", _num))  - line 26

the favouriteNumber variable inside Lib contract will be updated.  I am calling setFavouriteNumber from VictimContract and the favouriteNumber variable inside Lib is changing with the new value. Everything as expected until this point.

However, using delegatecall is a different story. Delegatecall executes the code at the targeted address in the context of the calling contract. So when 

lib.delegatecall(abi.encodeWithSignature("setFavouriteNumber", _num)) - line 23

 executes , this time the favouriteNumber inside VictimContract changes, even if the codes is executed in the Lib. Or that is what it should happen if you would use delegatecall correctly.

You might ask why would someone use delegatecall. Well, because it allows developers to modularize their code. Creating a library and using delegatecall  means I can update the variables in my contract without the need to write the actual functions inside this contract resulting in more compact contracts. Plus, I can interact with the same library(and the same functions within) from multiple contracts. It basically allows users to deploy reusable code once and call it from future contracts.

We must always be aware of the context-preserving nature of delegatecall because when used incorrectly, some critical vulnerabilities might occur. When delegatecall is used to update storage, the same state variables have to be declared in the exact same order. In order to understand the issue we must understand that state or storage variables (variables that persist over individual transactions) are placed into slots sequentially as they are introduced in the contract.

Example: For Lib contract, slots[0] corresponds to the favouriteNumber variable. For the VictimContract, slots[0] corresponds to the lib address, slots[1] to owner address, and slots[2] to favouriteNumber. This inconsistent mapping constitutes the vulnerability.

When setFavouriteNumber is called via call method , the value kept in slots[0] of the Lib contract is updated with whatever input we provide. However, when we delegatecall(keep in mind the context-preserving properties of the method)  slots[0] of the VictimContract will change, which in this case is the lib address.

At line 43, the attacker leverages this in order to override the address of Lib contract with the address of  Attack contract. From now on, line 23 will point to this contract. 

Therefore,  the attacker calls the function setFavouriteNumber again (the input does not really matter), forcing the victim to to call Attack.setFavouriteNumber() . As you can see at line 47, there actually is a function inside Attack contract with the same signature as the one the victim is looking for. The only difference is that this one changes the value of the owner variable.

The key here is to understand how delegatecall works. Victim contract ends up calling setFavouriteNumber inside the Attack contract using delegatecall. Meaning it executes code from this contract but updates its own storage variable, thus updating the owner.
