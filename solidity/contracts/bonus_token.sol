// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./nft.sol" ;

contract bonus_token is ERC20("AToken", "AT") , ERC20Burnable , Ownable {

    NFT_c nft_contract ;

    // OVERRIDE & REDEFINED FUNCTIONS
    function decimals() override public pure returns( uint8 ){
        return 0 ;
    }

    function set_n_c( address add ) public onlyOwner(){
        nft_contract = NFT_c( add ) ;
    }

    function t_mint( address _to ) public { // 사용 확인되면 토큰 1개 지급
        require( msg.sender == address( nft_contract ) ) ;
        _mint( _to , 1 ) ;
    }

    event Raffle( uint indexed _idx , address indexed _add ) ;
    event Auction( uint indexed _idx , address indexed _add , uint _bid ) ;

    function Raffle_participate( uint _n ) public {

        // 참여조건 토큰 1개 보유
        // 토큰 1개 내야함
        // burn( msg.sender , 1 ) ;
        emit Raffle( _n , msg.sender ) ;
        
    }

    function Auction_participate( uint _n , uint _bid ) public {

        // 참여조건 토큰 1개 보유
        // 토큰 1개 내야함
        // burn( msg.sender , 1 ) ;
        emit Auction( _n , msg.sender , _bid ) ;
        
    }

    function Raffle_End( uint _n , uint num ) public view returns( uint ) {//onlyOwner() returns( uint ) {
        uint r = uint( keccak256(abi.encodePacked(block.number , block.timestamp , _n , msg.sender ))) ;
        r %= num ;
        return r ;
    }

}