/*
This smart contract facilitates energy trading on the TRON network by enabling users to create, fulfill, 
and cancel energy trade offers. 
It handles the transfer of TRX from buyers to sellers as part of the transaction, 
while the actual transfer of energy between parties should be managed through the frontend application.
*/
// SPDX-License-Identifier: Aziz Ahmed
pragma solidity >=0.5.0 <0.9;

contract TronEnergyMarket {
    // logging offer creation details
    event OfferCreated(
        uint256 indexed offerId,
        address indexed seller,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );
    
    // logging offer fulfillment details
    event OfferFulfilled(
        uint256 indexed offerId,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 totalPrice,
        uint256 timestamp
    );
    
    // logging offer cancelation details
    event OfferCancelled(
        uint256 indexed offerId,
        address indexed seller,
        uint256 timestamp
    );

    // logging if offer fulfillment fails
    event OfferFulfillmentFailed(
        uint256 offerId, 
        address buyer, 
        uint256 amount, 
        string reason
        );

    struct Offer {
        address seller;
        uint256 amount;
        uint256 price; // Price per unit of energy in TRX
        bool isActive;
    }
    
    mapping(uint256 => Offer) public offers; // Mapping with offerId and the Offer
    mapping(address => uint256[]) public sellerOffers; // Contains the addresses of the sellers who created an offer for reporting purpose
    mapping(address => uint256[]) public buyerOffers; // Contains the addresses of the buyers who fulfilled an offer for reporting purpose

    uint256 public nextOfferId = 1; // offerId starts from 1

    modifier onlySeller(uint256 offerId) {
        require(offers[offerId].seller == msg.sender, "You are not the seller of this offer");
        _;
    }

    modifier offerExists(uint256 offerId) {
        require(offers[offerId].seller != address(0), "Offer does not exist");
        _;
    }

    modifier isActiveOffer(uint256 offerId) {
        require(offers[offerId].isActive, "Offer is not active");
        _;
    }

    function createOffer(uint256 amount, uint256 priceInTrx) external {
        require(amount > 0, "Amount must be greater than 0");
        require(priceInTrx > 0, "Price must be greater than 0");

        uint256 offerId = nextOfferId;
        // create the Offer struct
        Offer memory newOffer;
        newOffer.seller = msg.sender;
        newOffer.amount = amount;
        newOffer.price = priceInTrx;
        newOffer.isActive = true;

        // Assign the struct to the mapping
        offers[offerId] = newOffer;

        sellerOffers[msg.sender].push(offerId);
        nextOfferId++;

        emit OfferCreated(offerId, msg.sender, amount, priceInTrx, block.timestamp);
    }

    function cancelOffer(uint256 offerId) external offerExists(offerId) isActiveOffer(offerId) onlySeller(offerId) {
        offers[offerId].isActive = false;
        emit OfferCancelled(offerId, msg.sender, block.timestamp);
    }

    function fulfillOffer(uint256 offerId) external payable offerExists(offerId) isActiveOffer(offerId) {
        Offer storage offer = offers[offerId];
        uint256 totalPriceInSun = offer.amount * offer.price * 1e6; // Convert TRX to SUN

        require(msg.sender != offer.seller, "Seller cannot fulfill their own offer");

        if (msg.value < totalPriceInSun) {
        emit OfferFulfillmentFailed(offerId, msg.sender, msg.value, "Insufficient TRX sent");
        revert("Insufficient TRX sent");
        }

        // 1 Update the state first
        offers[offerId].isActive = false;
        buyerOffers[msg.sender].push(offerId);
        
        // 2 Then transfer the TRX
        (bool sent, ) = payable(offer.seller).call{value: msg.value}("");
        require(sent, "Failed to transfer funds to the seller");

        emit OfferFulfilled(offerId, msg.sender, offer.seller, offer.amount, offer.price, block.timestamp);
    }

    function getActiveOffers() external view returns (uint256[] memory) {
        uint256[] memory activeOffers = new uint256[](nextOfferId);
        uint256 counter = 0;

        for (uint256 i = 1; i < nextOfferId; i++) { // Start from 1 since offerId 0 is not used
            if (offers[i].isActive) {
                activeOffers[counter] = i;
                counter++;
            }
        }

        // Resize the array to remove unused elements
        assembly {
            mstore(activeOffers, counter)
        }

        return activeOffers;
    }

    function getSellerOffers() external view returns (uint256[] memory) {
        return sellerOffers[msg.sender];
    }

    function getBuyerOffers() external view returns (uint256[] memory) {
        return buyerOffers[msg.sender];
    }
}
