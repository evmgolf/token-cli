// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;
import {TokenType, Classify} from "./Classify.sol";
import {Decimal} from "codec/Decimal.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {JSON} from "codec/JSON.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";

library View {
  using Decimal for uint;
  using Hexadecimal for address;

  function revertEmpty(address token) internal view {
    revert(string(bytes.concat("NO_CODE: ", token.hexadecimal())));
  }

  function viewERC20(address token) internal view returns (bytes memory) {
    bytes[] memory keys = new bytes[](3);
    bytes[] memory values = new bytes[](3);
    keys[0] = "name";
    keys[1] = "symbol";
    keys[2] = "totalSupply";
    values[0] = JSON.encode(ERC20(token).name());
    values[1] = JSON.encode(ERC20(token).symbol());
    values[2] = JSON.encode(ERC20(token).totalSupply());
    return JSON.encode(keys, values);
  }

  function viewERC721(address token) internal view returns (bytes memory text) {
    bytes[] memory keys;
    bytes[] memory values;
    if (Classify.isERC721Metadata(token)) {
      keys = new bytes[](2);
      values = new bytes[](2);
      keys[0] = "name";
      keys[1] = "symbol";
      values[0] = JSON.encode(ERC721(token).name());
      values[1] = JSON.encode(ERC721(token).symbol());
    }
    return JSON.encode(keys, values);
  }

  function viewERC721(address token, address owner) internal view returns (bytes memory) {
    bytes[] memory keys = new bytes[](1);
    bytes[] memory values = new bytes[](1);
    keys[0] = bytes.concat(
      "balanceOf(",
      owner.hexadecimal(),
      ")"
    );
    values[0] = JSON.encode(ERC721(token).balanceOf(owner));
    return JSON.encode(keys, values);
  }

  function viewERC721(address token, uint id) internal view returns (bytes memory) {
    bytes[] memory keys = new bytes[](2);
    bytes[] memory values = new bytes[](2);
    keys[0] = bytes.concat(
      "ownerOf(",
      id.decimal(),
      ")"
    );
    keys[1] = bytes.concat(
      "tokenURI(",
      id.decimal(),
      ")"
    );
    values[0] = JSON.encode(ERC721(token).ownerOf(id));
    values[1] = JSON.encode(ERC721(token).tokenURI(id));
    return JSON.encode(keys, values);
  }

  function viewERC1155(address token, uint id) internal view returns (bytes memory) {
    bytes[] memory keys = new bytes[](1);
    bytes[] memory values = new bytes[](1);
    keys[0] = bytes.concat(
      "uri(",
      id.decimal(),
      ")"
    );
    values[0] = JSON.encode(ERC1155(token).uri(id));
    return JSON.encode(keys, values);
  }

  function viewToken(address token, TokenType tokenType, uint id) internal view returns (bytes memory) {
    if (tokenType == TokenType.ERC721) {
      return viewERC721(token, id);
    } else if (tokenType == TokenType.ERC1155) {
      return viewERC1155(token, id);
    } else {
      revert("invalid type");
    }
  }

  function viewToken(address token, TokenType tokenType, address owner) internal view returns (bytes memory) {
    if (tokenType == TokenType.NotContract) {
      return JSON.encode();
    } else {
      if (token.code.length == 0) {
        revertEmpty(token);
      } else {
        if (tokenType == TokenType.ERC20) {
          return viewERC20(token);
        } else if (tokenType == TokenType.ERC721) {
          return viewERC721(token, owner);
        } else if (tokenType == TokenType.ERC1155) {
          return JSON.encode();
        } else {
          return JSON.encode();
        }
      }
    }
  }

  function viewToken(address token) internal view returns (bytes memory) {
    return viewToken(token, Classify.classify(token), address(0));
  }
}
