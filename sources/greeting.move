module sui_move_examples::greeting {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use std::string::{Self, String};

    public struct Greeting has key, store {
        id: UID,
        message: String,
        author: address,
    }

    public struct GreetingCreated has copy, drop {
        greeting_id: address,
        message: String,
        author: address,
    }

    public struct GreetingUpdated has copy, drop {
        greeting_id: address,
        old_message: String,
        new_message: String,
    }

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

    public entry fun update_greeting(greeting: &mut Greeting, new_message: vector<u8>) {
        let old_message = greeting.message;
        greeting.message = string::utf8(new_message);

        event::emit(GreetingUpdated {
            greeting_id: object::uid_to_address(&greeting.id),
            old_message,
            new_message: greeting.message,
        });
    }

    public fun message(greeting: &Greeting): String {
        greeting.message
    }

    public fun author(greeting: &Greeting): address {
        greeting.author
    }
}
