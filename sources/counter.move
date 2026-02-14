module sui_move_examples::counter {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    public struct Counter has key, store {
        id: UID,
        value: u64,
        owner: address,
    }

    public fun create(ctx: &mut TxContext): Counter {
        Counter {
            id: object::new(ctx),
            value: 0,
            owner: tx_context::sender(ctx),
        }
    }

    public entry fun create_counter(ctx: &mut TxContext) {
        let counter = create(ctx);
        transfer::transfer(counter, tx_context::sender(ctx));
    }

    public entry fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    public entry fun increment_by(counter: &mut Counter, amount: u64) {
        counter.value = counter.value + amount;
    }

    public entry fun decrement(counter: &mut Counter) {
        assert!(counter.value > 0, 0);
        counter.value = counter.value - 1;
    }

    public entry fun reset(counter: &mut Counter) {
        counter.value = 0;
    }

    public fun value(counter: &Counter): u64 {
        counter.value
    }

    public fun owner(counter: &Counter): address {
        counter.owner
    }
}
