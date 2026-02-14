module sui_move_examples::simple_nft {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use sui::url::{Self, Url};
    use std::string::{Self, String};

    public struct NFT has key, store {
        id: UID,
        name: String,
        description: String,
        image_url: Url,
        creator: address,
    }

    public struct NFTMinted has copy, drop {
        nft_id: ID,
        name: String,
        creator: address,
        recipient: address,
    }

    public struct NFTTransferred has copy, drop {
        nft_id: ID,
        from: address,
        to: address,
    }

    public struct NFTBurned has copy, drop {
        nft_id: ID,
        owner: address,
    }

    public entry fun mint(
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let creator = tx_context::sender(ctx);
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            image_url: url::new_unsafe_from_bytes(image_url),
            creator,
        };

        event::emit(NFTMinted {
            nft_id: object::id(&nft),
            name: nft.name,
            creator,
            recipient,
        });

        transfer::public_transfer(nft, recipient);
    }

    public entry fun mint_to_self(
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        mint(name, description, image_url, sender, ctx);
    }

    public entry fun transfer_nft(
        nft: NFT,
        recipient: address,
        ctx: &TxContext
    ) {
        let sender = tx_context::sender(ctx);

        event::emit(NFTTransferred {
            nft_id: object::id(&nft),
            from: sender,
            to: recipient,
        });

        transfer::public_transfer(nft, recipient);
    }

    public entry fun burn(nft: NFT, ctx: &TxContext) {
        let sender = tx_context::sender(ctx);

        event::emit(NFTBurned {
            nft_id: object::id(&nft),
            owner: sender,
        });

        let NFT { id, name: _, description: _, image_url: _, creator: _ } = nft;
        object::delete(id);
    }

    public fun name(nft: &NFT): String { nft.name }
    public fun description(nft: &NFT): String { nft.description }
    public fun image_url(nft: &NFT): Url { nft.image_url }
    public fun creator(nft: &NFT): address { nft.creator }
}
