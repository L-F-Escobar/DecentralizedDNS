// https://hack.bg/blog/tutorials/part-one-smart-contracts-build-a-decentralized-domain-name-system-ddns-on-top-of-ethereum/
pragma solidity ^0.5.0;

import "./common/Ownable.sol";
import "./common/Destructible.sol";
import "./libs/SafeMath.sol";

contract DDNSService is Destructible {

    /** USINGS */
    using SafeMath for uint256;

    /** CONSTANTS */
    uint constant public DOMAIN_NAME_COST = .01 ether;
    uint constant public DOMAIN_NAME_COST_SHORT_ADDITION = .02 ether;
    uint constant public DOMAIN_EXPIRATION_DATE = 365 days;
    uint8 constant public DOMAIN_NAME_MIN_LENGTH = 5;
    uint8 constant public DOMAIN_NAME_EXPENSIVE_LENGTH = 8;
    uint8 constant public TOP_LEVEL_DOMAIN_MIN_LENGTH = 1;
    bytes1 constant public BYTES_DEFAULT_VALUE = bytes1(0x00);

    /** STATE VARIABLES */

    // @dev - storing the DomainHash (bytes32) to its details
    mapping (bytes32 => DomainDetails) public domainNames;

    // @dev - all the receipt hashes/keys/ids for certain address 
    mapping(address => bytes32[]) public paymentReceipts;

    // @dev - the details for a receipt by its hash/key/id
    mapping(bytes32 => Receipt) public receiptDetails;

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

    /** EVENTS */

    event LogDomainNameRegistered(
        uint indexed timestamp, 
        bytes domainName, 
        bytes12 topLevel
    );

    event LogDomainNameRenewed(
        uint indexed timestamp, 
        bytes domainName, 
        bytes12 topLevel, 
        address indexed owner
    ); 

    event LogDomainNameEdited(
        uint indexed timestamp, 
        bytes domainName, 
        bytes12 topLevel, 
        bytes15 newIp
    ); 

    event LogDomainNameTransferred(
        uint indexed timestamp, 
        bytes domainName, 
        bytes12 topLevel, 
        address indexed owner, 
        address newOwner
    );

    event LogPurchaseChangeReturned(
        uint indexed timestamp, 
        address indexed _owner, 
        uint amount
    );

    event LogReceipt(
        uint indexed timestamp, 
        bytes domainName, 
        uint amountInWei, 
        uint expires
    );

    /** MODIFIERS */

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


    /** FUNCTIONS */

    /*
        @dev - Get (domain name + top level) hash used for unique identifier 
        @param domain
        @param topLevel
        @return domainHash
    */
    function getDomainHash(bytes memory domain, bytes12 topLevel) public pure returns(bytes32) {
        // @dev - tightly pack parameters in struct for keccak256
        return keccak256(abi.encodePacked(domain, topLevel));
    } 


    /*
     * @dev - Get recepit key hash - unique identifier
     * @param domain
     * @param topLevel
     * @return receiptKey
     */
    function getReceiptKey(bytes memory domain, bytes12 topLevel) public view returns(bytes32) {
        // @dev - tightly pack parameters in struct for keccak256
        return keccak256(abi.encodePacked(domain, topLevel, msg.sender, block.timestamp));
    }    


    /*
     * @dev - Get price of domain
     * @param domain
     */
    function getPrice(bytes memory domain) public pure returns (uint) 
    {
        // check if the domain name fits in the expensive or cheap categroy
        if (domain.length < DOMAIN_NAME_EXPENSIVE_LENGTH) {
        
            // if the domain is too short - its more expensive
            return DOMAIN_NAME_COST + DOMAIN_NAME_COST_SHORT_ADDITION;
        }
        // otherwise return the regular price
        return DOMAIN_NAME_COST;
    }   


    /*
     * @dev - function to register domain name
     * @param domain - domain name to be registered
     * @param topLevel - domain top level (TLD)
     * @param ip - the ip of the host
     */
    function register(bytes memory domain, bytes12 topLevel, bytes15 ip) 
        public
        payable 
        isDomainNameLengthAllowed(domain) 
        isTopLevelLengthAllowed(topLevel) 
        isAvailable(domain, topLevel) 
        collectDomainNamePayment(domain) 
    {
        // calculate the domain hash
        bytes32 domainHash = getDomainHash(domain, topLevel);

        // create a new domain entry with the provided fn parameters
        DomainDetails memory newDomain = DomainDetails(
            {
                name: domain,
                topLevel: topLevel,
                owner: msg.sender,
                ip: ip,
                expires: block.timestamp + DOMAIN_EXPIRATION_DATE
            }
        );

        // save the domain to the storage
        domainNames[domainHash] = newDomain;
        
        // create an receipt entry for this domain purchase
        Receipt memory newReceipt = Receipt(
            {
                amountPaidWei: DOMAIN_NAME_COST,
                timestamp: block.timestamp,
                expires: block.timestamp + DOMAIN_EXPIRATION_DATE
            }
        );

        // calculate the receipt hash/key
        bytes32 receiptKey = getReceiptKey(domain, topLevel);
        
        // save the receipt key for this `msg.sender` in storage
        paymentReceipts[msg.sender].push(receiptKey);
        
        // save the receipt entry/details in storage
        receiptDetails[receiptKey] = newReceipt;

        // log receipt issuance
        emit LogReceipt(
            block.timestamp, 
            domain, 
            DOMAIN_NAME_COST, 
            block.timestamp + DOMAIN_EXPIRATION_DATE
        );
    
        // log domain name registered
        emit LogDomainNameRegistered(
            block.timestamp, 
            domain, 
            topLevel
        );
}


}