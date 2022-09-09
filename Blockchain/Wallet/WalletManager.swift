// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import BitcoinKit
import DIKit
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import JavaScriptCore
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit
import WalletPayloadKit

/**
 Manager object for operations to the Blockchain Wallet.
 */
@objc
class WalletManager: NSObject, JSContextProviderAPI, WalletRepositoryProvider, WalletManagerAPI {

    @Inject static var shared: WalletManager

    @LazyInject var loggedInReloadHandler: LoggedInReloadAPI

    @objc static var sharedInstance: WalletManager {
        shared
    }

    // TODO: Replace this with asset-specific wallet architecture
    @objc let wallet: Wallet
    let reactiveWallet: ReactiveWalletAPI

    // TODO: make this private(set) once other methods in RootService have been migrated in here
    @objc var latestMultiAddressResponse: MultiAddressResponse?

    @objc var didChangePassword: Bool = false

    weak var authDelegate: WalletAuthDelegate?
    weak var accountInfoDelegate: WalletAccountInfoDelegate?
    @objc weak var addressesDelegate: WalletAddressesDelegate?
    @objc weak var recoveryDelegate: WalletRecoveryDelegate?
    @objc weak var historyDelegate: WalletHistoryDelegate?
    @objc weak var accountInfoAndExchangeRatesDelegate: WalletAccountInfoAndExchangeRatesDelegate?
    @objc weak var backupDelegate: WalletBackupDelegate?
    weak var keyImportDelegate: WalletKeyImportDelegate?
    weak var secondPasswordDelegate: WalletSecondPasswordDelegate?

    private(set) var repository: WalletRepositoryAPI!
    private(set) var legacyRepository: WalletRepository!

    init(
        wallet: Wallet = Wallet()!,
        appSettings: AppSettingsAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.wallet = wallet
        self.reactiveWallet = reactiveWallet
        super.init()
        let repository = WalletRepository(
            jsContextProvider: self,
            appSettings: appSettings,
            reactiveWallet: reactiveWallet,
            featureFlagService: featureFlagService
        )
        let walletConnect = WalletConnectMetadata(
            jsContextProvider: self
        )
        legacyRepository = repository
        self.repository = repository
        self.wallet.repository = repository
        self.wallet.delegate = self
        self.wallet.ethereum.reactiveWallet = reactiveWallet
        self.wallet.bitcoin.reactiveWallet = reactiveWallet
        self.wallet.walletConnect = walletConnect
        self.wallet.handleReload = { [weak self] in
            self?.loggedInReloadHandler.reload()
        }
    }

    /// Returns the context. Should be invoked on the main queue always.
    /// If the context has not been generated,
    func fetchJSContext() -> JSContext {
        wallet.loadContextIfNeeded()
    }

    /// Performs closing operations on the wallet. This should be called on logout and
    /// when the app is backgrounded
    func close() {
        latestMultiAddressResponse = nil
        wallet.resetSyncStatus()
        wallet.loadJS()
        wallet.hasLoadedAccountInfo = false

        beginBackgroundUpdateTask()
    }

    @objc func forgetWallet() {
        BlockchainSettings.App.shared.clearPin()

        // Clear all cookies (important one is the server session id SID)
        HTTPCookieStorage.shared.deleteAllCookies()

        legacyRepository.legacySessionToken = nil
        legacyRepository.legacyPassword = nil

        BlockchainSettings.App.shared.set(guid: nil)
        BlockchainSettings.App.shared.set(sharedKey: nil)

        wallet.loadJS()

        latestMultiAddressResponse = nil

        let clearOnLogoutHandler: ClearOnLogoutAPI = DIKit.resolve()
        clearOnLogoutHandler.clearOnLogout()

        BlockchainSettings.App.shared.set(biometryEnabled: false)
    }

    private var backgroundUpdateTaskIdentifer: UIBackgroundTaskIdentifier?

