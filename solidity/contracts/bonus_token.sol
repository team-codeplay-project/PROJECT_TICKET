// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./nft.sol" ;

// chainlink vrf

contract bonus_token is ERC20("AToken", "AT") , ERC20Burnable , Ownable {

    NFT_c nft_contract ;
    address n_c_a ;
     
    mapping( uint => uint ) R_BAL ; // 래플 밸런스
//    mapping( uint => address[] ) R_add ; // n 번 래플에 참여한 지갑들
    mapping( uint => bool ) R_END ; // 래플 종료
    mapping( uint => address ) A_ADD ; // 옥션 최고 지값, 밸류
    mapping( uint => uint ) A_BAL ;
    mapping( uint => bool ) A_END ; // 옥션 종료
    // 옥션 미구현  

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

    function RAPPLE( address _from , uint _idx ) public {

        require( R_END[ _idx ] == false ) ;

        _transfer( _from , address( this ) , 1 ) ; // 토큰 1개 수거
        // _transfer override
        R_BAL[ _idx ] ++ ;

    }

    function RAPPLE_END( address _to , uint _idx ) public onlyOwner() {

        // _to 는 js에서 랜덤 돌려서 당첨자 뽑기.
        require( R_END[ _idx ] == false ) ;
        _transfer( address( this ) , _to , R_BAL[ _idx ] ) ;
        R_END[ _idx ] = true ;

    }

}

 function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }