// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;
import {TokenType, Classify} from "./Classify.sol";
import {Decimal} from "codec/Decimal.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";

enum ReturnType {
  String,
  Address,
  Uint
}

library Call {
  using Decimal for uint;
  using Hexadecimal for address;

  function decodeReturnType(bytes32 hash) internal pure returns (ReturnType) {
    if (hash == keccak256(abi.encode("string"))) {
      return ReturnType.String;
    } else if (hash == keccak256(abi.encode("address"))) {
      return ReturnType.Address;
    } else if (hash == keccak256(abi.encode("uint"))) {
      return ReturnType.Uint;
    } else {
      revert("Unknown ReturnType");
    }
  }

  function callFunction(address token, bytes4 selector, ReturnType returnType) internal view returns (string memory) {
    bytes memory result;
    bytes memory input = abi.encodeWithSelector(selector);
    assembly {
      let status := staticcall(
        gas(),
        token,
        add(input, 0x20),
        mload(input),
        0,
        0
      )

      if eq(status, 1) {
        let size := returndatasize()
        mstore(result, size)
        returndatacopy(add(result, 0x20), 0, size)
      }
    }

    if (returnType == ReturnType.String) {
      return abi.decode(result, (string));
    } else if (returnType == ReturnType.Address) {
      return string(address(abi.decode(result, (address))).hexadecimal());
    } else if (returnType == ReturnType.Uint) {
      return string(abi.decode(result, (uint)).decimal());
    } else {
      revert("Unknown ReturnType");
    }
  }
}
