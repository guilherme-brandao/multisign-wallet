pragma solidity 0.7.5;
pragma abicoder v2;

contract MultiSignWallet {
    
    uint approvalLimit;
    address[] owners;
    
    constructor(address[] memory _owners, uint _limit) {
        approvalLimit = _limit;
        owners = _owners;
        setWallet(owners[0]);
        setWallet(owners[1]);
        setWallet(owners[2]);
    }
    
    modifier onlyOwners {
        require(ownersWallets[msg.sender] == true, "You're not an owner!");
        _;
    }
    
    mapping (address => bool) public ownersWallets;
    
    mapping (address => mapping(uint => bool)) ownersApprovals;
    
    struct Request {
        uint requestId;
        uint amount;
        address payable to;
        address[] approvals;
        bool done;
    }
    
    Request[] requestList;
    
    function setWallet(address _wallet) public{
        ownersWallets[_wallet]=true;
    }
    
    function deposit() public payable { }
    
    function requestTransfer(uint _amount, address payable _to) public onlyOwners {
        address[] memory emptyAddressList;
        requestList.push(Request(requestList.length, _amount, _to, emptyAddressList, false));
    }
    
    function approveRequest(uint indexRequest) public onlyOwners {
        require(ownersApprovals[msg.sender][indexRequest] == false, "You already approved this request!");
        require(requestList[indexRequest].done == false, "The request is already done!");
        
        Request storage request = requestList[indexRequest];
        request.approvals.push(msg.sender);
        ownersApprovals[msg.sender][indexRequest] = true;
        
        
        if(request.approvals.length >= approvalLimit) {
            request.to.transfer(request.amount);
            request.done = true;
        }
    }
    
    function getRequests() public view returns (Request[] memory) {
        return requestList;
    }
}
    