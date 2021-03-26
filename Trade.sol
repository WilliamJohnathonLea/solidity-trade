// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;

/// @title Trade
/// @author William Lea
/// @notice A contract for a bilateral trade.
contract Trade {
    enum TradeState {
        Created,
        Accepted,
        Agreed,
        Terminated
    }

    TradeState state;

    address immutable party;
    address immutable counterparty;

    uint public start;
    uint public end;

    modifier eitherParty {
        require(msg.sender == party || msg.sender == counterparty);
        _;
    }

    modifier onlyParty {
        require(msg.sender == party);
        _;
    }

    modifier onlyCounterparty {
        require(msg.sender == counterparty);
        _;
    }

    modifier costs(uint _amount) {
        require(
            msg.value >= _amount,
            "Not enough Ether provided."
        );
        _;
        if(msg.value > _amount)
            payable(msg.sender).transfer(msg.value - _amount);
    }

    modifier withState(TradeState _state) {
        require(state == _state);
        _;
    }

    constructor(address _counterparty) {
        party = msg.sender; // The creator of the contract
        counterparty = _counterparty;
        state = TradeState.Created;
    }

    function setTradeStart(uint _start)
        public
        eitherParty
        withState(TradeState.Accepted)
    {
        start = _start;
    }

    function setTradeEnd(uint _end)
        public
        eitherParty
        withState(TradeState.Accepted)
    {
        end = _end;
    }

    function acceptTrade()
        public
        onlyCounterparty
        withState(TradeState.Created)
    {
        state = TradeState.Accepted;
    }

    function agreeTrade()
        public
        eitherParty
        withState(TradeState.Accepted)
    {
        state = TradeState.Agreed;
    }

}
