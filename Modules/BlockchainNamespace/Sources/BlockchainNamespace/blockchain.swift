import Foundation

// MARK: I

public protocol I: Sendable, TypeLocalized, SourceCodeIdentifiable {}

public protocol TypeLocalized {
	static var localized: String { get }
}

public protocol SourceCodeIdentifiable: CustomDebugStringConvertible {
	var __: String { get }
}

public extension SourceCodeIdentifiable {
	@inlinable var debugDescription: String { __ }
}

public enum CallAsFunctionExtensions<X> {
	case from
}

public extension I {
	func callAsFunction<Property>(_ keyPath: KeyPath<CallAsFunctionExtensions<I>, (I) -> Property>) -> Property {
		CallAsFunctionExtensions.from[keyPath: keyPath](self)
	}
}

public extension CallAsFunctionExtensions where X == I {
	var id: (I) -> String {{ $0.__ }}
	var localizedType: (I) -> String {{ type(of: $0).localized }}
}

// MARK: L

open class L: @unchecked Sendable, Hashable, I {
	open class var localized: String { "" }
	public let __: String
	public required init(_ id: String) { __ = id }
}

public extension L {
	static func == (lhs: L, rhs: L) -> Bool { lhs.__ == rhs.__ }
	func hash(into hasher: inout Hasher) { hasher.combine(__) }
}

// MARK: generated types

public let blockchain = L_blockchain("blockchain")

