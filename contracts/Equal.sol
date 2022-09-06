// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IEqual.sol";
import "./libraries/Ownable.sol";

contract Equal is IEqual, Ownable {

    string public constant name = "Equalizer";
    string public constant symbol = "EQUAL";
    uint8 public constant decimals = 18;
    uint public totalSupply = 0;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bool public initialMinted;
    address public minter;
    address public merkleClaim;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        _mint(msg.sender, 0);
    }
    
    // No checks as its meant to be once off to set minting rights to BaseV1 Minter
    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function setMerkleClaim(address _merkleClaim) external onlyOwner {
        merkleClaim = _merkleClaim;
    }

    // Initial mint: total 2.5M
    function initialMint(address _recipient) external onlyOwner {
        require(!initialMinted, "Already initial minted");
        initialMinted = true;
        _mint(_recipient, 25 * 1e5 * 1e18);
    }

    function approve(address _spender, uint _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _mint(address _to, uint _amount) internal returns (bool) {
        totalSupply += _amount;
        unchecked {
            balanceOf[_to] += _amount;
        }
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        balanceOf[_from] -= _value;
        unchecked {
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        uint allowedFrom = allowance[_from][msg.sender];
        if (allowedFrom != type(uint).max) {
            allowance[_from][msg.sender] -= _value;
        }
        return _transfer(_from, _to, _value);
    }

    function mint(address account, uint amount) external returns (bool) {
        require(msg.sender == minter, "Not minter");
        _mint(account, amount);
        return true;
    }

    function claim(address account, uint amount) external returns (bool) {
        require(msg.sender == merkleClaim, "Not merkleClaim");
        _mint(account, amount);
        return true;
    }
}
