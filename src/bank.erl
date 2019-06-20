-module(bank).
-export([bankProcess/2]).

bankProcess(BankObj, ParentID) ->
    {Name,Amount}=BankObj,
    % io:fwrite("Bank thread running for ~w~n", [Name]),
    receive      
      {Sender, LoanAmt} -> 
          if
              LoanAmt < Amount-> 
                  
                  UpdatedAmount = Amount-LoanAmt,
                  Sender ! {Name,1,UpdatedAmount},
                  ParentID ! {loanapproved,Name,Sender, LoanAmt},
                %   io:format("Remaining amount in ~w:~w~n",[Name,UpdatedAmount]),
                  if Amount<50 ->
                    ParentID ! {finalstatebank,Name,Amount};
                  true-> void
                  end,
                  bankProcess({Name,UpdatedAmount},ParentID);
            true->  if Amount==0 ->
                      ParentID ! {finalstatebank,Name,Amount};
                    true->void
                    end,
                    Sender ! {Name,0,Amount},
                    ParentID ! {loanrejected,Name, Sender,LoanAmt},
                    bankProcess({Name,Amount},ParentID)
        end
          % io:fwrite("At the end of bank ~w~n", [Amount])
    after 2000 ->
      ParentID ! {finalstatebank,Name,Amount}
  
    end.
