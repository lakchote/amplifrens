// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AmpliFrensProfile
 * @author Lucien Akchoté
 *
 * @notice Handles profile operations for AmpliFrens
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensProfile is AccessControl {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
