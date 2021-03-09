pragma solidity 0.7.5;
pragma abicoder v2;

contract MultiSignWallet {

    struct Request {
        uint requestId;
        uint amount;
        address payable to;
        uint approvals;
        bool done;
    }
    
    uint approvalLimit;
    address[] owners;
    uint[] public requestList;
     
    modifier onlyOwners() {
        bool owner = false;
        for(uint i=0; i < owners.length;i++) {
            if(owners[i] == msg.sender) {
                owner = true;
            }
        }
        require(owner == true, "You're not an owner!");
        _;
    }
    
    event RequestCreated(uint _id, uint _amount, address _from, address _to);
    event ApprovalReceived(uint _id, uint _approvals, address _approver);
    event TransferFinished(uint _id);

    mapping(address => mapping(uint => bool)) ownersApprovals;
    mapping(address => uint) balance;
    mapping(uint => Request) public requests;
    
    constructor(address[] memory _owners, uint _limit) {
        approvalLimit = _limit;
        owners = _owners;
    }
    
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }
    
    function requestTransfer(uint _amount, address payable _to) external onlyOwners {
        require(balance[msg.sender] >= _amount, "Balance not sufficient");
        
        balance[msg.sender] -= _amount;
        
        emit RequestCreated(requestList.length, _amount, msg.sender, _to);
        
        requests[requestList.length] = (Request(requestList.length, _amount, _to, 0, false));
        
    }
    
    function approveRequest(uint _indexRequest) external onlyOwners {
        require(ownersApprovals[msg.sender][_indexRequest] == false, "You already approved this request!");
        require(requests[_indexRequest].done == false, "The request is already done or were not created yet!");
        
        Request memory request = requests[_indexRequest];
        
        emit ApprovalReceived(_indexRequest, request.approvals, msg.sender);
        
        request.approvals += 1;
        ownersApprovals[msg.sender][_indexRequest] = true;
        
        if(request.approvals >= approvalLimit) {
            request.to.transfer(request.amount);
            request.done = true;
            
            balance[request.to] += request.amount;
            
            emit TransferFinished( _indexRequest);
        }
    }
    
    function getRequest(uint _indexRequest) public view returns (Request memory) {
        return requests[_indexRequest];
    }
    
    function getBalance() public view returns (uint) {
        return balance[msg.sender];
    }
}