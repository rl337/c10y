// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {C10Y} from "src/C10Y.sol";

contract C10YTest is Test {
    C10Y token;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new C10Y("Cryptovalley", "C10Y", address(this), 1_000_000 ether);
    }

    function testMetadata() public {
        assertEq(token.name(), "Cryptovalley");
        assertEq(token.symbol(), "C10Y");
        assertEq(token.decimals(), 18);
    }

    function testInitialSupplyToDeployer() public {
        assertEq(token.totalSupply(), 1_000_000 ether);
        assertEq(token.balanceOf(address(this)), 1_000_000 ether);
    }

    function testTransfer() public {
        token.transfer(alice, 100 ether);
        assertEq(token.balanceOf(alice), 100 ether);
        assertEq(token.balanceOf(address(this)), 1_000_000 ether - 100 ether);
    }

    function testApproveAndTransferFrom() public {
        token.approve(alice, 1000 ether);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 250 ether);
        assertEq(token.balanceOf(bob), 250 ether);
        assertEq(token.allowance(address(this), alice), 750 ether);
    }

    function testInfiniteAllowance() public {
        token.approve(alice, type(uint256).max);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 5 ether);
        assertEq(token.allowance(address(this), alice), type(uint256).max);
    }

    function testRevertInsufficientBalance() public {
        vm.expectRevert("balance");
        token.transfer(alice, 2_000_000 ether);
    }

    function testRevertAllowanceExceeded() public {
        token.approve(alice, 1 ether);
        vm.prank(alice);
        vm.expectRevert("allowance");
        token.transferFrom(address(this), bob, 2 ether);
    }

    // --- Mint/Burn/Ownership ---
    function testOwnerCanMint() public {
        // owner is address(this)
        token.mint(alice, 123 ether);
        assertEq(token.balanceOf(alice), 123 ether);
        assertEq(token.totalSupply(), 1_000_000 ether + 123 ether);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert("not owner");
        token.mint(alice, 1 ether);
    }

    function testBurnSelf() public {
        token.burn(10 ether);
        assertEq(token.balanceOf(address(this)), 1_000_000 ether - 10 ether);
        assertEq(token.totalSupply(), 1_000_000 ether - 10 ether);
    }

    function testBurnFromWithAllowance() public {
        token.approve(alice, 50 ether);
        vm.prank(alice);
        token.burnFrom(address(this), 20 ether);
        assertEq(token.balanceOf(address(this)), 1_000_000 ether - 20 ether);
        assertEq(token.totalSupply(), 1_000_000 ether - 20 ether);
        assertEq(token.allowance(address(this), alice), 30 ether);
    }

    function testTransferOwnership() public {
        token.transferOwnership(alice);
        // alice can mint now
        vm.prank(alice);
        token.mint(bob, 7 ether);
        assertEq(token.balanceOf(bob), 7 ether);
    }
}
