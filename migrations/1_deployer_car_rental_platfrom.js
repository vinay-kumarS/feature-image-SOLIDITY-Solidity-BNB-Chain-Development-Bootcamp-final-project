const { config } = require("dotenv");
const fs = require("fs");
const CarRentalPlatform = artifacts.require("CarRentalPlatform");


module.exports = async function (deployer){
    await deployer.deploy(CarRentalPlatform);

    const instance = await CarRentalPlatform.deployed();

    let CarRentalPlatformAddress =  await instance.address;
    
    let config = "export constr carRentalPlatformAddress = " + CarRentalPlatformAddress;
    console.log("carRentalPlatformAddress = "+CarRentalPlatformAddress);

    let data =  JSON.stringify(config);

    fs.writeFileSync("config.js", JSON.parse(data));
}