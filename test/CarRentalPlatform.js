const CarRentalPlatform = artifacts.require("CarRentalPlatform");

contract("CarRentalPlatform" , accounts =>{
    let carRentalPlatform;
    const owner = accounts[0];
    const user1 = accounts[1];

    beforeEach(async () =>{
        carRentalPlatform = await CarRentalPlatform.new();
    });

    describe("Add user and car",() =>{
        it("adds a new user" , async () =>{
            await carRentalPlatform.addUser("Alica" , "Smith",{from : user1});
            const user = carRentalPlatform.getUser(user1);
            assert.equal(user.name , "Alice","Problem with user name");
            assert.equal(user.lastname,"Smith","Problem with user last name");
        });

        it("adds a car" , async () =>{
            await carRentalPlatform.addCar("Tesla Model S","example URL",10,50000,{from : owner});
            const car = await carRentalPlatform.getCar(1);
            assert.equal(car.name , "Tesla Model S" , "Problem with car name");
            assert.equal(car.imgUrl , "example url", "Problem with URL");
            assert.equal(car.rentFee , 10, "Problem with rent fee");
            assert.equal(car.saleFee,50000,"Problem with sale fee");
        })
    })

})