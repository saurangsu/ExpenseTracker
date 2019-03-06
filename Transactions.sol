pragma solidity ^0.5.0;

import "./User.sol";

contract transactions{
    
    enum ExpenseTypes {DEFAULT, EQUAL, PERCENTAGE, SHARE}
    ExpenseTypes expenseType;
    struct expense{
        
        address[] spenders;
        uint expenseAmount;
        
    }
    
    
    mapping(uint => expense) expenseMapper;    
    
    function addExpense(uint expenseAmount, address[] memory spenders) public{
        expense memory currentExpense = expense(spenders,expenseAmount);
        
    }
}