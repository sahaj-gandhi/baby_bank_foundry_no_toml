// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IModule {
    function isInitialized(address smartAccount) external view returns (bool);
    function onInstall(bytes calldata data) external;
    function onUninstall(bytes calldata data) external;
    function executeFromModule(bytes calldata data) external returns (bytes memory);
}

contract baby_module is IModule {
    mapping(address => mapping(address => bool)) private _isAuthorized;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IModule).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function isInitialized(address smartAccount) external view override returns (bool) {
        // For simplicity, we'll consider it initialized if the smart account has any authorizations
        return _isAuthorized[smartAccount][msg.sender];
    }

    function onInstall(bytes calldata data) external override {
        address owner = abi.decode(data, (address));
        _isAuthorized[msg.sender][owner] = true;
    }

    function onUninstall(bytes calldata) external override {
        // Clear all authorizations for the smart account
        address smartAccount = msg.sender;
        address[] memory authorizedAddresses = getAuthorizedAddresses(smartAccount);
        for (uint256 i = 0; i < authorizedAddresses.length; i++) {
            _isAuthorized[smartAccount][authorizedAddresses[i]] = false;
        }
    }

    function executeFromModule(bytes calldata data) external override returns (bytes memory) {
        (address target, bytes memory callData) = abi.decode(data, (address, bytes));
        require(_isAuthorized[msg.sender][tx.origin], "Not authorized");

        (bool success, bytes memory result) = target.call(callData);
        require(success, "Call failed");

        return result;
    }

    // Additional helper functions
    function authorize(address account) external {
        _isAuthorized[msg.sender][account] = true;
    }

    function revoke(address account) external {
        _isAuthorized[msg.sender][account] = false;
    }

    function isAuthorized(address smartAccount, address account) external view returns (bool) {
        return _isAuthorized[smartAccount][account];
    }

    function getAuthorizedAddresses(address smartAccount) public view returns (address[] memory) {
        uint256 count = 0;
        address[] memory temp = new address[](100); // Arbitrary limit

        for (uint256 i = 0; i < temp.length; i++) {
            if (_isAuthorized[smartAccount][temp[i]]) {
                temp[count] = temp[i];
                count++;
            }
        }

        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = temp[i];
        }

        return result;
    }
}
