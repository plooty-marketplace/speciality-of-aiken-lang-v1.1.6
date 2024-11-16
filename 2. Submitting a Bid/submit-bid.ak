fn submit_bid(
  auction: Auction,
  bid_amount: Int,
  bidder: PubKeyHash,
  current_time: Int64
) -> Option<Auction> {
  if current_time > auction.deadline || bid_amount <= auction.current_bid {
    None
  } else {
    Some(Auction {
      nft_id: auction.nft_id,
      min_bid: auction.min_bid,
      current_bid: bid_amount,
      bidder: Some(bidder),
      deadline: auction.deadline,
      royalty_rate: auction.royalty_rate,
      royalty_receiver: auction.royalty_receiver,
    })
  }
}
