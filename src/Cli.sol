// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {IO} from "prompt/IO.sol";
import {Tokenizer} from "codec/Tokenizer.sol";
import {Decimal} from "codec/Decimal.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {Mixed} from "codec/Mixed.sol";
import {Quote} from "codec/Quote.sol";
import {JSON} from "codec/JSON.sol";
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
  using Quote for bytes;

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
      bytes[] memory values = new bytes[](2);
      values[0] = JSON.encode(string("token [address] - set the current token"));
      values[1] = JSON.encode(string("view {id} - displays information about the token id"));
      return JSON.encode(values).quote("'");
    } else if (words0 == keccak256(bytes("token"))) {
      bytes[] memory keys = new bytes[](3);
      bytes[] memory values = new bytes[](3);
      keys[0] = "token";
      keys[1] = "tokenType";
      keys[2] = "view";
      if (words.length > 1) {
        token = words[1].decodeAddress();
        if (words.length > 2) {
          tokenType = Classify.decodeTokenType(keccak256(words[2]));
        } else {
          tokenType = token.classify();
        }
      }
      values[0] = JSON.encode(token);
      values[1] = JSON.encode(string(Classify.encodeTokenType(tokenType)));
      values[2] = token.viewToken(tokenType, owner);
      return JSON.encode(keys, values).quote("'");
    } else if (words0 == keccak256(bytes("view"))) {
      if (tokenType == TokenType.ERC721 || tokenType == TokenType.ERC1155) {
        uint id = words[1].decodeMixedUint();
        return token.viewToken(tokenType, id).quote("'");
      }
    } else {
      running = false;
      return JSON.encode();
    }
  }
}
