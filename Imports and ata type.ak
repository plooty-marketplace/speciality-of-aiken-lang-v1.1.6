import aiken/collections/list
import aiken/collections/map

type Auction {
  nft_id: ByteArray
  min_bid: Int
  current_bid: Int
  bidder: Option<PubKeyHash>
  deadline: Int64
  royalty_rate: Int
  royalty_receiver: PubKeyHash
}
