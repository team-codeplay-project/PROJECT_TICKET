// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./nft.sol" ;

contract bonus_token is ERC20("AToken", "AT") , ERC20Burnable , Ownable {

    NFT_c nft_contract ;
    address n_c_a ;
    mapping( address => bytes32 ) user_db ;

    modifier chk_front( bytes32 _input ){ // 프론트에서 들어온거 체크

        require( _input == user_db[ msg.sender ] ) ;
        _ ;

    } 

    // OVERRIDE & REDEFINED FUNCTIONS
    function decimals() override public pure returns( uint8 ){
        return 0 ;
    }

    function set_n_c( address add ) public onlyOwner(){

        n_c_a = add ;
        nft_contract = NFT_c( n_c_a ) ;

    }

    function t_mint( address _to ) public { // 사용 확인되면 토큰 1개 지급
        require( msg.sender == n_c_a ) ;
        _mint( _to , 1 ) ;
    }

    event Raffle(uint indexed _idx , address indexed _add ) ;

    function Raffle_participate( uint _n ) public {
        emit Raffle( _n , msg.sender ) ;
    }

/*
    // 1안 구조체 써서 래플

    struct Raffle {

        mapping( uint => bool ) chk ; // 이번 래플에 참가 했는지 아닌지
        uint start_block ;
        uint end_block ;
        uint c ;

    }

    Raffle[] public R_db ;
    //mapping( uint => mapping( uint => bool ) ) R_db ;
    uint R_num ;

    function R_insert() public { 
        
        for( uint i = 0 ; i < 1000 ; i ++ ) { 

            //R_db[ l ].chk[ i ] = true ;
            //R_db[ l ][ i ] = true ; // 661248 , 574998 , 553934 // 641583 , 557898 , 536834
            R_db.push( ) ;
            R_db[ i ].start_block = block.number ;

        }

    }

    event R( uint a , uint b , uint c ) ;
    function R_insert2() public { // 2705168 , 2352320 , 2331256 // 2705168 , 2352320 , 2331256

        for( uint i = 0 ; i < 1000 ; i ++ ) {
        emit R( 1 , 0 , i ) ;
        }

    }

    function RAPPLE( address _from , uint _idx ) public {

        //require( R_END[ _idx ] == false ) ;

        _transfer( _from , address( this ) , 1 ) ; // 토큰 1개 수거
        R_BAL[ _idx ] ++ ;

    }

    function RAPPLE_END( address _to , uint _idx ) public onlyOwner() {

        // _to 는 js에서 랜덤 돌려서 당첨자 뽑기.
        require( R_END[ _idx ] == false ) ;
        _transfer( address( this ) , _to , R_BAL[ _idx ] ) ;
        R_END[ _idx ] = true ;

    }
*/
}