# PaymentsIntegration

This Package will contain all logic related to payments partner integrations.

## Plaid

To use Plaid for linking a bank make sure plaid feature flag is enabled:
`blockchain_ux_payment_method_plaid_is_enabled` and that your user is has an American address.
Depending on when you are testing this, your user might need the flags `ACH_INSTANT` and `INTERNAL_TESTING`.

Plaid feature is part of PaymentsIntegration Module. The LinkKit SDK if added to the main project while all the logic
for when to start the SDK and when/what to send to our Backend is inside the module. 
Most of the logic can be seen in the `PlaidReducer` while the handling of the LinkKit SDK is done in the main module 
and is controlled inside `PlaidLinkObserver`.

### Overall `PlaidReducer` flow is:
1. Get link token from our BE to start LinkKit SDK. 
2. Post blockchain event `blockchain.ux.payment.method.plaid.event.receive.link.token` with the token received so that 
`PlaidLinkObserver` can start LinkKit with that token.
3. User enters his credentials inside LinkKit SDK. If all goes well we get back a the success token and id.
At this point `PlaidReducer` is in the step `waitingForAccountLinkResult` waiting for the event 
`blockchain.ux.payment.method.plaid.event.finished)` to be posted.
4. When we get a sucess response we POST that token and id to our BE.
5. After we wait for that account id to be moved to active state so it can be used.
6. Emit event to update source selection of the amount screen with that newly added account.
`blockchain.ux.transaction.action.select.payment.method`


### To start Plaid from the Buy Flow, check `TransactionFlowRouter`:

`TransactionFlowRouter.presentLinkABank(transactionModel:)` handles if Plaid or Yodlee should be shown to the user

`TransactionFlowRouter.presentPlaidLinkABank(transactionModel:)` handles displaying Plaid flow.

[X] Add new bank with Plaid
[X] Add new bank: Update screen
[X] Add new bank: Handle BE errors

[ ] Renew credentials of previously added Plaid account
[ ] Renew credentials: Update screen
[X] Renew credentials: Handle BE errors

[X] Migrate Yodlee account to Plaid
[ ] Migrate: Update screen
[X] Migrate: Handle BE errors

Renew and Migrate states are handled by `BuyTransactionEngine` on the 
`createOrder(pendingTransaction:) -> Single<TransactionOrder?>`

### To start adding a bank via Plaid from the Deposit Flow, check `DepositRootRouter` and `DepositRootInteractor`:

`DepositRootRouter.showLinkBankFlow()` handles if Plaid or Yodlee should be shown to the user.

`DepositRootRouter.showLinkBankFlowWithPlaid()` handles displaying Plaid flow.

[X] Add new bank with Plaid
[ ] Add new bank: Update screen
[X] Add new bank: Handle BE errors
[X] Add new bank: Handle LinkKit SDK errors

### To migrate a bank to Plaid or renew its credentials from the Deposit Flow, check `FiatDepositTransactionEngine`:

`FiatDepositTransactionEngine.execute(pendingTransaction:) -> Single<TransactionResult>` checks if the source account
needs update.

[X] Renew credentials of previously added Plaid account
[ ] Renew credentials: Update screen
[X] Renew credentials: Handle BE errors
[X] Renew credentials: Handle LinkKit SDK errors

[X] Migrate Yodlee account to Plaid
[ ] Migrate: Update screen
[X] Migrate: Handle BE errors
[X] Migrate: Handle LinkKit SDK errors

### To start Plaid from the Settings, check `PaymentMethodLinkingRouter`:
 
`PaymentMethodLinkingRouter.routeToDirectBankLinkingFlow(from viewController:,completion:)` is where the check for the
Plaid Feature Flag and if the user is an American user to than start the flow with Plaid or go with the flow with Yodlee.

[X] Add new bank with Plaid
[ ] Add new bank: Update screen
[X] Add new bank: Handle BE errors

[ ] Handle case where the call to get the link token fails
