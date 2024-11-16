
test "Auction Workflow" {
  let auction = start_auction(
    nft_id: #deadbeef,
    min_bid: 100,
    deadline: 1690000000,
    royalty_rate: 5,
    royalty_receiver: #cafe1234
  );

  let updated_auction = submit_bid(
    auction,
    bid_amount: 150,
    bidder: #bidder123,
    current_time: 1689990000
  );

  let result = end_auction(updated_auction.unwrap());

  assert_eq(result.unwrap(), (#bidder123, 150, #cafe1234, 7));
}
