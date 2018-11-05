pragma solidity ^0.4.0;
//Demo steps: stage>100donate>stage>2donate>3donate>
//EndTime1>NowTime>numDonates>getBalance>過40秒>
//4donate>NowTime>numDonates>getBalance>
//5donate>numDonates
contract smartSponsor {
  address public owner;
  address public benefactor;
  bool public refunded;
  bool public complete;
  uint public numDonates;
  uint public stage;
  uint public Goal1;
  uint public Goal2;
  uint public Goal3;
  uint public EndTime1;
  uint public EndTime2;
  uint public EndTime3;
  uint public NowTime;
  uint public RefundStart;
  struct Donate {
    uint amount;
    address eth_address;
  }
  mapping(uint => Donate) public Donates;

  // constructor
  function smartSponsor(address _benefactor,uint _Goal1, uint _Goal2, uint _Goal3,uint _Period1,uint _Period2,uint _Period3) {
    owner = msg.sender;
    numDonates = 0;
    refunded = false;
    complete = false;
    benefactor = _benefactor;
    stage = 1; 
    Goal1 = _Goal1;
    Goal2 = _Goal2;
    Goal3 = _Goal3;
    EndTime1 = block.timestamp + (_Period1 * 20);
    EndTime2 = EndTime1 + (_Period2 * 20);
    EndTime3 = EndTime2 + (_Period3 * 20);
    NowTime = block.timestamp;
    RefundStart = 0; 
  }

  // 若募款時間截止，則將募得金額退還給贈與者
  function refund() returns (string){
    if (complete || refunded) throw;
    for (uint i = RefundStart; i < numDonates; ++i) {
      Donates[i].eth_address.send(Donates[i].amount);
    }
    refunded = true;
    return ("已退款");
  }

  // 若大於等於目標金額，則將募得金額給收受贈者
  function receiveFund() {
    if (complete || refunded) throw;
    benefactor.send(this.balance);
    if (stage == 3) {
        complete = true;
        return;
    }
    RefundStart = numDonates;
    stage++;
    
    }
    
  //捐款
  function donate() payable returns (string) {
    if (msg.value == 0 || complete || refunded) throw;
    Donates[numDonates] = Donate(msg.value, msg.sender);
    numDonates++;
    
    //確認時間是否截止
    NowTime = block.timestamp; 
    if( (stage == 1 && NowTime > EndTime1)||
    (stage == 2 && NowTime >  EndTime2)||
    (stage == 3 && NowTime >  EndTime3)){
        refund();
        return ("募款時間已截止");
    }

   //確認金額是否達標
    if( (stage == 1 && this.balance >= Goal1)||
    (stage == 2 && this.balance >= Goal2)||
    (stage == 3 && this.balance >= Goal3)){
        receiveFund();
        return "捐款完成，並已完成階段性目標";
    }

    return "捐款完成";
  }
  
  //查看餘額
  function getBalance() constant returns (uint) {
    return this.balance;
  }
}
