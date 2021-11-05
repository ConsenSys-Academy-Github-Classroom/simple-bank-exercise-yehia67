/*
 * This exercise has been updated to use Solidity version 0.8.5
 * See the latest Solidity updates at
 * https://solidity.readthedocs.io/en/latest/080-breaking-changes.html
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

import './Context.sol';

contract SimpleBank is Context{
  
    // Fill in the visibility keyword. 
    // Hint: We want to protect our users balance from other contracts
    mapping (address => uint) private balances;
    
    // Fill in the visibility keyword
    // Hint: We want to create a getter function and allow contracts to be able
    //       to see if a user is enrolled.
    mapping (address => bool) public enrolled;

    // Let's make sure everyone knows who owns the bank, yes, fill in the
    // appropriate visilibility keyword
    address public owner;
    
    /* Events - publicize actions to external listeners
     */
    
    // Add an argument for this event, an accountAddress
    event LogEnrolled(address indexed accountAddress);

    // Add 2 arguments for this event, an accountAddress and an amount
    event LogDepositMade(address indexed accountAddress, uint amount);

    // Create an event called LogWithdrawal
    // Hint: it should take 3 arguments: an accountAddress, withdrawAmount and a newBalance 
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);
    
    modifier isEnrolled() {        
        require(enrolled[_msgSender()] == true, "should been enrolled");
        _;
    } 

    constructor()  { 
        owner = _msgSender();
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    fallback() external payable {
      revert();
    }

    receive() external payable {
      deposit();
    }


    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() external view returns (uint) {
      return balances[_msgSender()];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() external returns (bool){
      enrolled[_msgSender()] = true;
      emit LogEnrolled(_msgSender());
      return enrolled[_msgSender()];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable isEnrolled returns (uint) {
      
      require(msg.value > 0, "REVERT: Deposit value must be a positive integer and greater than 0");
        
      balances[msg.sender] += msg.value;
        
      emit LogDepositMade(msg.sender, msg.value);

      return balances[msg.sender]; 
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) external returns (uint) {

      require(enrolled[_msgSender()], "REVERT: User is not enrolled into banking system");
      require(balances[_msgSender()] >= withdrawAmount, "REVERT: Insufficient funds for requested withdrawal");
      require(withdrawAmount > 0, "REVERT: Amount of Ether to withdraw MUST be greater than 0");
        
      uint pretransactionBalance = balances[_msgSender()];

      balances[_msgSender()] -= withdrawAmount;
      

      require(balances[_msgSender()] < pretransactionBalance, "REVERT: Withdraw amount is different");
        
      (bool isSent,) = payable(_msgSender()).call{value: withdrawAmount}(abi.encode(withdrawAmount));
       
      require(isSent, "Failed to send Ether");

      emit LogWithdrawal(_msgSender(), withdrawAmount, balances[_msgSender()]);

      return balances[_msgSender()];
    }
}
