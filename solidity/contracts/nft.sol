// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./bonus_token.sol" ;

// 가스효율
// 사이즈보다 퀼리티

contract NFT_c is ERC721("LIONTICKET", "LT") , Ownable {

    address sub_owner ;
    bonus_token private t_c ;
    bool private sub_chk ;
    uint public price ;
    mapping( uint => address ) private buyer ; // 민팅한 사람
    mapping( uint => bool ) private chk_seat ; // true : 사용 false : 비사용
    mapping( uint => bool ) private chk_day ; // 특정 날짜 오픈
    //  mapping( uint => uint ) proceeds ;

    constructor( address _sub ) {
        sub_owner = _sub ;
    }

    modifier sub_true() {
        require( sub_chk == true ) ;
        _ ;
    }

    function sub_change( address _sub ) public onlyOwner sub_true{
        sub_owner = _sub ;
    }

    function sub_agree( bool _tf ) public {
        require( msg.sender == sub_owner ) ;
        sub_chk = _tf ;
    }

    function set_t_c( bonus_token add ) public onlyOwner { // sub_true
        t_c = add ;
    }

    function set_day( uint _day , bool _tf ) public onlyOwner { // sub_true
        chk_day[ _day ] = _tf ;
    }

    function withdraw( uint _amount) public onlyOwner { // sub_true // 특정 경기의 수익금 출금

        payable( owner() ).transfer( _amount ) ;

    }

    function set_price( uint _price ) public onlyOwner { // 가격 정하기
        price = _price ;
    }

    function buy_ticket( uint _day , uint _type ) public payable { // 민팅 후 좌석 정보 변경 

        require( msg.value == price ) ;
        require( chk_day[ _day ] == true ) ;

        uint _tokenID = plus( _day , _type ) ;
        _safeMint( msg.sender , _tokenID ) ;
        buyer[ _tokenID ] = msg.sender ;

    }

    // 좌석이 이미 예약 되었는지 아닌지
    function seat_info( uint _day , uint _block , uint _endidx ) public view returns( bool[] memory rt ){
    
        require( chk_day[ _day ] == true ) ;

        rt = new bool[]( _endidx ) ;
        uint day = plus( _day , _block ) ;
        day = plus( day , 999 ) - 999 ;

        for( uint i = 1 ; i <= _endidx ; i ++ ) {

            uint tokenID = day + i ;
            rt[ i - 1 ] = _ownerOf( tokenID ) == address(0) ? false : true ;
            
        }

        return rt ;

    }

    function Chk_seat( uint _day , uint _type ) public view returns( bool ){
        uint tokenId = plus( _day , _type ) ;
        return chk_seat[ tokenId ] ;
    }
    
    function refund( uint _day , uint _type ) public { // 환불

        require( chk_day[ _day ] == true ) ;
  
        uint _tokenID = plus( _day , _type ) ;

        require( msg.sender == buyer[ _tokenID ] ) ;
        require( chk_seat[ _tokenID ] == false ) ;

        _burn( _tokenID ) ;
        // 수수료 10%
        uint _refund = price * 9 / 10 ;
        payable( msg.sender ).transfer( _refund ) ;
        
    }

    function use( uint _day , uint _type ) public { // 티켓 사용 조건 : 민팅한 사람

        require( chk_day[ _day ] == true ) ;

        uint _tokenID = plus( _day , _type ) ;
        
        require( chk_seat[ _tokenID ] == false ) ;
        require( msg.sender == buyer[ _tokenID ] ) ;

        chk_seat[ _tokenID ] = true ;
        t_c.t_mint( msg.sender ) ;

    }

    function plus( uint _a , uint _b ) internal pure returns ( uint ) { // day + type : nft tokenID 생성

        unchecked {
        uint temp = 10 ;
        while( _b >= temp ) {
            temp *= 10 ;
        }

        return _a * temp + _b ;

        }
        
    }

}