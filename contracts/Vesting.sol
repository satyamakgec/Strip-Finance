//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { Ownable }           from "openzeppelin-solidity/contracts/access/Ownable.sol";
import { SafeERC20, IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import { IBEP20 }            from "./interface/IBEP20.sol";

contract Vesting is Ownable {

    // Allocation distribution of the total supply.
    uint256 public constant E18                       = 10 ** 18;
    uint256 public constant SEED_ALLOCATION           = 5_000_000  * E18;
    uint256 public constant PRIVATE_ALLOCATION        = 5_000_000  * E18;
    uint256 public constant PUBLIC_ALLOCATION         = 1_250_000  * E18;
    uint256 public constant TEAM_ALLOCATION           = 9_250_000  * E18;
    uint256 public constant COMMUNITY_ALLOCATION      = 12_000_000 * E18;
    uint256 public constant LIQUIDITY_POOL_ALLOCATION = 9_500_000  * E18;
    uint256 public constant TREASURY_ALLOCATION       = 8_000_000  * E18;

    // Addresses that contain the funds for the given allocation.
    address public constant SEED      = 0x640F9A10254e0C28fA046B8b394a238Acf864641;
    address public constant PRIVATE   = 0x4B56Fe0DF8c5E330A65D6f8D6c6f341911b5FaB0;
    address public constant PUBLIC    = 0x8AD13271A702e91735132312E7ddD4AbeE96E37C;
    address public constant TEAM      = 0x127701ba09218882c7186974Fe5541dE53564915;
    address public constant COMMUNITY = 0xC8a3e44Cf503800d13C7300FF03AEB42731374FE;
    address public constant LQ_POOL   = 0x4b83d6E79993aF15aAEe182300268Cb0c8A6f2dC;
    address public constant TREASURY  = 0xeF9458C304Dc3888b574113F8AFF2bb88efF561D;

    uint256 public constant VESTING_END_AT = 1767119400;  // Wed Dec 31 2025 00:00:00 GMT+0530

    address public vestingToken;   // BEP20 token that get vested.

    event TokenSet(address vestingToken);
    event Pulled(address indexed beneficiary, uint256 amount);

    struct Schedule {
        // Name of the template
        bytes32 templateName;
        // Tokens that were already claimed
        uint256 claimedTokens;
        // Start time of the schedule
        uint256 startTime;
        // Total amount of tokens
        uint256 allocation;
        // Schedule duration (How long the schedule will last)
        uint256 duration;
        // Schedule frequency
        uint256 frequency;
        // Cliff of the schedule.
        uint256 cliff;
        // Percentage allocation for the frequency period.
        uint256 allocationAtFrequency;
        // Percentage allocation for the cliff.
        uint256 cliffAllocation;
    }

    mapping (address => Schedule[]) public schedules;

    constructor() {
        // For Seed allocation
        _createSchedule(SEED, Schedule({
            templateName         :  bytes32("Seed"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  SEED_ALLOCATION,
            duration             :  25920000,     // 10 Months (10 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (1 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  1000,         // 10 %
            cliffAllocation      :  uint256(0)
        }));

        // For Private allocation
        _createSchedule(PRIVATE, Schedule({
            templateName         :  bytes32("Private"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  PRIVATE_ALLOCATION,
            duration             :  23328000,     // 9 Months (9 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month  (1 * 30 * 24 * 60 * 60)
            cliff                :  2592000,      // 1 Month cliff.
            allocationAtFrequency:  1000,         // 10 %
            cliffAllocation      :  2000          // 20 %
        }));

        // For Public allocation
        _createSchedule(PUBLIC, Schedule({
            templateName         :  bytes32("Public"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  PUBLIC_ALLOCATION,
            duration             :  10368000,     // 4 Months (4 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month  (1 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),   
            allocationAtFrequency:  2500,         // 10 %
            cliffAllocation      :  uint256(0)
        }));

        // For Team allocation
        _createSchedule(TEAM, Schedule({
            templateName         :  bytes32("Team"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  TEAM_ALLOCATION,
            duration             :  54432000,     // 21 Months (21 * 30 * 24 * 60 * 60)
            frequency            :  7776000,      // 3 Month   (1 * 30 * 24 * 60 * 60)
            cliff                :  31104000,     // 12 Month cliff.
            allocationAtFrequency:  2500,         // 25 % 
            cliffAllocation      :  2500          // 25 %
        }));

        // For Community allocation -- 1
        _createSchedule(COMMUNITY, Schedule({
            templateName         :  bytes32("Community_1"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  24 * COMMUNITY_ALLOCATION / 100,   // 24 % of the total community allocation.
            duration             :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (01 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  833,          // 8.33 % Rest of the dust will send back to the user at the end of the schedule. 
            cliffAllocation      :  uint256(0)
        }));

        // For Community allocation -- 2
        _createSchedule(COMMUNITY, Schedule({
            templateName         :  bytes32("Community_2"),
            claimedTokens        :  uint256(0),
            startTime            :  1661884200,   // Wed Aug 31 2022 00:00:00 GMT+0530
            allocation           :  36 * COMMUNITY_ALLOCATION / 100,   // 36 % of the total community allocation.
            duration             :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (01 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  833,          // 8.33 % Rest of the dust will send back to the user at the end of the schedule. 
            cliffAllocation      :  uint256(0)
        }));

        // For Community allocation -- 3
        _createSchedule(COMMUNITY, Schedule({
            templateName         :  bytes32("Community_3"),
            claimedTokens        :  uint256(0),
            startTime            :  1693420200,   // Wed Aug 31 2023 00:00:00 GMT+0530
            allocation           :  40 * COMMUNITY_ALLOCATION / 100,   // 40 % of the total community allocation.
            duration             :  31104000,     // 12 Months (12 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (01 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  833,          // 8.33 % Rest of the dust will send back to the user at the end of the schedule. 
            cliffAllocation      :  uint256(0)
        }));

        // For Liquidity Pool allocation  -- 1
        _createSchedule(LQ_POOL, Schedule({
            templateName         :  bytes32("Liquidity_pool_1"),
            claimedTokens        :  uint256(0),
            startTime            :  1630348200,   // Tue Aug 31 2021 00:00:00 GMT+0530
            allocation           :  10 * LIQUIDITY_POOL_ALLOCATION / 100, // 10 % of the total liquidity pool allocation.
            duration             :  5184000,      // 2 Months (2 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month  (1 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  5000,         // 50 % 
            cliffAllocation      :  uint256(0)
        }));

        // For Liquidity Pool allocation  -- 2
        _createSchedule(LQ_POOL, Schedule({
            templateName         :  bytes32("Liquidity_pool_2"),
            claimedTokens        :  uint256(0),
            startTime            :  1635618600,   // Sun Oct 31 2021 00:00:00 GMT+0530
            allocation           :  90 * LIQUIDITY_POOL_ALLOCATION / 100,
            duration             :  116640000,    // 45 Months (45 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (1 * 30 * 24 * 60 * 60)
            cliff                :  uint256(0),
            allocationAtFrequency:  222,          // 2.22 % 
            cliffAllocation      :  uint256(0)
        }));

        // For Treasury allocation
        _createSchedule(TREASURY, Schedule({
            templateName         :  bytes32("Treasury"),
            claimedTokens        :  uint256(0),
            startTime            :  1661884200,   // Wed Aug 31 2022 00:00:00 GMT+0530
            allocation           :  TREASURY_ALLOCATION,
            duration             :  134784000,    // 52 Months (52 * 30 * 24 * 60 * 60)
            frequency            :  2592000,      // 1 Month   (1 * 30 * 24 * 60 * 60)
            cliff                :  31104000,     // 12 Month cliff.
            allocationAtFrequency:  250,          // 2.5 % 
            cliffAllocation      :  uint256(0)    // 0 %
        }));
    }

    function setToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Vesting: ZERO_ADDRESS_NOT_ALLOWED");
        require(vestingToken == address(0), "Vesting: ALREADY_SET");
        require(IBEP20(tokenAddress).balanceOf(address(this)) > uint256(0), "Vesting: INSUFFICIENT_BALANCE");
        vestingToken = tokenAddress;
        emit TokenSet(tokenAddress);
    }

    function skim(address tokenAddress, uint256 amount, address destination) external onlyOwner {
        require(block.timestamp > VESTING_END_AT, "Vesting: NOT_ALLOWED");
        require(destination != address(0),        "Vesting: ZERO_ADDRESS_NOT_ALLOWED");
        SafeERC20.safeTransfer(IERC20(tokenAddress), destination, amount);
    }

    function pull() external {
        Schedule[] memory _schedules = schedules[msg.sender];
        require(_schedules.length != uint256(0), "Vesting: NOT_AUTORIZE");
        uint256 amount = 0;
        for (uint8 i = 0; i < _schedules.length; i++) {
            uint256 vestedAmount = 0;
            if (_schedules[i].startTime > block.timestamp) {
                continue;
            }
            if (_schedules[i].startTime + _schedules[i].duration <= block.timestamp) {
                vestedAmount = _schedules[i].allocation;
            } else {
                if (_schedules[i].cliff != uint256(0) && _schedules[i].startTime + _schedules[i].cliff <= block.timestamp) {
                    vestedAmount = _schedules[i].cliffAllocation * _schedules[i].allocation / 10_000;
                }
                else if (block.timestamp > _schedules[i].startTime + _schedules[i].cliff) {
                    uint256 timeDelta            = block.timestamp - _schedules[i].startTime - _schedules[i].cliff;
                    uint256 noOfPeriods          = timeDelta / _schedules[i].frequency;
                    uint256 unitPeriodAllocation = _schedules[i].allocationAtFrequency * _schedules[i].allocation / 10_000;
                    vestedAmount += unitPeriodAllocation * noOfPeriods;
                } 
            }
            amount += _schedules[i].claimedTokens - vestedAmount;
        }
        if (amount > uint256(0)) {
            SafeERC20.safeTransfer(IERC20(vestingToken), msg.sender, amount);
            emit Pulled(msg.sender, amount);
        }
    }

    function _createSchedule(address _beneficiary, Schedule memory _schedule) internal {
        schedules[_beneficiary].push(_schedule);
    }

}