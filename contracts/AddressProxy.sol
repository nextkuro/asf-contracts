pragma solidity ^0.4.19;

/**
@title AddressProxy contract
@author App Store Foundation
@dev This contract works as part of a set of mechanisms in order to maintain tracking of the latest
version's contracts deployed to the network.
 */

contract AddressProxy {

    struct ContractAddress {
        bytes32 id;
        string name;
        address at;
        uint createdTime;
        uint updatedTime;
    }

    address public owner;
    mapping(bytes32 => ContractAddress) private contractsAddress;
    bytes32[] public availableIds;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event AddressCreated(bytes32 id, string name, address at, uint createdTime, uint updatedTime);
    event AddressUpdated(bytes32 id, string name, address at, uint createdTime, uint updatedTime);

    function AddressProxy() public {
        owner = msg.sender;
    }


    /**
    @notice Get all avaliable ids registered on the contract
    @dev Just shows the list of ids registerd on the contract
    @return { "Id List" : "List of registered ids" }
     */
    function getAvailableIds() public view returns (bytes32[]) {
        return availableIds;
    }

    /** 
    @notice  Adds or updates an address
    @dev Used when a new address needs to be updated to a currently registered id or to a new id.
    @param name Name of the contract
    @param newAddress Address of the contract
    */
    function addAddress(string name, address newAddress) public onlyOwner {
        bytes32 contAddId = stringToBytes32(name);

        uint nowInMilliseconds = now * 1000;

        if (contractsAddress[contAddId].id == 0x0) {
            ContractAddress memory newContractAddress;
            newContractAddress.id = contAddId;
            newContractAddress.name = name;
            newContractAddress.at = newAddress;
            newContractAddress.createdTime = nowInMilliseconds;
            newContractAddress.updatedTime = nowInMilliseconds;
            availableIds.push(contAddId);
            contractsAddress[contAddId] = newContractAddress;

            emit AddressCreated(newContractAddress.id, newContractAddress.name, newContractAddress.at, newContractAddress.createdTime, newContractAddress.updatedTime);
        } else {
            ContractAddress storage contAdd = contractsAddress[contAddId];
            contAdd.at = newAddress;
            contAdd.updatedTime = nowInMilliseconds;

            emit AddressUpdated(contAdd.id, contAdd.name, contAdd.at, contAdd.createdTime, contAdd.updatedTime);
        }
    }

    /**
    @notice Get the contract name associated to a certain id
    @param id Id of the registry
    @return { 'name' : 'Name of the contract associated to the given id' }
     */
    function getContractNameById(bytes32 id) public view returns(string) {
        return contractsAddress[id].name;
    }


    /**
    @notice Get the contract address associated to a certain id
    @param id Id of the registry
    @return { 'address' : 'Address of the contract associated to the given id' }
     */
    function getContractAddressById(bytes32 id) public view returns(address) {
        return contractsAddress[id].at;
    }

    /**
    @notice Get the specific date on which the contract address was firstly registered 
    to a certain id
    @param id Id of the registry
    @return { 'time' : 'Time in miliseconds of the first time the given id was registered' }
     */
    function getContractCreatedTimeById(bytes32 id) public view returns(uint) {
        return contractsAddress[id].createdTime;
    }

    /**
    @notice Get the specific date on which the contract address was lastly updated to a certain id
    @param id Id of the registry
    @return { 'time' : 'Time in miliseconds of the last time the given id was updated' }
     */
    function getContractUpdatedTimeById(bytes32 id) public view returns(uint) {
        return contractsAddress[id].updatedTime;
    }

    /**
    @notice Converts a string type variable into a byte32 type variable
    @dev This function is internal and uses inline assembly instructions.
    @param source string to be converted to a byte32 type
    @return { 'result' : 'Initial string content converted to a byte32 type' }
     */
    function stringToBytes32(string source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
