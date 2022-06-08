// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;
import {TokenType, Classify} from "./Classify.sol";
import {Decimal} from "codec/Decimal.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";

library View {
  using Decimal for uint;
  using Hexadecimal for address;

  function viewAddress(address token) internal view returns (bytes memory) {
    return token.hexadecimal();
  }

  function revertEmpty(address token) internal view {
    revert(string(bytes.concat("NO_CODE: ", token.hexadecimal())));
  }

  function viewContract(address token) internal view returns (bytes memory) {
    return bytes.concat(bytes(viewAddress(token)), " [Unknown]");
  }

  function viewERC20(address token) internal view returns (bytes memory) {
    return bytes.concat(
      viewAddress(token),
      " [ERC20]\n",
      bytes(ERC20(token).name()),
      " - $",
      bytes(ERC20(token).symbol()),
      "\n  ",
      "totalSupply: ",
      ERC20(token).totalSupply().decimal()
    );
  }

  function viewERC721(address token) internal view returns (bytes memory text) {
    text = bytes.concat(bytes(viewAddress(token)), " [ERC721]");
    if (Classify.isERC721Metadata(token)) {
      text = bytes.concat(
        text,
        "\n",
        bytes(ERC721(token).name()),
        " - $",
        bytes(ERC721(token).symbol())
      );
    }
  }

  function viewERC721(address token, address owner) internal view returns (bytes memory) {
    return bytes.concat(
        viewERC721(token),
        "\nbalanceOf(",
        owner.hexadecimal(),
        "): ",
        ERC721(token).balanceOf(owner).decimal()
    );
  }

  function viewERC721(address token, uint id) internal view returns (bytes memory) {
    return bytes.concat(
      "$",
      bytes(ERC721(token).symbol()),
      ":",
      id.decimal(),
      "\nownerOf: ",
      ERC721(token).ownerOf(id).hexadecimal(),
      "\ntokenURI: ",
      bytes(ERC721(token).tokenURI(id))
    );
  }

  function viewERC1155(address token) internal view returns (bytes memory) {
    return bytes.concat(bytes(viewAddress(token)), " [ERC1155]");
  }


  function viewERC1155(address token, uint id) internal view returns (bytes memory) {
    return bytes.concat(
      viewERC1155(token),
      ":",
      id.decimal(),
      "\nuri: ",
      bytes(ERC1155(token).uri(id))
    );
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
      return viewAddress(token);
    } else {
      if (token.code.length == 0) {
        revertEmpty(token);
      } else {
        if (tokenType == TokenType.ERC20) {
          return viewERC20(token);
        } else if (tokenType == TokenType.ERC721) {
          return viewERC721(token, owner);
        } else if (tokenType == TokenType.ERC1155) {
          return viewERC1155(token);
        } else {
          return viewContract(token);
        }
      }
    }
  }

  function viewToken(address token) internal view returns (bytes memory) {
    return viewToken(token, Classify.classify(token), address(0));
  }
}
