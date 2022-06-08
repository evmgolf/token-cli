// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {View} from "../View.sol";
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

  function tokenURI(uint id) public override view returns (string memory) {
    return string(id.decimal());
  }
}

contract SampleERC1155 is ERC1155 {
  using Decimal for uint;

  constructor() ERC1155() {}

  function uri(uint id) public override view returns (string memory) {
    return string(id.decimal());
  }
}

contract ViewTest is Test {
  using View for address;
  SampleERC20 erc20;
  SampleERC721 erc721;
  SampleERC1155 erc1155;

  function setUp() public {
    erc20 = new SampleERC20("ERC20 Token", "ERC20", 18);
    erc721 = new SampleERC721("ERC721 Token", "ERC721");
    erc1155 = new SampleERC1155();
  }

  function testViewNotContract() public {
    emit log_bytes(msg.sender.viewToken());
    assertEq(msg.sender.viewToken(), msg.sender.viewAddress());
  }

  function testViewUnknown() public {
    emit log_bytes(address(this).viewToken());
    assertEq(address(this).viewToken(), address(this).viewContract());
  }

  function testViewERC20() public {
    emit log_bytes(address(erc20).viewERC20());
  }

  function testViewERC721() public {
    emit log_bytes(address(erc721).viewToken());
    assertEq(address(erc721).viewToken(), address(erc721).viewERC721());
  }

  function testViewERC1155() public {
    emit log_bytes(address(erc1155).viewToken());
    assertEq(address(erc1155).viewToken(), address(erc1155).viewERC1155());
  }
}
