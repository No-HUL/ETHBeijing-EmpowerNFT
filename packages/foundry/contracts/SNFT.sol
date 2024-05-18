//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Useful for debugging. Remove when deploying to a live network.
import {console} from "forge-std/console.sol";

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that define the SNFT token.
 * @author Transnature.
 */

contract SNFT is ERC20Burnable, Ownable{

    error SNFT__CantMintToZeroAddress();
    error SNFT__MustBurnMoreThanZero();
    error SNFT__BurnAmountExceedsBalance();

    constructor(address initialOwner) 
        Ownable(initialOwner) 
        ERC20("Shit NFT", "SNFT") {}

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if(_to == address(0)){
            revert SNFT__CantMintToZeroAddress();
        }
        else if(_amount <= 0){
            revert SNFT__MustBurnMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) public override onlyOwner{
        uint256 balance = balanceOf(msg.sender);
        if(_amount <= 0){
            revert SNFT__MustBurnMoreThanZero();
        }
        else if(balance < _amount){
            revert SNFT__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

}

