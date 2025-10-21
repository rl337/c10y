// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {C10Y} from "src/C10Y.sol";

/// @notice Forge script to deploy C10Y token
/// Usage:
///   - set DEPLOYER_PRIVATE_KEY in .env
///   - forge script script/DeployC10Y.s.sol:DeployC10Y --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv
contract DeployC10Y is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address initialRecipient = vm.envOr("INITIAL_RECIPIENT", vm.addr(deployerKey));
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", 1_000_000 ether);

        vm.startBroadcast(deployerKey);
        C10Y token = new C10Y("Cryptovalley", "C10Y", initialRecipient, initialSupply);
        vm.stopBroadcast();

        console2.log("C10Y deployed", address(token));
        console2.log("Initial recipient", initialRecipient);
        console2.log("Initial supply", initialSupply);
    }
}
