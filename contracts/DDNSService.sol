pragma solidity ^0.5.0;

import "./common/Ownable.sol";
import "./common/Destructible.sol";
import "./libs/SafeMath.sol";

contract DDNSService is Destructible {

    /** USINGS */
    using SafeMath for uint256;

    /** CONSTANTS */
    uint constant public DOMAIN_NAME_COST = .01 ether;
    uint constant public DOMAIN_NAME_COST_SHORT_ADDITION = .01 ether;
    uint constant public DOMAIN_EXPIRATION_DATE = 365 days;
    uint8 constant public DOMAIN_NAME_MIN_LENGTH = 5;
    uint8 constant public DOMAIN_NAME_EXPENSIVE_LENGTH = 8;
    uint8 constant public TOP_LEVEL_DOMAIN_MIN_LENGTH = 1;
    bytes1 constant public BYTES_DEFAULT_VALUE = bytes1(0x00);

    struct DomainDetails {
        bytes name;
        bytes12 topLevel;
        address owner;
        bytes15 ip;
        uint expires;
    }

    struct Receipt {
        uint amountPaidWei;
        uint timestamp;
        uint expires;
    }

    modifier isAvailable(bytes memory domain, bytes12 topLevel) {
        // @dev - get the domain hash by the domain name and the TLD
        bytes32 domainHash = getDomainHash(domain, topLevel);
        
        // @dev - check whether the domain name is available by checking if it is expired
        // if it was not registered at all the `expires` property will be default: 0x00
        require(
            domainNames[domainHash].expires < block.timestamp,
            "Domain name is not available."
        );
        
        // continue with execution
        _;
    }

    modifier collectDomainNamePayment(bytes memory domain) {
        // @dev - get the price for the provided domain
        uint domainPrice = getPrice(domain);

        // @dev - require the payment sent to be enough for
        // the current domain cost
        require(
            msg.value >= domainPrice,
            "Insufficient amount."
        );
        
        // continue execution
        _;
    }


    modifier isDomainOwner(bytes memory domain, bytes12 topLevel) {
        // @dev - get the hash of the domain with the provided TLD.
        bytes32 domainHash = getDomainHash(domain, topLevel);
        
        // @dev - check whether the msg.sender is the owner of the domain name
        require(
            domainNames[domainHash].owner == msg.sender,
            "You are not the owner of this domain."
            );
        
        // continue with execution
        _;
    }


    modifier isDomainNameLengthAllowed(bytes memory domain) {
        // @dev - check if the provided domain is with allowed length
        require(
            domain.length >= DOMAIN_NAME_MIN_LENGTH,
            "Domain name is too short."
        );

        // continue with execution
        _;
    }


    modifier isTopLevelLengthAllowed(bytes12 topLevel) {
  
        // @dev - require the TLD lenght to be equal or greater
        // than `TOP_LEVEL_DOMAIN_MIN_LENGTH` constant
        require(
            topLevel.length >= TOP_LEVEL_DOMAIN_MIN_LENGTH,
            "The provided TLD is too short."
        );
        
        // continue with execution
        _;
    }

    /**
     * @dev - Constructor of the contract
     */
    constructor() public {
        
    }


}