    private func beginBackgroundUpdateTask() {
        // We're using a background task to ensure we get enough time to sync. The bg task has to be ended before or when the timer expires,
        // otherwise the app gets killed by the system. Always kill the old handler before starting a new one. In case the system starts a bg
        // task when the app goes into background, comes to foreground and goes to background before the first background task was ended.
        // In that case the first background task is never killed and the system kills the app when the maximum time is up.
        endBackgroundUpdateTask()

        backgroundUpdateTaskIdentifer = UIApplication.shared.beginBackgroundTask { [unowned self] in
            self.endBackgroundUpdateTask()
        }
    }

    private func endBackgroundUpdateTask() {
        guard let backgroundUpdateTaskIdentifer = backgroundUpdateTaskIdentifer else { return }
        UIApplication.shared.endBackgroundTask(backgroundUpdateTaskIdentifer)
    }

    fileprivate func updateFiatSymbols() {
        guard wallet.hasLoadedAccountInfo == true else { return }

        guard let fiatCode = wallet.accountInfo["currency"] as? String else {
            Logger.shared.warning("Could not get fiat code")
            return
        }
        guard let btcRates = wallet.btcRates else {
            Logger.shared.warning("btcRates not present")
            return
        }
        guard var currencySymbols = btcRates[fiatCode] as? [AnyHashable: Any] else {
            Logger.shared.warning("Currency symbols dictionary is nil")
            return
        }
        currencySymbols["code"] = fiatCode
        latestMultiAddressResponse?.symbol_local = CurrencySymbol(dict: currencySymbols)
    }
}

extension WalletManager {
    func loadWalletJS() {
        wallet.loadJS()
    }

    func fetch(with password: String) {
        wallet.fetch(with: password)
    }

    func walletIsInitialized() -> Bool {
        wallet.isInitialized()
    }

    func walletNeedsSecondPassword() -> Bool {
        wallet.needsSecondPassword()
    }

    func walletGetHistoryForAllAssets() {
        wallet.getHistoryForAllAssets()
    }

    func newWallet(password: String, email: String) {
        wallet.newAccount(password, email: email)
    }

    func load(with guid: String, sharedKey: String, password: String) {
        wallet.load(withGuid: guid, sharedKey: sharedKey, password: password)
    }

    func markWalletAsNew() {
        wallet.isNew = true
    }

    func recoverFromMetadata(seedPhrase: String) {
        wallet.recoverFromMetadata(withMnemonicPassphrase: seedPhrase)
    }

    func recover(email: String, password: String, seedPhrase: String) {
        wallet.recover(
            withEmail: email,
            password: password,
            mnemonicPassphrase: seedPhrase
        )
    }
}

extension WalletManager: WalletDelegate {

    // MARK: - Auth

    func didCreateNewAccount(_ guid: String!, sharedKey: String!, password: String!) {
        // this is no-op intentionally
        // for context, `CreateWalletScreenInteractor` and `RecoverWalletScreenInteractor`
        // are stealing the `Wallet` delegate and capturing this method to do their logic
        //
        // This is added here so that the `WalletManager+Rx` and `WalletManager+Combine`
        // would be able to listen if the method is invoked and handle it.
    }

    func errorCreatingNewAccount(_ message: String!) {
        // this is no-op intentionally ^^ same as above ^^
    }

    func walletJSReady() {
        // this is no-op intentionally ^^ same as above ^^
    }

    func walletDidGetBtcExchangeRates() {
        updateFiatSymbols()
    }

    func walletDidLoad() {
        Logger.shared.info("walletDidLoad()")
        endBackgroundUpdateTask()
    }

    func walletDidDecrypt(withSharedKey sharedKey: String?, guid: String?) {
        Logger.shared.info("walletDidDecrypt()")

        DispatchQueue.main.async {
            self.authDelegate?.didDecryptWallet(
                guid: guid,
                sharedKey: sharedKey,
                password: self.legacyRepository.legacyPassword
            )
        }

        didChangePassword = false
    }

