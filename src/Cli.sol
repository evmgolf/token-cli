// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {IO} from "prompt/IO.sol";
import {Tokenizer} from "codec/Tokenizer.sol";
import {Decimal} from "codec/Decimal.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {Mixed} from "codec/Mixed.sol";
import {TokenType, Classify} from "./Classify.sol";
import {View} from "./View.sol";
import {ReturnType, Call} from "./Call.sol";

contract Cli is IO {
  using Call for address;
  using View for address;
  using Classify for address;
  using Tokenizer for bytes;
  using Decimal for bytes;
  using Hexadecimal for bytes;
  using Hexadecimal for address;
  using Mixed for bytes;

  address token;
  TokenType tokenType;
  address owner;
  bool ownerSet = false;

  constructor () IO() {}

  function handleInput (bytes memory input) internal override returns (bytes memory) {
    if (!ownerSet) {
      owner = msg.sender;
      ownerSet = true;
    }
    bytes[] memory words = input.split(" ");

    bytes32 words0 = keccak256(words[0]);
    if (words0 == keccak256(bytes("help"))) {
      return bytes.concat(
        "'token [address] - set the current token",
        "\nview {id} - displays information about the token id'"
      );
    } else if (words0 == keccak256(bytes("token"))) {
      if (words.length > 1) {
        token = words[1].decodeAddress();
        if (words.length > 2) {
          tokenType = Classify.decodeTokenType(keccak256(words[2]));
        } else {
          tokenType = token.classify();
        }
      }
      return bytes.concat("'", token.viewToken(tokenType, owner), "'");
    } else if (words0 == keccak256(bytes("view"))) {
      if (tokenType == TokenType.ERC721 || tokenType == TokenType.ERC1155) {
        uint id = words[1].decodeMixedUint();
        return bytes.concat("'", token.viewToken(tokenType, id), "'");
      }
    } else {
      running = false;
      return "";
    }
  }
}
