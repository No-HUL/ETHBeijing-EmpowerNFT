//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {SNFT} from "./SNFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//只有不在抽奖的时候，项目方才能打钱进奖池。现在只支持一个奖池。每次都是winner takes all。按照权重计算中奖概率。
//TODO: 1.在完成注册部分后部署并测试 2.中奖权重（performUpkeep）的逻辑实现 3.寻找Scroll上支持Automation的服务

contract Raffle {

//errors
    error Raffle__MustMoreThanZero();
    error Raffle__RaffleIsNotOpen();

//state variable
    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;
    address[] private s_participants;
    address private s_stablecoin;

//immutable variable
    // uint256 private immutable i_interval;
    SNFT private immutable i_sNft;
    uint256 private immutable i_amountSnftToEnter;

//mappings
    mapping(address participant => uint256 amountSnftMinted) private s_SnftMinted;

    enum RaffleState {
        OPEN,
        CALCULATING_WINNER
    }

//events

//modifiers
    modifier moreThanZero(uint256 amount) {
        if(amount <= 0){
            revert Raffle__MustMoreThanZero();
        }
        _;
    }

    // modifier whenRafflsOpen() {
    //     if(s_raffleState != RaffleState.OPEN){
    //         revert Raffle__RaffleIsNotOpen();
    //     }
    //     _;
    // }

//constructor
    constructor(
        address sNftAddress,
        uint256 amountSnftToEnter
        // uint256 interval
    ){
        i_sNft = SNFT(sNftAddress);
        i_amountSnftToEnter = amountSnftToEnter;
        // i_interval = interval;

        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    function projectCheckIn(
        address nftAddress,
        uint256 prizeTokenAmount
    ) external {
        _addMoneyToPrizePool(prizeTokenAmount);
        _checkInNftToBurn(nftAddress);
    }

    //持有checkIn过的NFT的用户burnNFT，然后进入抽奖
    function burnCheckedNft(uint256[] memory tokenIds) external {
        _burnNftAndMintSnft(address(i_sNft), tokenIds);
    }

    // function enterRaffle() external {}

    // function checkUpkeep(bytes memory /*checkData*/) 
    //     public view returns(bool, bytes memory){}

    // function performUpkeep(bytes memory /*performData*/) public {}

    // function fulfuillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{}

    //项目方打钱进奖池
    function _addMoneyToPrizePool(uint256 amount) moreThanZero(amount) internal {
        // if(s_raffleState != RaffleState.OPEN){
        //     revert Raffle__RaffleIsNotOpen();
        // }

        IERC20(s_stablecoin).transferFrom(msg.sender, address(this), amount);
    }

    //项目方在平台checkIn，设置可被销毁的NFT
    function _checkInNftToBurn(address nftAddress) internal returns(bool){
        bool approved = IERC721(nftAddress).isApprovedForAll(msg.sender, address(this));
        if(!approved){
            IERC721(nftAddress).setApprovalForAll(address(this), true);
        }
        return true;
    }

    //销毁nft并铸造Snft
    function _burnNftAndMintSnft(address nftAddress, uint256[] memory tokenIds) internal {
       for(uint256 i = 0; i < tokenIds.length; i++){
            IERC721(nftAddress).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
    }

}