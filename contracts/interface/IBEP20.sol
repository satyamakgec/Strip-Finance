//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `_owner`.
   */
  function balanceOf(address _owner) external view returns (uint256 balance);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address _to, uint256 _value) external returns (bool success);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `_value` as the allowance of `_spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address _spender, uint256 _value) external returns (bool success);

  /**
   * @dev Moves `_value` tokens from `_from` to `_to` using the
   * allowance mechanism. `_value` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  /**
   * @dev Emitted when `_value` tokens are moved from one account (`_from`) to
   * another (`_to`).
   *
   * Note that `_value` may be zero.
   */
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /**
   * @dev Emitted when the allowance of a `_spender` for an `_owner` is set by
   * a call to {approve}. `_value` is the new allowance.
   */
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}