// SPDX-License-Identifier: MIT 

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CarRentalPlatform is ReentrancyGuard{
    // Data

    // Counter
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    // Owner
    address private owner;

    // total payments
    uint private totalPayments;

    // user struct
    struct User{
        address walletAddress;
        string name;
        string lastname;
        uint rentedCarId;
        uint balance;
        uint debt;
        uint start;
    }

    // car struct
    struct Car{
        uint id;
        string name;
        string imgUrl;
        Status status;
        uint rentFee;
        uint saleFee;
    }

    // enum to indidcate status of the car
    enum Status{
        Retired,
        InUse,
        Available
    }

    // events
    event CarAdded(uint indexed id,string name,string imgUrl,uint rentFee,uint saleFee);
    event CarMetadataEdited(uint indexed id,string name,string imgUrl,uint rentFeem,uint saleFee);
    event CarStatusEdited(uint indexed id,Status status);
    event UserAdded(address indexed walletAddress,string name,string lastname);
    event Deposit(address indexed walletAddress,uint amount);
    event ChechOut(address indexed walletAddress,uint indexed carId);
    event ChechIn(address indexed walletAddress,uint indexed carId);
    event PaymentMade(address indexed walletAddress,uint amount);
    event BalanceWithdrawn(address indexed walletAddress,uint amount);

    

    // user mapping
    mapping(address => User) private users;

    // car mapping
    mapping(uint => Car) private cars;

    // constructor
    constructor(){
        owner = msg.sender;
        totalPayments = 0;
    }

    // MODIFIERS
    // only owner
    modifier onlyOwner(){
        require(msg.sender == owner,"Owner accessable");
        _;
    }

    // FUNCTIONS
    // Execute functions
    
    // Set owner #onlyOwner
    function setOwner(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    // add user #nonExsisting
    function addUser(string calldata name,string calldata lastname) external {
        require(!isUser(msg.sender), "User Exists");
        users[msg.sender] = User(msg.sender,name,lastname,0,0,0,0);

        emit UserAdded(msg.sender, users[msg.sender].name, users[msg.sender].lastname);
    }

    // add car #onlyOwner #nonExisitingUser
    function addCar(string calldata name,string calldata imgUrl,uint rent,uint sale) external onlyOwner {
        _counter.increment();
        uint counter = _counter.current();
        cars[counter] = Car(counter,name,imgUrl,Status.Available,rent,sale);
        
        emit CarAdded(counter, cars[counter].name, cars[counter].imgUrl, cars[counter].rentFee, cars[counter].saleFee);
    }


    // Edit car meta data #Only owner  #Exisiting user
    function editCarMetadata(uint id , string calldata name,string calldata imgUrl,uint rentFee,uint saleFee) external onlyOwner{
        require(cars[id].id != 0, "Car not exixst");
        Car storage car = cars[id];

        if(bytes(name).length != 0){
            car.name = name;
        }

        if(bytes(imgUrl).length != 0){
            car.imgUrl = imgUrl;
        }

        if(rentFee > 0 ){
            car.rentFee = rentFee;
        }

        if(saleFee > 0){
            car.saleFee = saleFee;
        }

        emit CarMetadataEdited(car.id, car.name, car.imgUrl, car.rentFee, car.saleFee);
    }

    // edit car status #onlyOwner #Exisiting car
    function editCarStatus(uint id,Status status) external onlyOwner { 
        require(cars[id].id != 0,"Car not exist");
        cars[id].status = status;

        emit CarStatusEdited(cars[id].id, cars[id].status);
    }

    // Check out #ExisitingUser #ExisitingCar #isCarAvailable #userHasnotRentedacar #userHasNoDebt
    function checkOut(uint id) external {
        require(isUser(msg.sender),"User does not exist");
        require(cars[id].status == Status.Available,"Car is not Available for use");
        require(users[msg.sender].rentedCarId == 0,"User has already rented a car");
        require(users[msg.sender].debt == 0 ,"User has outstanding debt");

        users[msg.sender].start = block.timestamp;
        users[msg.sender].rentedCarId = id;
        cars[id].status = Status.InUse;

        emit ChechOut(msg.sender, id);
    }

    // CheckIn #exisitingUser #userHasRentedACar
    function checkIn() external{
        require(isUser(msg.sender),"User does not exist");
        uint rentedCarId = users[msg.sender].rentedCarId; 
        require(rentedCarId != 0, "User has not rented a car");

        uint usedSeconds = block.timestamp - users[msg.sender].start;
        uint rentFee = cars[rentedCarId].rentFee;
        users[msg.sender].debt += calculateDebt(usedSeconds,rentFee);

        users[msg.sender].rentedCarId = 0;
        users[msg.sender].start = 0;
        cars[rentedCarId].status = Status.Available;

        emit ChechIn(msg.sender, rentedCarId);
    }

    // Deposit #exisiting user
    function deposit() external payable {
        require(isUser(msg.sender),"User does not exist");
        users[msg.sender].balance += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    // makePayment #exisitingUser #exisitingDebt #sufficientBalance
    function makePayment() external {
        require(isUser(msg.sender),"User does not exist");

        uint debt = users[msg.sender].debt;
        uint balance = users[msg.sender].balance;

        require(debt > 0 ,"User has no debt to pay");
        require(balance >= debt , "User has insufficient balance");

        unchecked {
            users[msg.sender].balance -= debt;
        }

        totalPayments += debt;
        users[msg.sender].debt = 0;

        emit PaymentMade(msg.sender, debt);
    }

    // withDraw balance #Exisiting user
    function withDrawBalance(uint amount) external nonReentrant {
        require(isUser(msg.sender),"User does not exist");
        uint balance = users[msg.sender].balance;
        require(balance >= amount,"Insufficent balance");

        unchecked {
            users[msg.sender].balance -=amount;
        }

        (bool success, ) = msg.sender.call{value : amount}("");
        require(success , "Transaction failed");
        

        emit BalanceWithdrawn(msg.sender, amount);
    }

    // withDrawOwner Balance
    function withdrawOwnerBalance(uint amount) external onlyOwner {
        require(totalPayments >= amount,"Insufficient contract balance");

        (bool success, ) = owner.call{value : amount}("");

        require(success , "Transaction failed");

        unchecked {
            totalPayments -=amount;
        }
    }

    // QueryFunctions

    // getOwner
    function getOwner() external view returns(address){
        return owner;
    }

    // isUser

    function isUser(address walletAddress) private   view returns(bool){
        return users[walletAddress].walletAddress != address(0);
    }

    // getUser #Exsisting User
    function getUser(address walletAddress) external view returns(User memory){
        require(isUser(walletAddress),"User does not exist");
        return users[walletAddress];
    }

    // getCar #Exsisting car
    function getCar(uint id) external view returns(Car memory){
        require(cars[id].id != 0 ,"Car does not exist");
        return cars[id];
    }

    // getCarByStatus
    function getCarsByStatus(Status _status) external view returns(Car[] memory){
        uint count = 0;
        uint length = _counter.current();

        for(uint i=1;i <= length;i++){
            if(cars[i].status == _status){
                count++;
            }
        }
        Car[] memory carsWithStatus = new Car[](count);

        count = 0;
        for(uint i=1;i <= length;i++){
            if(cars[i].status == _status){
                carsWithStatus[count++] = cars[i];
            }
        }


        return carsWithStatus;
    }

    // CalculateDebt
    function calculateDebt(uint usedSeconds,uint rentFee) public pure returns(uint amount){
        uint usedMinutes = usedSeconds / 60;
        return usedMinutes * rentFee;
    }

    // GetCurrentCount 
    function getCurrentCount() external view returns(uint){
        return _counter.current();
    }

    // getContractBalance #onlyOwner
    function getContractBalance() external view onlyOwner returns(uint){
        return address(this).balance;
    }

    // getTotalPayment #onlyOwner
    function getTotalPayment() external view onlyOwner returns(uint){
        return totalPayments;
    }


}


