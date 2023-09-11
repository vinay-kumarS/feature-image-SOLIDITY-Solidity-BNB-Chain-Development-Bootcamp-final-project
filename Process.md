1. Install all nessesary packages like truffle and ganache
2. Create a test net in meta mask
3. Request free bnb tokens in testnet.bnbchain.org
4. After that follow process in docs of truffle
5. Then starter files will automatically created
6. Start doing project.



# Logical part

1. Bare Bones of project

    // Data

    // Counter

    // Owner

    // total payments

    // user struct

    // car struct

    // enum to indidcate status of the car

    // events

    // user mapping

    // car mapping

    // constructor

    // MODIFIERS
    // only owner

    // FUNCTIONS
    // Execute functions
    
    // Set owner #onlyOwner

    // add user #nonExsisting

    // add car #onlyOwner #nonExisitingUser

    // Edit car meta data #Only owner  #Exisiting user

    // edit car status #onlyOwner #Exisiting car

    // Check out #Exisiting user #Exisiting car #isCarAvailable #userHasnotRentedacar #userHasNoDebt

    // CheckIn #exisitingUser #userHasRentedACar

    // Deposit #exisiting user

    // makePayment #exisitingUser #exisitingDebt #sufficientBalance

    // withDraw balance #onlyOwner

    // QueryFunctions

    // getOwner

    // isUser

    // getUser #Exsisting User

    // getCar #Exsisting car

    // getCarByStatus

    // CalculateDebt

    // Get current count 

    // get Contract balance #onlyOwner

    // get total payment #onlyOwner


2. install using npm @openzappling/contract
