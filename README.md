# TronEnergyMarket - Decentralized Energy Trading on TRON

This project provides a smart contract that facilitates decentralized energy trading on the TRON network. Users can create, fulfill, and cancel energy trade offers directly on the blockchain. The contract handles TRX transfers between buyers and sellers, while the actual transfer of energy resources should be managed via a frontend application.

# Getting Started

Follow these steps to test, deploy, and interact with the TronEnergyMarket smart contract.

1. Prerequisites
   Node.js: Ensure you have Node.js installed. You can download it here.
   TronBox: Install TronBox globally using the command:
   npm install -g tronbox
   TronLink Wallet: Make sure you have the TronLink wallet installed and configured with at least two accounts.
2. Installation
   Install dependencies:
   npm install
3. Testing the Smart Contract
   Compile the smart contract:
   tronbox compile
   Run the local development network:
   tronbox develop
4. Deploy the smart contract:
   tronbox migrate --reset --network development
   Run the tests:
   tronbox test

# To deploy the contract to your local TRON network, follow these steps:

Start the local TRON node:
tronbox develop
Deploy the contract:
tronbox migrate --reset --network development

# Using the Frontend

A simple frontend application is included to interact with some of the smart contract functionalities.

Install Live Server Extension: If using VSCode, install the Live Server Extension.
Open the frontend file:
open frontend/index.html
Start the live server: Click "Go Live" in the bottom right corner of VSCode to start a local server and open the frontend in your browser.
Connect TronLink Wallet: Import your accounts into TronLink and ensure your network is set to the development network.
Interact with the Contract: Use the frontend to create, fulfill, or cancel offers on the TRON blockchain.
Contract Overview
The TronEnergyMarket contract allows users to:

Create Offer: Sellers can list the amount of energy they want to sell and the price per unit in TRX.
Fulfill Offer: Buyers can fulfill offers by sending the required amount of TRX to the seller.
Cancel Offer: Sellers can cancel their active offers.
View Offers: Users can view all active offers or the offers they have created or fulfilled.
Events
The contract emits the following events:

OfferCreated: Emitted when a new offer is created.
OfferFulfilled: Emitted when an offer is successfully fulfilled.
OfferCancelled: Emitted when an offer is canceled by the seller.
OfferFulfillmentFailed: Emitted when an offer fulfillment fails due to insufficient TRX.
