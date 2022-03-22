/**
 *Submitted for verification at BscScan.com on 2022-01-14
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IERC20Like {
    function balanceOf(address account_) external view returns (uint256 balance_);
    function transfer(address recipient_, uint256 amount_) external returns (bool success_);
    function allowance(address owner_, address spender_) external view returns (uint256 allowance_);
    function approve(address spender_, uint256 amount_) external returns (bool success_);
    function transferFrom(address sender_, address recipient_, uint256 amount_) external returns (bool success_);

} interface ITokenVesting {

    /**************************/
    /*** Contract Ownership ***/
    /**************************/

    event OwnershipTransferPending(address indexed owner, address indexed pendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Returns the owner of the contract.
    function owner() external view returns (address owner_);

    /// @dev Returns the pending owner of the contract.
    function pendingOwner() external view returns (address pendingOwner_);

    /// @dev Leaves the contract without owner, and clears the pendingOwner, if any.
    function renounceOwnership() external;

    /// @dev Allows a new account to take ownership of the contract.
    function transferOwnership(address newOwner_) external;

    /// @dev Takes ownership of the contract.
    function acceptOwnership() external;

    /*********************/
    /*** Token Vesting ***/
    /*********************/

    /**
     * @dev   Is emitted when a token vesting schedule is set for a receiver.
     * @param receiver_ The receiver of a token vesting schedule.
     */
    event VestingScheduleSet(address indexed receiver_);

    /**
     * @dev   Is emitted when the contract is funded for vesting.
     * @param totalTokens_ The total amount of tokens to be vested.
     */
    event VestingFunded(uint256 totalTokens_);

    /**
     * @dev   Is emitted when the receiver of a token vesting schedule is changed.
     * @param oldReceiver The old receiver of the token vesting schedule.
     * @param newReceiver The new receiver of the token vesting schedule.
     */
    event ReceiverChanged(address indexed oldReceiver, address indexed newReceiver);

    /**
     * @dev   Is emitted when the token vesting schedule for a receiver is killed.
     * @param receiver_      The receiver that had its token vesting schedule killed.
     * @param tokensClaimed_ The amount of tokens claimed.
     * @param destination_   The destination the token have been sent to.
     */
    event VestingKilled(address indexed receiver_, uint256 tokensClaimed_, address indexed destination_);

    /**
     * @dev   Is emitted when a receiver claims tokens from its vesting schedule.
     * @param receiver_      The receiver of a token vesting schedule.
     * @param tokensClaimed_ The amount of tokens claimed.
     * @param destination_   The destination the claimed tokens have been sent to.
     */
    event TokensClaimed(address indexed receiver_, uint256 tokensClaimed_, address indexed destination_);

    struct VestingSchedule {
        uint256 startTime;
        uint256 cliff;
        uint256 totalPeriods;
        uint256 timePerPeriod;
        uint256 totalTokens;
        uint256 tokensClaimed;
    }

    /// @dev The vesting token.
    function token() external returns (address token_);

    /// @dev The total amount of tokens being vested.
    function totalVestingsTokens() external returns (uint256 totalVestingsTokens_);

    /**
     * @dev   Returns the vesting schedule of a receiver.
     * @param receiver_      The receiver of a vesting schedule.
     */
    function vestingScheduleOf(address receiver_) external returns (
        uint256 startTime_,
        uint256 cliff_,
        uint256 totalPeriods_,
        uint256 timePerPeriod_,
        uint256 totalTokens_,
        uint256 tokensClaimed_
    );

    /**
     * @dev   Set the vesting schedules for some receivers, respectively.
     * @param receivers_ An array of receivers of vesting schedules.
     * @param vestings_  An array of vesting schedules.
     */
    function setVestingSchedules(address[] calldata receivers_, VestingSchedule[] calldata vestings_) external;

    /**
     * @dev   Fund the contact with tokens that will be vested.
     * @param totalTokens_ The amount of tokens that will be supplied to this contract.
     */
    function fundVesting(uint256 totalTokens_) external;

    /**
     * @dev   Change the receiver of an existing vesting schedule.
     * @param oldReceiver_ The old receiver address.
     * @param newReceiver_ The new receiver address.
     */
    function changeReceiver(address oldReceiver_, address newReceiver_) external;

    /**
     * @dev    Returns the amount of claimable tokens for a receiver of a vesting schedule.
     * @param  receiver_        The receiver address.
     * @return claimableTokens_ The amount of claimable tokens.
     */
    function claimableTokens(address receiver_) external view returns (uint256 claimableTokens_);

    /**
     * @dev   Claim the callers tokens of a vesting schedule.
     * @param destination_ The destination to send the tokens.
     */
    function claimTokens(address destination_) external;

    /**
     * @dev   Kill the vesting schedule for a receiver.
     * @param receiver_    The receiver address.
     * @param destination_ The destination to send the tokens.
     */
    function killVesting(address receiver_, address destination_) external;

    /*********************/
    /*** Miscellaneous ***/
    /*********************/

    /**
     * @dev   Is emitted when some ERC20 token is recovered from the contract.
     * @param token       The address of the token.
     * @param amount      The amount of token recovered.
     * @param destination The destination the token was sent to.
     */
    event RecoveredToken(address indexed token, uint256 amount, address indexed destination);

    /**
     * @dev   Recover tokens owned by the contract.
     * @param token_       The token address.
     * @param destination_ The destination to send the ETH.
     */
    function recoverToken(address token_, address destination_) external;

} contract TokenVesting is ITokenVesting {

    address public override owner;
    address public override pendingOwner;

    address public override token;
    uint256 public override totalVestingsTokens;

    mapping(address => VestingSchedule) public override vestingScheduleOf;

    /**
     * @dev   Constructor.
     * @param token_ The address of an erc20 token.
     */
    constructor(address token_) {
        owner = msg.sender;
        token = token_;
    }

    /**************************/
    /*** Contract Ownership ***/
    /**************************/

    modifier onlyOwner() {
        require(owner == msg.sender, "TV:NOT_OWNER");
        _;
    }

    function renounceOwnership() external override onlyOwner {
        pendingOwner = owner = address(0);

        emit OwnershipTransferred(msg.sender, address(0));
    }

    function transferOwnership(address newOwner_) external override onlyOwner {
        pendingOwner = newOwner_;

        emit OwnershipTransferPending(msg.sender, newOwner_);
    }

    function acceptOwnership() external override {
        require(pendingOwner == msg.sender, "TV:NOT_PENDING_OWNER");

        emit OwnershipTransferred(owner, msg.sender);

        owner = msg.sender;
        pendingOwner = address(0);
    }

    /*********************/
    /*** Token Vesting ***/
    /*********************/

    function setVestingSchedules(address[] calldata receivers_, VestingSchedule[] calldata vestingSchedules_) external override onlyOwner {
        for (uint256 i; i < vestingSchedules_.length; ++i) {
            address receiver = receivers_[i];

            vestingScheduleOf[receiver] = vestingSchedules_[i];

            emit VestingScheduleSet(receiver);
        }
    }

    function fundVesting(uint256 totalTokens_) external override onlyOwner {
        require(totalVestingsTokens == uint256(0), "TV:ALREADY_FUNDED");

        _safeTransferFrom(token, msg.sender, address(this), totalTokens_);

        totalVestingsTokens = totalTokens_;

        emit VestingFunded(totalTokens_);
    }

    function changeReceiver(address oldReceiver_, address newReceiver_) external override onlyOwner {
        // Swap old and new receivers' vesting schedule, using address(0) as a scratch space.
        // This is done to not overwrite an active vesting schedule.
        vestingScheduleOf[address(0)] = vestingScheduleOf[oldReceiver_];
        vestingScheduleOf[oldReceiver_] = vestingScheduleOf[newReceiver_];
        vestingScheduleOf[newReceiver_] = vestingScheduleOf[address(0)];

        delete vestingScheduleOf[address(0)];

        emit ReceiverChanged(oldReceiver_, newReceiver_);
    }

    function claimableTokens(address receiver_) public view override returns (uint256 claimableTokens_) {
        VestingSchedule storage vestingSchedule = vestingScheduleOf[receiver_];

        uint256 totalPeriods = vestingSchedule.totalPeriods;

        if (totalPeriods == uint256(0)) return uint256(0);

        uint256 timePassed = block.timestamp - vestingSchedule.startTime;
        uint256 cliff = vestingSchedule.cliff;

        if (timePassed <= cliff) return uint256(0);

        uint256 multiplier = (timePassed - cliff) / vestingSchedule.timePerPeriod;

        return
            (
                (
                    (
                        multiplier > totalPeriods ? totalPeriods : multiplier
                    )
                    * vestingSchedule.totalTokens
                )
                / totalPeriods
            )
            - vestingSchedule.tokensClaimed;
    }

    function claimTokens(address destination_) external override {
        require(totalVestingsTokens > uint256(0), "TV:NOT_FUNDED");

        VestingSchedule storage vestingSchedule = vestingScheduleOf[msg.sender];

        uint256 tokensToClaim = claimableTokens(msg.sender);

        require(tokensToClaim > uint256(0), "TV:NO_CLAIMABLE");

        // NOTE: Setting tokensClaimed before transfer will result in no additional transfer on a reentrance.
        vestingSchedule.tokensClaimed += tokensToClaim;

        _safeTransfer(token, destination_, tokensToClaim);

        emit TokensClaimed(msg.sender, tokensToClaim, destination_);
    }

    function killVesting(address receiver_, address destination_) external override onlyOwner {
        VestingSchedule storage vestingSchedule = vestingScheduleOf[receiver_];

        uint256 totalTokens = vestingSchedule.totalTokens;
        uint256 tokensToClaim = totalTokens - vestingSchedule.tokensClaimed;

        // NOTE: Setting tokensClaimed before transfer will result in no additional transfer on a reentrance.
        vestingScheduleOf[receiver_].tokensClaimed = totalTokens;

        _safeTransfer(token, destination_, tokensToClaim);

        emit VestingKilled(receiver_, tokensToClaim, destination_);
    }

    /*********************/
    /*** Miscellaneous ***/
    /*********************/

    function recoverToken(address token_, address destination_) external override onlyOwner {
        require(token_ != token, "TV:CANNOT_RECOVER_VESTING_TOKEN");

        uint256 amount = IERC20Like(token_).balanceOf(address(this));

        require(amount > uint256(0), "TV:NO_TOKEN");

        _safeTransfer(token_, destination_, amount);

        emit RecoveredToken(token_, amount, destination_);
    }

    /******************/
    /*** Safe ERC20 ***/
    /******************/

    function _safeTransfer(address token_, address to_, uint256 amount_) internal {
        ( bool success, bytes memory data ) = token_.call(abi.encodeWithSelector(IERC20Like.transfer.selector, to_, amount_));

        require(success && (data.length == uint256(0) || abi.decode(data, (bool))), 'TV:SAFE_TRANSFER_FAILED');
    }

    function _safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        ( bool success, bytes memory data ) = token_.call(abi.encodeWithSelector(IERC20Like.transferFrom.selector, from_, to_, amount_));

        require(success && (data.length == uint256(0) || abi.decode(data, (bool))), 'TV:SAFE_TRANSFER_FROM_FAILED');
    }

    // Token Vesting //

    event ScheduleVestingTokens(
        uint256 indexed scheduleId,
        address token,
        address minter,
        address to,
        uint256 amount,
        uint256 time
    );

    event RedeemTokens(
        uint256 indexed scheduleId,
        address redeemer,
        uint256 amount,
        uint256 redeemAt
    );

    uint256 scheduleCounter;

    struct Schedule {
        address _token;
        address minter;
        address toAddress;
        uint256 totalAmount;
        uint256 redeemedTokens;
        uint256 time;
        uint256 lastRedeemedTime;
        uint256 totalDiffrence;
    }

    mapping(uint256 => Schedule) public tokenVestingSchedules;

    function mint(address _token, address _to, uint256 _amount,uint256 _time) public returns (uint256 _scheduleId) {

        require(
            _time >= block.timestamp,
            "INVALID TIME"
        );

        // Transfering token to vesting Contract
        IERC20Like(_token).transferFrom(msg.sender, address(this), _amount);
        // Creating Schedule
        scheduleCounter = scheduleCounter + 1;
        tokenVestingSchedules[scheduleCounter] = Schedule(_token,msg.sender,_to,_amount,0,_time,block.timestamp,(block.timestamp-_time));
        emit ScheduleVestingTokens(scheduleCounter,token,msg.sender,_to,_amount,_time);

        return _scheduleId;
        
    }

    function redeem(uint256 _scheduleId) public {
        
        require(
            tokenVestingSchedules[_scheduleId].toAddress == msg.sender,
            "ERROR: YOU CANNOT REDEEM THE TOKENS"
        );

        require(
            tokenVestingSchedules[_scheduleId].totalAmount - tokenVestingSchedules[_scheduleId].redeemedTokens > 0,
            "YOU CANNOT REDEEM MORE TOKENS"
        );

        uint256 tokensToRedeem = 0;
        uint256 currentDiffrence = block.timestamp - tokenVestingSchedules[_scheduleId].lastRedeemedTime;
        uint256 percentTokensToRedeem = (currentDiffrence * 100) / tokenVestingSchedules[_scheduleId].totalDiffrence;
        
        tokensToRedeem = (tokenVestingSchedules[_scheduleId].totalAmount / 100) * percentTokensToRedeem;

        IERC20Like(tokenVestingSchedules[_scheduleId]._token).transfer(msg.sender, tokensToRedeem);

        tokenVestingSchedules[_scheduleId].lastRedeemedTime = block.timestamp;

        emit RedeemTokens(_scheduleId, msg.sender,tokensToRedeem,block.timestamp);

    }

}
