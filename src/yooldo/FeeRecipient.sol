// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeeRecipient {

    // Event to emit when Ether is received
    event Received(address sender, uint amount);

    // Fallback function to accept Ether when no data is sent
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Receive function to accept Ether when calldata is empty
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}