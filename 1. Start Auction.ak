fn start_auction(
  nft_id: ByteArray,
  min_bid: Int,
  deadline: Int64,
  royalty_rate: Int,
  royalty_receiver: PubKeyHash
) -> Auction {
  Auction {
    nft_id,
    min_bid,
    current_bid: 0,    // No bid at the start
    bidder: None,
    deadline,
    royalty_rate,
    royalty_receiver,
  }
}
