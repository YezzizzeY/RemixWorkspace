
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: USTFaucet.sol

/**
 *Submitted for verification at Etherscan.io on 2023-02-03
*/

pragma solidity ^0.8.4;

// 引入OpenZeppelin的ERC20和Ownable合约



contract USTFaucet {

    struct user_details {
        mapping(address => uint) latest_request;
        mapping(address => bool) request_permission;
    } 

    address public manager;
    mapping(address => user_details) user_token_mapping; 
    mapping(address => uint256) faucet_amount; //Amount of tokens sent by faucet per user per day`

    constructor() {
        manager = msg.sender;    
    }

    function set_faucet_amount(address token_address, uint256 value) public {
        require(
            msg.sender == manager,
            "Only manager can register users"
        );
        faucet_amount[token_address]=value;
    }

    function registerUsers(address[] calldata user_list, address token_address) public {
        require(
            msg.sender == manager,
            "Only manager can register users"
        );
        for(uint256 i=0; i< user_list.length; i++)
            user_token_mapping[user_list[i]].request_permission[token_address] = true;
    }

    function deRegisterUsers(address[] calldata user_list, address token_address) public {
        require(
            msg.sender == manager,
            "Only manager can deregister users"
        );
        for(uint256 i=0; i< user_list.length; i++)
            user_token_mapping[user_list[i]].request_permission[token_address] = false;
    }

    function requestTokens(IERC20 token) public {
        require(
            user_token_mapping[msg.sender].request_permission[address(token)] == true,
            "Only registered users can use this airdrop"
        );
        require(
            user_token_mapping[msg.sender].latest_request[address(token)] <= block.timestamp - 86400,
            "Only one request per day" 
        );
        require(
            faucet_amount[address(token)]>0,
            "This faucet does not support the token provided" 
        );
        require(
            token.balanceOf(address(this))>=faucet_amount[address(token)],
            "The faucet has exhaused its tokens, replenish faucet"
        );
        token.transfer(msg.sender,faucet_amount[address(token)]);
        user_token_mapping[msg.sender].latest_request[address(token)] = block.timestamp;
    }

    function retrieveFaucetAmount(IERC20 token) public view returns(uint256){
        return faucet_amount[address(token)];
    }

    function retrieveFaucetBalance(IERC20 token) public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function getRegistrationStatus(address user_address, address token_address) public view returns(bool){
        return user_token_mapping[user_address].request_permission[token_address];
    }

    function getLatestRequestTimestamp(address user_address, address token_address) public view returns(uint){
        return user_token_mapping[user_address].latest_request[token_address];
    }

}