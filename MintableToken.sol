// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
 * @title Advanced Mintable ERC-20 Token
 * @dev Implementation of an ERC-20 token with minting capabilities restricted to the owner.
 * Includes governance features like voting and delegation from OpenZeppelin's ERC20Votes extension.
 * 
 * Features:
 * - Mintable by owner
 * - Gas-efficient snapshots for voting
 * - Permit functionality for meta-transactions
 * - Fully compliant with ERC-20 standard
 * - Time-locked admin functions (can be added)
 */
contract MintableToken is ERC20, Ownable, ERC20Permit, ERC20Votes {
    uint256 private constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billion tokens
    
    /**
     * @dev Emitted when new tokens are minted
     */
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @dev Constructor that initializes the token with a name and symbol
     * @param name_ Name of the token
     * @param symbol_ Symbol of the token
     * @param initialSupply Initial supply to mint to the owner
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) Ownable(msg.sender) ERC20Permit(name_) {
        require(initialSupply <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mints new tokens to the specified address
     * @param to Address to receive the minted tokens
     * @param amount Amount of tokens to mint
     * 
     * Requirements:
     * - Only owner can call this function
     * - Total supply after minting cannot exceed MAX_SUPPLY
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting would exceed max supply");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Returns the maximum supply cap for the token
     */
    function maxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }

    // The following functions are overrides required by Solidity for ERC20Votes

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
