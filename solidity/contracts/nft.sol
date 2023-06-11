// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 , OWANABLE {

    address payable contract_owner ;
    uint public price ;

    constructor() ERC721("LIONTICKET", "LT") { 
        contract_owner = payable( msg.sender ) ;
    }

    modifier chk_owner() {

        // ownable뜯어보고 업데이트 예정

        require( msg.sender == contract_owner ) ;
        _ ;

    }

    function withdraw( uint _amount ) public chk_owner() { // 원하는 만큼만 출금

        // todo_ 이미 지난 경기들의 가격만 출금가능. 안끝난 경기는 환불이슈 있음.

        contract_owner.transfer( _amount ) ;

    }

    function set_price( uint _price ) public chk_owner() { // 가격 정하기

        // 질문1 _price 에 1 ether 이렇게 넣어도 되나?
        price = _price ;

    }

    // 필요 없을 수도 있다. 721 기본 코드에서 알아서 다 해줌.
    // 사용 여부 구분할때는 필요할거같은디?
    // mapping( uint => mapping( uint => uint ) ) public chk_seat ;
    // chk[ 230604(날짜)1(프리미엄석)101(블럭)303(몇번째 ) ] = 0 : 발행x , 1 : 발행o , 2 : 사용됨
    mapping( uint => bool ) public chk_seat ; // true : 사용
    
    function refund( uint _day , uint _type ) public { // 환불
        
        uint _tokenID = plus( _day , _type ) ;

        // 사용되면 환불 불가
        require( chk_seat[ _tokenID ] == false ) ;

        // 2. 질문2 오늘 날짜 vs _day ( 경기 이후 환불 불가 ) 

        


        // 사용 후에 보냄. 
        // 1번 경기의 좌석이 20개 , 맵핑으로 민팅할때 좌석값까지
        // chk_seat[ _day ][ _type ] = 0 ;
        _burn( _tokenID ) ;
        payable( msg.sender ).transfer( price * 10 / 9 ) ;
        // 수수료 10%
         
    }

    function use( uint _day , uint _type ) public {

        uint _tokenID = plus( _day , _type ) ;

        require( msg.sender ==  _ownerOf( _tokenID ) ) ;

        chk_seat[ _tokenID ] = true ;

        // todo : bonus_token 드랍

    }

    function mintNFT( uint _day , uint _type ) public payable { // 민팅 후 좌석 정보 변경 

        // 가격
        require( msg.value == 1 ether ) ;
        // 이더말고 스테이블은 어떻게 받음??
        // 스테이블 받는건 그쪽 컨트렉트 받아서 하면되지않나.
        // 구현해보고 싶으면 스테이블용도의 erc20 따로 발행해서 추후 확장

        uint _tokenID = plus( _day , _type ) ;
        _safeMint( msg.sender , _tokenID ) ;

    }

     function plus( uint _a, uint _b ) internal pure returns ( uint ) { // day + type : nft tokenID 생성

        unchecked {
        uint temp = 10 ;
        while( _b >= temp ) {

            temp *= 10 ;
        }

        return _a * temp + _b ;

        }
        
    }

}