public final class L_blockchain: L, I_blockchain {
	public override class var localized: String { NSLocalizedString("blockchain", comment: "") }
}
public protocol I_blockchain: I {}
public extension I_blockchain {
	var `app`: L_blockchain_app { .init("\(__).app") }
	var `db`: L_blockchain_db { .init("\(__).db") }
	var `nabu`: L_blockchain_nabu { .init("\(__).nabu") }
	var `namespace`: L_blockchain_namespace { .init("\(__).namespace") }
	var `session`: L_blockchain_session { .init("\(__).session") }
	var `type`: L_blockchain_type { .init("\(__).type") }
	var `ui`: L_blockchain_ui { .init("\(__).ui") }
	var `user`: L_blockchain_user { .init("\(__).user") }
	var `ux`: L_blockchain_ux { .init("\(__).ux") }
}
public final class L_blockchain_app: L, I_blockchain_app {
	public override class var localized: String { NSLocalizedString("blockchain.app", comment: "") }
}
public protocol I_blockchain_app: I {}
public extension I_blockchain_app {
	var `configuration`: L_blockchain_app_configuration { .init("\(__).configuration") }
	var `deep_link`: L_blockchain_app_deep__link { .init("\(__).deep_link") }
	var `did`: L_blockchain_app_did { .init("\(__).did") }
	var `enter`: L_blockchain_app_enter { .init("\(__).enter") }
	var `fraud`: L_blockchain_app_fraud { .init("\(__).fraud") }
	var `is`: L_blockchain_app_is { .init("\(__).is") }
	var `process`: L_blockchain_app_process { .init("\(__).process") }
}
public final class L_blockchain_app_configuration: L, I_blockchain_app_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration", comment: "") }
}
public protocol I_blockchain_app_configuration: I {}
public extension I_blockchain_app_configuration {
	var `announcements`: L_blockchain_app_configuration_announcements { .init("\(__).announcements") }
	var `app`: L_blockchain_app_configuration_app { .init("\(__).app") }
	var `apple`: L_blockchain_app_configuration_apple { .init("\(__).apple") }
	var `card`: L_blockchain_app_configuration_card { .init("\(__).card") }
	var `customer`: L_blockchain_app_configuration_customer { .init("\(__).customer") }
	var `debug`: L_blockchain_app_configuration_debug { .init("\(__).debug") }
	var `deep_link`: L_blockchain_app_configuration_deep__link { .init("\(__).deep_link") }
	var `frequent`: L_blockchain_app_configuration_frequent { .init("\(__).frequent") }
	var `localized`: L_blockchain_app_configuration_localized { .init("\(__).localized") }
	var `manual`: L_blockchain_app_configuration_manual { .init("\(__).manual") }
	var `native`: L_blockchain_app_configuration_native { .init("\(__).native") }
	var `performance`: L_blockchain_app_configuration_performance { .init("\(__).performance") }
	var `polygon`: L_blockchain_app_configuration_polygon { .init("\(__).polygon") }
	var `prefill`: L_blockchain_app_configuration_prefill { .init("\(__).prefill") }
	var `pubkey`: L_blockchain_app_configuration_pubkey { .init("\(__).pubkey") }
	var `redesign`: L_blockchain_app_configuration_redesign { .init("\(__).redesign") }
	var `remote`: L_blockchain_app_configuration_remote { .init("\(__).remote") }
	var `request`: L_blockchain_app_configuration_request { .init("\(__).request") }
	var `SSL`: L_blockchain_app_configuration_SSL { .init("\(__).SSL") }
	var `stx`: L_blockchain_app_configuration_stx { .init("\(__).stx") }
	var `tabs`: L_blockchain_app_configuration_tabs { .init("\(__).tabs") }
	var `test`: L_blockchain_app_configuration_test { .init("\(__).test") }
	var `transaction`: L_blockchain_app_configuration_transaction { .init("\(__).transaction") }
	var `unified`: L_blockchain_app_configuration_unified { .init("\(__).unified") }
}
public final class L_blockchain_app_configuration_announcements: L, I_blockchain_app_configuration_announcements {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.announcements", comment: "") }
}
public protocol I_blockchain_app_configuration_announcements: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_app: L, I_blockchain_app_configuration_app {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app", comment: "") }
}
public protocol I_blockchain_app_configuration_app: I {}
public extension I_blockchain_app_configuration_app {
	var `maintenance`: L_blockchain_app_configuration_app_maintenance { .init("\(__).maintenance") }
}
public final class L_blockchain_app_configuration_app_maintenance: L, I_blockchain_app_configuration_app_maintenance {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.maintenance", comment: "") }
}
public protocol I_blockchain_app_configuration_app_maintenance: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_apple: L, I_blockchain_app_configuration_apple {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple", comment: "") }
}
public protocol I_blockchain_app_configuration_apple: I {}
public extension I_blockchain_app_configuration_apple {
	var `pay`: L_blockchain_app_configuration_apple_pay { .init("\(__).pay") }
}
public final class L_blockchain_app_configuration_apple_pay: L, I_blockchain_app_configuration_apple_pay {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay: I {}
public extension I_blockchain_app_configuration_apple_pay {
	var `is`: L_blockchain_app_configuration_apple_pay_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_apple_pay_is: L, I_blockchain_app_configuration_apple_pay_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay.is", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay_is: I {}
public extension I_blockchain_app_configuration_apple_pay_is {
	var `enabled`: L_blockchain_app_configuration_apple_pay_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_apple_pay_is_enabled: L, I_blockchain_app_configuration_apple_pay_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_card: L, I_blockchain_app_configuration_card {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card", comment: "") }
}
public protocol I_blockchain_app_configuration_card: I {}
public extension I_blockchain_app_configuration_card {
	var `issuing`: L_blockchain_app_configuration_card_issuing { .init("\(__).issuing") }
}
public final class L_blockchain_app_configuration_card_issuing: L, I_blockchain_app_configuration_card_issuing {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.issuing", comment: "") }
}
public protocol I_blockchain_app_configuration_card_issuing: I {}
public extension I_blockchain_app_configuration_card_issuing {
	var `is`: L_blockchain_app_configuration_card_issuing_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_card_issuing_is: L, I_blockchain_app_configuration_card_issuing_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.issuing.is", comment: "") }
}
public protocol I_blockchain_app_configuration_card_issuing_is: I {}
public extension I_blockchain_app_configuration_card_issuing_is {
	var `enabled`: L_blockchain_app_configuration_card_issuing_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_card_issuing_is_enabled: L, I_blockchain_app_configuration_card_issuing_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.issuing.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_card_issuing_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_customer: L, I_blockchain_app_configuration_customer {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer", comment: "") }
}
public protocol I_blockchain_app_configuration_customer: I {}
public extension I_blockchain_app_configuration_customer {
	var `support`: L_blockchain_app_configuration_customer_support { .init("\(__).support") }
}
public final class L_blockchain_app_configuration_customer_support: L, I_blockchain_app_configuration_customer_support {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support: I {}
public extension I_blockchain_app_configuration_customer_support {
	var `is`: L_blockchain_app_configuration_customer_support_is { .init("\(__).is") }
	var `url`: L_blockchain_app_configuration_customer_support_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_customer_support_is: L, I_blockchain_app_configuration_customer_support_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.is", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_is: I {}
public extension I_blockchain_app_configuration_customer_support_is {
	var `enabled`: L_blockchain_app_configuration_customer_support_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_customer_support_is_enabled: L, I_blockchain_app_configuration_customer_support_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_customer_support_url: L, I_blockchain_app_configuration_customer_support_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.url", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_debug: L, I_blockchain_app_configuration_debug {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.debug", comment: "") }
}
public protocol I_blockchain_app_configuration_debug: I {}
public extension I_blockchain_app_configuration_debug {
	var `observers`: L_blockchain_app_configuration_debug_observers { .init("\(__).observers") }
}
public final class L_blockchain_app_configuration_debug_observers: L, I_blockchain_app_configuration_debug_observers {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.debug.observers", comment: "") }
}
public protocol I_blockchain_app_configuration_debug_observers: I_blockchain_db_type_array_of_tags, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_deep__link: L, I_blockchain_app_configuration_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.deep_link", comment: "") }
}
public protocol I_blockchain_app_configuration_deep__link: I {}
public extension I_blockchain_app_configuration_deep__link {
	var `rules`: L_blockchain_app_configuration_deep__link_rules { .init("\(__).rules") }
}
public final class L_blockchain_app_configuration_deep__link_rules: L, I_blockchain_app_configuration_deep__link_rules {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.deep_link.rules", comment: "") }
}
public protocol I_blockchain_app_configuration_deep__link_rules: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_frequent: L, I_blockchain_app_configuration_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent: I {}
public extension I_blockchain_app_configuration_frequent {
	var `action`: L_blockchain_app_configuration_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_app_configuration_frequent_action: L, I_blockchain_app_configuration_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent.action", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent_action: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_localized: L, I_blockchain_app_configuration_localized {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized", comment: "") }
}
public protocol I_blockchain_app_configuration_localized: I {}
public extension I_blockchain_app_configuration_localized {
	var `error`: L_blockchain_app_configuration_localized_error { .init("\(__).error") }
}
public final class L_blockchain_app_configuration_localized_error: L, I_blockchain_app_configuration_localized_error {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized.error", comment: "") }
}
public protocol I_blockchain_app_configuration_localized_error: I {}
public extension I_blockchain_app_configuration_localized_error {
	var `override`: L_blockchain_app_configuration_localized_error_override { .init("\(__).override") }
}
public final class L_blockchain_app_configuration_localized_error_override: L, I_blockchain_app_configuration_localized_error_override {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized.error.override", comment: "") }
}
public protocol I_blockchain_app_configuration_localized_error_override: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_configuration_manual: L, I_blockchain_app_configuration_manual {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual", comment: "") }
}
public protocol I_blockchain_app_configuration_manual: I {}
public extension I_blockchain_app_configuration_manual {
	var `login`: L_blockchain_app_configuration_manual_login { .init("\(__).login") }
}
public final class L_blockchain_app_configuration_manual_login: L, I_blockchain_app_configuration_manual_login {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login: I {}
public extension I_blockchain_app_configuration_manual_login {
	var `is`: L_blockchain_app_configuration_manual_login_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_manual_login_is: L, I_blockchain_app_configuration_manual_login_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login.is", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login_is: I {}
public extension I_blockchain_app_configuration_manual_login_is {
	var `enabled`: L_blockchain_app_configuration_manual_login_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_manual_login_is_enabled: L, I_blockchain_app_configuration_manual_login_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_native: L, I_blockchain_app_configuration_native {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.native", comment: "") }
}
public protocol I_blockchain_app_configuration_native: I {}
public extension I_blockchain_app_configuration_native {
	var `wallet`: L_blockchain_app_configuration_native_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_app_configuration_native_wallet: L, I_blockchain_app_configuration_native_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.native.wallet", comment: "") }
}
public protocol I_blockchain_app_configuration_native_wallet: I {}
public extension I_blockchain_app_configuration_native_wallet {
	var `payload`: L_blockchain_app_configuration_native_wallet_payload { .init("\(__).payload") }
}
public final class L_blockchain_app_configuration_native_wallet_payload: L, I_blockchain_app_configuration_native_wallet_payload {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.native.wallet.payload", comment: "") }
}
public protocol I_blockchain_app_configuration_native_wallet_payload: I {}
public extension I_blockchain_app_configuration_native_wallet_payload {
	var `is`: L_blockchain_app_configuration_native_wallet_payload_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_native_wallet_payload_is: L, I_blockchain_app_configuration_native_wallet_payload_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.native.wallet.payload.is", comment: "") }
}
public protocol I_blockchain_app_configuration_native_wallet_payload_is: I {}
public extension I_blockchain_app_configuration_native_wallet_payload_is {
	var `enabled`: L_blockchain_app_configuration_native_wallet_payload_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_native_wallet_payload_is_enabled: L, I_blockchain_app_configuration_native_wallet_payload_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.native.wallet.payload.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_native_wallet_payload_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_performance: L, I_blockchain_app_configuration_performance {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.performance", comment: "") }
}
public protocol I_blockchain_app_configuration_performance: I {}
public extension I_blockchain_app_configuration_performance {
	var `tracing`: L_blockchain_app_configuration_performance_tracing { .init("\(__).tracing") }
}
public final class L_blockchain_app_configuration_performance_tracing: L, I_blockchain_app_configuration_performance_tracing {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.performance.tracing", comment: "") }
}
public protocol I_blockchain_app_configuration_performance_tracing: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_polygon: L, I_blockchain_app_configuration_polygon {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.polygon", comment: "") }
}
public protocol I_blockchain_app_configuration_polygon: I {}
public extension I_blockchain_app_configuration_polygon {
	var `is`: L_blockchain_app_configuration_polygon_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_polygon_is: L, I_blockchain_app_configuration_polygon_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.polygon.is", comment: "") }
}
public protocol I_blockchain_app_configuration_polygon_is: I {}
public extension I_blockchain_app_configuration_polygon_is {
	var `enabled`: L_blockchain_app_configuration_polygon_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_polygon_is_enabled: L, I_blockchain_app_configuration_polygon_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.polygon.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_polygon_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_prefill: L, I_blockchain_app_configuration_prefill {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill: I {}
public extension I_blockchain_app_configuration_prefill {
	var `is`: L_blockchain_app_configuration_prefill_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_prefill_is: L, I_blockchain_app_configuration_prefill_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill.is", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill_is: I {}
public extension I_blockchain_app_configuration_prefill_is {
	var `enabled`: L_blockchain_app_configuration_prefill_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_prefill_is_enabled: L, I_blockchain_app_configuration_prefill_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_pubkey: L, I_blockchain_app_configuration_pubkey {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey: I {}
public extension I_blockchain_app_configuration_pubkey {
	var `service`: L_blockchain_app_configuration_pubkey_service { .init("\(__).service") }
}
public final class L_blockchain_app_configuration_pubkey_service: L, I_blockchain_app_configuration_pubkey_service {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey.service", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey_service: I {}
public extension I_blockchain_app_configuration_pubkey_service {
	var `auth`: L_blockchain_app_configuration_pubkey_service_auth { .init("\(__).auth") }
}
public final class L_blockchain_app_configuration_pubkey_service_auth: L, I_blockchain_app_configuration_pubkey_service_auth {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey.service.auth", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey_service_auth: I_blockchain_db_type_array_of_strings, I_blockchain_session_state_preference_value {}
public final class L_blockchain_app_configuration_redesign: L, I_blockchain_app_configuration_redesign {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.redesign", comment: "") }
}
public protocol I_blockchain_app_configuration_redesign: I {}
public extension I_blockchain_app_configuration_redesign {
	var `checkout`: L_blockchain_app_configuration_redesign_checkout { .init("\(__).checkout") }
}
public final class L_blockchain_app_configuration_redesign_checkout: L, I_blockchain_app_configuration_redesign_checkout {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.redesign.checkout", comment: "") }
}
public protocol I_blockchain_app_configuration_redesign_checkout: I {}
public extension I_blockchain_app_configuration_redesign_checkout {
	var `is`: L_blockchain_app_configuration_redesign_checkout_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_redesign_checkout_is: L, I_blockchain_app_configuration_redesign_checkout_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.redesign.checkout.is", comment: "") }
}
public protocol I_blockchain_app_configuration_redesign_checkout_is: I {}
public extension I_blockchain_app_configuration_redesign_checkout_is {
	var `enabled`: L_blockchain_app_configuration_redesign_checkout_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_redesign_checkout_is_enabled: L, I_blockchain_app_configuration_redesign_checkout_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.redesign.checkout.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_redesign_checkout_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_remote: L, I_blockchain_app_configuration_remote {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote", comment: "") }
}
public protocol I_blockchain_app_configuration_remote: I {}
public extension I_blockchain_app_configuration_remote {
	var `is`: L_blockchain_app_configuration_remote_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_remote_is: L, I_blockchain_app_configuration_remote_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote.is", comment: "") }
}
public protocol I_blockchain_app_configuration_remote_is: I {}
public extension I_blockchain_app_configuration_remote_is {
	var `stale`: L_blockchain_app_configuration_remote_is_stale { .init("\(__).stale") }
}
public final class L_blockchain_app_configuration_remote_is_stale: L, I_blockchain_app_configuration_remote_is_stale {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote.is.stale", comment: "") }
}
public protocol I_blockchain_app_configuration_remote_is_stale: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_configuration_request: L, I_blockchain_app_configuration_request {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request", comment: "") }
}
public protocol I_blockchain_app_configuration_request: I {}
public extension I_blockchain_app_configuration_request {
	var `console`: L_blockchain_app_configuration_request_console { .init("\(__).console") }
}
public final class L_blockchain_app_configuration_request_console: L, I_blockchain_app_configuration_request_console {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request.console", comment: "") }
}
public protocol I_blockchain_app_configuration_request_console: I {}
public extension I_blockchain_app_configuration_request_console {
	var `logging`: L_blockchain_app_configuration_request_console_logging { .init("\(__).logging") }
}
public final class L_blockchain_app_configuration_request_console_logging: L, I_blockchain_app_configuration_request_console_logging {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request.console.logging", comment: "") }
}
public protocol I_blockchain_app_configuration_request_console_logging: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_SSL: L, I_blockchain_app_configuration_SSL {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL: I {}
public extension I_blockchain_app_configuration_SSL {
	var `pinning`: L_blockchain_app_configuration_SSL_pinning { .init("\(__).pinning") }
}
public final class L_blockchain_app_configuration_SSL_pinning: L, I_blockchain_app_configuration_SSL_pinning {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning: I {}
public extension I_blockchain_app_configuration_SSL_pinning {
	var `is`: L_blockchain_app_configuration_SSL_pinning_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_SSL_pinning_is: L, I_blockchain_app_configuration_SSL_pinning_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning.is", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning_is: I {}
public extension I_blockchain_app_configuration_SSL_pinning_is {
	var `enabled`: L_blockchain_app_configuration_SSL_pinning_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_SSL_pinning_is_enabled: L, I_blockchain_app_configuration_SSL_pinning_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_stx: L, I_blockchain_app_configuration_stx {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx", comment: "") }
}
public protocol I_blockchain_app_configuration_stx: I {}
public extension I_blockchain_app_configuration_stx {
	var `airdrop`: L_blockchain_app_configuration_stx_airdrop { .init("\(__).airdrop") }
	var `all`: L_blockchain_app_configuration_stx_all { .init("\(__).all") }
}
public final class L_blockchain_app_configuration_stx_airdrop: L, I_blockchain_app_configuration_stx_airdrop {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop: I {}
public extension I_blockchain_app_configuration_stx_airdrop {
	var `users`: L_blockchain_app_configuration_stx_airdrop_users { .init("\(__).users") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users: L, I_blockchain_app_configuration_stx_airdrop_users {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users: I {}
public extension I_blockchain_app_configuration_stx_airdrop_users {
	var `is`: L_blockchain_app_configuration_stx_airdrop_users_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users_is: L, I_blockchain_app_configuration_stx_airdrop_users_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users.is", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users_is: I {}
public extension I_blockchain_app_configuration_stx_airdrop_users_is {
	var `enabled`: L_blockchain_app_configuration_stx_airdrop_users_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users_is_enabled: L, I_blockchain_app_configuration_stx_airdrop_users_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_stx_all: L, I_blockchain_app_configuration_stx_all {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all: I {}
public extension I_blockchain_app_configuration_stx_all {
	var `users`: L_blockchain_app_configuration_stx_all_users { .init("\(__).users") }
}
public final class L_blockchain_app_configuration_stx_all_users: L, I_blockchain_app_configuration_stx_all_users {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users: I {}
public extension I_blockchain_app_configuration_stx_all_users {
	var `is`: L_blockchain_app_configuration_stx_all_users_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_stx_all_users_is: L, I_blockchain_app_configuration_stx_all_users_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users.is", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users_is: I {}
public extension I_blockchain_app_configuration_stx_all_users_is {
	var `enabled`: L_blockchain_app_configuration_stx_all_users_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_stx_all_users_is_enabled: L, I_blockchain_app_configuration_stx_all_users_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_tabs: L, I_blockchain_app_configuration_tabs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.tabs", comment: "") }
}
public protocol I_blockchain_app_configuration_tabs: I_blockchain_db_type_array_of_tags, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_test: L, I_blockchain_app_configuration_test {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test", comment: "") }
}
public protocol I_blockchain_app_configuration_test: I {}
public extension I_blockchain_app_configuration_test {
	var `shared`: L_blockchain_app_configuration_test_shared { .init("\(__).shared") }
}
public final class L_blockchain_app_configuration_test_shared: L, I_blockchain_app_configuration_test_shared {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test.shared", comment: "") }
}
public protocol I_blockchain_app_configuration_test_shared: I {}
public extension I_blockchain_app_configuration_test_shared {
	var `preference`: L_blockchain_app_configuration_test_shared_preference { .init("\(__).preference") }
}
public final class L_blockchain_app_configuration_test_shared_preference: L, I_blockchain_app_configuration_test_shared_preference {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test.shared.preference", comment: "") }
}
public protocol I_blockchain_app_configuration_test_shared_preference: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_configuration_transaction: L, I_blockchain_app_configuration_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction: I_blockchain_db_collection {}
public extension I_blockchain_app_configuration_transaction {
	var `should`: L_blockchain_app_configuration_transaction_should { .init("\(__).should") }
}
public final class L_blockchain_app_configuration_transaction_should: L, I_blockchain_app_configuration_transaction_should {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should: I {}
public extension I_blockchain_app_configuration_transaction_should {
	var `prefill`: L_blockchain_app_configuration_transaction_should_prefill { .init("\(__).prefill") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill: L, I_blockchain_app_configuration_transaction_should_prefill {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill {
	var `with`: L_blockchain_app_configuration_transaction_should_prefill_with { .init("\(__).with") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with: L, I_blockchain_app_configuration_transaction_should_prefill_with {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill_with {
	var `previous`: L_blockchain_app_configuration_transaction_should_prefill_with_previous { .init("\(__).previous") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with_previous: L, I_blockchain_app_configuration_transaction_should_prefill_with_previous {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with.previous", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with_previous: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill_with_previous {
	var `amount`: L_blockchain_app_configuration_transaction_should_prefill_with_previous_amount { .init("\(__).amount") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with_previous_amount: L, I_blockchain_app_configuration_transaction_should_prefill_with_previous_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with.previous.amount", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with_previous_amount: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_unified: L, I_blockchain_app_configuration_unified {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified", comment: "") }
}
public protocol I_blockchain_app_configuration_unified: I {}
public extension I_blockchain_app_configuration_unified {
	var `sign_in`: L_blockchain_app_configuration_unified_sign__in { .init("\(__).sign_in") }
}
public final class L_blockchain_app_configuration_unified_sign__in: L, I_blockchain_app_configuration_unified_sign__in {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in: I {}
public extension I_blockchain_app_configuration_unified_sign__in {
	var `is`: L_blockchain_app_configuration_unified_sign__in_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_unified_sign__in_is: L, I_blockchain_app_configuration_unified_sign__in_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in.is", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in_is: I {}
public extension I_blockchain_app_configuration_unified_sign__in_is {
	var `enabled`: L_blockchain_app_configuration_unified_sign__in_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_unified_sign__in_is_enabled: L, I_blockchain_app_configuration_unified_sign__in_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_deep__link: L, I_blockchain_app_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link", comment: "") }
}
public protocol I_blockchain_app_deep__link: I {}
public extension I_blockchain_app_deep__link {
	var `activity`: L_blockchain_app_deep__link_activity { .init("\(__).activity") }
	var `asset`: L_blockchain_app_deep__link_asset { .init("\(__).asset") }
	var `buy`: L_blockchain_app_deep__link_buy { .init("\(__).buy") }
	var `dsl`: L_blockchain_app_deep__link_dsl { .init("\(__).dsl") }
	var `kyc`: L_blockchain_app_deep__link_kyc { .init("\(__).kyc") }
	var `qr`: L_blockchain_app_deep__link_qr { .init("\(__).qr") }
	var `referral`: L_blockchain_app_deep__link_referral { .init("\(__).referral") }
	var `send`: L_blockchain_app_deep__link_send { .init("\(__).send") }
}
public final class L_blockchain_app_deep__link_activity: L, I_blockchain_app_deep__link_activity {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity: I {}
public extension I_blockchain_app_deep__link_activity {
	var `transaction`: L_blockchain_app_deep__link_activity_transaction { .init("\(__).transaction") }
}
public final class L_blockchain_app_deep__link_activity_transaction: L, I_blockchain_app_deep__link_activity_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity.transaction", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity_transaction: I {}
public extension I_blockchain_app_deep__link_activity_transaction {
	var `id`: L_blockchain_app_deep__link_activity_transaction_id { .init("\(__).id") }
}
public final class L_blockchain_app_deep__link_activity_transaction_id: L, I_blockchain_app_deep__link_activity_transaction_id {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity.transaction.id", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity_transaction_id: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_asset: L, I_blockchain_app_deep__link_asset {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.asset", comment: "") }
}
public protocol I_blockchain_app_deep__link_asset: I {}
public extension I_blockchain_app_deep__link_asset {
	var `code`: L_blockchain_app_deep__link_asset_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_asset_code: L, I_blockchain_app_deep__link_asset_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.asset.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_asset_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_buy: L, I_blockchain_app_deep__link_buy {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy: I {}
public extension I_blockchain_app_deep__link_buy {
	var `amount`: L_blockchain_app_deep__link_buy_amount { .init("\(__).amount") }
	var `crypto`: L_blockchain_app_deep__link_buy_crypto { .init("\(__).crypto") }
}
public final class L_blockchain_app_deep__link_buy_amount: L, I_blockchain_app_deep__link_buy_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.amount", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_amount: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_buy_crypto: L, I_blockchain_app_deep__link_buy_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.crypto", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_crypto: I {}
public extension I_blockchain_app_deep__link_buy_crypto {
	var `code`: L_blockchain_app_deep__link_buy_crypto_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_buy_crypto_code: L, I_blockchain_app_deep__link_buy_crypto_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.crypto.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_crypto_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_dsl: L, I_blockchain_app_deep__link_dsl {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl: I {}
public extension I_blockchain_app_deep__link_dsl {
	var `is`: L_blockchain_app_deep__link_dsl_is { .init("\(__).is") }
}
public final class L_blockchain_app_deep__link_dsl_is: L, I_blockchain_app_deep__link_dsl_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl.is", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl_is: I {}
public extension I_blockchain_app_deep__link_dsl_is {
	var `enabled`: L_blockchain_app_deep__link_dsl_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_deep__link_dsl_is_enabled: L, I_blockchain_app_deep__link_dsl_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl.is.enabled", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl_is_enabled: I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_deep__link_kyc: L, I_blockchain_app_deep__link_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc: I {}
public extension I_blockchain_app_deep__link_kyc {
	var `tier`: L_blockchain_app_deep__link_kyc_tier { .init("\(__).tier") }
}
public final class L_blockchain_app_deep__link_kyc_tier: L, I_blockchain_app_deep__link_kyc_tier {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc.tier", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc_tier: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_qr: L, I_blockchain_app_deep__link_qr {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.qr", comment: "") }
}
public protocol I_blockchain_app_deep__link_qr: I {}
public final class L_blockchain_app_deep__link_referral: L, I_blockchain_app_deep__link_referral {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.referral", comment: "") }
}
public protocol I_blockchain_app_deep__link_referral: I {}
public final class L_blockchain_app_deep__link_send: L, I_blockchain_app_deep__link_send {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send", comment: "") }
}
public protocol I_blockchain_app_deep__link_send: I {}
public extension I_blockchain_app_deep__link_send {
	var `amount`: L_blockchain_app_deep__link_send_amount { .init("\(__).amount") }
	var `crypto`: L_blockchain_app_deep__link_send_crypto { .init("\(__).crypto") }
	var `destination`: L_blockchain_app_deep__link_send_destination { .init("\(__).destination") }
}
public final class L_blockchain_app_deep__link_send_amount: L, I_blockchain_app_deep__link_send_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.amount", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_amount: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_send_crypto: L, I_blockchain_app_deep__link_send_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.crypto", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_crypto: I {}
public extension I_blockchain_app_deep__link_send_crypto {
	var `code`: L_blockchain_app_deep__link_send_crypto_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_send_crypto_code: L, I_blockchain_app_deep__link_send_crypto_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.crypto.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_crypto_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_send_destination: L, I_blockchain_app_deep__link_send_destination {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.destination", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_destination: I_blockchain_db_type_string {}
public final class L_blockchain_app_did: L, I_blockchain_app_did {
	public override class var localized: String { NSLocalizedString("blockchain.app.did", comment: "") }
}
public protocol I_blockchain_app_did: I {}
public extension I_blockchain_app_did {
	var `finish`: L_blockchain_app_did_finish { .init("\(__).finish") }
}
public final class L_blockchain_app_did_finish: L, I_blockchain_app_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.app.did.finish", comment: "") }
}
public protocol I_blockchain_app_did_finish: I {}
public extension I_blockchain_app_did_finish {
	var `launching`: L_blockchain_app_did_finish_launching { .init("\(__).launching") }
}
public final class L_blockchain_app_did_finish_launching: L, I_blockchain_app_did_finish_launching {
	public override class var localized: String { NSLocalizedString("blockchain.app.did.finish.launching", comment: "") }
}
public protocol I_blockchain_app_did_finish_launching: I_blockchain_db_type_boolean {}
public final class L_blockchain_app_enter: L, I_blockchain_app_enter {
	public override class var localized: String { NSLocalizedString("blockchain.app.enter", comment: "") }
}
public protocol I_blockchain_app_enter: I {}
public extension I_blockchain_app_enter {
	var `into`: L_blockchain_app_enter_into { .init("\(__).into") }
}
public final class L_blockchain_app_enter_into: L, I_blockchain_app_enter_into {
	public override class var localized: String { NSLocalizedString("blockchain.app.enter.into", comment: "") }
}
public protocol I_blockchain_app_enter_into: I_blockchain_ux_type_story {}
public final class L_blockchain_app_fraud: L, I_blockchain_app_fraud {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud", comment: "") }
}
public protocol I_blockchain_app_fraud: I {}
public extension I_blockchain_app_fraud {
	var `sardine`: L_blockchain_app_fraud_sardine { .init("\(__).sardine") }
}
public final class L_blockchain_app_fraud_sardine: L, I_blockchain_app_fraud_sardine {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine: I {}
public extension I_blockchain_app_fraud_sardine {
	var `client`: L_blockchain_app_fraud_sardine_client { .init("\(__).client") }
	var `current`: L_blockchain_app_fraud_sardine_current { .init("\(__).current") }
	var `flow`: L_blockchain_app_fraud_sardine_flow { .init("\(__).flow") }
	var `session`: L_blockchain_app_fraud_sardine_session { .init("\(__).session") }
	var `submit`: L_blockchain_app_fraud_sardine_submit { .init("\(__).submit") }
	var `trigger`: L_blockchain_app_fraud_sardine_trigger { .init("\(__).trigger") }
	var `user`: L_blockchain_app_fraud_sardine_user { .init("\(__).user") }
}
public final class L_blockchain_app_fraud_sardine_client: L, I_blockchain_app_fraud_sardine_client {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.client", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_client: I {}
public extension I_blockchain_app_fraud_sardine_client {
	var `identifier`: L_blockchain_app_fraud_sardine_client_identifier { .init("\(__).identifier") }
}
public final class L_blockchain_app_fraud_sardine_client_identifier: L, I_blockchain_app_fraud_sardine_client_identifier {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.client.identifier", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_client_identifier: I_blockchain_db_type_string, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_current: L, I_blockchain_app_fraud_sardine_current {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.current", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_current: I {}
public extension I_blockchain_app_fraud_sardine_current {
	var `flow`: L_blockchain_app_fraud_sardine_current_flow { .init("\(__).flow") }
}
public final class L_blockchain_app_fraud_sardine_current_flow: L, I_blockchain_app_fraud_sardine_current_flow {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.current.flow", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_current_flow: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_fraud_sardine_flow: L, I_blockchain_app_fraud_sardine_flow {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.flow", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_flow: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_session: L, I_blockchain_app_fraud_sardine_session {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.session", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_session: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_fraud_sardine_submit: L, I_blockchain_app_fraud_sardine_submit {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.submit", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_submit: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_app_fraud_sardine_trigger: L, I_blockchain_app_fraud_sardine_trigger {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.trigger", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_trigger: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_user: L, I_blockchain_app_fraud_sardine_user {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.user", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_user: I {}
public extension I_blockchain_app_fraud_sardine_user {
	var `identifier`: L_blockchain_app_fraud_sardine_user_identifier { .init("\(__).identifier") }
}
public final class L_blockchain_app_fraud_sardine_user_identifier: L, I_blockchain_app_fraud_sardine_user_identifier {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.user.identifier", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_user_identifier: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_is: L, I_blockchain_app_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.is", comment: "") }
}
public protocol I_blockchain_app_is: I {}
public extension I_blockchain_app_is {
	var `ready`: L_blockchain_app_is_ready { .init("\(__).ready") }
}
public final class L_blockchain_app_is_ready: L, I_blockchain_app_is_ready {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready", comment: "") }
}
public protocol I_blockchain_app_is_ready: I {}
public extension I_blockchain_app_is_ready {
	var `for`: L_blockchain_app_is_ready_for { .init("\(__).for") }
}
public final class L_blockchain_app_is_ready_for: L, I_blockchain_app_is_ready_for {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready.for", comment: "") }
}
public protocol I_blockchain_app_is_ready_for: I {}
public extension I_blockchain_app_is_ready_for {
	var `deep_link`: L_blockchain_app_is_ready_for_deep__link { .init("\(__).deep_link") }
}
public final class L_blockchain_app_is_ready_for_deep__link: L, I_blockchain_app_is_ready_for_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready.for.deep_link", comment: "") }
}
public protocol I_blockchain_app_is_ready_for_deep__link: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_app_process: L, I_blockchain_app_process {
	public override class var localized: String { NSLocalizedString("blockchain.app.process", comment: "") }
}
public protocol I_blockchain_app_process: I {}
public extension I_blockchain_app_process {
	var `deep_link`: L_blockchain_app_process_deep__link { .init("\(__).deep_link") }
}
public final class L_blockchain_app_process_deep__link: L, I_blockchain_app_process_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link", comment: "") }
}
public protocol I_blockchain_app_process_deep__link: I {}
public extension I_blockchain_app_process_deep__link {
	var `error`: L_blockchain_app_process_deep__link_error { .init("\(__).error") }
	var `url`: L_blockchain_app_process_deep__link_url { .init("\(__).url") }
}
public final class L_blockchain_app_process_deep__link_error: L, I_blockchain_app_process_deep__link_error {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link.error", comment: "") }
}
public protocol I_blockchain_app_process_deep__link_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_app_process_deep__link_url: L, I_blockchain_app_process_deep__link_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link.url", comment: "") }
}
public protocol I_blockchain_app_process_deep__link_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_db: L, I_blockchain_db {
	public override class var localized: String { NSLocalizedString("blockchain.db", comment: "") }
}
public protocol I_blockchain_db: I {}
public extension I_blockchain_db {
	var `array`: L_blockchain_db_array { .init("\(__).array") }
	var `collection`: L_blockchain_db_collection { .init("\(__).collection") }
	var `field`: L_blockchain_db_field { .init("\(__).field") }
	var `leaf`: L_blockchain_db_leaf { .init("\(__).leaf") }
	var `type`: L_blockchain_db_type { .init("\(__).type") }
}
public final class L_blockchain_db_array: L, I_blockchain_db_array {
	public override class var localized: String { NSLocalizedString("blockchain.db.array", comment: "") }
}
public protocol I_blockchain_db_array: I {}
public final class L_blockchain_db_collection: L, I_blockchain_db_collection {
	public override class var localized: String { NSLocalizedString("blockchain.db.collection", comment: "") }
}
public protocol I_blockchain_db_collection: I {}
public extension I_blockchain_db_collection {
	var `id`: L_blockchain_db_collection_id { .init("\(__).id") }
}
public final class L_blockchain_db_collection_id: L, I_blockchain_db_collection_id {
	public override class var localized: String { NSLocalizedString("blockchain.db.collection.id", comment: "") }
}
public protocol I_blockchain_db_collection_id: I_blockchain_db_type_string {}
public final class L_blockchain_db_field: L, I_blockchain_db_field {
	public override class var localized: String { NSLocalizedString("blockchain.db.field", comment: "") }
}
public protocol I_blockchain_db_field: I {}
public final class L_blockchain_db_leaf: L, I_blockchain_db_leaf {
	public override class var localized: String { NSLocalizedString("blockchain.db.leaf", comment: "") }
}
public protocol I_blockchain_db_leaf: I {}
public final class L_blockchain_db_type: L, I_blockchain_db_type {
	public override class var localized: String { NSLocalizedString("blockchain.db.type", comment: "") }
}
public protocol I_blockchain_db_type: I {}
public extension I_blockchain_db_type {
	var `any`: L_blockchain_db_type_any { .init("\(__).any") }
	var `array`: L_blockchain_db_type_array { .init("\(__).array") }
	var `bigint`: L_blockchain_db_type_bigint { .init("\(__).bigint") }
	var `boolean`: L_blockchain_db_type_boolean { .init("\(__).boolean") }
	var `data`: L_blockchain_db_type_data { .init("\(__).data") }
	var `date`: L_blockchain_db_type_date { .init("\(__).date") }
	var `enum`: L_blockchain_db_type_enum { .init("\(__).enum") }
	var `integer`: L_blockchain_db_type_integer { .init("\(__).integer") }
	var `map`: L_blockchain_db_type_map { .init("\(__).map") }
	var `number`: L_blockchain_db_type_number { .init("\(__).number") }
	var `string`: L_blockchain_db_type_string { .init("\(__).string") }
	var `tag`: L_blockchain_db_type_tag { .init("\(__).tag") }
	var `url`: L_blockchain_db_type_url { .init("\(__).url") }
}
public final class L_blockchain_db_type_any: L, I_blockchain_db_type_any {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.any", comment: "") }
}
public protocol I_blockchain_db_type_any: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_array: L, I_blockchain_db_type_array {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array", comment: "") }
}
public protocol I_blockchain_db_type_array: I {}
public extension I_blockchain_db_type_array {
	var `of`: L_blockchain_db_type_array_of { .init("\(__).of") }
}
public final class L_blockchain_db_type_array_of: L, I_blockchain_db_type_array_of {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of", comment: "") }
}
public protocol I_blockchain_db_type_array_of: I {}
public extension I_blockchain_db_type_array_of {
	var `booleans`: L_blockchain_db_type_array_of_booleans { .init("\(__).booleans") }
	var `dates`: L_blockchain_db_type_array_of_dates { .init("\(__).dates") }
	var `integers`: L_blockchain_db_type_array_of_integers { .init("\(__).integers") }
	var `maps`: L_blockchain_db_type_array_of_maps { .init("\(__).maps") }
	var `numbers`: L_blockchain_db_type_array_of_numbers { .init("\(__).numbers") }
	var `strings`: L_blockchain_db_type_array_of_strings { .init("\(__).strings") }
	var `tags`: L_blockchain_db_type_array_of_tags { .init("\(__).tags") }
	var `urls`: L_blockchain_db_type_array_of_urls { .init("\(__).urls") }
}
public final class L_blockchain_db_type_array_of_booleans: L, I_blockchain_db_type_array_of_booleans {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.booleans", comment: "") }
}
public protocol I_blockchain_db_type_array_of_booleans: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_dates: L, I_blockchain_db_type_array_of_dates {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.dates", comment: "") }
}
public protocol I_blockchain_db_type_array_of_dates: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_integers: L, I_blockchain_db_type_array_of_integers {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.integers", comment: "") }
}
public protocol I_blockchain_db_type_array_of_integers: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_maps: L, I_blockchain_db_type_array_of_maps {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.maps", comment: "") }
}
public protocol I_blockchain_db_type_array_of_maps: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_numbers: L, I_blockchain_db_type_array_of_numbers {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.numbers", comment: "") }
}
public protocol I_blockchain_db_type_array_of_numbers: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_strings: L, I_blockchain_db_type_array_of_strings {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.strings", comment: "") }
}
public protocol I_blockchain_db_type_array_of_strings: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_tags: L, I_blockchain_db_type_array_of_tags {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.tags", comment: "") }
}
public protocol I_blockchain_db_type_array_of_tags: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_urls: L, I_blockchain_db_type_array_of_urls {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.urls", comment: "") }
}
public protocol I_blockchain_db_type_array_of_urls: I_blockchain_db_array {}
public final class L_blockchain_db_type_bigint: L, I_blockchain_db_type_bigint {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.bigint", comment: "") }
}
public protocol I_blockchain_db_type_bigint: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_boolean: L, I_blockchain_db_type_boolean {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.boolean", comment: "") }
}
public protocol I_blockchain_db_type_boolean: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_data: L, I_blockchain_db_type_data {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.data", comment: "") }
}
public protocol I_blockchain_db_type_data: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_date: L, I_blockchain_db_type_date {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.date", comment: "") }
}
public protocol I_blockchain_db_type_date: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_enum: L, I_blockchain_db_type_enum {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.enum", comment: "") }
}
public protocol I_blockchain_db_type_enum: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_integer: L, I_blockchain_db_type_integer {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.integer", comment: "") }
}
public protocol I_blockchain_db_type_integer: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_map: L, I_blockchain_db_type_map {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.map", comment: "") }
}
public protocol I_blockchain_db_type_map: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_number: L, I_blockchain_db_type_number {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.number", comment: "") }
}
public protocol I_blockchain_db_type_number: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_string: L, I_blockchain_db_type_string {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.string", comment: "") }
}
public protocol I_blockchain_db_type_string: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_tag: L, I_blockchain_db_type_tag {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.tag", comment: "") }
}
public protocol I_blockchain_db_type_tag: I_blockchain_db_leaf {}
public extension I_blockchain_db_type_tag {
	var `none`: L_blockchain_db_type_tag_none { .init("\(__).none") }
}
public final class L_blockchain_db_type_tag_none: L, I_blockchain_db_type_tag_none {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.tag.none", comment: "") }
}
public protocol I_blockchain_db_type_tag_none: I {}
public final class L_blockchain_db_type_url: L, I_blockchain_db_type_url {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.url", comment: "") }
}
public protocol I_blockchain_db_type_url: I_blockchain_db_leaf {}
public final class L_blockchain_nabu: L, I_blockchain_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.nabu", comment: "") }
}
public protocol I_blockchain_nabu: I {}
public extension I_blockchain_nabu {
	var `error`: L_blockchain_nabu_error { .init("\(__).error") }
}
public final class L_blockchain_nabu_error: L, I_blockchain_nabu_error {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error", comment: "") }
}
public protocol I_blockchain_nabu_error: I {}
public extension I_blockchain_nabu_error {
	var `payment`: L_blockchain_nabu_error_payment { .init("\(__).payment") }
}
public final class L_blockchain_nabu_error_payment: L, I_blockchain_nabu_error_payment {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment", comment: "") }
}
public protocol I_blockchain_nabu_error_payment: I {}
public extension I_blockchain_nabu_error_payment {
	var `card`: L_blockchain_nabu_error_payment_card { .init("\(__).card") }
}
public final class L_blockchain_nabu_error_payment_card: L, I_blockchain_nabu_error_payment_card {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card: I {}
public extension I_blockchain_nabu_error_payment_card {
	var `authorization`: L_blockchain_nabu_error_payment_card_authorization { .init("\(__).authorization") }
	var `blocked`: L_blockchain_nabu_error_payment_card_blocked { .init("\(__).blocked") }
	var `declined`: L_blockchain_nabu_error_payment_card_declined { .init("\(__).declined") }
	var `failed`: L_blockchain_nabu_error_payment_card_failed { .init("\(__).failed") }
	var `has`: L_blockchain_nabu_error_payment_card_has { .init("\(__).has") }
	var `information`: L_blockchain_nabu_error_payment_card_information { .init("\(__).information") }
	var `system`: L_blockchain_nabu_error_payment_card_system { .init("\(__).system") }
}
public final class L_blockchain_nabu_error_payment_card_authorization: L, I_blockchain_nabu_error_payment_card_authorization {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization: I {}
public extension I_blockchain_nabu_error_payment_card_authorization {
	var `declined`: L_blockchain_nabu_error_payment_card_authorization_declined { .init("\(__).declined") }
	var `expired`: L_blockchain_nabu_error_payment_card_authorization_expired { .init("\(__).expired") }
}
public final class L_blockchain_nabu_error_payment_card_authorization_declined: L, I_blockchain_nabu_error_payment_card_authorization_declined {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization.declined", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization_declined: I {}
public final class L_blockchain_nabu_error_payment_card_authorization_expired: L, I_blockchain_nabu_error_payment_card_authorization_expired {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization.expired", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization_expired: I {}
public final class L_blockchain_nabu_error_payment_card_blocked: L, I_blockchain_nabu_error_payment_card_blocked {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked: I {}
public extension I_blockchain_nabu_error_payment_card_blocked {
	var `suspected`: L_blockchain_nabu_error_payment_card_blocked_suspected { .init("\(__).suspected") }
}
public final class L_blockchain_nabu_error_payment_card_blocked_suspected: L, I_blockchain_nabu_error_payment_card_blocked_suspected {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked.suspected", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked_suspected: I {}
public extension I_blockchain_nabu_error_payment_card_blocked_suspected {
	var `fraud`: L_blockchain_nabu_error_payment_card_blocked_suspected_fraud { .init("\(__).fraud") }
}
public final class L_blockchain_nabu_error_payment_card_blocked_suspected_fraud: L, I_blockchain_nabu_error_payment_card_blocked_suspected_fraud {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked.suspected.fraud", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked_suspected_fraud: I {}
public final class L_blockchain_nabu_error_payment_card_declined: L, I_blockchain_nabu_error_payment_card_declined {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined: I {}
public extension I_blockchain_nabu_error_payment_card_declined {
	var `by`: L_blockchain_nabu_error_payment_card_declined_by { .init("\(__).by") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by: L, I_blockchain_nabu_error_payment_card_declined_by {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by {
	var `bank`: L_blockchain_nabu_error_payment_card_declined_by_bank { .init("\(__).bank") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank: L, I_blockchain_nabu_error_payment_card_declined_by_bank {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank {
	var `should`: L_blockchain_nabu_error_payment_card_declined_by_bank_should { .init("\(__).should") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should {
	var `not`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_not { .init("\(__).not") }
	var `retry`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_not: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_not: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should_not {
	var `retry`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.not.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry: I {}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry {
	var `immediately`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately { .init("\(__).immediately") }
	var `later`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later { .init("\(__).later") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry.immediately", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately: I {}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry.later", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later: I {}
public final class L_blockchain_nabu_error_payment_card_failed: L, I_blockchain_nabu_error_payment_card_failed {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed: I {}
public extension I_blockchain_nabu_error_payment_card_failed {
	var `should`: L_blockchain_nabu_error_payment_card_failed_should { .init("\(__).should") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should: L, I_blockchain_nabu_error_payment_card_failed_should {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should {
	var `not`: L_blockchain_nabu_error_payment_card_failed_should_not { .init("\(__).not") }
	var `retry`: L_blockchain_nabu_error_payment_card_failed_should_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_not: L, I_blockchain_nabu_error_payment_card_failed_should_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_not: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should_not {
	var `retry`: L_blockchain_nabu_error_payment_card_failed_should_not_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_not_retry: L, I_blockchain_nabu_error_payment_card_failed_should_not_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.not.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_not_retry: I {}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry: L, I_blockchain_nabu_error_payment_card_failed_should_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should_retry {
	var `immediately`: L_blockchain_nabu_error_payment_card_failed_should_retry_immediately { .init("\(__).immediately") }
	var `later`: L_blockchain_nabu_error_payment_card_failed_should_retry_later { .init("\(__).later") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry_immediately: L, I_blockchain_nabu_error_payment_card_failed_should_retry_immediately {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry.immediately", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry_immediately: I {}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry_later: L, I_blockchain_nabu_error_payment_card_failed_should_retry_later {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry.later", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry_later: I {}
public final class L_blockchain_nabu_error_payment_card_has: L, I_blockchain_nabu_error_payment_card_has {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has: I {}
public extension I_blockchain_nabu_error_payment_card_has {
	var `expired`: L_blockchain_nabu_error_payment_card_has_expired { .init("\(__).expired") }
	var `insufficient`: L_blockchain_nabu_error_payment_card_has_insufficient { .init("\(__).insufficient") }
}
public final class L_blockchain_nabu_error_payment_card_has_expired: L, I_blockchain_nabu_error_payment_card_has_expired {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.expired", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_expired: I {}
public final class L_blockchain_nabu_error_payment_card_has_insufficient: L, I_blockchain_nabu_error_payment_card_has_insufficient {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.insufficient", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_insufficient: I {}
public extension I_blockchain_nabu_error_payment_card_has_insufficient {
	var `funds`: L_blockchain_nabu_error_payment_card_has_insufficient_funds { .init("\(__).funds") }
}
public final class L_blockchain_nabu_error_payment_card_has_insufficient_funds: L, I_blockchain_nabu_error_payment_card_has_insufficient_funds {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.insufficient.funds", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_insufficient_funds: I {}
public final class L_blockchain_nabu_error_payment_card_information: L, I_blockchain_nabu_error_payment_card_information {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information: I {}
public extension I_blockchain_nabu_error_payment_card_information {
	var `cvv`: L_blockchain_nabu_error_payment_card_information_cvv { .init("\(__).cvv") }
	var `does`: L_blockchain_nabu_error_payment_card_information_does { .init("\(__).does") }
	var `number`: L_blockchain_nabu_error_payment_card_information_number { .init("\(__).number") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv: L, I_blockchain_nabu_error_payment_card_information_cvv {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv {
	var `does`: L_blockchain_nabu_error_payment_card_information_cvv_does { .init("\(__).does") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does: L, I_blockchain_nabu_error_payment_card_information_cvv_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_cvv_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does_not: L, I_blockchain_nabu_error_payment_card_information_cvv_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_cvv_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does_not_match: L, I_blockchain_nabu_error_payment_card_information_cvv_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_information_does: L, I_blockchain_nabu_error_payment_card_information_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_does_not: L, I_blockchain_nabu_error_payment_card_information_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_does_not_match: L, I_blockchain_nabu_error_payment_card_information_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_information_number: L, I_blockchain_nabu_error_payment_card_information_number {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number: I {}
public extension I_blockchain_nabu_error_payment_card_information_number {
	var `does`: L_blockchain_nabu_error_payment_card_information_number_does { .init("\(__).does") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does: L, I_blockchain_nabu_error_payment_card_information_number_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_number_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_number_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does_not: L, I_blockchain_nabu_error_payment_card_information_number_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_number_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_number_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does_not_match: L, I_blockchain_nabu_error_payment_card_information_number_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_system: L, I_blockchain_nabu_error_payment_card_system {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.system", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_system: I {}
public extension I_blockchain_nabu_error_payment_card_system {
	var `failure`: L_blockchain_nabu_error_payment_card_system_failure { .init("\(__).failure") }
}
public final class L_blockchain_nabu_error_payment_card_system_failure: L, I_blockchain_nabu_error_payment_card_system_failure {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.system.failure", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_system_failure: I {}
public final class L_blockchain_namespace: L, I_blockchain_namespace {
	public override class var localized: String { NSLocalizedString("blockchain.namespace", comment: "") }
}
public protocol I_blockchain_namespace: I {}
public extension I_blockchain_namespace {
	var `language`: L_blockchain_namespace_language { .init("\(__).language") }
}
public final class L_blockchain_namespace_language: L, I_blockchain_namespace_language {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language", comment: "") }
}
public protocol I_blockchain_namespace_language: I {}
public extension I_blockchain_namespace_language {
	var `error`: L_blockchain_namespace_language_error { .init("\(__).error") }
	var `state`: L_blockchain_namespace_language_state { .init("\(__).state") }
	var `taskpaper`: L_blockchain_namespace_language_taskpaper { .init("\(__).taskpaper") }
}
public final class L_blockchain_namespace_language_error: L, I_blockchain_namespace_language_error {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.error", comment: "") }
}
public protocol I_blockchain_namespace_language_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_namespace_language_state: L, I_blockchain_namespace_language_state {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state", comment: "") }
}
public protocol I_blockchain_namespace_language_state: I_blockchain_db_type_enum, I_blockchain_session_state_value {}
public extension I_blockchain_namespace_language_state {
	var `grammar`: L_blockchain_namespace_language_state_grammar { .init("\(__).grammar") }
	var `language`: L_blockchain_namespace_language_state_language { .init("\(__).language") }
}
public final class L_blockchain_namespace_language_state_grammar: L, I_blockchain_namespace_language_state_grammar {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state.grammar", comment: "") }
}
public protocol I_blockchain_namespace_language_state_grammar: I {}
public final class L_blockchain_namespace_language_state_language: L, I_blockchain_namespace_language_state_language {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state.language", comment: "") }
}
public protocol I_blockchain_namespace_language_state_language: I {}
public final class L_blockchain_namespace_language_taskpaper: L, I_blockchain_namespace_language_taskpaper {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.taskpaper", comment: "") }
}
public protocol I_blockchain_namespace_language_taskpaper: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_session: L, I_blockchain_session {
	public override class var localized: String { NSLocalizedString("blockchain.session", comment: "") }
}
public protocol I_blockchain_session: I {}
public extension I_blockchain_session {
	var `configuration`: L_blockchain_session_configuration { .init("\(__).configuration") }
	var `event`: L_blockchain_session_event { .init("\(__).event") }
	var `state`: L_blockchain_session_state { .init("\(__).state") }
}
public final class L_blockchain_session_configuration: L, I_blockchain_session_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.session.configuration", comment: "") }
}
public protocol I_blockchain_session_configuration: I {}
public extension I_blockchain_session_configuration {
	var `value`: L_blockchain_session_configuration_value { .init("\(__).value") }
}
public final class L_blockchain_session_configuration_value: L, I_blockchain_session_configuration_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.configuration.value", comment: "") }
}
public protocol I_blockchain_session_configuration_value: I {}
public final class L_blockchain_session_event: L, I_blockchain_session_event {
	public override class var localized: String { NSLocalizedString("blockchain.session.event", comment: "") }
}
public protocol I_blockchain_session_event: I {}
public extension I_blockchain_session_event {
	var `did`: L_blockchain_session_event_did { .init("\(__).did") }
	var `will`: L_blockchain_session_event_will { .init("\(__).will") }
}
public final class L_blockchain_session_event_did: L, I_blockchain_session_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did", comment: "") }
}
public protocol I_blockchain_session_event_did: I {}
public extension I_blockchain_session_event_did {
	var `sign`: L_blockchain_session_event_did_sign { .init("\(__).sign") }
}
public final class L_blockchain_session_event_did_sign: L, I_blockchain_session_event_did_sign {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign", comment: "") }
}
public protocol I_blockchain_session_event_did_sign: I {}
public extension I_blockchain_session_event_did_sign {
	var `in`: L_blockchain_session_event_did_sign_in { .init("\(__).in") }
	var `out`: L_blockchain_session_event_did_sign_out { .init("\(__).out") }
}
public final class L_blockchain_session_event_did_sign_in: L, I_blockchain_session_event_did_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign.in", comment: "") }
}
public protocol I_blockchain_session_event_did_sign_in: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_did_sign_out: L, I_blockchain_session_event_did_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign.out", comment: "") }
}
public protocol I_blockchain_session_event_did_sign_out: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_will: L, I_blockchain_session_event_will {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will", comment: "") }
}
public protocol I_blockchain_session_event_will: I {}
public extension I_blockchain_session_event_will {
	var `sign`: L_blockchain_session_event_will_sign { .init("\(__).sign") }
}
public final class L_blockchain_session_event_will_sign: L, I_blockchain_session_event_will_sign {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign", comment: "") }
}
public protocol I_blockchain_session_event_will_sign: I {}
public extension I_blockchain_session_event_will_sign {
	var `in`: L_blockchain_session_event_will_sign_in { .init("\(__).in") }
	var `out`: L_blockchain_session_event_will_sign_out { .init("\(__).out") }
}
public final class L_blockchain_session_event_will_sign_in: L, I_blockchain_session_event_will_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign.in", comment: "") }
}
public protocol I_blockchain_session_event_will_sign_in: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_will_sign_out: L, I_blockchain_session_event_will_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign.out", comment: "") }
}
public protocol I_blockchain_session_event_will_sign_out: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_state: L, I_blockchain_session_state {
	public override class var localized: String { NSLocalizedString("blockchain.session.state", comment: "") }
}
public protocol I_blockchain_session_state: I {}
public extension I_blockchain_session_state {
	var `key`: L_blockchain_session_state_key { .init("\(__).key") }
	var `preference`: L_blockchain_session_state_preference { .init("\(__).preference") }
	var `shared`: L_blockchain_session_state_shared { .init("\(__).shared") }
	var `stored`: L_blockchain_session_state_stored { .init("\(__).stored") }
	var `value`: L_blockchain_session_state_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key: L, I_blockchain_session_state_key {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key", comment: "") }
}
public protocol I_blockchain_session_state_key: I {}
public extension I_blockchain_session_state_key {
	var `value`: L_blockchain_session_state_key_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key_value: L, I_blockchain_session_state_key_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value", comment: "") }
}
public protocol I_blockchain_session_state_key_value: I {}
public extension I_blockchain_session_state_key_value {
	var `pair`: L_blockchain_session_state_key_value_pair { .init("\(__).pair") }
}
public final class L_blockchain_session_state_key_value_pair: L, I_blockchain_session_state_key_value_pair {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair: I {}
public extension I_blockchain_session_state_key_value_pair {
	var `key`: L_blockchain_session_state_key_value_pair_key { .init("\(__).key") }
	var `value`: L_blockchain_session_state_key_value_pair_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key_value_pair_key: L, I_blockchain_session_state_key_value_pair_key {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair.key", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair_key: I_blockchain_type_key {}
public final class L_blockchain_session_state_key_value_pair_value: L, I_blockchain_session_state_key_value_pair_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair.value", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair_value: I_blockchain_db_type_any {}
public final class L_blockchain_session_state_preference: L, I_blockchain_session_state_preference {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.preference", comment: "") }
}
public protocol I_blockchain_session_state_preference: I {}
public extension I_blockchain_session_state_preference {
	var `value`: L_blockchain_session_state_preference_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_preference_value: L, I_blockchain_session_state_preference_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.preference.value", comment: "") }
}
public protocol I_blockchain_session_state_preference_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_shared: L, I_blockchain_session_state_shared {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.shared", comment: "") }
}
public protocol I_blockchain_session_state_shared: I {}
public extension I_blockchain_session_state_shared {
	var `value`: L_blockchain_session_state_shared_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_shared_value: L, I_blockchain_session_state_shared_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.shared.value", comment: "") }
}
public protocol I_blockchain_session_state_shared_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_stored: L, I_blockchain_session_state_stored {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.stored", comment: "") }
}
public protocol I_blockchain_session_state_stored: I {}
public extension I_blockchain_session_state_stored {
	var `value`: L_blockchain_session_state_stored_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_stored_value: L, I_blockchain_session_state_stored_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.stored.value", comment: "") }
}
public protocol I_blockchain_session_state_stored_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_value: L, I_blockchain_session_state_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.value", comment: "") }
}
public protocol I_blockchain_session_state_value: I {}
public final class L_blockchain_type: L, I_blockchain_type {
	public override class var localized: String { NSLocalizedString("blockchain.type", comment: "") }
}
public protocol I_blockchain_type: I {}
public extension I_blockchain_type {
	var `currency`: L_blockchain_type_currency { .init("\(__).currency") }
	var `key`: L_blockchain_type_key { .init("\(__).key") }
	var `money`: L_blockchain_type_money { .init("\(__).money") }
}
public final class L_blockchain_type_currency: L, I_blockchain_type_currency {
	public override class var localized: String { NSLocalizedString("blockchain.type.currency", comment: "") }
}
public protocol I_blockchain_type_currency: I {}
public extension I_blockchain_type_currency {
	var `code`: L_blockchain_type_currency_code { .init("\(__).code") }
}
public final class L_blockchain_type_currency_code: L, I_blockchain_type_currency_code {
	public override class var localized: String { NSLocalizedString("blockchain.type.currency.code", comment: "") }
}
public protocol I_blockchain_type_currency_code: I_blockchain_db_type_string {}
public final class L_blockchain_type_key: L, I_blockchain_type_key {
	public override class var localized: String { NSLocalizedString("blockchain.type.key", comment: "") }
}
public protocol I_blockchain_type_key: I {}
public extension I_blockchain_type_key {
	var `context`: L_blockchain_type_key_context { .init("\(__).context") }
	var `tag`: L_blockchain_type_key_tag { .init("\(__).tag") }
}
public final class L_blockchain_type_key_context: L, I_blockchain_type_key_context {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context", comment: "") }
}
public protocol I_blockchain_type_key_context: I_blockchain_db_type_array_of_maps {}
public extension I_blockchain_type_key_context {
	var `key`: L_blockchain_type_key_context_key { .init("\(__).key") }
	var `value`: L_blockchain_type_key_context_value { .init("\(__).value") }
}
public final class L_blockchain_type_key_context_key: L, I_blockchain_type_key_context_key {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context.key", comment: "") }
}
public protocol I_blockchain_type_key_context_key: I_blockchain_db_type_tag {}
public final class L_blockchain_type_key_context_value: L, I_blockchain_type_key_context_value {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context.value", comment: "") }
}
public protocol I_blockchain_type_key_context_value: I_blockchain_db_type_string {}
public final class L_blockchain_type_key_tag: L, I_blockchain_type_key_tag {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.tag", comment: "") }
}
public protocol I_blockchain_type_key_tag: I_blockchain_db_type_tag {}
public final class L_blockchain_type_money: L, I_blockchain_type_money {
	public override class var localized: String { NSLocalizedString("blockchain.type.money", comment: "") }
}
public protocol I_blockchain_type_money: I {}
public extension I_blockchain_type_money {
	var `amount`: L_blockchain_type_money_amount { .init("\(__).amount") }
	var `currency`: L_blockchain_type_money_currency { .init("\(__).currency") }
	var `display`: L_blockchain_type_money_display { .init("\(__).display") }
	var `precision`: L_blockchain_type_money_precision { .init("\(__).precision") }
}
public final class L_blockchain_type_money_amount: L, I_blockchain_type_money_amount {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.amount", comment: "") }
}
public protocol I_blockchain_type_money_amount: I_blockchain_db_type_bigint {}
public final class L_blockchain_type_money_currency: L, I_blockchain_type_money_currency {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.currency", comment: "") }
}
public protocol I_blockchain_type_money_currency: I_blockchain_type_currency {}
public final class L_blockchain_type_money_display: L, I_blockchain_type_money_display {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display", comment: "") }
}
public protocol I_blockchain_type_money_display: I {}
public extension I_blockchain_type_money_display {
	var `code`: L_blockchain_type_money_display_code { .init("\(__).code") }
	var `string`: L_blockchain_type_money_display_string { .init("\(__).string") }
	var `symbol`: L_blockchain_type_money_display_symbol { .init("\(__).symbol") }
}
public final class L_blockchain_type_money_display_code: L, I_blockchain_type_money_display_code {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display.code", comment: "") }
}
public protocol I_blockchain_type_money_display_code: I_blockchain_db_type_string {}
public final class L_blockchain_type_money_display_string: L, I_blockchain_type_money_display_string {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display.string", comment: "") }
}
public protocol I_blockchain_type_money_display_string: I {}
public extension I_blockchain_type_money_display_string {
	var `major`: L_blockchain_type_money_display_string_major { .init("\(__).major") }
	var `minor`: L_blockchain_type_money_display_string_minor { .init("\(__).minor") }
}
public final class L_blockchain_type_money_display_string_major: L, I_blockchain_type_money_display_string_major {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display.string.major", comment: "") }
}
public protocol I_blockchain_type_money_display_string_major: I_blockchain_db_type_string {}
public final class L_blockchain_type_money_display_string_minor: L, I_blockchain_type_money_display_string_minor {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display.string.minor", comment: "") }
}
public protocol I_blockchain_type_money_display_string_minor: I_blockchain_db_type_string {}
public final class L_blockchain_type_money_display_symbol: L, I_blockchain_type_money_display_symbol {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.display.symbol", comment: "") }
}
public protocol I_blockchain_type_money_display_symbol: I_blockchain_db_type_string {}
public final class L_blockchain_type_money_precision: L, I_blockchain_type_money_precision {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.precision", comment: "") }
}
public protocol I_blockchain_type_money_precision: I_blockchain_db_type_integer {}
public final class L_blockchain_ui: L, I_blockchain_ui {
	public override class var localized: String { NSLocalizedString("blockchain.ui", comment: "") }
}
public protocol I_blockchain_ui: I {}
public extension I_blockchain_ui {
	var `type`: L_blockchain_ui_type { .init("\(__).type") }
}
public final class L_blockchain_ui_type: L, I_blockchain_ui_type {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type", comment: "") }
}
public protocol I_blockchain_ui_type: I {}
public extension I_blockchain_ui_type {
	var `action`: L_blockchain_ui_type_action { .init("\(__).action") }
	var `control`: L_blockchain_ui_type_control { .init("\(__).control") }
	var `state`: L_blockchain_ui_type_state { .init("\(__).state") }
}
public final class L_blockchain_ui_type_action: L, I_blockchain_ui_type_action {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action", comment: "") }
}
public protocol I_blockchain_ui_type_action: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ui_type_control: L, I_blockchain_ui_type_control {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control", comment: "") }
}
public protocol I_blockchain_ui_type_control: I {}
public extension I_blockchain_ui_type_control {
	var `analytics`: L_blockchain_ui_type_control_analytics { .init("\(__).analytics") }
	var `event`: L_blockchain_ui_type_control_event { .init("\(__).event") }
}
public final class L_blockchain_ui_type_control_analytics: L, I_blockchain_ui_type_control_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.analytics", comment: "") }
}
public protocol I_blockchain_ui_type_control_analytics: I {}
public extension I_blockchain_ui_type_control_analytics {
	var `context`: L_blockchain_ui_type_control_analytics_context { .init("\(__).context") }
}
public final class L_blockchain_ui_type_control_analytics_context: L, I_blockchain_ui_type_control_analytics_context {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.analytics.context", comment: "") }
}
public protocol I_blockchain_ui_type_control_analytics_context: I_blockchain_type_key_context {}
public final class L_blockchain_ui_type_control_event: L, I_blockchain_ui_type_control_event {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event", comment: "") }
}
public protocol I_blockchain_ui_type_control_event: I {}
public extension I_blockchain_ui_type_control_event {
	var `select`: L_blockchain_ui_type_control_event_select { .init("\(__).select") }
	var `swipe`: L_blockchain_ui_type_control_event_swipe { .init("\(__).swipe") }
	var `value`: L_blockchain_ui_type_control_event_value { .init("\(__).value") }
	var `tap`: L_blockchain_ui_type_control_event_tap { select }
}
public final class L_blockchain_ui_type_control_event_select: L, I_blockchain_ui_type_control_event_select {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.select", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_select: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe: L, I_blockchain_ui_type_control_event_swipe {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe: I {}
public extension I_blockchain_ui_type_control_event_swipe {
	var `any`: L_blockchain_ui_type_control_event_swipe_any { .init("\(__).any") }
	var `down`: L_blockchain_ui_type_control_event_swipe_down { .init("\(__).down") }
	var `horizontal`: L_blockchain_ui_type_control_event_swipe_horizontal { .init("\(__).horizontal") }
	var `left`: L_blockchain_ui_type_control_event_swipe_left { .init("\(__).left") }
	var `right`: L_blockchain_ui_type_control_event_swipe_right { .init("\(__).right") }
	var `up`: L_blockchain_ui_type_control_event_swipe_up { .init("\(__).up") }
	var `vertical`: L_blockchain_ui_type_control_event_swipe_vertical { .init("\(__).vertical") }
}
public final class L_blockchain_ui_type_control_event_swipe_any: L, I_blockchain_ui_type_control_event_swipe_any {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.any", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_any: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_down: L, I_blockchain_ui_type_control_event_swipe_down {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.down", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_down: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_horizontal: L, I_blockchain_ui_type_control_event_swipe_horizontal {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.horizontal", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_horizontal: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_left: L, I_blockchain_ui_type_control_event_swipe_left {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.left", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_left: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_right: L, I_blockchain_ui_type_control_event_swipe_right {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.right", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_right: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_up: L, I_blockchain_ui_type_control_event_swipe_up {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.up", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_up: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_vertical: L, I_blockchain_ui_type_control_event_swipe_vertical {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.vertical", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_vertical: I_blockchain_ui_type_action {}
public typealias L_blockchain_ui_type_control_event_tap = L_blockchain_ui_type_control_event_select
public final class L_blockchain_ui_type_control_event_value: L, I_blockchain_ui_type_control_event_value {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value: I {}
public extension I_blockchain_ui_type_control_event_value {
	var `change`: L_blockchain_ui_type_control_event_value_change { .init("\(__).change") }
	var `decremented`: L_blockchain_ui_type_control_event_value_decremented { .init("\(__).decremented") }
	var `incremented`: L_blockchain_ui_type_control_event_value_incremented { .init("\(__).incremented") }
	var `initialise`: L_blockchain_ui_type_control_event_value_initialise { .init("\(__).initialise") }
}
public final class L_blockchain_ui_type_control_event_value_change: L, I_blockchain_ui_type_control_event_value_change {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.change", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_change: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_decremented: L, I_blockchain_ui_type_control_event_value_decremented {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.decremented", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_decremented: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_incremented: L, I_blockchain_ui_type_control_event_value_incremented {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.incremented", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_incremented: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_initialise: L, I_blockchain_ui_type_control_event_value_initialise {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.initialise", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_initialise: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_state: L, I_blockchain_ui_type_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.state", comment: "") }
}
public protocol I_blockchain_ui_type_state: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_user: L, I_blockchain_user {
	public override class var localized: String { NSLocalizedString("blockchain.user", comment: "") }
}
public protocol I_blockchain_user: I_blockchain_db_collection {}
public extension I_blockchain_user {
	var `account`: L_blockchain_user_account { .init("\(__).account") }
	var `address`: L_blockchain_user_address { .init("\(__).address") }
	var `creation`: L_blockchain_user_creation { .init("\(__).creation") }
	var `currency`: L_blockchain_user_currency { .init("\(__).currency") }
	var `email`: L_blockchain_user_email { .init("\(__).email") }
	var `is`: L_blockchain_user_is { .init("\(__).is") }
	var `name`: L_blockchain_user_name { .init("\(__).name") }
	var `referral`: L_blockchain_user_referral { .init("\(__).referral") }
	var `token`: L_blockchain_user_token { .init("\(__).token") }
	var `wallet`: L_blockchain_user_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_user_account: L, I_blockchain_user_account {
	public override class var localized: String { NSLocalizedString("blockchain.user.account", comment: "") }
}
public protocol I_blockchain_user_account: I {}
public extension I_blockchain_user_account {
	var `tier`: L_blockchain_user_account_tier { .init("\(__).tier") }
}
public final class L_blockchain_user_account_tier: L, I_blockchain_user_account_tier {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier", comment: "") }
}
public protocol I_blockchain_user_account_tier: I_blockchain_db_type_enum {}
public extension I_blockchain_user_account_tier {
	var `gold`: L_blockchain_user_account_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_user_account_tier_none { .init("\(__).none") }
	var `platinum`: L_blockchain_user_account_tier_platinum { .init("\(__).platinum") }
	var `silver`: L_blockchain_user_account_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_user_account_tier_gold: L, I_blockchain_user_account_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.gold", comment: "") }
}
public protocol I_blockchain_user_account_tier_gold: I {}
public final class L_blockchain_user_account_tier_none: L, I_blockchain_user_account_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.none", comment: "") }
}
public protocol I_blockchain_user_account_tier_none: I {}
public final class L_blockchain_user_account_tier_platinum: L, I_blockchain_user_account_tier_platinum {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.platinum", comment: "") }
}
public protocol I_blockchain_user_account_tier_platinum: I {}
public final class L_blockchain_user_account_tier_silver: L, I_blockchain_user_account_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.silver", comment: "") }
}
public protocol I_blockchain_user_account_tier_silver: I {}
public final class L_blockchain_user_address: L, I_blockchain_user_address {
	public override class var localized: String { NSLocalizedString("blockchain.user.address", comment: "") }
}
public protocol I_blockchain_user_address: I {}
public extension I_blockchain_user_address {
	var `city`: L_blockchain_user_address_city { .init("\(__).city") }
	var `country`: L_blockchain_user_address_country { .init("\(__).country") }
	var `line_1`: L_blockchain_user_address_line__1 { .init("\(__).line_1") }
	var `line_2`: L_blockchain_user_address_line__2 { .init("\(__).line_2") }
	var `postal`: L_blockchain_user_address_postal { .init("\(__).postal") }
	var `state`: L_blockchain_user_address_state { .init("\(__).state") }
}
public final class L_blockchain_user_address_city: L, I_blockchain_user_address_city {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.city", comment: "") }
}
public protocol I_blockchain_user_address_city: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_country: L, I_blockchain_user_address_country {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.country", comment: "") }
}
public protocol I_blockchain_user_address_country: I {}
public extension I_blockchain_user_address_country {
	var `code`: L_blockchain_user_address_country_code { .init("\(__).code") }
}
public final class L_blockchain_user_address_country_code: L, I_blockchain_user_address_country_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.country.code", comment: "") }
}
public protocol I_blockchain_user_address_country_code: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_line__1: L, I_blockchain_user_address_line__1 {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.line_1", comment: "") }
}
public protocol I_blockchain_user_address_line__1: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_line__2: L, I_blockchain_user_address_line__2 {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.line_2", comment: "") }
}
public protocol I_blockchain_user_address_line__2: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_postal: L, I_blockchain_user_address_postal {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.postal", comment: "") }
}
public protocol I_blockchain_user_address_postal: I {}
public extension I_blockchain_user_address_postal {
	var `code`: L_blockchain_user_address_postal_code { .init("\(__).code") }
}
public final class L_blockchain_user_address_postal_code: L, I_blockchain_user_address_postal_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.postal.code", comment: "") }
}
public protocol I_blockchain_user_address_postal_code: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_state: L, I_blockchain_user_address_state {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.state", comment: "") }
}
public protocol I_blockchain_user_address_state: I_blockchain_db_type_string {}
public final class L_blockchain_user_creation: L, I_blockchain_user_creation {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation", comment: "") }
}
public protocol I_blockchain_user_creation: I {}
public extension I_blockchain_user_creation {
	var `referral`: L_blockchain_user_creation_referral { .init("\(__).referral") }
}
public final class L_blockchain_user_creation_referral: L, I_blockchain_user_creation_referral {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation.referral", comment: "") }
}
public protocol I_blockchain_user_creation_referral: I {}
public extension I_blockchain_user_creation_referral {
	var `code`: L_blockchain_user_creation_referral_code { .init("\(__).code") }
}
public final class L_blockchain_user_creation_referral_code: L, I_blockchain_user_creation_referral_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation.referral.code", comment: "") }
}
public protocol I_blockchain_user_creation_referral_code: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency: L, I_blockchain_user_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency", comment: "") }
}
public protocol I_blockchain_user_currency: I {}
public extension I_blockchain_user_currency {
	var `available`: L_blockchain_user_currency_available { .init("\(__).available") }
	var `currencies`: L_blockchain_user_currency_currencies { .init("\(__).currencies") }
	var `default`: L_blockchain_user_currency_default { .init("\(__).default") }
	var `preferred`: L_blockchain_user_currency_preferred { .init("\(__).preferred") }
}
public final class L_blockchain_user_currency_available: L, I_blockchain_user_currency_available {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.available", comment: "") }
}
public protocol I_blockchain_user_currency_available: I {}
public extension I_blockchain_user_currency_available {
	var `currencies`: L_blockchain_user_currency_available_currencies { .init("\(__).currencies") }
}
public final class L_blockchain_user_currency_available_currencies: L, I_blockchain_user_currency_available_currencies {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.available.currencies", comment: "") }
}
public protocol I_blockchain_user_currency_available_currencies: I_blockchain_db_array, I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_currencies: L, I_blockchain_user_currency_currencies {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.currencies", comment: "") }
}
public protocol I_blockchain_user_currency_currencies: I_blockchain_db_array, I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_default: L, I_blockchain_user_currency_default {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.default", comment: "") }
}
public protocol I_blockchain_user_currency_default: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_preferred: L, I_blockchain_user_currency_preferred {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred", comment: "") }
}
public protocol I_blockchain_user_currency_preferred: I {}
public extension I_blockchain_user_currency_preferred {
	var `fiat`: L_blockchain_user_currency_preferred_fiat { .init("\(__).fiat") }
}
public final class L_blockchain_user_currency_preferred_fiat: L, I_blockchain_user_currency_preferred_fiat {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat: I {}
public extension I_blockchain_user_currency_preferred_fiat {
	var `display`: L_blockchain_user_currency_preferred_fiat_display { .init("\(__).display") }
	var `trading`: L_blockchain_user_currency_preferred_fiat_trading { .init("\(__).trading") }
}
public final class L_blockchain_user_currency_preferred_fiat_display: L, I_blockchain_user_currency_preferred_fiat_display {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.display", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_display: I {}
public extension I_blockchain_user_currency_preferred_fiat_display {
	var `currency`: L_blockchain_user_currency_preferred_fiat_display_currency { .init("\(__).currency") }
}
public final class L_blockchain_user_currency_preferred_fiat_display_currency: L, I_blockchain_user_currency_preferred_fiat_display_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.display.currency", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_display_currency: I_blockchain_db_type_string, I_blockchain_session_state_preference_value {}
public final class L_blockchain_user_currency_preferred_fiat_trading: L, I_blockchain_user_currency_preferred_fiat_trading {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.trading", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_trading: I {}
public extension I_blockchain_user_currency_preferred_fiat_trading {
	var `currency`: L_blockchain_user_currency_preferred_fiat_trading_currency { .init("\(__).currency") }
}
public final class L_blockchain_user_currency_preferred_fiat_trading_currency: L, I_blockchain_user_currency_preferred_fiat_trading_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.trading.currency", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_trading_currency: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_email: L, I_blockchain_user_email {
	public override class var localized: String { NSLocalizedString("blockchain.user.email", comment: "") }
}
public protocol I_blockchain_user_email: I {}
public extension I_blockchain_user_email {
	var `address`: L_blockchain_user_email_address { .init("\(__).address") }
	var `is`: L_blockchain_user_email_is { .init("\(__).is") }
}
public final class L_blockchain_user_email_address: L, I_blockchain_user_email_address {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.address", comment: "") }
}
public protocol I_blockchain_user_email_address: I_blockchain_db_type_string {}
public final class L_blockchain_user_email_is: L, I_blockchain_user_email_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.is", comment: "") }
}
public protocol I_blockchain_user_email_is: I {}
public extension I_blockchain_user_email_is {
	var `verified`: L_blockchain_user_email_is_verified { .init("\(__).verified") }
}
public final class L_blockchain_user_email_is_verified: L, I_blockchain_user_email_is_verified {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.is.verified", comment: "") }
}
public protocol I_blockchain_user_email_is_verified: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_is: L, I_blockchain_user_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.is", comment: "") }
}
public protocol I_blockchain_user_is: I {}
public extension I_blockchain_user_is {
	var `tier`: L_blockchain_user_is_tier { .init("\(__).tier") }
}
public final class L_blockchain_user_is_tier: L, I_blockchain_user_is_tier {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier", comment: "") }
}
public protocol I_blockchain_user_is_tier: I {}
public extension I_blockchain_user_is_tier {
	var `gold`: L_blockchain_user_is_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_user_is_tier_none { .init("\(__).none") }
	var `silver`: L_blockchain_user_is_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_user_is_tier_gold: L, I_blockchain_user_is_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.gold", comment: "") }
}
public protocol I_blockchain_user_is_tier_gold: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_is_tier_none: L, I_blockchain_user_is_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.none", comment: "") }
}
public protocol I_blockchain_user_is_tier_none: I {}
public final class L_blockchain_user_is_tier_silver: L, I_blockchain_user_is_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.silver", comment: "") }
}
public protocol I_blockchain_user_is_tier_silver: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_name: L, I_blockchain_user_name {
	public override class var localized: String { NSLocalizedString("blockchain.user.name", comment: "") }
}
public protocol I_blockchain_user_name: I {}
public extension I_blockchain_user_name {
	var `first`: L_blockchain_user_name_first { .init("\(__).first") }
	var `last`: L_blockchain_user_name_last { .init("\(__).last") }
}
public final class L_blockchain_user_name_first: L, I_blockchain_user_name_first {
	public override class var localized: String { NSLocalizedString("blockchain.user.name.first", comment: "") }
}
public protocol I_blockchain_user_name_first: I_blockchain_db_type_string {}
public final class L_blockchain_user_name_last: L, I_blockchain_user_name_last {
	public override class var localized: String { NSLocalizedString("blockchain.user.name.last", comment: "") }
}
public protocol I_blockchain_user_name_last: I_blockchain_db_type_string {}
public final class L_blockchain_user_referral: L, I_blockchain_user_referral {
	public override class var localized: String { NSLocalizedString("blockchain.user.referral", comment: "") }
}
public protocol I_blockchain_user_referral: I {}
public extension I_blockchain_user_referral {
	var `campaign`: L_blockchain_user_referral_campaign { .init("\(__).campaign") }
}
public final class L_blockchain_user_referral_campaign: L, I_blockchain_user_referral_campaign {
	public override class var localized: String { NSLocalizedString("blockchain.user.referral.campaign", comment: "") }
}
public protocol I_blockchain_user_referral_campaign: I_blockchain_session_state_value {}
public final class L_blockchain_user_token: L, I_blockchain_user_token {
	public override class var localized: String { NSLocalizedString("blockchain.user.token", comment: "") }
}
public protocol I_blockchain_user_token: I {}
public extension I_blockchain_user_token {
	var `firebase`: L_blockchain_user_token_firebase { .init("\(__).firebase") }
	var `nabu`: L_blockchain_user_token_nabu { .init("\(__).nabu") }
}
public final class L_blockchain_user_token_firebase: L, I_blockchain_user_token_firebase {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.firebase", comment: "") }
}
public protocol I_blockchain_user_token_firebase: I {}
public extension I_blockchain_user_token_firebase {
	var `installation`: L_blockchain_user_token_firebase_installation { .init("\(__).installation") }
}
public final class L_blockchain_user_token_firebase_installation: L, I_blockchain_user_token_firebase_installation {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.firebase.installation", comment: "") }
}
public protocol I_blockchain_user_token_firebase_installation: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_token_nabu: L, I_blockchain_user_token_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.nabu", comment: "") }
}
public protocol I_blockchain_user_token_nabu: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_wallet: L, I_blockchain_user_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet", comment: "") }
}
public protocol I_blockchain_user_wallet: I_blockchain_db_collection {}
public extension I_blockchain_user_wallet {
	var `created`: L_blockchain_user_wallet_created { .init("\(__).created") }
	var `is`: L_blockchain_user_wallet_is { .init("\(__).is") }
	var `was`: L_blockchain_user_wallet_was { .init("\(__).was") }
}
public final class L_blockchain_user_wallet_created: L, I_blockchain_user_wallet_created {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.created", comment: "") }
}
public protocol I_blockchain_user_wallet_created: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_wallet_is: L, I_blockchain_user_wallet_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.is", comment: "") }
}
public protocol I_blockchain_user_wallet_is: I {}
public extension I_blockchain_user_wallet_is {
	var `funded`: L_blockchain_user_wallet_is_funded { .init("\(__).funded") }
}
public final class L_blockchain_user_wallet_is_funded: L, I_blockchain_user_wallet_is_funded {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.is.funded", comment: "") }
}
public protocol I_blockchain_user_wallet_is_funded: I {}
public final class L_blockchain_user_wallet_was: L, I_blockchain_user_wallet_was {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.was", comment: "") }
}
public protocol I_blockchain_user_wallet_was: I {}
public extension I_blockchain_user_wallet_was {
	var `created`: L_blockchain_user_wallet_was_created { .init("\(__).created") }
}
public final class L_blockchain_user_wallet_was_created: L, I_blockchain_user_wallet_was_created {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.was.created", comment: "") }
}
public protocol I_blockchain_user_wallet_was_created: I_blockchain_db_type_boolean {}
public final class L_blockchain_ux: L, I_blockchain_ux {
	public override class var localized: String { NSLocalizedString("blockchain.ux", comment: "") }
}
public protocol I_blockchain_ux: I {}
public extension I_blockchain_ux {
	var `asset`: L_blockchain_ux_asset { .init("\(__).asset") }
	var `buy_and_sell`: L_blockchain_ux_buy__and__sell { .init("\(__).buy_and_sell") }
	var `customer`: L_blockchain_ux_customer { .init("\(__).customer") }
	var `error`: L_blockchain_ux_error { .init("\(__).error") }
	var `frequent`: L_blockchain_ux_frequent { .init("\(__).frequent") }
	var `home`: L_blockchain_ux_home { .init("\(__).home") }
	var `kyc`: L_blockchain_ux_kyc { .init("\(__).kyc") }
	var `maintenance`: L_blockchain_ux_maintenance { .init("\(__).maintenance") }
	var `nft`: L_blockchain_ux_nft { .init("\(__).nft") }
	var `payment`: L_blockchain_ux_payment { .init("\(__).payment") }
	var `prices`: L_blockchain_ux_prices { .init("\(__).prices") }
	var `referral`: L_blockchain_ux_referral { .init("\(__).referral") }
	var `scan`: L_blockchain_ux_scan { .init("\(__).scan") }
	var `transaction`: L_blockchain_ux_transaction { .init("\(__).transaction") }
	var `type`: L_blockchain_ux_type { .init("\(__).type") }
	var `user`: L_blockchain_ux_user { .init("\(__).user") }
	var `web`: L_blockchain_ux_web { .init("\(__).web") }
}
public final class L_blockchain_ux_asset: L, I_blockchain_ux_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset", comment: "") }
}
public protocol I_blockchain_ux_asset: I_blockchain_ux_type_story, I_blockchain_db_collection {}
public extension I_blockchain_ux_asset {
	var `account`: L_blockchain_ux_asset_account { .init("\(__).account") }
	var `bio`: L_blockchain_ux_asset_bio { .init("\(__).bio") }
	var `buy`: L_blockchain_ux_asset_buy { .init("\(__).buy") }
	var `chart`: L_blockchain_ux_asset_chart { .init("\(__).chart") }
	var `error`: L_blockchain_ux_asset_error { .init("\(__).error") }
	var `receive`: L_blockchain_ux_asset_receive { .init("\(__).receive") }
	var `recurring`: L_blockchain_ux_asset_recurring { .init("\(__).recurring") }
	var `refresh`: L_blockchain_ux_asset_refresh { .init("\(__).refresh") }
	var `select`: L_blockchain_ux_asset_select { .init("\(__).select") }
	var `sell`: L_blockchain_ux_asset_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_asset_send { .init("\(__).send") }
	var `watchlist`: L_blockchain_ux_asset_watchlist { .init("\(__).watchlist") }
}
public final class L_blockchain_ux_asset_account: L, I_blockchain_ux_asset_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account", comment: "") }
}
public protocol I_blockchain_ux_asset_account: I_blockchain_ux_type_story, I_blockchain_db_collection {}
public extension I_blockchain_ux_asset_account {
	var `activity`: L_blockchain_ux_asset_account_activity { .init("\(__).activity") }
	var `buy`: L_blockchain_ux_asset_account_buy { .init("\(__).buy") }
	var `error`: L_blockchain_ux_asset_account_error { .init("\(__).error") }
	var `exchange`: L_blockchain_ux_asset_account_exchange { .init("\(__).exchange") }
	var `explainer`: L_blockchain_ux_asset_account_explainer { .init("\(__).explainer") }
	var `receive`: L_blockchain_ux_asset_account_receive { .init("\(__).receive") }
	var `require`: L_blockchain_ux_asset_account_require { .init("\(__).require") }
	var `rewards`: L_blockchain_ux_asset_account_rewards { .init("\(__).rewards") }
	var `sell`: L_blockchain_ux_asset_account_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_asset_account_send { .init("\(__).send") }
	var `sheet`: L_blockchain_ux_asset_account_sheet { .init("\(__).sheet") }
	var `swap`: L_blockchain_ux_asset_account_swap { .init("\(__).swap") }
	var `type`: L_blockchain_ux_asset_account_type { .init("\(__).type") }
}
public final class L_blockchain_ux_asset_account_activity: L, I_blockchain_ux_asset_account_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.activity", comment: "") }
}
public protocol I_blockchain_ux_asset_account_activity: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_buy: L, I_blockchain_ux_asset_account_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_account_buy: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_error: L, I_blockchain_ux_asset_account_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.error", comment: "") }
}
public protocol I_blockchain_ux_asset_account_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_ux_asset_account_exchange: L, I_blockchain_ux_asset_account_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange: I {}
public extension I_blockchain_ux_asset_account_exchange {
	var `connect`: L_blockchain_ux_asset_account_exchange_connect { .init("\(__).connect") }
	var `deposit`: L_blockchain_ux_asset_account_exchange_deposit { .init("\(__).deposit") }
	var `withdraw`: L_blockchain_ux_asset_account_exchange_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_asset_account_exchange_connect: L, I_blockchain_ux_asset_account_exchange_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.connect", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_connect: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_exchange_deposit: L, I_blockchain_ux_asset_account_exchange_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.deposit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_deposit: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_exchange_withdraw: L, I_blockchain_ux_asset_account_exchange_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.withdraw", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_withdraw: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_explainer: L, I_blockchain_ux_asset_account_explainer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_asset_account_explainer {
	var `accept`: L_blockchain_ux_asset_account_explainer_accept { .init("\(__).accept") }
	var `reset`: L_blockchain_ux_asset_account_explainer_reset { .init("\(__).reset") }
}
public final class L_blockchain_ux_asset_account_explainer_accept: L, I_blockchain_ux_asset_account_explainer_accept {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer.accept", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer_accept: I {}
public final class L_blockchain_ux_asset_account_explainer_reset: L, I_blockchain_ux_asset_account_explainer_reset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer.reset", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer_reset: I {}
public final class L_blockchain_ux_asset_account_receive: L, I_blockchain_ux_asset_account_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.receive", comment: "") }
}
public protocol I_blockchain_ux_asset_account_receive: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_require: L, I_blockchain_ux_asset_account_require {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.require", comment: "") }
}
public protocol I_blockchain_ux_asset_account_require: I {}
public extension I_blockchain_ux_asset_account_require {
	var `KYC`: L_blockchain_ux_asset_account_require_KYC { .init("\(__).KYC") }
}
public final class L_blockchain_ux_asset_account_require_KYC: L, I_blockchain_ux_asset_account_require_KYC {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.require.KYC", comment: "") }
}
public protocol I_blockchain_ux_asset_account_require_KYC: I_blockchain_ui_type_action {}
public final class L_blockchain_ux_asset_account_rewards: L, I_blockchain_ux_asset_account_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards: I {}
public extension I_blockchain_ux_asset_account_rewards {
	var `deposit`: L_blockchain_ux_asset_account_rewards_deposit { .init("\(__).deposit") }
	var `summary`: L_blockchain_ux_asset_account_rewards_summary { .init("\(__).summary") }
	var `withdraw`: L_blockchain_ux_asset_account_rewards_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_asset_account_rewards_deposit: L, I_blockchain_ux_asset_account_rewards_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.deposit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_deposit: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_rewards_summary: L, I_blockchain_ux_asset_account_rewards_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_summary: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_rewards_withdraw: L, I_blockchain_ux_asset_account_rewards_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.withdraw", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_withdraw: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_sell: L, I_blockchain_ux_asset_account_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.sell", comment: "") }
}
public protocol I_blockchain_ux_asset_account_sell: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_send: L, I_blockchain_ux_asset_account_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.send", comment: "") }
}
public protocol I_blockchain_ux_asset_account_send: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_sheet: L, I_blockchain_ux_asset_account_sheet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.sheet", comment: "") }
}
public protocol I_blockchain_ux_asset_account_sheet: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_swap: L, I_blockchain_ux_asset_account_swap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.swap", comment: "") }
}
public protocol I_blockchain_ux_asset_account_swap: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_type: L, I_blockchain_ux_asset_account_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.type", comment: "") }
}
public protocol I_blockchain_ux_asset_account_type: I_blockchain_db_type_string {}
public final class L_blockchain_ux_asset_bio: L, I_blockchain_ux_asset_bio {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio", comment: "") }
}
public protocol I_blockchain_ux_asset_bio: I {}
public extension I_blockchain_ux_asset_bio {
	var `visit`: L_blockchain_ux_asset_bio_visit { .init("\(__).visit") }
}
public final class L_blockchain_ux_asset_bio_visit: L, I_blockchain_ux_asset_bio_visit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit: I {}
public extension I_blockchain_ux_asset_bio_visit {
	var `website`: L_blockchain_ux_asset_bio_visit_website { .init("\(__).website") }
}
public final class L_blockchain_ux_asset_bio_visit_website: L, I_blockchain_ux_asset_bio_visit_website {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit.website", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit_website: I {}
public extension I_blockchain_ux_asset_bio_visit_website {
	var `url`: L_blockchain_ux_asset_bio_visit_website_url { .init("\(__).url") }
}
public final class L_blockchain_ux_asset_bio_visit_website_url: L, I_blockchain_ux_asset_bio_visit_website_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit.website.url", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit_website_url: I_blockchain_db_type_url {}
public final class L_blockchain_ux_asset_buy: L, I_blockchain_ux_asset_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_buy: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_chart: L, I_blockchain_ux_asset_chart {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart", comment: "") }
}
public protocol I_blockchain_ux_asset_chart: I {}
public extension I_blockchain_ux_asset_chart {
	var `deselected`: L_blockchain_ux_asset_chart_deselected { .init("\(__).deselected") }
	var `interval`: L_blockchain_ux_asset_chart_interval { .init("\(__).interval") }
	var `selected`: L_blockchain_ux_asset_chart_selected { .init("\(__).selected") }
}
public final class L_blockchain_ux_asset_chart_deselected: L, I_blockchain_ux_asset_chart_deselected {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.deselected", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_deselected: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_chart_interval: L, I_blockchain_ux_asset_chart_interval {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.interval", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_interval: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_chart_selected: L, I_blockchain_ux_asset_chart_selected {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.selected", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_selected: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_error: L, I_blockchain_ux_asset_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.error", comment: "") }
}
public protocol I_blockchain_ux_asset_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_ux_asset_receive: L, I_blockchain_ux_asset_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.receive", comment: "") }
}
public protocol I_blockchain_ux_asset_receive: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_recurring: L, I_blockchain_ux_asset_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring: I {}
public extension I_blockchain_ux_asset_recurring {
	var `buy`: L_blockchain_ux_asset_recurring_buy { .init("\(__).buy") }
	var `buys`: L_blockchain_ux_asset_recurring_buys { .init("\(__).buys") }
}
public final class L_blockchain_ux_asset_recurring_buy: L, I_blockchain_ux_asset_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy: I {}
public extension I_blockchain_ux_asset_recurring_buy {
	var `summary`: L_blockchain_ux_asset_recurring_buy_summary { .init("\(__).summary") }
}
public final class L_blockchain_ux_asset_recurring_buy_summary: L, I_blockchain_ux_asset_recurring_buy_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_summary: I_blockchain_ux_type_story, I_blockchain_db_collection {}
public extension I_blockchain_ux_asset_recurring_buy_summary {
	var `cancel`: L_blockchain_ux_asset_recurring_buy_summary_cancel { .init("\(__).cancel") }
}
public final class L_blockchain_ux_asset_recurring_buy_summary_cancel: L, I_blockchain_ux_asset_recurring_buy_summary_cancel {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.summary.cancel", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_summary_cancel: I {}
public final class L_blockchain_ux_asset_recurring_buys: L, I_blockchain_ux_asset_recurring_buys {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buys", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buys: I {}
public extension I_blockchain_ux_asset_recurring_buys {
	var `notification`: L_blockchain_ux_asset_recurring_buys_notification { .init("\(__).notification") }
}
public final class L_blockchain_ux_asset_recurring_buys_notification: L, I_blockchain_ux_asset_recurring_buys_notification {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buys.notification", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buys_notification: I {}
public final class L_blockchain_ux_asset_refresh: L, I_blockchain_ux_asset_refresh {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.refresh", comment: "") }
}
public protocol I_blockchain_ux_asset_refresh: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_select: L, I_blockchain_ux_asset_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.select", comment: "") }
}
public protocol I_blockchain_ux_asset_select: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_select {
	var `origin`: L_blockchain_ux_asset_select_origin { .init("\(__).origin") }
}
public final class L_blockchain_ux_asset_select_origin: L, I_blockchain_ux_asset_select_origin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.select.origin", comment: "") }
}
public protocol I_blockchain_ux_asset_select_origin: I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_sell: L, I_blockchain_ux_asset_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.sell", comment: "") }
}
public protocol I_blockchain_ux_asset_sell: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_send: L, I_blockchain_ux_asset_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.send", comment: "") }
}
public protocol I_blockchain_ux_asset_send: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_watchlist: L, I_blockchain_ux_asset_watchlist {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist: I {}
public extension I_blockchain_ux_asset_watchlist {
	var `add`: L_blockchain_ux_asset_watchlist_add { .init("\(__).add") }
	var `is`: L_blockchain_ux_asset_watchlist_is { .init("\(__).is") }
	var `remove`: L_blockchain_ux_asset_watchlist_remove { .init("\(__).remove") }
}
public final class L_blockchain_ux_asset_watchlist_add: L, I_blockchain_ux_asset_watchlist_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.add", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_add: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_asset_watchlist_is: L, I_blockchain_ux_asset_watchlist_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.is", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_is: I {}
public extension I_blockchain_ux_asset_watchlist_is {
	var `on`: L_blockchain_ux_asset_watchlist_is_on { .init("\(__).on") }
}
public final class L_blockchain_ux_asset_watchlist_is_on: L, I_blockchain_ux_asset_watchlist_is_on {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.is.on", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_is_on: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_watchlist_remove: L, I_blockchain_ux_asset_watchlist_remove {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.remove", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_remove: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_buy__and__sell: L, I_blockchain_ux_buy__and__sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_buy__and__sell {
	var `buy`: L_blockchain_ux_buy__and__sell_buy { .init("\(__).buy") }
	var `sell`: L_blockchain_ux_buy__and__sell_sell { .init("\(__).sell") }
}
public final class L_blockchain_ux_buy__and__sell_buy: L, I_blockchain_ux_buy__and__sell_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell.buy", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell_buy: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_buy__and__sell_sell: L, I_blockchain_ux_buy__and__sell_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell.sell", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell_sell: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_customer: L, I_blockchain_ux_customer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer", comment: "") }
}
public protocol I_blockchain_ux_customer: I {}
public extension I_blockchain_ux_customer {
	var `support`: L_blockchain_ux_customer_support { .init("\(__).support") }
}
public final class L_blockchain_ux_customer_support: L, I_blockchain_ux_customer_support {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support", comment: "") }
}
public protocol I_blockchain_ux_customer_support: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_customer_support {
	var `show`: L_blockchain_ux_customer_support_show { .init("\(__).show") }
	var `unread`: L_blockchain_ux_customer_support_unread { .init("\(__).unread") }
}
public final class L_blockchain_ux_customer_support_show: L, I_blockchain_ux_customer_support_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show: I {}
public extension I_blockchain_ux_customer_support_show {
	var `messenger`: L_blockchain_ux_customer_support_show_messenger { .init("\(__).messenger") }
}
public final class L_blockchain_ux_customer_support_show_messenger: L, I_blockchain_ux_customer_support_show_messenger {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show.messenger", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show_messenger: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_customer_support_unread: L, I_blockchain_ux_customer_support_unread {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.unread", comment: "") }
}
public protocol I_blockchain_ux_customer_support_unread: I {}
public extension I_blockchain_ux_customer_support_unread {
	var `count`: L_blockchain_ux_customer_support_unread_count { .init("\(__).count") }
}
public final class L_blockchain_ux_customer_support_unread_count: L, I_blockchain_ux_customer_support_unread_count {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.unread.count", comment: "") }
}
public protocol I_blockchain_ux_customer_support_unread_count: I_blockchain_db_type_integer, I_blockchain_session_state_value {}
public final class L_blockchain_ux_error: L, I_blockchain_ux_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error", comment: "") }
}
public protocol I_blockchain_ux_error: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_error {
	var `then`: L_blockchain_ux_error_then { .init("\(__).then") }
}
public final class L_blockchain_ux_error_then: L, I_blockchain_ux_error_then {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.then", comment: "") }
}
public protocol I_blockchain_ux_error_then: I {}
public extension I_blockchain_ux_error_then {
	var `launch`: L_blockchain_ux_error_then_launch { .init("\(__).launch") }
}
public final class L_blockchain_ux_error_then_launch: L, I_blockchain_ux_error_then_launch {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.then.launch", comment: "") }
}
public protocol I_blockchain_ux_error_then_launch: I {}
public extension I_blockchain_ux_error_then_launch {
	var `url`: L_blockchain_ux_error_then_launch_url { .init("\(__).url") }
}
public final class L_blockchain_ux_error_then_launch_url: L, I_blockchain_ux_error_then_launch_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.then.launch.url", comment: "") }
}
public protocol I_blockchain_ux_error_then_launch_url: I_blockchain_db_type_url, I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_frequent: L, I_blockchain_ux_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent", comment: "") }
}
public protocol I_blockchain_ux_frequent: I {}
public extension I_blockchain_ux_frequent {
	var `action`: L_blockchain_ux_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_ux_frequent_action: L, I_blockchain_ux_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action", comment: "") }
}
public protocol I_blockchain_ux_frequent_action: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_frequent_action {
	var `buy`: L_blockchain_ux_frequent_action_buy { .init("\(__).buy") }
	var `deposit`: L_blockchain_ux_frequent_action_deposit { .init("\(__).deposit") }
	var `receive`: L_blockchain_ux_frequent_action_receive { .init("\(__).receive") }
	var `rewards`: L_blockchain_ux_frequent_action_rewards { .init("\(__).rewards") }
	var `sell`: L_blockchain_ux_frequent_action_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_frequent_action_send { .init("\(__).send") }
	var `swap`: L_blockchain_ux_frequent_action_swap { .init("\(__).swap") }
	var `withdraw`: L_blockchain_ux_frequent_action_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_frequent_action_buy: L, I_blockchain_ux_frequent_action_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.buy", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_buy: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_deposit: L, I_blockchain_ux_frequent_action_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.deposit", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_deposit: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_receive: L, I_blockchain_ux_frequent_action_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.receive", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_receive: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_rewards: L, I_blockchain_ux_frequent_action_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.rewards", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_rewards: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_sell: L, I_blockchain_ux_frequent_action_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.sell", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_sell: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_send: L, I_blockchain_ux_frequent_action_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.send", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_send: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_swap: L, I_blockchain_ux_frequent_action_swap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.swap", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_swap: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_frequent_action_withdraw: L, I_blockchain_ux_frequent_action_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.withdraw", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_withdraw: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_home: L, I_blockchain_ux_home {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home", comment: "") }
}
public protocol I_blockchain_ux_home: I {}
public extension I_blockchain_ux_home {
	var `event`: L_blockchain_ux_home_event { .init("\(__).event") }
	var `tab`: L_blockchain_ux_home_tab { .init("\(__).tab") }
}
public final class L_blockchain_ux_home_event: L, I_blockchain_ux_home_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event", comment: "") }
}
public protocol I_blockchain_ux_home_event: I {}
public extension I_blockchain_ux_home_event {
	var `did`: L_blockchain_ux_home_event_did { .init("\(__).did") }
}
public final class L_blockchain_ux_home_event_did: L, I_blockchain_ux_home_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did", comment: "") }
}
public protocol I_blockchain_ux_home_event_did: I {}
public extension I_blockchain_ux_home_event_did {
	var `pull`: L_blockchain_ux_home_event_did_pull { .init("\(__).pull") }
}
public final class L_blockchain_ux_home_event_did_pull: L, I_blockchain_ux_home_event_did_pull {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull: I {}
public extension I_blockchain_ux_home_event_did_pull {
	var `to`: L_blockchain_ux_home_event_did_pull_to { .init("\(__).to") }
}
public final class L_blockchain_ux_home_event_did_pull_to: L, I_blockchain_ux_home_event_did_pull_to {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull.to", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull_to: I {}
public extension I_blockchain_ux_home_event_did_pull_to {
	var `refresh`: L_blockchain_ux_home_event_did_pull_to_refresh { .init("\(__).refresh") }
}
public final class L_blockchain_ux_home_event_did_pull_to_refresh: L, I_blockchain_ux_home_event_did_pull_to_refresh {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull.to.refresh", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull_to_refresh: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_home_tab: L, I_blockchain_ux_home_tab {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.tab", comment: "") }
}
public protocol I_blockchain_ux_home_tab: I_blockchain_db_collection {}
public extension I_blockchain_ux_home_tab {
	var `select`: L_blockchain_ux_home_tab_select { .init("\(__).select") }
}
public final class L_blockchain_ux_home_tab_select: L, I_blockchain_ux_home_tab_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.tab.select", comment: "") }
}
public protocol I_blockchain_ux_home_tab_select: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_kyc: L, I_blockchain_ux_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc", comment: "") }
}
public protocol I_blockchain_ux_kyc: I {}
public extension I_blockchain_ux_kyc {
	var `event`: L_blockchain_ux_kyc_event { .init("\(__).event") }
	var `extra`: L_blockchain_ux_kyc_extra { .init("\(__).extra") }
	var `tier`: L_blockchain_ux_kyc_tier { .init("\(__).tier") }
}
public final class L_blockchain_ux_kyc_event: L, I_blockchain_ux_kyc_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event", comment: "") }
}
public protocol I_blockchain_ux_kyc_event: I {}
public extension I_blockchain_ux_kyc_event {
	var `did`: L_blockchain_ux_kyc_event_did { .init("\(__).did") }
	var `status`: L_blockchain_ux_kyc_event_status { .init("\(__).status") }
}
public final class L_blockchain_ux_kyc_event_did: L, I_blockchain_ux_kyc_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did: I {}
public extension I_blockchain_ux_kyc_event_did {
	var `cancel`: L_blockchain_ux_kyc_event_did_cancel { .init("\(__).cancel") }
	var `finish`: L_blockchain_ux_kyc_event_did_finish { .init("\(__).finish") }
	var `start`: L_blockchain_ux_kyc_event_did_start { .init("\(__).start") }
}
public final class L_blockchain_ux_kyc_event_did_cancel: L, I_blockchain_ux_kyc_event_did_cancel {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.cancel", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_cancel: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_did_finish: L, I_blockchain_ux_kyc_event_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.finish", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_finish: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_did_start: L, I_blockchain_ux_kyc_event_did_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.start", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_start: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_status: L, I_blockchain_ux_kyc_event_status {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status: I {}
public extension I_blockchain_ux_kyc_event_status {
	var `did`: L_blockchain_ux_kyc_event_status_did { .init("\(__).did") }
}
public final class L_blockchain_ux_kyc_event_status_did: L, I_blockchain_ux_kyc_event_status_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status.did", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status_did: I {}
public extension I_blockchain_ux_kyc_event_status_did {
	var `change`: L_blockchain_ux_kyc_event_status_did_change { .init("\(__).change") }
}
public final class L_blockchain_ux_kyc_event_status_did_change: L, I_blockchain_ux_kyc_event_status_did_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status.did.change", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status_did_change: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_extra: L, I_blockchain_ux_kyc_extra {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra: I {}
public extension I_blockchain_ux_kyc_extra {
	var `questions`: L_blockchain_ux_kyc_extra_questions { .init("\(__).questions") }
}
public final class L_blockchain_ux_kyc_extra_questions: L, I_blockchain_ux_kyc_extra_questions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions: I {}
public extension I_blockchain_ux_kyc_extra_questions {
	var `context`: L_blockchain_ux_kyc_extra_questions_context { .init("\(__).context") }
	var `default`: L_blockchain_ux_kyc_extra_questions_default { .init("\(__).default") }
	var `form`: L_blockchain_ux_kyc_extra_questions_form { .init("\(__).form") }
}
public final class L_blockchain_ux_kyc_extra_questions_context: L, I_blockchain_ux_kyc_extra_questions_context {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.context", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_context: I {}
public extension I_blockchain_ux_kyc_extra_questions_context {
	var `observer`: L_blockchain_ux_kyc_extra_questions_context_observer { .init("\(__).observer") }
}
public final class L_blockchain_ux_kyc_extra_questions_context_observer: L, I_blockchain_ux_kyc_extra_questions_context_observer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.context.observer", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_context_observer: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_kyc_extra_questions_default: L, I_blockchain_ux_kyc_extra_questions_default {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.default", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_default: I {}
public extension I_blockchain_ux_kyc_extra_questions_default {
	var `context`: L_blockchain_ux_kyc_extra_questions_default_context { .init("\(__).context") }
}
public final class L_blockchain_ux_kyc_extra_questions_default_context: L, I_blockchain_ux_kyc_extra_questions_default_context {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.default.context", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_default_context: I_blockchain_db_type_string, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_kyc_extra_questions_form: L, I_blockchain_ux_kyc_extra_questions_form {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form: I_blockchain_db_collection {}
public extension I_blockchain_ux_kyc_extra_questions_form {
	var `data`: L_blockchain_ux_kyc_extra_questions_form_data { .init("\(__).data") }
	var `is`: L_blockchain_ux_kyc_extra_questions_form_is { .init("\(__).is") }
}
public final class L_blockchain_ux_kyc_extra_questions_form_data: L, I_blockchain_ux_kyc_extra_questions_form_data {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.data", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_data: I_blockchain_session_state_value {}
public final class L_blockchain_ux_kyc_extra_questions_form_is: L, I_blockchain_ux_kyc_extra_questions_form_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.is", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_is: I {}
public extension I_blockchain_ux_kyc_extra_questions_form_is {
	var `empty`: L_blockchain_ux_kyc_extra_questions_form_is_empty { .init("\(__).empty") }
}
public final class L_blockchain_ux_kyc_extra_questions_form_is_empty: L, I_blockchain_ux_kyc_extra_questions_form_is_empty {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.is.empty", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_is_empty: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_kyc_tier: L, I_blockchain_ux_kyc_tier {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier: I_blockchain_db_type_enum {}
public extension I_blockchain_ux_kyc_tier {
	var `gold`: L_blockchain_ux_kyc_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_ux_kyc_tier_none { .init("\(__).none") }
	var `platinum`: L_blockchain_ux_kyc_tier_platinum { .init("\(__).platinum") }
	var `silver`: L_blockchain_ux_kyc_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_ux_kyc_tier_gold: L, I_blockchain_ux_kyc_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.gold", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_gold: I {}
public final class L_blockchain_ux_kyc_tier_none: L, I_blockchain_ux_kyc_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.none", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_none: I {}
public final class L_blockchain_ux_kyc_tier_platinum: L, I_blockchain_ux_kyc_tier_platinum {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.platinum", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_platinum: I {}
public final class L_blockchain_ux_kyc_tier_silver: L, I_blockchain_ux_kyc_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.silver", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_silver: I {}
public final class L_blockchain_ux_maintenance: L, I_blockchain_ux_maintenance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.maintenance", comment: "") }
}
public protocol I_blockchain_ux_maintenance: I_blockchain_ux_type_story, I_blockchain_db_collection {}
public final class L_blockchain_ux_nft: L, I_blockchain_ux_nft {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft", comment: "") }
}
public protocol I_blockchain_ux_nft: I {}
public extension I_blockchain_ux_nft {
	var `asset`: L_blockchain_ux_nft_asset { .init("\(__).asset") }
	var `collection`: L_blockchain_ux_nft_collection { .init("\(__).collection") }
	var `wallet`: L_blockchain_ux_nft_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_nft_asset: L, I_blockchain_ux_nft_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.asset", comment: "") }
}
public protocol I_blockchain_ux_nft_asset: I_blockchain_db_collection {}
public extension I_blockchain_ux_nft_asset {
	var `select`: L_blockchain_ux_nft_asset_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_asset_select: L, I_blockchain_ux_nft_asset_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.asset.select", comment: "") }
}
public protocol I_blockchain_ux_nft_asset_select: I {}
public final class L_blockchain_ux_nft_collection: L, I_blockchain_ux_nft_collection {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.collection", comment: "") }
}
public protocol I_blockchain_ux_nft_collection: I_blockchain_db_collection {}
public extension I_blockchain_ux_nft_collection {
	var `select`: L_blockchain_ux_nft_collection_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_collection_select: L, I_blockchain_ux_nft_collection_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.collection.select", comment: "") }
}
public protocol I_blockchain_ux_nft_collection_select: I {}
public final class L_blockchain_ux_nft_wallet: L, I_blockchain_ux_nft_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.wallet", comment: "") }
}
public protocol I_blockchain_ux_nft_wallet: I_blockchain_db_collection {}
public extension I_blockchain_ux_nft_wallet {
	var `select`: L_blockchain_ux_nft_wallet_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_wallet_select: L, I_blockchain_ux_nft_wallet_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.wallet.select", comment: "") }
}
public protocol I_blockchain_ux_nft_wallet_select: I {}
public final class L_blockchain_ux_payment: L, I_blockchain_ux_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment", comment: "") }
}
public protocol I_blockchain_ux_payment: I {}
public extension I_blockchain_ux_payment {
	var `method`: L_blockchain_ux_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_payment_method: L, I_blockchain_ux_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method", comment: "") }
}
public protocol I_blockchain_ux_payment_method: I {}
public extension I_blockchain_ux_payment_method {
	var `link`: L_blockchain_ux_payment_method_link { .init("\(__).link") }
	var `open`: L_blockchain_ux_payment_method_open { .init("\(__).open") }
}
public final class L_blockchain_ux_payment_method_link: L, I_blockchain_ux_payment_method_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link: I {}
public extension I_blockchain_ux_payment_method_link {
	var `bank`: L_blockchain_ux_payment_method_link_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_payment_method_link_card { .init("\(__).card") }
}
public final class L_blockchain_ux_payment_method_link_bank: L, I_blockchain_ux_payment_method_link_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.bank", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_bank: I {}
public extension I_blockchain_ux_payment_method_link_bank {
	var `wire`: L_blockchain_ux_payment_method_link_bank_wire { .init("\(__).wire") }
}
public final class L_blockchain_ux_payment_method_link_bank_wire: L, I_blockchain_ux_payment_method_link_bank_wire {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.bank.wire", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_bank_wire: I {}
public final class L_blockchain_ux_payment_method_link_card: L, I_blockchain_ux_payment_method_link_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.card", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_card: I {}
public final class L_blockchain_ux_payment_method_open: L, I_blockchain_ux_payment_method_open {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open: I {}
public extension I_blockchain_ux_payment_method_open {
	var `banking`: L_blockchain_ux_payment_method_open_banking { .init("\(__).banking") }
}
public final class L_blockchain_ux_payment_method_open_banking: L, I_blockchain_ux_payment_method_open_banking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking: I {}
public extension I_blockchain_ux_payment_method_open_banking {
	var `account`: L_blockchain_ux_payment_method_open_banking_account { .init("\(__).account") }
	var `authorisation`: L_blockchain_ux_payment_method_open_banking_authorisation { .init("\(__).authorisation") }
	var `callback`: L_blockchain_ux_payment_method_open_banking_callback { .init("\(__).callback") }
	var `consent`: L_blockchain_ux_payment_method_open_banking_consent { .init("\(__).consent") }
	var `currency`: L_blockchain_ux_payment_method_open_banking_currency { .init("\(__).currency") }
	var `error`: L_blockchain_ux_payment_method_open_banking_error { .init("\(__).error") }
	var `is`: L_blockchain_ux_payment_method_open_banking_is { .init("\(__).is") }
}
public final class L_blockchain_ux_payment_method_open_banking_account: L, I_blockchain_ux_payment_method_open_banking_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.account", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_account: I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_authorisation: L, I_blockchain_ux_payment_method_open_banking_authorisation {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.authorisation", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_authorisation: I {}
public extension I_blockchain_ux_payment_method_open_banking_authorisation {
	var `url`: L_blockchain_ux_payment_method_open_banking_authorisation_url { .init("\(__).url") }
}
public final class L_blockchain_ux_payment_method_open_banking_authorisation_url: L, I_blockchain_ux_payment_method_open_banking_authorisation_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.authorisation.url", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_authorisation_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_callback: L, I_blockchain_ux_payment_method_open_banking_callback {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback: I {}
public extension I_blockchain_ux_payment_method_open_banking_callback {
	var `base`: L_blockchain_ux_payment_method_open_banking_callback_base { .init("\(__).base") }
	var `path`: L_blockchain_ux_payment_method_open_banking_callback_path { .init("\(__).path") }
}
public final class L_blockchain_ux_payment_method_open_banking_callback_base: L, I_blockchain_ux_payment_method_open_banking_callback_base {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.base", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_base: I {}
public extension I_blockchain_ux_payment_method_open_banking_callback_base {
	var `url`: L_blockchain_ux_payment_method_open_banking_callback_base_url { .init("\(__).url") }
}
public final class L_blockchain_ux_payment_method_open_banking_callback_base_url: L, I_blockchain_ux_payment_method_open_banking_callback_base_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.base.url", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_base_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_callback_path: L, I_blockchain_ux_payment_method_open_banking_callback_path {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.path", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_path: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_consent: L, I_blockchain_ux_payment_method_open_banking_consent {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent: I {}
public extension I_blockchain_ux_payment_method_open_banking_consent {
	var `error`: L_blockchain_ux_payment_method_open_banking_consent_error { .init("\(__).error") }
	var `token`: L_blockchain_ux_payment_method_open_banking_consent_token { .init("\(__).token") }
}
public final class L_blockchain_ux_payment_method_open_banking_consent_error: L, I_blockchain_ux_payment_method_open_banking_consent_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent.error", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent_error: I_blockchain_ux_type_analytics_error, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_consent_token: L, I_blockchain_ux_payment_method_open_banking_consent_token {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent.token", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent_token: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_currency: L, I_blockchain_ux_payment_method_open_banking_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.currency", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_currency: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_error: L, I_blockchain_ux_payment_method_open_banking_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.error", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_error: I {}
public extension I_blockchain_ux_payment_method_open_banking_error {
	var `code`: L_blockchain_ux_payment_method_open_banking_error_code { .init("\(__).code") }
}
public final class L_blockchain_ux_payment_method_open_banking_error_code: L, I_blockchain_ux_payment_method_open_banking_error_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.error.code", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_error_code: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_is: L, I_blockchain_ux_payment_method_open_banking_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.is", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_is: I {}
public extension I_blockchain_ux_payment_method_open_banking_is {
	var `authorised`: L_blockchain_ux_payment_method_open_banking_is_authorised { .init("\(__).authorised") }
}
public final class L_blockchain_ux_payment_method_open_banking_is_authorised: L, I_blockchain_ux_payment_method_open_banking_is_authorised {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.is.authorised", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_is_authorised: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_prices: L, I_blockchain_ux_prices {
	public override class var localized: String { NSLocalizedString("blockchain.ux.prices", comment: "") }
}
public protocol I_blockchain_ux_prices: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_referral: L, I_blockchain_ux_referral {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral", comment: "") }
}
public protocol I_blockchain_ux_referral: I {}
public extension I_blockchain_ux_referral {
	var `entry`: L_blockchain_ux_referral_entry { .init("\(__).entry") }
	var `giftbox`: L_blockchain_ux_referral_giftbox { .init("\(__).giftbox") }
}
public final class L_blockchain_ux_referral_entry: L, I_blockchain_ux_referral_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.entry", comment: "") }
}
public protocol I_blockchain_ux_referral_entry: I_blockchain_ux_type_story_entry {}
public final class L_blockchain_ux_referral_giftbox: L, I_blockchain_ux_referral_giftbox {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.giftbox", comment: "") }
}
public protocol I_blockchain_ux_referral_giftbox: I {}
public extension I_blockchain_ux_referral_giftbox {
	var `seen`: L_blockchain_ux_referral_giftbox_seen { .init("\(__).seen") }
}
public final class L_blockchain_ux_referral_giftbox_seen: L, I_blockchain_ux_referral_giftbox_seen {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.giftbox.seen", comment: "") }
}
public protocol I_blockchain_ux_referral_giftbox_seen: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_scan: L, I_blockchain_ux_scan {
	public override class var localized: String { NSLocalizedString("blockchain.ux.scan", comment: "") }
}
public protocol I_blockchain_ux_scan: I {}
public extension I_blockchain_ux_scan {
	var `QR`: L_blockchain_ux_scan_QR { .init("\(__).QR") }
}
public final class L_blockchain_ux_scan_QR: L, I_blockchain_ux_scan_QR {
	public override class var localized: String { NSLocalizedString("blockchain.ux.scan.QR", comment: "") }
}
public protocol I_blockchain_ux_scan_QR: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_transaction: L, I_blockchain_ux_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction", comment: "") }
}
public protocol I_blockchain_ux_transaction: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction {
	var `action`: L_blockchain_ux_transaction_action { .init("\(__).action") }
	var `configuration`: L_blockchain_ux_transaction_configuration { .init("\(__).configuration") }
	var `event`: L_blockchain_ux_transaction_event { .init("\(__).event") }
	var `previous`: L_blockchain_ux_transaction_previous { .init("\(__).previous") }
	var `source`: L_blockchain_ux_transaction_source { .init("\(__).source") }
}
public final class L_blockchain_ux_transaction_action: L, I_blockchain_ux_transaction_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action", comment: "") }
}
public protocol I_blockchain_ux_transaction_action: I {}
public extension I_blockchain_ux_transaction_action {
	var `add`: L_blockchain_ux_transaction_action_add { .init("\(__).add") }
	var `change`: L_blockchain_ux_transaction_action_change { .init("\(__).change") }
	var `go`: L_blockchain_ux_transaction_action_go { .init("\(__).go") }
	var `reset`: L_blockchain_ux_transaction_action_reset { .init("\(__).reset") }
	var `show`: L_blockchain_ux_transaction_action_show { .init("\(__).show") }
}
public final class L_blockchain_ux_transaction_action_add: L, I_blockchain_ux_transaction_action_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add: I {}
public extension I_blockchain_ux_transaction_action_add {
	var `account`: L_blockchain_ux_transaction_action_add_account { .init("\(__).account") }
	var `bank`: L_blockchain_ux_transaction_action_add_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_action_add_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_action_add_account: L, I_blockchain_ux_transaction_action_add_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.account", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_account: I {}
public final class L_blockchain_ux_transaction_action_add_bank: L, I_blockchain_ux_transaction_action_add_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_bank: I {}
public final class L_blockchain_ux_transaction_action_add_card: L, I_blockchain_ux_transaction_action_add_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_card: I {}
public final class L_blockchain_ux_transaction_action_change: L, I_blockchain_ux_transaction_action_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change: I {}
public extension I_blockchain_ux_transaction_action_change {
	var `payment`: L_blockchain_ux_transaction_action_change_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_action_change_payment: L, I_blockchain_ux_transaction_action_change_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change_payment: I {}
public extension I_blockchain_ux_transaction_action_change_payment {
	var `method`: L_blockchain_ux_transaction_action_change_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_action_change_payment_method: L, I_blockchain_ux_transaction_action_change_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change_payment_method: I {}
public final class L_blockchain_ux_transaction_action_go: L, I_blockchain_ux_transaction_action_go {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go: I {}
public extension I_blockchain_ux_transaction_action_go {
	var `back`: L_blockchain_ux_transaction_action_go_back { .init("\(__).back") }
}
public final class L_blockchain_ux_transaction_action_go_back: L, I_blockchain_ux_transaction_action_go_back {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back: I {}
public extension I_blockchain_ux_transaction_action_go_back {
	var `to`: L_blockchain_ux_transaction_action_go_back_to { .init("\(__).to") }
}
public final class L_blockchain_ux_transaction_action_go_back_to: L, I_blockchain_ux_transaction_action_go_back_to {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to: I {}
public extension I_blockchain_ux_transaction_action_go_back_to {
	var `enter`: L_blockchain_ux_transaction_action_go_back_to_enter { .init("\(__).enter") }
}
public final class L_blockchain_ux_transaction_action_go_back_to_enter: L, I_blockchain_ux_transaction_action_go_back_to_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to.enter", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to_enter: I {}
public extension I_blockchain_ux_transaction_action_go_back_to_enter {
	var `amount`: L_blockchain_ux_transaction_action_go_back_to_enter_amount { .init("\(__).amount") }
}
public final class L_blockchain_ux_transaction_action_go_back_to_enter_amount: L, I_blockchain_ux_transaction_action_go_back_to_enter_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to.enter.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to_enter_amount: I {}
public final class L_blockchain_ux_transaction_action_reset: L, I_blockchain_ux_transaction_action_reset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.reset", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_reset: I {}
public final class L_blockchain_ux_transaction_action_show: L, I_blockchain_ux_transaction_action_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show: I {}
public extension I_blockchain_ux_transaction_action_show {
	var `wire`: L_blockchain_ux_transaction_action_show_wire { .init("\(__).wire") }
}
public final class L_blockchain_ux_transaction_action_show_wire: L, I_blockchain_ux_transaction_action_show_wire {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire: I {}
public extension I_blockchain_ux_transaction_action_show_wire {
	var `transfer`: L_blockchain_ux_transaction_action_show_wire_transfer { .init("\(__).transfer") }
}
public final class L_blockchain_ux_transaction_action_show_wire_transfer: L, I_blockchain_ux_transaction_action_show_wire_transfer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire.transfer", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire_transfer: I {}
public extension I_blockchain_ux_transaction_action_show_wire_transfer {
	var `instructions`: L_blockchain_ux_transaction_action_show_wire_transfer_instructions { .init("\(__).instructions") }
}
public final class L_blockchain_ux_transaction_action_show_wire_transfer_instructions: L, I_blockchain_ux_transaction_action_show_wire_transfer_instructions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire.transfer.instructions", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire_transfer_instructions: I {}
public final class L_blockchain_ux_transaction_configuration: L, I_blockchain_ux_transaction_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration: I {}
public extension I_blockchain_ux_transaction_configuration {
	var `link`: L_blockchain_ux_transaction_configuration_link { .init("\(__).link") }
}
public final class L_blockchain_ux_transaction_configuration_link: L, I_blockchain_ux_transaction_configuration_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link: I {}
public extension I_blockchain_ux_transaction_configuration_link {
	var `a`: L_blockchain_ux_transaction_configuration_link_a { .init("\(__).a") }
}
public final class L_blockchain_ux_transaction_configuration_link_a: L, I_blockchain_ux_transaction_configuration_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a: I {}
public extension I_blockchain_ux_transaction_configuration_link_a {
	var `card`: L_blockchain_ux_transaction_configuration_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card: L, I_blockchain_ux_transaction_configuration_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card {
	var `credit`: L_blockchain_ux_transaction_configuration_link_a_card_credit { .init("\(__).credit") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit: L, I_blockchain_ux_transaction_configuration_link_a_card_credit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit {
	var `card`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card {
	var `learn`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn { .init("\(__).learn") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn {
	var `more`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more {
	var `url`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_event: L, I_blockchain_ux_transaction_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event", comment: "") }
}
public protocol I_blockchain_ux_transaction_event: I {}
public extension I_blockchain_ux_transaction_event {
	var `checkout`: L_blockchain_ux_transaction_event_checkout { .init("\(__).checkout") }
	var `did`: L_blockchain_ux_transaction_event_did { .init("\(__).did") }
	var `enter`: L_blockchain_ux_transaction_event_enter { .init("\(__).enter") }
	var `in`: L_blockchain_ux_transaction_event_in { .init("\(__).in") }
	var `link`: L_blockchain_ux_transaction_event_link { .init("\(__).link") }
	var `select`: L_blockchain_ux_transaction_event_select { .init("\(__).select") }
	var `validate`: L_blockchain_ux_transaction_event_validate { .init("\(__).validate") }
	var `will`: L_blockchain_ux_transaction_event_will { .init("\(__).will") }
}
public final class L_blockchain_ux_transaction_event_checkout: L, I_blockchain_ux_transaction_event_checkout {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.checkout", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_checkout: I {}
public final class L_blockchain_ux_transaction_event_did: L, I_blockchain_ux_transaction_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did: I {}
public extension I_blockchain_ux_transaction_event_did {
	var `error`: L_blockchain_ux_transaction_event_did_error { .init("\(__).error") }
	var `finish`: L_blockchain_ux_transaction_event_did_finish { .init("\(__).finish") }
	var `start`: L_blockchain_ux_transaction_event_did_start { .init("\(__).start") }
}
public final class L_blockchain_ux_transaction_event_did_error: L, I_blockchain_ux_transaction_event_did_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.error", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_error: I {}
public final class L_blockchain_ux_transaction_event_did_finish: L, I_blockchain_ux_transaction_event_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.finish", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_finish: I {}
public final class L_blockchain_ux_transaction_event_did_start: L, I_blockchain_ux_transaction_event_did_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.start", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_start: I {}
public final class L_blockchain_ux_transaction_event_enter: L, I_blockchain_ux_transaction_event_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.enter", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_enter: I {}
public extension I_blockchain_ux_transaction_event_enter {
	var `address`: L_blockchain_ux_transaction_event_enter_address { .init("\(__).address") }
	var `amount`: L_blockchain_ux_transaction_event_enter_amount { .init("\(__).amount") }
}
public final class L_blockchain_ux_transaction_event_enter_address: L, I_blockchain_ux_transaction_event_enter_address {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.enter.address", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_enter_address: I {}
public final class L_blockchain_ux_transaction_event_enter_amount: L, I_blockchain_ux_transaction_event_enter_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.enter.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_enter_amount: I {}
public final class L_blockchain_ux_transaction_event_in: L, I_blockchain_ux_transaction_event_in {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.in", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_in: I {}
public extension I_blockchain_ux_transaction_event_in {
	var `progress`: L_blockchain_ux_transaction_event_in_progress { .init("\(__).progress") }
}
public final class L_blockchain_ux_transaction_event_in_progress: L, I_blockchain_ux_transaction_event_in_progress {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.in.progress", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_in_progress: I {}
public final class L_blockchain_ux_transaction_event_link: L, I_blockchain_ux_transaction_event_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link: I {}
public extension I_blockchain_ux_transaction_event_link {
	var `a`: L_blockchain_ux_transaction_event_link_a { .init("\(__).a") }
	var `payment`: L_blockchain_ux_transaction_event_link_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_event_link_a: L, I_blockchain_ux_transaction_event_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a: I {}
public extension I_blockchain_ux_transaction_event_link_a {
	var `bank`: L_blockchain_ux_transaction_event_link_a_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_event_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_event_link_a_bank: L, I_blockchain_ux_transaction_event_link_a_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a_bank: I {}
public final class L_blockchain_ux_transaction_event_link_a_card: L, I_blockchain_ux_transaction_event_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a_card: I {}
public final class L_blockchain_ux_transaction_event_link_payment: L, I_blockchain_ux_transaction_event_link_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_payment: I {}
public extension I_blockchain_ux_transaction_event_link_payment {
	var `method`: L_blockchain_ux_transaction_event_link_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_event_link_payment_method: L, I_blockchain_ux_transaction_event_link_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_payment_method: I {}
public final class L_blockchain_ux_transaction_event_select: L, I_blockchain_ux_transaction_event_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select: I {}
public extension I_blockchain_ux_transaction_event_select {
	var `source`: L_blockchain_ux_transaction_event_select_source { .init("\(__).source") }
	var `target`: L_blockchain_ux_transaction_event_select_target { .init("\(__).target") }
}
public final class L_blockchain_ux_transaction_event_select_source: L, I_blockchain_ux_transaction_event_select_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select_source: I {}
public final class L_blockchain_ux_transaction_event_select_target: L, I_blockchain_ux_transaction_event_select_target {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select.target", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select_target: I {}
public final class L_blockchain_ux_transaction_event_validate: L, I_blockchain_ux_transaction_event_validate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate: I {}
public extension I_blockchain_ux_transaction_event_validate {
	var `source`: L_blockchain_ux_transaction_event_validate_source { .init("\(__).source") }
	var `transaction`: L_blockchain_ux_transaction_event_validate_transaction { .init("\(__).transaction") }
}
public final class L_blockchain_ux_transaction_event_validate_source: L, I_blockchain_ux_transaction_event_validate_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate_source: I {}
public final class L_blockchain_ux_transaction_event_validate_transaction: L, I_blockchain_ux_transaction_event_validate_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate.transaction", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate_transaction: I {}
public final class L_blockchain_ux_transaction_event_will: L, I_blockchain_ux_transaction_event_will {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will: I {}
public extension I_blockchain_ux_transaction_event_will {
	var `finish`: L_blockchain_ux_transaction_event_will_finish { .init("\(__).finish") }
	var `start`: L_blockchain_ux_transaction_event_will_start { .init("\(__).start") }
}
public final class L_blockchain_ux_transaction_event_will_finish: L, I_blockchain_ux_transaction_event_will_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will.finish", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will_finish: I {}
public final class L_blockchain_ux_transaction_event_will_start: L, I_blockchain_ux_transaction_event_will_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will.start", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will_start: I {}
public final class L_blockchain_ux_transaction_previous: L, I_blockchain_ux_transaction_previous {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous: I {}
public extension I_blockchain_ux_transaction_previous {
	var `payment`: L_blockchain_ux_transaction_previous_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_previous_payment: L, I_blockchain_ux_transaction_previous_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment: I {}
public extension I_blockchain_ux_transaction_previous_payment {
	var `method`: L_blockchain_ux_transaction_previous_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_previous_payment_method: L, I_blockchain_ux_transaction_previous_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment_method: I {}
public extension I_blockchain_ux_transaction_previous_payment_method {
	var `id`: L_blockchain_ux_transaction_previous_payment_method_id { .init("\(__).id") }
}
public final class L_blockchain_ux_transaction_previous_payment_method_id: L, I_blockchain_ux_transaction_previous_payment_method_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment.method.id", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment_method_id: I_blockchain_db_type_string, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_source: L, I_blockchain_ux_transaction_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_source: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction_source {
	var `target`: L_blockchain_ux_transaction_source_target { .init("\(__).target") }
}
public final class L_blockchain_ux_transaction_source_target: L, I_blockchain_ux_transaction_source_target {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction_source_target {
	var `previous`: L_blockchain_ux_transaction_source_target_previous { .init("\(__).previous") }
}
public final class L_blockchain_ux_transaction_source_target_previous: L, I_blockchain_ux_transaction_source_target_previous {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous: I {}
public extension I_blockchain_ux_transaction_source_target_previous {
	var `did`: L_blockchain_ux_transaction_source_target_previous_did { .init("\(__).did") }
	var `input`: L_blockchain_ux_transaction_source_target_previous_input { .init("\(__).input") }
}
public final class L_blockchain_ux_transaction_source_target_previous_did: L, I_blockchain_ux_transaction_source_target_previous_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.did", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_did: I {}
public extension I_blockchain_ux_transaction_source_target_previous_did {
	var `error`: L_blockchain_ux_transaction_source_target_previous_did_error { .init("\(__).error") }
}
public final class L_blockchain_ux_transaction_source_target_previous_did_error: L, I_blockchain_ux_transaction_source_target_previous_did_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.did.error", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_did_error: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_previous_input: L, I_blockchain_ux_transaction_source_target_previous_input {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input: I {}
public extension I_blockchain_ux_transaction_source_target_previous_input {
	var `amount`: L_blockchain_ux_transaction_source_target_previous_input_amount { .init("\(__).amount") }
	var `currency`: L_blockchain_ux_transaction_source_target_previous_input_currency { .init("\(__).currency") }
}
public final class L_blockchain_ux_transaction_source_target_previous_input_amount: L, I_blockchain_ux_transaction_source_target_previous_input_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_amount: I_blockchain_db_type_bigint, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_source_target_previous_input_currency: L, I_blockchain_ux_transaction_source_target_previous_input_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.currency", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_currency: I {}
public extension I_blockchain_ux_transaction_source_target_previous_input_currency {
	var `code`: L_blockchain_ux_transaction_source_target_previous_input_currency_code { .init("\(__).code") }
}
public final class L_blockchain_ux_transaction_source_target_previous_input_currency_code: L, I_blockchain_ux_transaction_source_target_previous_input_currency_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.currency.code", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_currency_code: I_blockchain_db_type_string, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_type: L, I_blockchain_ux_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type", comment: "") }
}
public protocol I_blockchain_ux_type: I {}
public extension I_blockchain_ux_type {
	var `action`: L_blockchain_ux_type_action { .init("\(__).action") }
	var `analytics`: L_blockchain_ux_type_analytics { .init("\(__).analytics") }
	var `story`: L_blockchain_ux_type_story { .init("\(__).story") }
}
public final class L_blockchain_ux_type_action: L, I_blockchain_ux_type_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.action", comment: "") }
}
public protocol I_blockchain_ux_type_action: I_blockchain_ui_type_action {}
public final class L_blockchain_ux_type_analytics: L, I_blockchain_ux_type_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics", comment: "") }
}
public protocol I_blockchain_ux_type_analytics: I {}
public extension I_blockchain_ux_type_analytics {
	var `action`: L_blockchain_ux_type_analytics_action { .init("\(__).action") }
	var `current`: L_blockchain_ux_type_analytics_current { .init("\(__).current") }
	var `error`: L_blockchain_ux_type_analytics_error { .init("\(__).error") }
	var `event`: L_blockchain_ux_type_analytics_event { .init("\(__).event") }
	var `state`: L_blockchain_ux_type_analytics_state { .init("\(__).state") }
}
public final class L_blockchain_ux_type_analytics_action: L, I_blockchain_ux_type_analytics_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.action", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_action: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_type_analytics_current: L, I_blockchain_ux_type_analytics_current {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.current", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_current: I {}
public extension I_blockchain_ux_type_analytics_current {
	var `state`: L_blockchain_ux_type_analytics_current_state { .init("\(__).state") }
}
public final class L_blockchain_ux_type_analytics_current_state: L, I_blockchain_ux_type_analytics_current_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.current.state", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_current_state: I_blockchain_db_type_tag, I_blockchain_session_state_value {}
public final class L_blockchain_ux_type_analytics_error: L, I_blockchain_ux_type_analytics_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.error", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_error: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_type_analytics_error {
	var `message`: L_blockchain_ux_type_analytics_error_message { .init("\(__).message") }
}
public final class L_blockchain_ux_type_analytics_error_message: L, I_blockchain_ux_type_analytics_error_message {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.error.message", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_error_message: I {}
public final class L_blockchain_ux_type_analytics_event: L, I_blockchain_ux_type_analytics_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event: I {}
public extension I_blockchain_ux_type_analytics_event {
	var `source`: L_blockchain_ux_type_analytics_event_source { .init("\(__).source") }
}
public final class L_blockchain_ux_type_analytics_event_source: L, I_blockchain_ux_type_analytics_event_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source: I {}
public extension I_blockchain_ux_type_analytics_event_source {
	var `file`: L_blockchain_ux_type_analytics_event_source_file { .init("\(__).file") }
	var `line`: L_blockchain_ux_type_analytics_event_source_line { .init("\(__).line") }
}
public final class L_blockchain_ux_type_analytics_event_source_file: L, I_blockchain_ux_type_analytics_event_source_file {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source.file", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source_file: I {}
public final class L_blockchain_ux_type_analytics_event_source_line: L, I_blockchain_ux_type_analytics_event_source_line {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source.line", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source_line: I {}
public final class L_blockchain_ux_type_analytics_state: L, I_blockchain_ux_type_analytics_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.state", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_state: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_type_story: L, I_blockchain_ux_type_story {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story", comment: "") }
}
public protocol I_blockchain_ux_type_story: I_blockchain_ux_type_analytics_state {}
public extension I_blockchain_ux_type_story {
	var `entry`: L_blockchain_ux_type_story_entry { .init("\(__).entry") }
	var `event`: L_blockchain_ux_type_story_event { .init("\(__).event") }
}
public final class L_blockchain_ux_type_story_entry: L, I_blockchain_ux_type_story_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story.entry", comment: "") }
}
public protocol I_blockchain_ux_type_story_entry: I {}
public final class L_blockchain_ux_type_story_event: L, I_blockchain_ux_type_story_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story.event", comment: "") }
}
public protocol I_blockchain_ux_type_story_event: I {}
public extension I_blockchain_ux_type_story_event {
	var `did`: L_blockchain_ux_type_story_event_did { .init("\(__).did") }
}
public final class L_blockchain_ux_type_story_event_did: L, I_blockchain_ux_type_story_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story.event.did", comment: "") }
}
public protocol I_blockchain_ux_type_story_event_did: I {}
public extension I_blockchain_ux_type_story_event_did {
	var `dismiss`: L_blockchain_ux_type_story_event_did_dismiss { .init("\(__).dismiss") }
}
public final class L_blockchain_ux_type_story_event_did_dismiss: L, I_blockchain_ux_type_story_event_did_dismiss {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story.event.did.dismiss", comment: "") }
}
public protocol I_blockchain_ux_type_story_event_did_dismiss: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_user: L, I_blockchain_ux_user {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user", comment: "") }
}
public protocol I_blockchain_ux_user: I {}
public extension I_blockchain_ux_user {
	var `account`: L_blockchain_ux_user_account { .init("\(__).account") }
	var `activity`: L_blockchain_ux_user_activity { .init("\(__).activity") }
	var `KYC`: L_blockchain_ux_user_KYC { .init("\(__).KYC") }
	var `portfolio`: L_blockchain_ux_user_portfolio { .init("\(__).portfolio") }
	var `rewards`: L_blockchain_ux_user_rewards { .init("\(__).rewards") }
}
public final class L_blockchain_ux_user_account: L, I_blockchain_ux_user_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account", comment: "") }
}
public protocol I_blockchain_ux_user_account: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account {
	var `airdrops`: L_blockchain_ux_user_account_airdrops { .init("\(__).airdrops") }
	var `connect`: L_blockchain_ux_user_account_connect { .init("\(__).connect") }
	var `currency`: L_blockchain_ux_user_account_currency { .init("\(__).currency") }
	var `debit_card`: L_blockchain_ux_user_account_debit__card { .init("\(__).debit_card") }
	var `help`: L_blockchain_ux_user_account_help { .init("\(__).help") }
	var `linked`: L_blockchain_ux_user_account_linked { .init("\(__).linked") }
	var `notification`: L_blockchain_ux_user_account_notification { .init("\(__).notification") }
	var `profile`: L_blockchain_ux_user_account_profile { .init("\(__).profile") }
	var `rate`: L_blockchain_ux_user_account_rate { .init("\(__).rate") }
	var `security`: L_blockchain_ux_user_account_security { .init("\(__).security") }
	var `sign`: L_blockchain_ux_user_account_sign { .init("\(__).sign") }
	var `web`: L_blockchain_ux_user_account_web { .init("\(__).web") }
}
public final class L_blockchain_ux_user_account_airdrops: L, I_blockchain_ux_user_account_airdrops {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.airdrops", comment: "") }
}
public protocol I_blockchain_ux_user_account_airdrops: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_connect: L, I_blockchain_ux_user_account_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect: I {}
public extension I_blockchain_ux_user_account_connect {
	var `with`: L_blockchain_ux_user_account_connect_with { .init("\(__).with") }
}
public final class L_blockchain_ux_user_account_connect_with: L, I_blockchain_ux_user_account_connect_with {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with: I {}
public extension I_blockchain_ux_user_account_connect_with {
	var `exchange`: L_blockchain_ux_user_account_connect_with_exchange { .init("\(__).exchange") }
}
public final class L_blockchain_ux_user_account_connect_with_exchange: L, I_blockchain_ux_user_account_connect_with_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with.exchange", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with_exchange: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_connect_with_exchange {
	var `connect`: L_blockchain_ux_user_account_connect_with_exchange_connect { .init("\(__).connect") }
}
public final class L_blockchain_ux_user_account_connect_with_exchange_connect: L, I_blockchain_ux_user_account_connect_with_exchange_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with.exchange.connect", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with_exchange_connect: I {}
public final class L_blockchain_ux_user_account_currency: L, I_blockchain_ux_user_account_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency: I {}
public extension I_blockchain_ux_user_account_currency {
	var `native`: L_blockchain_ux_user_account_currency_native { .init("\(__).native") }
	var `trading`: L_blockchain_ux_user_account_currency_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_user_account_currency_native: L, I_blockchain_ux_user_account_currency_native {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.native", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_native: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_currency_native {
	var `select`: L_blockchain_ux_user_account_currency_native_select { .init("\(__).select") }
}
public final class L_blockchain_ux_user_account_currency_native_select: L, I_blockchain_ux_user_account_currency_native_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.native.select", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_native_select: I {}
public final class L_blockchain_ux_user_account_currency_trading: L, I_blockchain_ux_user_account_currency_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.trading", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_trading: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_currency_trading {
	var `select`: L_blockchain_ux_user_account_currency_trading_select { .init("\(__).select") }
}
public final class L_blockchain_ux_user_account_currency_trading_select: L, I_blockchain_ux_user_account_currency_trading_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.trading.select", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_trading_select: I {}
public final class L_blockchain_ux_user_account_debit__card: L, I_blockchain_ux_user_account_debit__card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.debit_card", comment: "") }
}
public protocol I_blockchain_ux_user_account_debit__card: I {}
public extension I_blockchain_ux_user_account_debit__card {
	var `order`: L_blockchain_ux_user_account_debit__card_order { .init("\(__).order") }
}
public final class L_blockchain_ux_user_account_debit__card_order: L, I_blockchain_ux_user_account_debit__card_order {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.debit_card.order", comment: "") }
}
public protocol I_blockchain_ux_user_account_debit__card_order: I {}
public final class L_blockchain_ux_user_account_help: L, I_blockchain_ux_user_account_help {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help", comment: "") }
}
public protocol I_blockchain_ux_user_account_help: I {}
public extension I_blockchain_ux_user_account_help {
	var `contact`: L_blockchain_ux_user_account_help_contact { .init("\(__).contact") }
	var `policy`: L_blockchain_ux_user_account_help_policy { .init("\(__).policy") }
	var `terms_and_conditions`: L_blockchain_ux_user_account_help_terms__and__conditions { .init("\(__).terms_and_conditions") }
}
public final class L_blockchain_ux_user_account_help_contact: L, I_blockchain_ux_user_account_help_contact {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.contact", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_contact: I {}
public extension I_blockchain_ux_user_account_help_contact {
	var `support`: L_blockchain_ux_user_account_help_contact_support { .init("\(__).support") }
}
public final class L_blockchain_ux_user_account_help_contact_support: L, I_blockchain_ux_user_account_help_contact_support {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.contact.support", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_contact_support: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_policy: L, I_blockchain_ux_user_account_help_policy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy: I {}
public extension I_blockchain_ux_user_account_help_policy {
	var `cookie`: L_blockchain_ux_user_account_help_policy_cookie { .init("\(__).cookie") }
	var `privacy`: L_blockchain_ux_user_account_help_policy_privacy { .init("\(__).privacy") }
}
public final class L_blockchain_ux_user_account_help_policy_cookie: L, I_blockchain_ux_user_account_help_policy_cookie {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy.cookie", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy_cookie: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_policy_privacy: L, I_blockchain_ux_user_account_help_policy_privacy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy.privacy", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy_privacy: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_terms__and__conditions: L, I_blockchain_ux_user_account_help_terms__and__conditions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.terms_and_conditions", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_terms__and__conditions: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_linked: L, I_blockchain_ux_user_account_linked {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked: I {}
public extension I_blockchain_ux_user_account_linked {
	var `accounts`: L_blockchain_ux_user_account_linked_accounts { .init("\(__).accounts") }
}
public final class L_blockchain_ux_user_account_linked_accounts: L, I_blockchain_ux_user_account_linked_accounts {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts: I {}
public extension I_blockchain_ux_user_account_linked_accounts {
	var `add`: L_blockchain_ux_user_account_linked_accounts_add { .init("\(__).add") }
}
public final class L_blockchain_ux_user_account_linked_accounts_add: L, I_blockchain_ux_user_account_linked_accounts_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts.add", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts_add: I {}
public extension I_blockchain_ux_user_account_linked_accounts_add {
	var `new`: L_blockchain_ux_user_account_linked_accounts_add_new { .init("\(__).new") }
}
public final class L_blockchain_ux_user_account_linked_accounts_add_new: L, I_blockchain_ux_user_account_linked_accounts_add_new {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts.add.new", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts_add_new: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_notification: L, I_blockchain_ux_user_account_notification {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification: I {}
public extension I_blockchain_ux_user_account_notification {
	var `email`: L_blockchain_ux_user_account_notification_email { .init("\(__).email") }
	var `push`: L_blockchain_ux_user_account_notification_push { .init("\(__).push") }
}
public final class L_blockchain_ux_user_account_notification_email: L, I_blockchain_ux_user_account_notification_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification.email", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification_email: I {}
public final class L_blockchain_ux_user_account_notification_push: L, I_blockchain_ux_user_account_notification_push {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification.push", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification_push: I {}
public final class L_blockchain_ux_user_account_profile: L, I_blockchain_ux_user_account_profile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile: I {}
public extension I_blockchain_ux_user_account_profile {
	var `email`: L_blockchain_ux_user_account_profile_email { .init("\(__).email") }
	var `limits`: L_blockchain_ux_user_account_profile_limits { .init("\(__).limits") }
	var `mobile`: L_blockchain_ux_user_account_profile_mobile { .init("\(__).mobile") }
	var `wallet`: L_blockchain_ux_user_account_profile_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_user_account_profile_email: L, I_blockchain_ux_user_account_profile_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.email", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_email: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_profile_email {
	var `change`: L_blockchain_ux_user_account_profile_email_change { .init("\(__).change") }
}
public final class L_blockchain_ux_user_account_profile_email_change: L, I_blockchain_ux_user_account_profile_email_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.email.change", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_email_change: I {}
public final class L_blockchain_ux_user_account_profile_limits: L, I_blockchain_ux_user_account_profile_limits {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.limits", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_limits: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_profile_mobile: L, I_blockchain_ux_user_account_profile_mobile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile: I {}
public extension I_blockchain_ux_user_account_profile_mobile {
	var `number`: L_blockchain_ux_user_account_profile_mobile_number { .init("\(__).number") }
}
public final class L_blockchain_ux_user_account_profile_mobile_number: L, I_blockchain_ux_user_account_profile_mobile_number {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile.number", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile_number: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_profile_mobile_number {
	var `verify`: L_blockchain_ux_user_account_profile_mobile_number_verify { .init("\(__).verify") }
}
public final class L_blockchain_ux_user_account_profile_mobile_number_verify: L, I_blockchain_ux_user_account_profile_mobile_number_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile.number.verify", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile_number_verify: I {}
public final class L_blockchain_ux_user_account_profile_wallet: L, I_blockchain_ux_user_account_profile_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet: I {}
public extension I_blockchain_ux_user_account_profile_wallet {
	var `id`: L_blockchain_ux_user_account_profile_wallet_id { .init("\(__).id") }
}
public final class L_blockchain_ux_user_account_profile_wallet_id: L, I_blockchain_ux_user_account_profile_wallet_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet.id", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet_id: I {}
public extension I_blockchain_ux_user_account_profile_wallet_id {
	var `copy`: L_blockchain_ux_user_account_profile_wallet_id_copy { .init("\(__).copy") }
}
public final class L_blockchain_ux_user_account_profile_wallet_id_copy: L, I_blockchain_ux_user_account_profile_wallet_id_copy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet.id.copy", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet_id_copy: I {}
public final class L_blockchain_ux_user_account_rate: L, I_blockchain_ux_user_account_rate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate: I {}
public extension I_blockchain_ux_user_account_rate {
	var `the`: L_blockchain_ux_user_account_rate_the { .init("\(__).the") }
}
public final class L_blockchain_ux_user_account_rate_the: L, I_blockchain_ux_user_account_rate_the {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate.the", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate_the: I {}
public extension I_blockchain_ux_user_account_rate_the {
	var `app`: L_blockchain_ux_user_account_rate_the_app { .init("\(__).app") }
}
public final class L_blockchain_ux_user_account_rate_the_app: L, I_blockchain_ux_user_account_rate_the_app {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate.the.app", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate_the_app: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security: L, I_blockchain_ux_user_account_security {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security", comment: "") }
}
public protocol I_blockchain_ux_user_account_security: I {}
public extension I_blockchain_ux_user_account_security {
	var `backup`: L_blockchain_ux_user_account_security_backup { .init("\(__).backup") }
	var `biometric`: L_blockchain_ux_user_account_security_biometric { .init("\(__).biometric") }
	var `change`: L_blockchain_ux_user_account_security_change { .init("\(__).change") }
	var `cloud`: L_blockchain_ux_user_account_security_cloud { .init("\(__).cloud") }
	var `synchronize`: L_blockchain_ux_user_account_security_synchronize { .init("\(__).synchronize") }
	var `two_factor_authentication`: L_blockchain_ux_user_account_security_two__factor__authentication { .init("\(__).two_factor_authentication") }
}
public final class L_blockchain_ux_user_account_security_backup: L, I_blockchain_ux_user_account_security_backup {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup: I {}
public extension I_blockchain_ux_user_account_security_backup {
	var `phrase`: L_blockchain_ux_user_account_security_backup_phrase { .init("\(__).phrase") }
}
public final class L_blockchain_ux_user_account_security_backup_phrase: L, I_blockchain_ux_user_account_security_backup_phrase {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_security_backup_phrase {
	var `verify`: L_blockchain_ux_user_account_security_backup_phrase_verify { .init("\(__).verify") }
	var `view`: L_blockchain_ux_user_account_security_backup_phrase_view { .init("\(__).view") }
	var `warning`: L_blockchain_ux_user_account_security_backup_phrase_warning { .init("\(__).warning") }
}
public final class L_blockchain_ux_user_account_security_backup_phrase_verify: L, I_blockchain_ux_user_account_security_backup_phrase_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.verify", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_verify: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_backup_phrase_view: L, I_blockchain_ux_user_account_security_backup_phrase_view {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.view", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_view: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_backup_phrase_warning: L, I_blockchain_ux_user_account_security_backup_phrase_warning {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.warning", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_warning: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_biometric: L, I_blockchain_ux_user_account_security_biometric {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.biometric", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_biometric: I {}
public final class L_blockchain_ux_user_account_security_change: L, I_blockchain_ux_user_account_security_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change: I {}
public extension I_blockchain_ux_user_account_security_change {
	var `password`: L_blockchain_ux_user_account_security_change_password { .init("\(__).password") }
	var `pin`: L_blockchain_ux_user_account_security_change_pin { .init("\(__).pin") }
}
public final class L_blockchain_ux_user_account_security_change_password: L, I_blockchain_ux_user_account_security_change_password {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change.password", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change_password: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_change_pin: L, I_blockchain_ux_user_account_security_change_pin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change.pin", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change_pin: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_cloud: L, I_blockchain_ux_user_account_security_cloud {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud: I {}
public extension I_blockchain_ux_user_account_security_cloud {
	var `backup`: L_blockchain_ux_user_account_security_cloud_backup { .init("\(__).backup") }
}
public final class L_blockchain_ux_user_account_security_cloud_backup: L, I_blockchain_ux_user_account_security_cloud_backup {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud.backup", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud_backup: I {}
public extension I_blockchain_ux_user_account_security_cloud_backup {
	var `enable`: L_blockchain_ux_user_account_security_cloud_backup_enable { .init("\(__).enable") }
}
public final class L_blockchain_ux_user_account_security_cloud_backup_enable: L, I_blockchain_ux_user_account_security_cloud_backup_enable {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud.backup.enable", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud_backup_enable: I {}
public final class L_blockchain_ux_user_account_security_synchronize: L, I_blockchain_ux_user_account_security_synchronize {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.synchronize", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_synchronize: I {}
public extension I_blockchain_ux_user_account_security_synchronize {
	var `widget`: L_blockchain_ux_user_account_security_synchronize_widget { .init("\(__).widget") }
}
public final class L_blockchain_ux_user_account_security_synchronize_widget: L, I_blockchain_ux_user_account_security_synchronize_widget {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.synchronize.widget", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_synchronize_widget: I {}
public final class L_blockchain_ux_user_account_security_two__factor__authentication: L, I_blockchain_ux_user_account_security_two__factor__authentication {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication: I {}
public extension I_blockchain_ux_user_account_security_two__factor__authentication {
	var `add`: L_blockchain_ux_user_account_security_two__factor__authentication_add { .init("\(__).add") }
	var `remove`: L_blockchain_ux_user_account_security_two__factor__authentication_remove { .init("\(__).remove") }
}
public final class L_blockchain_ux_user_account_security_two__factor__authentication_add: L, I_blockchain_ux_user_account_security_two__factor__authentication_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication.add", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication_add: I {}
public final class L_blockchain_ux_user_account_security_two__factor__authentication_remove: L, I_blockchain_ux_user_account_security_two__factor__authentication_remove {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication.remove", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication_remove: I {}
public final class L_blockchain_ux_user_account_sign: L, I_blockchain_ux_user_account_sign {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.sign", comment: "") }
}
public protocol I_blockchain_ux_user_account_sign: I {}
public extension I_blockchain_ux_user_account_sign {
	var `out`: L_blockchain_ux_user_account_sign_out { .init("\(__).out") }
}
public final class L_blockchain_ux_user_account_sign_out: L, I_blockchain_ux_user_account_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.sign.out", comment: "") }
}
public protocol I_blockchain_ux_user_account_sign_out: I {}
public final class L_blockchain_ux_user_account_web: L, I_blockchain_ux_user_account_web {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.web", comment: "") }
}
public protocol I_blockchain_ux_user_account_web: I {}
public extension I_blockchain_ux_user_account_web {
	var `login`: L_blockchain_ux_user_account_web_login { .init("\(__).login") }
}
public final class L_blockchain_ux_user_account_web_login: L, I_blockchain_ux_user_account_web_login {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.web.login", comment: "") }
}
public protocol I_blockchain_ux_user_account_web_login: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_activity: L, I_blockchain_ux_user_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.activity", comment: "") }
}
public protocol I_blockchain_ux_user_activity: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_KYC: L, I_blockchain_ux_user_KYC {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.KYC", comment: "") }
}
public protocol I_blockchain_ux_user_KYC: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_portfolio: L, I_blockchain_ux_user_portfolio {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.portfolio", comment: "") }
}
public protocol I_blockchain_ux_user_portfolio: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_rewards: L, I_blockchain_ux_user_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.rewards", comment: "") }
}
public protocol I_blockchain_ux_user_rewards: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_web: L, I_blockchain_ux_web {
	public override class var localized: String { NSLocalizedString("blockchain.ux.web", comment: "") }
}
public protocol I_blockchain_ux_web: I_blockchain_ux_type_story, I_blockchain_db_collection {}