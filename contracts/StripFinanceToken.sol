//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { Ownable } from "openzeppelin-solidity/contracts/access/Ownable.sol";
import { IBEP20 }  from "./interface/IBEP20.sol";

contract StripFinanceToken is IBEP20, Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => uint256) public nonces;

  bytes32 public immutable DOMAIN_SEPARATOR;

  // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 amount,uint256 nonce,uint256 deadline)");
  bytes32 public constant PERMIT_TYPEHASH = 0xfc77c2b9d30fe91687fd39abb7d16fcdfe1472d065740051ab8b13e4bf4a617f;

  uint256 private _totalSupply;
  uint8   private _decimals;

  string private _symbol;
  string private _name;

  constructor(address _vestingContract) {
    require(_vestingContract != address(0), "SFT:ZERO_ADDRESS");

    uint256 chainId;
    assembly {
        chainId := chainid()
    }
    DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
            keccak256(bytes(_name)),
            keccak256(bytes('1')),
            chainId,
            address(this)
        )
    );
    
    _name     = "Strip Finance";
    _symbol   = "STRIP";
    _decimals = 18;

    _mintTokens(_vestingContract, 50_000_000 * 10 ** 18);
  }

  function _mintTokens(address _to, uint256 _amount) internal {
    _balances[_to] = _amount;
    _totalSupply  += _amount;         // Should be 50 Million
    emit Transfer(address(0), _to, _amount);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender    != address(0), "StripFinanceToken: transfer from the zero address");
    require(recipient != address(0), "StripFinanceToken: transfer to the zero address");

    _balances[sender]    = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
    emit Transfer(sender, recipient, amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner   != address(0), "StripFinanceToken: approve from the zero address");
    require(spender != address(0), "StripFinanceToken: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
    @dev Approve by signature.
    @param owner    Owner address that signed the permit
    @param spender  Spender of the permit
    @param amount   Permit approval spend limit
    @param deadline Deadline after which the permit is invalid
    @param v        ECDSA signature v component
    @param r        ECDSA signature r component
    @param s        ECDSA signature s component
  */
  function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
      require(deadline >= block.timestamp, 'StripFinanceToken:EXPIRED');
      bytes32 digest = keccak256(
          abi.encodePacked(
              '\x19\x01',
              DOMAIN_SEPARATOR,
              keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline))
          )
      );
      address recoveredAddress = ecrecover(digest, v, r, s);
      require(recoveredAddress == owner, 'StripFinanceToken:INVALID_SIGNATURE');
      _approve(owner, spender, amount);
  }

}