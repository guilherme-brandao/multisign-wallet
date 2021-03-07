pragma solidity 0.7.5;
pragma abicoder v2;

contract MultiSignWallet {
    
    struct Request {
        uint requestId;
        uint amount;
        address payable to;
        address[] approvals;
        bool done;
    }
    
    uint approvalLimit;
    address[] owners;
    Request[] requestList;
    
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

    mapping (address => mapping(uint => bool)) ownersApprovals;
    mapping(address => uint) balance;
    
    constructor(address[] memory _owners, uint _limit) {
        approvalLimit = _limit;
        owners = _owners;
    }
    
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }
    
    function requestTransfer(uint _amount, address payable _to) public onlyOwners {
        require(balance[msg.sender] >= _amount, "Balance not sufficient");
        address[] memory emptyAddressList;
        balance[msg.sender] -= _amount;
        emit RequestCreated(requestList.length, _amount, msg.sender, _to);
        requestList.push(Request(requestList.length, _amount, _to, emptyAddressList, false));
    }
    
    function approveRequest(uint _indexRequest) public onlyOwners {
        require(ownersApprovals[msg.sender][_indexRequest] == false, "You already approved this request!");
        require(requestList[_indexRequest].done == false, "The request is already done!");
        
        Request storage request = requestList[_indexRequest];
        emit ApprovalReceived(_indexRequest, request.approvals.length, msg.sender);
        
        request.approvals.push(msg.sender);
        ownersApprovals[msg.sender][_indexRequest] = true;
        
        if(request.approvals.length >= approvalLimit) {
            request.to.transfer(request.amount);
            request.done = true;
            
            balance[request.to] += request.amount;
            
            emit TransferFinished( _indexRequest);
        }
    }
    
    function getRequests() public view returns (Request[] memory) {
        return requestList;
    }
    
    function getBalance() public view returns (uint) {
        return balance[msg.sender];
    }
}
   