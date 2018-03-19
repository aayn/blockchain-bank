# README - Bank Smart Contract

Author(s): Aayush Naik

## Instructions

1. Add the two files under `browser` in the [Remix IDE](http://remix.ethereum.org).
2. Create a `Bank` with any user. Note the address of the bank.
3. Create an `Account`. This account may be single or joint. For a single account, leave the `_owners` field blank. For a joint account, add the addresses of the various users in the `_owners` field.
4. Then, register the account with the bank using `registerAccount` and also paying some ether which serves as the initial balance.
5. An approval from all the users is needed for registration and deletion of an account in the case of a joint account.
6. You may then try out the different functionalities like `deposit`, `withdraw`, `transfer` etc.