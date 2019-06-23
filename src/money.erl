-module(money).

-export([start/0,masterprocess/1,printResult/1]).

start() -> 
		CustomerFinaMessages=[],
		BankFinalMessages=[],
		register(masterprocessthread,spawn(money,masterprocess,[CustomerFinaMessages])),
		masterprocessthread ! start.
	    % masterprocess(CustomerFinaMessages).

masterprocess(CustomerFinaMessages) ->
	% counter=0,
receive
	
	start->
			{_, CustomerData} = file:consult("customers.txt"),
			{_, BankData} = file:consult("banks.txt"),
		% This has all the customer threads
			CThreadList =[Name || {Name,_} <- CustomerData],
			BThreadList =[Name || {Name,_} <- BankData],
			% numberOfCustomers=CThreadList,
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
			masterprocess(CustomerFinaMessages);
	{loanrequest, Sender, RequestAmount, TargetBank}->
			io:format("~w is requesting loan to ~w for ~w~n",[Sender,TargetBank,RequestAmount]),
			masterprocess(CustomerFinaMessages);
	{loanreceived,Sender, RequestAmount, TargetBank}->
			io:format("Loan recived by ~w from ~w of amount ~w~n",[Sender,TargetBank, RequestAmount]),
			masterprocess(CustomerFinaMessages);
	{loanrejected,Sender, Customer, LoanAmount}->
			io:format("~w denies loan of amount ~w for ~w~n",[Sender, LoanAmount, Customer]),
			masterprocess(CustomerFinaMessages);
	{loanapproved,Sender, Customer,LoanAmount}->
			io:format("~w approves loan of amount ~w for ~w~n",[Sender, LoanAmount, Customer]),
			masterprocess(CustomerFinaMessages);
	{finalstatecustomer,Name,Amount,TA}->
			
			if(Amount==0)->
					
					% io:format("~w was able to get all the money!!!!!!! Yay! ~w~n~n",[Name,TA]);\
					String= lists:concat([Name," was able to get all the money!!!!!!! Yay! ",TA,"~n"]),
					UCustomerFinalMessages = [ String  | CustomerFinaMessages ];
			true-> 	String2=lists:concat([Name," was not able to get all the money...He was able to get only ",  TA-Amount," :( ~n"]),
					UCustomerFinalMessages = [ String2  | CustomerFinaMessages ]
			end,
			masterprocess(UCustomerFinalMessages);
	{finalstatebank,Name,Amount}->
			io:format("~w bank is left with ~w~n",[Name,Amount]),
			masterprocess(CustomerFinaMessages)
	after 8000->
		% lists:map(fun(Message) -> io:format(Message) end, CustomerFinaMessages),
	% [io:format(||]
		io:format("~n~nThe simulation is ending and printing final customer results below, above are the final bank messages PLEASE WAIT!~n"),
		printResult(CustomerFinaMessages)
		
end.
printResult(CustomerFinaMessages) ->
	
	lists:map(fun(Message) -> io:format(Message) end, CustomerFinaMessages).
