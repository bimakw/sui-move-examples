/*
 * Copyright (c) 2024 Bima Kharisma Wicaksana
 * GitHub: https://github.com/bimakw
 *
 * Licensed under MIT License with Attribution Requirement.
 * See LICENSE file for details.
 */

/// A simple escrow module for secure peer-to-peer trades.
/// Demonstrates object wrapping, capability pattern, and conditional transfers.
module sui_move_examples::escrow {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::event;

    /// Error codes
    const ENotSeller: u64 = 0;
    const ENotBuyer: u64 = 1;
    const EInsufficientPayment: u64 = 2;
    const EEscrowNotActive: u64 = 3;

    /// Escrow status
    const STATUS_ACTIVE: u8 = 0;
    const STATUS_COMPLETED: u8 = 1;
    const STATUS_CANCELLED: u8 = 2;

    /// Escrow object holding funds until conditions are met
    public struct Escrow has key {
        id: UID,
        seller: address,
        buyer: address,
        amount: Balance<SUI>,
        price: u64,
        status: u8,
    }

    /// Event emitted when escrow is created
    public struct EscrowCreated has copy, drop {
        escrow_id: ID,
        seller: address,
        buyer: address,
        price: u64,
    }

    /// Event emitted when escrow is completed
    public struct EscrowCompleted has copy, drop {
        escrow_id: ID,
        seller: address,
        buyer: address,
        amount: u64,
    }

    /// Event emitted when escrow is cancelled
    public struct EscrowCancelled has copy, drop {
        escrow_id: ID,
        refunded_to: address,
        amount: u64,
    }

    /// Create a new escrow agreement
    public entry fun create_escrow(
        buyer: address,
        price: u64,
        ctx: &mut TxContext
    ) {
        let seller = tx_context::sender(ctx);
        let escrow = Escrow {
            id: object::new(ctx),
            seller,
            buyer,
            amount: balance::zero(),
            price,
            status: STATUS_ACTIVE,
        };

        event::emit(EscrowCreated {
            escrow_id: object::id(&escrow),
            seller,
            buyer,
            price,
        });

        transfer::share_object(escrow);
    }

    /// Buyer deposits funds into escrow
    public entry fun deposit(
        escrow: &mut Escrow,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(escrow.status == STATUS_ACTIVE, EEscrowNotActive);
        assert!(tx_context::sender(ctx) == escrow.buyer, ENotBuyer);
        assert!(coin::value(&payment) >= escrow.price, EInsufficientPayment);

        let payment_balance = coin::into_balance(payment);
        balance::join(&mut escrow.amount, payment_balance);
    }

    /// Buyer confirms receipt, releasing funds to seller
    public entry fun confirm_receipt(
        escrow: &mut Escrow,
        ctx: &mut TxContext
    ) {
        assert!(escrow.status == STATUS_ACTIVE, EEscrowNotActive);
        assert!(tx_context::sender(ctx) == escrow.buyer, ENotBuyer);

        let amount = balance::value(&escrow.amount);
        let payment = coin::from_balance(balance::withdraw_all(&mut escrow.amount), ctx);

        escrow.status = STATUS_COMPLETED;

        event::emit(EscrowCompleted {
            escrow_id: object::id(escrow),
            seller: escrow.seller,
            buyer: escrow.buyer,
            amount,
        });

        transfer::public_transfer(payment, escrow.seller);
    }

    /// Cancel escrow and refund buyer (only seller can cancel)
    public entry fun cancel_escrow(
        escrow: &mut Escrow,
        ctx: &mut TxContext
    ) {
        assert!(escrow.status == STATUS_ACTIVE, EEscrowNotActive);
        assert!(tx_context::sender(ctx) == escrow.seller, ENotSeller);

        let amount = balance::value(&escrow.amount);

        if (amount > 0) {
            let refund = coin::from_balance(balance::withdraw_all(&mut escrow.amount), ctx);
            transfer::public_transfer(refund, escrow.buyer);
        };

        escrow.status = STATUS_CANCELLED;

        event::emit(EscrowCancelled {
            escrow_id: object::id(escrow),
            refunded_to: escrow.buyer,
            amount,
        });
    }

    /// View functions
    public fun get_price(escrow: &Escrow): u64 { escrow.price }
    public fun get_seller(escrow: &Escrow): address { escrow.seller }
    public fun get_buyer(escrow: &Escrow): address { escrow.buyer }
    public fun get_balance(escrow: &Escrow): u64 { balance::value(&escrow.amount) }
    public fun get_status(escrow: &Escrow): u8 { escrow.status }
}
