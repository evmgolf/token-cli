// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

enum TokenType {
  NotContract,
  Unknown,
  ERC20,
  ERC721,
  ERC1155
}

interface ERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

library Classify {
  bytes4 constant ERC721InterfaceId = 0x80ac58cd;
  bytes4 constant ERC721MetadataInterfaceId = 0x5b5e139f;
  bytes4 constant ERC1155InterfaceId = 0xd9b67a26;
  bytes4 constant ERC1155MetadataURIInterfaceId = 0x0e89341c;

  function decodeTokenType(bytes32 hash) internal pure returns (TokenType) {
    if (hash == keccak256(abi.encode("NotContract"))) {
      return TokenType.NotContract;
    } else if (hash == keccak256(abi.encode("Unknown"))) {
      return TokenType.Unknown;
    } else if (hash == keccak256(abi.encode("ERC20"))) {
      return TokenType.ERC20;
    } else if (hash == keccak256(abi.encode("ERC721"))) {
      return TokenType.ERC721;
    } else if (hash == keccak256(abi.encode("ERC1155"))) {
      return TokenType.ERC1155;
    } else {
      revert("Unknown type");
    }
  }

  function isERC721Metadata(address token) internal view returns (bool) {
    return ERC165(token).supportsInterface(ERC721MetadataInterfaceId);
  }

  function isERC1155MetadataURI(address token) internal view returns (bool) {
    return ERC165(token).supportsInterface(ERC1155MetadataURIInterfaceId);
  }

  function classifyERC165(address token) internal view returns (TokenType) {
    if (ERC165(token).supportsInterface(ERC721InterfaceId)) {
      return TokenType.ERC721;
    } else if (ERC165(token).supportsInterface(ERC1155InterfaceId)) {
      return TokenType.ERC1155;
    } else if (token.code.length > 0){
      return TokenType.Unknown;
    } else {
      return TokenType.NotContract;
    }
  }

  function supportsERC165(address token) internal view returns (bool doesSupport) {
    bool callSucceeded;
    bytes memory callData = hex"01ffc9a701ffc9a700000000000000000000000000000000000000000000000000000000";
    bytes memory callResult = new bytes(32);
    assembly {
      callSucceeded := staticcall(30000, token, add(callData, 0x20), 0x24, add(callResult, 0x20), 0x20)
    }
    doesSupport = callSucceeded && abi.decode(callResult, (bool));
    if (doesSupport) {
      callData = hex"01ffc9a7ffffffff00000000000000000000000000000000000000000000000000000000";
      assembly {
        callSucceeded := staticcall(30000, token, add(callData, 0x20), 0x24, add(callResult, 0x20), 0x20)
      }
      doesSupport = callSucceeded && !(abi.decode(callResult, (bool)));
    }
  }

  function classify(address token) internal view returns (TokenType) {
    if (supportsERC165(token)) {
      return classifyERC165(token);
    } else if (token.code.length > 0){
      return TokenType.Unknown;
    } else {
      return TokenType.NotContract;
    }
  }
}
