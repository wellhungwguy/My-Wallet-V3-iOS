# Wallet Payload - all things wallet, natively!

## Intro

Historically we used to handle all things related for wallet using a specialized version of `My-Wallet-V3` which 
was written for web in JavaScript, while this has served us well for many years, the overhead of communicating
between JS and the native world of Swift introduced a lot of complexity from threading issues to many other.

This library is a Swift implementation of handling Wallet related methods such as decoding, decrypting, 
encrypting, upgrading and syncing.

## Implementation

Wallet payload handling can become a bit complicated. The following will layout the core classes and methods 
as clearly as possible.

# Core Wallet Models

_The following assumes a v4 wallet payload._

### Wrapper

An object containing, or "wrapping" the `Wallet` object, as well other information, such as the version number.

### Wallet (aka NativeWallet, will be renamed)

An object containing the core information for non-custodial HD (Hierarchical Deterministic) Wallet(s).

### HDWallet

An object containing Account(s) for our HD Wallet, this contains the seedHex which is
used to derive the mnemonic, the master node (BIP39), etc.
_At the time of writing this, only *one* HDWallet ever exists_

### Account 
An object describing an `Account` which contains the `Derivation`(s) array and its `index`
The `index` is used to derive the correct `Derivation`.

### Derivation 
An object which contains the `xpriv` & `xpub` for a given account.
A `Derivation` is described by a `DerivationType` which can either be a `legacy` or `segwit` (aka bech32) which is 
translated in a numerical value.

Further explanation can be found on [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) and
[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) 

# Core Classes/Methods

## State Management

### **WalletRepo**

Holds information for a given session, such as `guid`, `sharedKey`, the encrypted `wallet payload`, etc. 

### **WalletPersistance** 

Monitors and persists any changes that occur on `WalletRepo` to the `Keychain`.

### **WalletHolder**

Responsible for holding the in-memory decrypted wallet and metadata state as `WalletState`

The `WalletState` is expressed as an `enum` and it can either be `partiallyLoaded` or `loaded`.
This is because we have can have partially loaded state for either `Wallet` or `Metadata`. 
So, only when *both* are available the state is fully initialized.

## Classes

### **WalletLogic**

The core place for initializing a decrypted wallet and its metadata, it is also responsible for updating 
the state in `WalletHolder` accordingly.

This also includes restoring/importing a wallet from metadata.

### **WalletFetcher** 

Fetching occurs in a few cases: 
- On fresh login
- On pin entry (after a fresh login)
- On account recovery from metadata (more on that later)

`WalletFetcher` gets the stored encrypted payload from `WalletHolder` and then it decrypts the wallet payload.
After decryption we pass the information to `WalletLogic` where it initializes the `Metadata`

### **WalletCreator**

#### This contains two methods

1) Creating a brand new wallet and saving it on the backend
2) Importing a wallet via a seed phrase.

#### A new wallet (v4) is created as per following

1) Generate a random number for the entropy, see `RNGService`
2) Generate two UUIDs, one for `guid` and `sharedKey`, see method `uuidProvider`
3) With the above information we then generate all the neccessary models
4) We encode the models in usable network responses and in turn into JSON
5) We encrypt the encoded JSON wrapper
6) We save the wallet to the backend

#### Importing a wallet (not created by Blockchain.com)

1) We create an HDWallet with the given seed phrase (mnemonic)
2) We then create master node for each derivation type (legacy & bech32)
3) Using the master nodes we perform a search for used accounts so that we can revive funds, see `UsedAccountsFinder`
4) We then create a wallet as usual (from step 2 of the above steps)


### **WalletSync**

This is responsible for syncing the wallet with the backend.

As of writing this syncing a wallet from iOS can happen from the following cases

1) Change password, see `ChangePasswordService`
2) Verify backup phrase (mnemonic), see `VerifyMnemonicBackupService`
3) Updating a non-custodial BTC note transaction, see `WalletTxNoteStrategy`
