// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library ContractUtils {
    // Función para validar si una dirección es válida o no
    function isValidAddress(address _address) internal pure returns (bool) {
        return _address != address(0);
    }

    // Función que valida si un string no está vacío
    function isNonEmptyString(string memory _input) internal pure returns (bool) {
        return bytes(_input).length > 0;
    }

    // Función para calcular un valor aleatorio a partir de un bloque
    function randomFromBlock(address _user) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number, _user)));
    }
}
