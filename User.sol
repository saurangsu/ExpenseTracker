/*
    @Author/Dev: Functionalities of this contract - 
        Functions - 
        
        1. Allow a user to register using. - FN: register
        2. Allow the registered users to login. This needs to be re-visited. - FN: login
        3. Allow a user to add friends. - FN: addFriends
        4. Allow a user to delete friends. - FN: deleteFriends
        
    
*/

pragma solidity ^0.5.0;

contract user{
    
    struct users {
        string username;
        string password;
        bool exists;
        //address userAddress;
        address[] friends;
       
    } 
    
    
    //users[] public  userList;
    mapping (address => users) addressToUserMapping;
    //mapping (address => friends) userToFriendMapping;
    
    //@dev: verify that same user doesn't register twice
    modifier registerOnlyOnce (address _address){
       require(addressToUserMapping[_address].exists == false,"User already exists");
       _; 
    }
    //@dev: verify if this user exists in the chain
    modifier checkUserValidity(){
        require(addressToUserMapping[msg.sender].exists == true,"User does not exist");
        _;
    }
    
    
    //@dev: verify that the user is not adding a duplicate friends
    modifier addOnlyOnce (address _address){
        users memory currentUser = addressToUserMapping[msg.sender];
        uint noOfFriends = currentUser.friends.length;
        //@dev: when friends count is 0, the for loop is breaking, due to underflow of unsigned integer
        //hence putting it in an if..else.. statement
        if(noOfFriends == 0){
            _;
        }else{
            bool friendNotFound;
            //@dev: traverse through every element in a users's friend array, to verify if the address passed into this function exists
            for (uint i=0; i<noOfFriends;i++){
                if(currentUser.friends[i] == _address){
                    friendNotFound = false;
                    break;
                }else{
                    friendNotFound = true;
                }
            }
        
        require(friendNotFound == true);
        _;
        }
    }

    //@dev: register a user
    function register(string memory _username, string memory _password) public registerOnlyOnce(msg.sender){
        
        users memory newUser = users(_username,_password,true,new address[](0));
        
        addressToUserMapping[msg.sender] = newUser;
    }
    //@dev: login module. This isn't a proper approach for a Distributed App. 
    function login(string memory _username, string memory _password) public view returns (bool){
        users memory currentUser = addressToUserMapping[msg.sender];
        require(currentUser.exists == true,"User does not exist");
        
        require (keccak256(abi.encodePacked(_username)) == keccak256(abi.encodePacked(currentUser.username)) && 
            keccak256(abi.encodePacked(_password)) == keccak256(abi.encodePacked(currentUser.password))
            ,"Wrong Login information provided");
        
        return true;
    
        
    }
    //@dev: function for adding a friend
    function addFriends(address _friendAddress) public checkUserValidity() addOnlyOnce(_friendAddress){
        users storage currentUser = addressToUserMapping[msg.sender];
        currentUser.friends.push(_friendAddress);
        
    }
    //@dev: function for deleting a friend
    function deleteFriends(address _friendAddress) public checkUserValidity(){
        users storage currentUser = addressToUserMapping[msg.sender];
        uint noOfFriends = currentUser.friends.length;
       
        
        if(noOfFriends == 0){
            //@dev: throws error if the caller doesn't have any friend
            revert("You do not have any friends");
        }else{
            for (uint i=0; i<noOfFriends;i++){
                if(currentUser.friends[i] == _friendAddress){
                    //@dev: If friend has been found in user's list, it's place in friends array is replaced by the last element of that array
                    currentUser.friends[i] = currentUser.friends[noOfFriends - 1];
                    //@dev: then the last element of the array is removed
                    currentUser.friends.length--;
                    break;
                }else{
                    //@dev: throws error if the address is unavailable in friends array
                    revert("You do not have this user as a friend");
                }
            }
        }
    }
    

    
}