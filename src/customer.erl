-module(customer).

-export([customerProcess/4]).

customerProcess(Cus,BankList,ParentID,TA) ->
    {Name, Amount} = Cus,
    % io:format("Customer thread for ~w~n", [Name]),
    % io:format("The RB is: ~w~n",[RandomBankNumber]),
    % timer:sleep(rand:uniform(100)),
    Request = rand:uniform(50),
    if (length(BankList) /= 0)->
        if (Amount-Request >= 0)->
        % random number
            if
                length(BankList)==1 -> RandomBankNumber=1;
            true->
                RandomBankNumber = rand:uniform(length(BankList))
            end,    
        SelectRBank = lists:nth(RandomBankNumber, BankList),
        % io:format("~w is requesting loan to ~w for ~w ~n",[Name,SelectRBank,Request]),
        ParentID ! {loanrequest,Name,Request,SelectRBank},
        timer:sleep(rand:uniform(100)),
        SelectRBank ! {Name,Request},
            receive
                {Sender, Status, Remaining } -> 
                    if Status==1 -> 
                        UpdatedAmount= Amount-Request,
                        ParentID ! {loanreceived,Name,Request,Sender},
                        if(UpdatedAmount==0)->
                            ParentID ! {finalstatecustomer,Name,UpdatedAmount,TA};
                        true->customerProcess({Name,UpdatedAmount},BankList, ParentID,TA)
                        end;
                    true-> 
                        UpdatedAmount=Amount,
                        ParentID ! {finalstatebank,Sender,Remaining},
                        UpdateBankList= lists:delete(Sender,BankList),
                        customerProcess({Name,UpdatedAmount},UpdateBankList, ParentID,TA)
                    end
                    
            end;
            true-> customerProcess({Name,Amount},BankList, ParentID,TA)
        end;
    true-> ParentID ! {finalstatecustomer,Name,Amount,TA}
end.