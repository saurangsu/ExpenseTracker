/*
    @Author/dev: Functionalities of this contract - 
    
        1. Record an expense
        2. Verify if expenses can only be added between friends
        3. Include the following splitting mechanisms - Equal and shares
        4. Delete an expense, ensuring that only the owner of 
        
    Work need to be done - 
    
        1. Add every expense to an array, to have a list of expenses - some logical errors happened while trying to implement that
        2. Modify a transaction
        
        
*/

pragma solidity ^0.5.0;

import "./User.sol";

contract transactions is user{
    
   // uint transactionId = 0;
    
    
    enum ExpenseTypes {DEFAULT, EQUAL, PERCENTAGE, SHARE}
    ExpenseTypes expenseType;
    //uint transactionId;
    struct expense{
        
        address[] spenders;
        uint expenseAmount;
        uint[] splits;
        address payer;
        uint[] distributedAmounts;
    }
    //expense[] expensesList;
    mapping(string => expense) expenseMapper;    
    
/*    constructor() public{
        transactionId = 0;
    }*/
    //uint transactionId = expensesList.length;
    //@dev: for every element in the _friends array, verify if that friend exists using FN doesFriendExist
    modifier checkFriendList(address[] memory _friends){
        users memory currentUser = addressToUserMapping[msg.sender];
        uint noOfFriends = currentUser.friends.length;
        //bool allFriendExist = false;
        //@dev: when friends count is 0, the for loop is breaking, due to underflow of unsigned integer
        //hence putting it in an if..else.. statement
        if(noOfFriends == 0){
            revert("You do not have any friends to share exp1enses with");
        }else{
            for(uint i=0;i<_friends.length;i++){
                if(_friends[i] == msg.sender){
                    _;
                }
                else if (doesFriendExist(_friends[i])){
                    //allFriendExist = true;
                    _;
                }else{
                    revert("User does not exist in your friend list");
                }                            
            }
        }

    }
    
    modifier ownerOfTransaction(string memory _textDetails){
        require(expenseMapper[_textDetails].payer == msg.sender);
        _;
    }

    //@dev: verifies if the the friend exists
    function doesFriendExist (address _address) private view returns (bool friendFound){
        users memory currentUser = addressToUserMapping[msg.sender];
        uint noOfFriends = currentUser.friends.length;
        
           //@dev: traverse through every element in a users's friend array, to verify if the address passed into this function exists
            for (uint i=0; i<noOfFriends;i++){
                if(currentUser.friends[i] == _address){
                    friendFound = true;
                    break;
                }else{
                    friendFound = false;
                }
            }
        return friendFound;
        
    }
    
    //@dev: function to add expenses
    function addExpense(string memory txDetails, uint expenseAmount, ExpenseTypes _type, address[] memory spenders, uint[] memory splits) public checkUserValidity() checkFriendList(spenders){
       
        //uint[] memory splitAmount;
       
        
        //expensesList.push(transactionId);
        expense memory currentExpense = expense(spenders,expenseAmount, splits,msg.sender,new uint[](0));
        
        expenseMapper[txDetails] = currentExpense;
        
        //@dev: if the splitting option is set as EQUAL
        if (_type == ExpenseTypes.EQUAL){
           uint splitPerPerson = expenseAmount/spenders.length;
           for(uint i=0;i<spenders.length;i++){
               //splitAmount[i].push(splitPerPerson);
               expenseMapper[txDetails].distributedAmounts.push(splitPerPerson);
              }
        //@dev: if the splitting option is set as SHARES
       }else if(_type == ExpenseTypes.SHARE){
           require(splits.length>0 && spenders.length == splits.length, "Shares per person hasn't been recoreded");
           uint totalShares = 0; 
           //@dev: assigns shares per person - in the same order as spenders
           for(uint i=0;i<splits.length;i++){
           
           totalShares = totalShares + splits[i];
      
           }
           //uint temp = transactionId;
           //@dev: assigns distributed amounts per person
           for(uint i=0;i<splits.length;i++){
           
           //if(temp == 0 ){
           expenseMapper[txDetails].distributedAmounts
           .push((expenseAmount/totalShares)*splits[i]);         
           }//}
            
       }else{
           
       }
    //@dev: some logical error while trying to use a unique uint as a transaction ID and use that to populate an array containing list of transactions. 
    //transactionId++;
    //transactionId = transactionId + 1;
    //expensesList.push(currentExpense);
        //increaseTransactionID(transactionId);

    }
    
/*    function increaseTransactionID(uint _transactionId) private{
        expensesList.push(_transactionId);
    }*/

    function deleteTransaction(string memory _textDetails) public ownerOfTransaction(_textDetails){
        delete expenseMapper[_textDetails];
    }
}