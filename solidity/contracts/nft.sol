// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./bonus_token.sol" ;

contract NFT_c is ERC721("LIONTICKET", "LT") , Ownable {

    bonus_token private t_c ;
    uint public price ;
    mapping( uint => uint ) proceeds ;

    function set_t_c( bonus_token add ) public onlyOwner() {
        t_c = add ;
    }

    function withdraw( uint _day ) public onlyOwner { // 특정 경기의 수익금 출금

        // 날짜가 지나야만 출금 가능
        // 날짜 관련은 프론트에서 처리 ?
        payable( owner() ).transfer( proceeds[ _day ] ) ;

    }

    function set_price( uint _price ) public onlyOwner { // 가격 정하기
        price = _price ;
    }

    // mapping( uint => mapping( uint => uint ) ) public chk_seat ;
    // chk[ 230604(날짜)1(프리미엄석)101(블럭)303(몇번째 ) ] = 0 : 발행x , 1 : 발행o , 2 : 사용됨
    mapping( uint => bool ) public chk_seat ; // true : 사용

       function mintNFT( uint _day , uint _type ) public payable { // 민팅 후 좌석 정보 변경 

        // 가격
        require( msg.value == price ) ;
        // 이더말고 스테이블은 어떻게 받음??
        // 스테이블 받는건 그쪽 컨트렉트 받아서 하면되지않나.
        // 구현해보고 싶으면 스테이블용도의 erc20 따로 발행해서 추후 확장

        proceeds[ _day ] += price ;
        uint _tokenID = plus( _day , _type ) ;
        _safeMint( msg.sender , _tokenID ) ;

    }

    // 좌석이 이미 예약 되었는지 아닌지
    function seat_info( uint _day , uint _block , uint _endidx ) public view returns( bool[] memory rt ){
    
        rt = new bool[]( _endidx ) ;
        uint day = plus( _day , _block ) * 1000 ;

        for( uint i = 1 ; i <= _endidx ; i ++ ) {

            uint tokenID = day + i ;
            rt[ i - 1 ] = _ownerOf( tokenID ) == address(0) ? false : true ;
            
        }

        return rt ;

    }
    
    function refund( uint _day , uint _type ) public { // 환불
  
        uint _tokenID = plus( _day , _type ) ;
        address owner = ownerOf( _tokenID ) ;

        // 주인 확인
        require( owner == msg.sender ) ;

        // 사용되면 환불 불가
        require( chk_seat[ _tokenID ] == false ) ;

        // 날짜는 프론트에서 처리 ?
        // 인트 크기비교로
        // 경기시작하면 환불 불가.


        // 사용 후에 보냄. 
        // 1번 경기의 좌석이 20개 , 맵핑으로 민팅할때 좌석값까지
        // chk_seat[ _day ][ _type ] = 0 ;
        _burn( _tokenID ) ;
        uint _refund = price * 9 / 10 ;
        proceeds[ _day ] -= _refund ;
        payable( msg.sender ).transfer( _refund ) ;
        // 수수료 10%
         
    }

    function use( uint _day , uint _type ) public {

        uint _tokenID = plus( _day , _type ) ;
        
        require( chk_seat[ _tokenID ] == false ) ;
        require( msg.sender ==  _ownerOf( _tokenID ) ) ;

        // 사용 체크
        chk_seat[ _tokenID ] = true ;

        // 사용되면 토큰 지급
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