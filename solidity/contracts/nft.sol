// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./bonus_token.sol" ;

contract NFT_c is ERC721 , Ownable {

    address payable contract_owner ;

    bonus_token t_c ;
    uint public price ;
    mapping( uint => uint ) proceeds ;

    constructor() ERC721("LIONTICKET", "LT") {

        contract_owner = payable( msg.sender ) ;

    }

    function set_t_c( bonus_token add ) public onlyOwner() {

        t_c = add ;

    }

    function withdraw( uint _day ) public onlyOwner { // 특정 경기의 수익금 출금

        // 날짜가 지나야만 출금 가능
        // 날짜 관련은 프론트에서 처리 ?
        contract_owner.transfer( proceeds[ _day ] ) ;

    }

    function set_price( uint _price ) public onlyOwner { // 가격 정하기

        price = _price ;

    }

    // 필요 없을 수도 있다. 721 기본 코드에서 알아서 다 해줌.
    // 사용 여부 구분할때는 필요할거같은디?
    // mapping( uint => mapping( uint => uint ) ) public chk_seat ;
    // chk[ 230604(날짜)1(프리미엄석)101(블럭)303(몇번째 ) ] = 0 : 발행x , 1 : 발행o , 2 : 사용됨
    mapping( uint => bool ) public chk_seat ; // true : 사용
    
    function refund( uint _day , uint _type ) public { // 환불
  
        uint _tokenID = plus( _day , _type ) ;
        address owner = ownerOf( _tokenID ) ;

        // 주인 확인
        require( owner == msg.sender ) ;

        // 사용되면 환불 불가
        require( chk_seat[ _tokenID ] == false ) ;

        // 날짜는 프론트에서 처리 ?
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

        chk_seat[ _tokenID ] = true ;

        // todo : bonus_token 드랍
        t_c.t_mint( msg.sender ) ;

    }

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