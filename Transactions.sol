pragma solidity ^0.5.0;

import "./User.sol";

contract transactions is user{
    
    //uint transactionId = 0;
    
    enum ExpenseTypes {DEFAULT, EQUAL, PERCENTAGE, SHARE}
    ExpenseTypes expenseType;
    
    struct expense{
        
        address[] spenders;
        uint expenseAmount;
        uint[] splits;
        address payer;
        uint[] distributedAmounts;
    }
    uint[] expensesList;
    mapping(uint => expense) expenseMapper;    

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
    function addExpense(uint expenseAmount, ExpenseTypes _type, address[] memory spenders, uint[] memory splits) public checkUserValidity() checkFriendList(spenders){
       
        //uint[] memory splitAmount;
       
        uint transactionId = expensesList.length;
        expensesList.push(transactionId);
        expense memory currentExpense = expense(spenders,expenseAmount, splits,msg.sender,new uint[](0));
        
        expenseMapper[transactionId] = currentExpense;
        
 
        if (_type == ExpenseTypes.EQUAL){
           uint splitPerPerson = expenseAmount/spenders.length;
           for(uint i=0;i<spenders.length;i++){
               //splitAmount[i].push(splitPerPerson);
               expenseMapper[transactionId].distributedAmounts.push(splitPerPerson);
              }

       }else if(_type == ExpenseTypes.SHARE){
           require(splits.length>0 && spenders.length == splits.length, "Shares per person hasn't been recoreded");
           uint totalShares = 0; 
           for(uint i=0;i<splits.length;i++){
           
           totalShares = totalShares + splits[i];
      
           }
           
           for(uint i=0;i<splits.length;i++){
           
           
           expenseMapper[transactionId].distributedAmounts
           .push((expenseAmount/totalShares)*splits[i]);         
           }

       }


    //transactionId = transactionId + 1;
    


    }


    function showBalance() public returns(uint){
        return addressToUserMapping[msg.sender].amountOwed;
    }
}