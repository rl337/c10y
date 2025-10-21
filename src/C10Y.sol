// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title C10Y - Cryptovalley ERC20 Token
/// @notice Minimal, self-contained ERC20 implementation (no external deps)
contract C10Y {
    // --- ERC20 metadata ---
    string public name;
    string public symbol;
    uint8 public immutable decimals = 18;

    // --- ERC20 storage ---
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // --- ERC20 events ---
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @param tokenName Human-readable name
    /// @param tokenSymbol Ticker symbol (e.g., "C10Y")
    /// @param initialRecipient Address to receive initialSupply
    /// @param initialSupply Amount minted on deploy, in wei units (18 decimals)
    constructor(string memory tokenName, string memory tokenSymbol, address initialRecipient, uint256 initialSupply) {
        require(initialRecipient != address(0), "recipient=0");
        name = tokenName;
        symbol = tokenSymbol;
        _mint(initialRecipient, initialSupply);
    }

    // --- ERC20 core ---
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            require(allowed >= amount, "allowance");
            unchecked { allowance[from][msg.sender] = allowed - amount; }
        }
        _transfer(from, to, amount);
        return true;
    }

    // --- internal helpers ---
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "to=0");
        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= amount, "balance");
        unchecked {
            balanceOf[from] = fromBalance - amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0) && spender != address(0), "0addr");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "to=0");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}
