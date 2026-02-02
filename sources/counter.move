/*
 * Copyright (c) 2025 Bima Kharisma Wicaksana
 * GitHub: https://github.com/bimakw
 *
 * Licensed under MIT License with Attribution Requirement.
 * See LICENSE file for details.
 */

/// A simple counter module demonstrating basic Move concepts on Sui.
/// This module shows object creation, ownership, and state mutation.
module sui_move_examples::counter {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    /// Counter object that tracks a count value
    public struct Counter has key, store {
        id: UID,
        value: u64,
        owner: address,
    }

    /// Create a new counter with initial value of 0
    public fun create(ctx: &mut TxContext): Counter {
        Counter {
            id: object::new(ctx),
            value: 0,
            owner: tx_context::sender(ctx),
        }
    }

    /// Create and transfer counter to sender
    public entry fun create_counter(ctx: &mut TxContext) {
        let counter = create(ctx);
        transfer::transfer(counter, tx_context::sender(ctx));
    }

    /// Increment the counter by 1
    public entry fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    /// Increment the counter by a specific amount
    public entry fun increment_by(counter: &mut Counter, amount: u64) {
        counter.value = counter.value + amount;
    }

    /// Decrement the counter by 1 (will abort if value is 0)
    public entry fun decrement(counter: &mut Counter) {
        assert!(counter.value > 0, 0);
        counter.value = counter.value - 1;
    }

    /// Reset counter to 0
    public entry fun reset(counter: &mut Counter) {
        counter.value = 0;
    }

    /// Get the current value
    public fun value(counter: &Counter): u64 {
        counter.value
    }

    /// Get the owner address
    public fun owner(counter: &Counter): address {
        counter.owner
    }
}
