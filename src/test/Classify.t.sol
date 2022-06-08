// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {TokenType, Classify} from "../Classify.sol";
import {Decimal} from "codec/Decimal.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";

contract SampleERC20 is ERC20 {
  constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {}
}

contract SampleERC721 is ERC721 {
  using Decimal for uint;

  constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

  function tokenURI(uint tokenId) public override view returns (string memory) {
    return string(tokenId.decimal());
  }
}

contract SampleERC1155 is ERC1155 {
  using Decimal for uint;

  constructor() ERC1155() {}

  function uri(uint id) public override view returns (string memory) {
    return string(id.decimal());
  }
}

contract ClassifyTest is Test {
  using Classify for address;

  SampleERC20 erc20;
  SampleERC721 erc721;
  SampleERC1155 erc1155;

  event log_bool(bool);

  function setUp() public {
    erc20 = new SampleERC20("ERC20 Token", "ERC20", 18);
    erc721 = new SampleERC721("ERC721 Token", "ERC721");
    erc1155 = new SampleERC1155();
  }

  function testClassifyNotContract() public {
    assertTrue(!msg.sender.supportsERC165());
    assertEq(uint(msg.sender.classify()), uint(TokenType.NotContract));
  }

  function testClassifyUnknown() public {
    assertTrue(!address(this).supportsERC165());
    assertEq(uint(address(this).classify()), uint(TokenType.Unknown));
  }

  function testClassifyERC20() public {
    assertTrue(!address(erc20).supportsERC165());
    assertEq(uint(address(erc20).classify()), uint(TokenType.Unknown));
  }

  function testClassifyERC721() public {
    assertTrue(address(erc721).supportsERC165());
    assertEq(uint(address(erc721).classify()), uint(TokenType.ERC721));
  }

  function testClassifyERC1155() public {
    assertTrue(address(erc1155).supportsERC165());
    assertEq(uint(address(erc1155).classify()), uint(TokenType.ERC1155));
  }
}
