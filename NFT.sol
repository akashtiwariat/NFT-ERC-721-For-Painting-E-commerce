// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.16 <0.9.0;



contract NFT_for_Painting_ERC_721 {

    struct Painting {
        uint256 id;
        string name;
        string description;
        uint256 price;
        address payable seller;
        bool sold;
    }

     Painting[] public painting;
    mapping (uint256 => bool) public paintingIds;
    mapping (uint256 => address) public tokenOwner;
    mapping (address => uint256) public ownershipTokenCount;
    mapping (uint256 => address) public approved;
    mapping(address => uint256[]) public sellerToProducts;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event PaintingListed(uint256 indexed id, string name, string description, uint256 price, address seller);


   function listPainting(uint _paintingiD,string memory _name, string memory _description, uint256 _price) public {
         require(!paintingIds[_paintingiD], "Painting ID already exists");
        uint256 newTokenId = _paintingiD;
        paintingIds[_paintingiD] = true;
        painting.push(Painting(_paintingiD,_name, _description, _price, payable(msg.sender), false));
        sellerToProducts[msg.sender].push(newTokenId);
        mint(msg.sender, newTokenId);
        emit PaintingListed(newTokenId, _name, _description, _price, msg.sender);
    }

    function buyPainting(uint256 _paintingId,uint _price) public payable {
    require(tokenOwner[_paintingId] != address(0), "Token does not exist");
    require(tokenOwner[_paintingId] != msg.sender, "You already own this token");
    require(painting[_paintingId].price == msg.value, "Incorrect payment amount");
    require(painting[_paintingId].sold == false, "Painting already sold");

    // Transfer payment to seller
    painting[_paintingId].seller.transfer(msg.value);

    // Update painting and NFT ownership
    painting[_paintingId].sold = true;
    transfer(msg.sender, _paintingId);

    // Mint NFT for the painting
    mint(msg.sender, _paintingId);
}



    function mint(address _to, uint256 _tokenId) public {
        require(_to != address(0), "Invalid address");
        require(tokenOwner[_tokenId] == address(0), "Token already exists");

        tokenOwner[_tokenId] = _to;
        ownershipTokenCount[_to]++;
        emit Transfer(address(0), _to, _tokenId);
    }


    function transfer(address _to, uint256 _tokenId) public payable{
        require(_to != address(0), "Invalid address");
        require(_to != address(this), "Invalid address");
        require(tokenOwner[_tokenId] == msg.sender || approved[_tokenId] == msg.sender, "Unauthorized");

        approved[_tokenId] = address(0);
        tokenOwner[_tokenId] = _to;
        ownershipTokenCount[msg.sender]--;
        ownershipTokenCount[_to]++;
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public {
        require(msg.sender == tokenOwner[_tokenId], "Unauthorized");
        approved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}


