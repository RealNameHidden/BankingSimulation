-module(money).

-export([main/0,masterprocess/0]).

main() -> 
		register(masterprocessthread,spawn(money,masterprocess,[])),
		masterprocessthread ! start,
	    masterprocess().

masterprocess() ->
	% counter=0,
receive
	
	start->
			{_, CustomerData} = file:consult("customers.txt"),
			{_, BankData} = file:consult("banks.txt"),
		% This has all the customer threads
			CThreadList =[Name || {Name,_} <- CustomerData],
			BThreadList =[Name || {Name,_} <- BankData],
			% numberOfCustomers=length(CThreadList),
		% Display customer and bank data
			io:format("*****The customers and their objectives*****~n"),
			lists:map(fun({Name,Amount}) -> io:format("~w : ~w~n",[Name,Amount]) end,CustomerData),
			io:format("~n*****The Banks and the mone they have****~n"),
			lists:map(fun({Name,Amount}) -> io:format("~w : ~w~n",[Name,Amount]) end,BankData),
			io:format("~n Creating processes.....~n"),	
		% Make processes
			CacheListCustomers = [register (Name, spawn(customer, customerProcess, [{Name,Amount}, BThreadList,self(),Amount])) || {Name,Amount} <- CustomerData],
		% timer:sleep(1000),
			CacheListBank = [register (BName,spawn(bank, bankProcess, [{BName,Amount}, self()])) || {BName,Amount} <- BankData],
			masterprocess();
	{loanrequest, Sender, RequestAmount, TargetBank}->
			io:format("~w is requesting loan to ~w for ~w~n",[Sender,TargetBank,RequestAmount]),
			masterprocess();
	{loanreceived,Sender, RequestAmount, TargetBank}->
			io:format("Loan recived by ~w from ~w of amount ~w~n",[Sender,TargetBank, RequestAmount]),
			masterprocess();
	{loanrejected,Sender, Customer, LoanAmount}->
			io:format("~w denies loan of amount ~w for ~w~n",[Sender, LoanAmount, Customer]),
			masterprocess();
	{loanapproved,Sender, Customer,LoanAmount}->
			io:format("~w approves loan of amount ~w for ~w~n",[Sender, LoanAmount, Customer]),
			masterprocess();
	{finalstatecustomer,Name,Amount,TA}->
			
			if(Amount==0)->
					
					io:format("~w was able to get all the money!!! Yay! ~w~n~n",[Name,TA]);
			true-> 	io:format("~w was not able to get all the money...He was able to get only ~w :( :(~n~n", [Name, TA-Amount])
			end,
			masterprocess();
	{finalstatebank,Name,Amount}->
			io:format("~w bank is left with ~w~n",[Name,Amount]),
			masterprocess()

end.

































 	% Send = fun(X) -> X ! {self(), 40} end,
 	% Z=[Send(BankX) || BankX <- BThreadList].

% % Unregitering the names so that you can run multiple times
% timer:sleep(5000),
 	% CacheListCustomers2 = [unregister (element(1,{Name,Amount})) || {Name,Amount} <- CustomerData],
 	% CacheListBank2 = [unregister (element(1,{Name,Amount})) || {Name,Amount} <- BankData].

	


