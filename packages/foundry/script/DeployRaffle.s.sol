//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
import {Raffle} from '../contracts/Raffle.sol';
import {SNFT} from '../contracts/SNFT.sol';
import {ScaffoldETHDeploy} from './DeployHelpers.s.sol';

contract DeployRaffle is Script {
    
    error InvalidPrivateKey(string);

    Raffle raffle;
    SNFT sNft;

    function run() external returns(Raffle, SNFT, ScaffoldETHDeploy){
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        raffle =new Raffle(vm.addr(deployerPrivateKey));
        
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
