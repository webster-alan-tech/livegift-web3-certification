// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title GiftBadgeNFT
/// @notice Um NFT que representa um presente simbólico dado a um usuário
contract GiftBadgeNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;

    /// @notice Evento emitido quando um novo badge é presenteado
    event Gifted(address indexed to, uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("GiftBadgeNFT", "GBN") {}

    /// @notice Emite um NFT como presente simbólico
    /// @param to Endereço do destinatário
    /// @param tokenURI URI de metadados (imagem, descrição, nome do badge)
    function giftBadge(address to, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit Gifted(to, tokenId, tokenURI);
        return tokenId;
    }

    /// @notice Retorna o total de badges emitidos
    function totalMinted() external view returns (uint256) {
        return nextTokenId;
    }
}
