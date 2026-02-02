/*
 * Copyright (c) 2025 Bima Kharisma Wicaksana
 * GitHub: https://github.com/bimakw
 *
 * Licensed under MIT License with Attribution Requirement.
 * See LICENSE file for details.
 */

/// A greeting module demonstrating string handling and events in Move.
module sui_move_examples::greeting {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use std::string::{Self, String};

    /// Greeting object that stores a message
    public struct Greeting has key, store {
        id: UID,
        message: String,
        author: address,
    }

    /// Event emitted when a greeting is created
    public struct GreetingCreated has copy, drop {
        greeting_id: address,
        message: String,
        author: address,
    }

    /// Event emitted when a greeting is updated
    public struct GreetingUpdated has copy, drop {
        greeting_id: address,
        old_message: String,
        new_message: String,
    }

    /// Create a new greeting with a message
    public entry fun create_greeting(message: vector<u8>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let greeting = Greeting {
            id: object::new(ctx),
            message: string::utf8(message),
            author: sender,
        };

        event::emit(GreetingCreated {
            greeting_id: object::uid_to_address(&greeting.id),
            message: greeting.message,
            author: sender,
        });

        transfer::transfer(greeting, sender);
    }

    /// Update the greeting message
    public entry fun update_greeting(greeting: &mut Greeting, new_message: vector<u8>) {
        let old_message = greeting.message;
        greeting.message = string::utf8(new_message);

        event::emit(GreetingUpdated {
            greeting_id: object::uid_to_address(&greeting.id),
            old_message,
            new_message: greeting.message,
        });
    }

    /// Get the message
    public fun message(greeting: &Greeting): String {
        greeting.message
    }

    /// Get the author
    public fun author(greeting: &Greeting): address {
        greeting.author
    }
}
