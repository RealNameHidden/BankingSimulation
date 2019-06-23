# BankingSimulation
## This is a project that was done to explore concurrency in Erlang.
It reads a set of banks and a set of customers with their goal loans, and each customer and bank is made as an indivisual process. Customers request loans to bank as until their goal is fulfilled. Banks sanction loans if it has the requested amount.
An the end the results are printed.

prerequisites: Installation of Erlang and updating the environment variable.
Instructions to run the project:
1. Open shell
2. cd inside project location.
3. Type `erl`.
4. Type `c(money).
          c(customer).
          c(bank).`
5. To run `money:start().`
