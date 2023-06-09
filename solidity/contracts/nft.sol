// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract NFT is ERC721 {

    address owner ;

    constructor() ERC721("LIONTICKET", "LT") {

        owner = msg.sender ;

    }

    mapping( uint => mapping( uint => uint ) ) public chk_seat ;
    // chk[ 230604(날짜)1(프리미엄석)101(블럭)303(몇번째 ) ] = 0 : 발행x , 1 : 발행o , 2 : 사용됨

    mapping( uint => address ) ticket_user ;

    function burn( uint _day , uint _type ) public { // 환불
         
        // 사용 후에 보냄. 
        // 1번 경기의 좌석이 20개 , 맵핑으로 민팅할때 좌석값까지
        chk_seat[ _day ][ _type ] = 0 ;
         
    }

    function chk( uint _day , uint _type ) public view returns( uint ) {

        return chk_seat[ _day ][ _type ] ;

    }

    function use( uint _day , uint _type ) public {

        uint _tokenID = plus( _day , _type ) ;
        _mint( msg.sender , _tokenID ) ;
        chk_seat[ _day ][ _type ] = 2 ;

    }

    function mintNFT( uint _day , uint _type ) public { // 민팅 후 좌석 정보 변경 

        // require( msg.value == 1 ether ) ;
        // 프론트에서 호출했을때는 어떻게 진행됨??
        // 이더말고 스테이블은 어떻게 받음??

        uint _tokenID = plus( _day , _type ) ;
        chk_seat[ _day ][ _type ] = 1 ;
        ticket_user[ _tokenID ] = msg.sender ;

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

contract bonus_token is ERC20 , ERC20Burnable {

    // 질문 1 ERC20 의 근본적인... 건 좀 공부 더하고

    address owner ;
    
    mapping( uint => uint ) R_BAL ; // 래플 밸런스
    mapping( uint => bool ) R_END ; // 래플 종료
    mapping( uint => address ) A_ADD ; // 옥션 최고 지값, 밸류
    mapping( uint => uint ) A_BAL ;
    mapping( uint => bool ) A_END ; // 옥션 종료

    constructor () ERC20("AToken", "AT") {

        owner = msg.sender ;

    }

    event A
    
    emit A
    

    // OVERRIDE & REDEFINED FUNCTIONS
    function decimals() override public pure returns( uint8 ){
        return 0 ;
    }

    modifier chk_owner() {

        require( msg.sender == owner ) ;
        _ ;

    }

    function mint( address _to ) public chk_owner { // 사용 확인되면 토큰 1개 지급
        _mint( _to , 1 ) ;
    }

    function RAPPLE( address _from , uint _idx ) public {

        require( R_END[ _idx ] == false ) ;

        _transfer( _from , address( this ) , 1 ) ; // 토큰 1개 수거
        R_BAL[ _idx ] ++ ;

    }

    function RAPPLE_END( address _to , uint _idx ) public chk_owner {

        // _to 는 js에서 랜덤 돌려서 당첨자 뽑기.
        require( R_END[ _idx ] == false ) ;
        _transfer( address( this ) , _to , R_BAL[ _idx ] ) ;
        R_END[ _idx ] = true ;

    }

    function Auction( address _from , uint _idx ) public {

        require( A_END[ _idx ] == false ) ;

        _transfer( _from , address( this ) , 1 ) ; // 토큰 1개 수거
        A_BAL[ _idx ] ++ ;

    }

    function Auction_END( uint _idx ) public chk_owner {

        require( A_END[ _idx ] == false ) ;

    

    }

}