pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract NFTCheque is ERC721 {
    address public owner;
    mapping (uint256 => bool) public cheques;
    mapping (uint256 => address payable) public chequeToAddress;
    mapping (uint256 => uint256) public chequeToAmount;
    mapping (uint256 => bool) public chequeToVerified;
    mapping(uint256 => uint256) public chequeIds;
    uint256 private _id = 0;

    constructor(){
        owner = msg.sender;
    }

    function mint(uint256 _chequeId, address payable _address, uint256 _amount) public {
        require(msg.sender == owner, "Solo el propietario del contrato puede crear nuevos NFT.");
        _mint(msg.sender, _id);
        _id++;
        cheques[_chequeId] = true;
        chequeToAddress[_chequeId] = _address;
        chequeToAmount[_chequeId] = _amount;
        chequeIds[_id] = _chequeId;
    }

    function transfer(address payable to, uint256 _chequeId) public {
        require(cheques[_chequeId], "Este cheque no tiene un NFT asociado.");
        require(msg.sender == owner, "Solo el propietario del contrato puede transferir NFT.");
        _transfer(msg.sender, to, _chequeId);
    }

    function _idToChequeId(uint256 _nftId) private view returns (uint256) {
        return chequeIds[_nftId];
    }

    function verify(uint256 _chequeId) public {
        require(msg.sender == owner, "Solo el propietario del contrato puede verificar cheques.");
        require(cheques[_chequeId], "Este cheque no tiene un NFT asociado.");
        chequeToVerified[_chequeId] = true;
    }

    function withdraw(uint256 _chequeId) public {
        require(cheques[_chequeId], "Este cheque no tiene un NFT asociado.");
        require(chequeToVerified[_chequeId], "Este cheque no ha sido verificado.");
        require(msg.sender == chequeToAddress[_chequeId], "Solo el destinatario del cheque puede retirar fondos.");
        chequeToAddress[_chequeId].transfer(chequeToAmount[_chequeId]);
    }

        function pay(uint256 _chequeId) public {
        require(cheques[_chequeId], "Este cheque no tiene un NFT asociado.");
        require(chequeToVerified[_chequeId], "Este cheque no ha sido verificado.");
        require(msg.sender == owner, "Solo el propietario del contrato puede pagar el cheque.");
        chequeToAddress[_chequeId].transfer(chequeToAmount[_chequeId]);
    }
}
