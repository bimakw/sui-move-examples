module sui_move_examples::whitelist {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::event;

    const ENotAdmin: u64 = 0;
    const EAlreadyWhitelisted: u64 = 1;
    const ENotWhitelisted: u64 = 2;

    public struct AdminCap has key, store {
        id: UID,
    }

    public struct Whitelist has key {
        id: UID,
        addresses: Table<address, bool>,
        count: u64,
    }

    public struct AddressAdded has copy, drop {
        address: address,
        added_by: address,
    }

    public struct AddressRemoved has copy, drop {
        address: address,
        removed_by: address,
    }

    fun init(ctx: &mut TxContext) {
        let admin = AdminCap {
            id: object::new(ctx),
        };

        let whitelist = Whitelist {
            id: object::new(ctx),
            addresses: table::new(ctx),
            count: 0,
        };

        transfer::transfer(admin, tx_context::sender(ctx));
        transfer::share_object(whitelist);
    }

    public entry fun add_address(
        _admin: &AdminCap,
        whitelist: &mut Whitelist,
        addr: address,
        ctx: &TxContext
    ) {
        assert!(!table::contains(&whitelist.addresses, addr), EAlreadyWhitelisted);

        table::add(&mut whitelist.addresses, addr, true);
        whitelist.count = whitelist.count + 1;

        event::emit(AddressAdded {
            address: addr,
            added_by: tx_context::sender(ctx),
        });
    }

    public entry fun remove_address(
        _admin: &AdminCap,
        whitelist: &mut Whitelist,
        addr: address,
        ctx: &TxContext
    ) {
        assert!(table::contains(&whitelist.addresses, addr), ENotWhitelisted);

        table::remove(&mut whitelist.addresses, addr);
        whitelist.count = whitelist.count - 1;

        event::emit(AddressRemoved {
            address: addr,
            removed_by: tx_context::sender(ctx),
        });
    }

    public fun is_whitelisted(whitelist: &Whitelist, addr: address): bool {
        table::contains(&whitelist.addresses, addr)
    }

    public fun count(whitelist: &Whitelist): u64 {
        whitelist.count
    }

    public entry fun transfer_admin(admin: AdminCap, recipient: address) {
        transfer::transfer(admin, recipient);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
}