    func walletDidFinishLoad() {
        Logger.shared.info("walletDidFinishLoad()")

        DispatchQueue.main.async {
            self.authDelegate?.authenticationCompleted()
        }
    }

    func walletFailedToDecrypt() {
        Logger.shared.info("walletFailedToDecrypt()")
        DispatchQueue.main.async {
            self.authDelegate?.authenticationError(error:
                AuthenticationError(
                    code: .errorDecryptingWallet
                )
            )
        }
    }

    func walletFailedToLoad() {
        Logger.shared.info("walletFailedToLoad()")
        DispatchQueue.main.async { [unowned self] in
            self.authDelegate?.authenticationError(
                error: AuthenticationError(
                    code: .failedToLoadWallet
                )
            )
        }
    }

    // MARK: - Addresses

    func returnToAddressesScreen() {
        DispatchQueue.main.async { [unowned self] in
            self.addressesDelegate?.returnToAddressesScreen()
        }
    }

    // MARK: - Account Info

    func walletDidGetAccountInfo(_ wallet: Wallet!) {
        DispatchQueue.main.async { [unowned self] in
            self.accountInfoDelegate?.didGetAccountInfo()
        }
    }

    // MARK: - BTC Multiaddress

    func didGet(_ response: MultiAddressResponse) {
        latestMultiAddressResponse = response
        wallet.getAccountInfoAndExchangeRates()
        updateFiatSymbols()
    }

    // MARK: - Backup

    func didBackupWallet() {
        DispatchQueue.main.async { [unowned self] in
            self.backupDelegate?.didBackupWallet()
        }
    }

    func didFailBackupWallet() {
        DispatchQueue.main.async { [unowned self] in
            self.backupDelegate?.didFailBackupWallet()
        }
    }

    // MARK: - Account Info and Exchange Rates on startup

    func walletDidGetAccountInfoAndExchangeRates(_ wallet: Wallet!) {
        DispatchQueue.main.async { [unowned self] in
            self.accountInfoAndExchangeRatesDelegate?.didGetAccountInfoAndExchangeRates()
        }
    }

    // MARK: - Recovery

    func didRecoverWallet() {
        DispatchQueue.main.async { [unowned self] in
            self.recoveryDelegate?.didRecoverWallet()
        }
    }

    func didFailRecovery() {
        DispatchQueue.main.async { [unowned self] in
            self.recoveryDelegate?.didFailRecovery()
        }
    }

    // MARK: - History

    func didFailGetHistory(_ error: String?) {
        DispatchQueue.main.async { [unowned self] in
            self.historyDelegate?.didFailGetHistory(error: error)
        }
    }

    func didFetchBitcoinCashHistory() {
        DispatchQueue.main.async { [unowned self] in
            self.historyDelegate?.didFetchBitcoinCashHistory()
        }
    }

    // MARK: - Second Password

    @objc func getSecondPassword(withSuccess success: WalletSuccessCallback, dismiss: WalletDismissCallback) {
        secondPasswordDelegate?.getSecondPassword(success: success, dismiss: dismiss)
    }

    @objc func getPrivateKeyPassword(withSuccess success: WalletSuccessCallback) {
        secondPasswordDelegate?.getPrivateKeyPassword(success: success)
    }

    // MARK: - Key Importing

    func askUserToAddWatchOnlyAddress(_ address: AssetAddress, then: @escaping () -> Void) {
        DispatchQueue.main.async { [unowned self] in
            self.keyImportDelegate?.askUserToAddWatchOnlyAddress(address, then: then)
        }
    }

    @objc func scanPrivateKeyForWatchOnlyAddress(_ address: String) {
        let address = BitcoinAssetAddress(publicKey: address)
        DispatchQueue.main.async { [unowned self] in
            self.keyImportDelegate?.scanPrivateKeyForWatchOnlyAddress(address)
        }
    }
}
