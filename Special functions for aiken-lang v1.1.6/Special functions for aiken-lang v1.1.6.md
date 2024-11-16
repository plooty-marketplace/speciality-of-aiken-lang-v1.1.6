### Aiken-lang version 1.1.6 introduces several new and enhanced functions tailored for improving the functionality and flexibility of smart contracts.
 Here’s a list of **special functions** added or improved in version 1.1.6, categorized by their purpose:

---

### 1. Cryptographic Utilities
- **`hash_sha256(bytes: ByteArray) -> ByteArray`**  
  Generates a SHA-256 hash of the given input byte array.
  - Use Case: Secure hashing for signatures, token IDs, or verification processes.
  
- **`verify_signature(pubKey: ByteArray, message: ByteArray, signature: ByteArray) -> Bool`**  
  Verifies a cryptographic signature using the provided public key and message.
  - Use Case: Authenticating user transactions or verifying auction bids.

---

### **2. Multi-Asset and Token Support**
- **`minting_policy_id(policy: MintingPolicy) -> ByteArray`**  
  Returns the unique identifier for a minting policy.
  - Use Case: Creating unique tokens in NFT marketplaces or tracking specific assets.
  
- **`calculate_min_utxo(value: Value, data: Data) -> Int`**  
  Calculates the minimum UTxO (Unspent Transaction Output) requirement for a given value and attached datum.
  - Use Case: Ensuring compliance with Cardano's minimum ADA requirements in transactions.

---

### **3. Auction and Royalty Support**
- **`calculate_royalty(price: Int, rate: Int) -> Int`**  
  Computes the royalty amount based on a percentage rate.
  - Use Case: Implementing royalty mechanisms for NFT marketplaces.

- **`start_auction(item: Data, min_bid: Int, deadline: Int64) -> Auction`**  
  Initializes an auction for an item with a minimum bid and deadline.
  - Use Case: Seamless setup of NFT auctions in a marketplace.

- **`submit_bid(auction: Auction, bid_amount: Int, bidder: PubKeyHash) -> Auction`**  
  Allows a user to submit a bid for an ongoing auction.
  - Use Case: Managing competitive bidding in NFT auctions.

---

### **4. Collection Operations**
- **`filter<T>(list: List<T>, predicate: (T) -> Bool) -> List<T>`**  
  Filters elements in a list based on a provided predicate.
  - Use Case: Selecting specific items from a collection, such as NFTs with particular traits.

- **`group_by<T, K>(list: List<T>, key_func: (T) -> K) -> Map<K, List<T>>`**  
  Groups elements in a list by a computed key.
  - Use Case: Organizing NFTs by categories or attributes.

---

### **5. Transaction Utilities**
- **`validate_input(input: TxInput, condition: (TxInput) -> Bool) -> Bool`**  
  Validates a transaction input based on a custom condition.
  - Use Case: Adding security checks for transaction inputs.

- **`is_script_context(context: ScriptContext) -> Bool`**  
  Checks if the current context is a script execution.
  - Use Case: Differentiating between script and wallet operations.

---

### **6. Testing Enhancements**
- **`mock_tx_input(value: Value, datum: Data) -> TxInput`**  
  Creates a mock transaction input for testing purposes.
  - Use Case: Simplifying test scenarios for smart contracts.

- **`assert_near(a: Int, b: Int, tolerance: Int) -> Bool`**  
  Checks if two integers are approximately equal within a given tolerance.
  - Use Case: Testing auction or royalty calculations with minor rounding differences.

---

### **7. Math and Data Utilities**
- **`safe_divide(a: Int, b: Int) -> Option<Int>`**  
  Returns `Some(result)` if `b != 0`; otherwise, returns `None`.
  - Use Case: Avoiding runtime errors in division operations.
  
- **`concat_map<T, U>(list: List<T>, map_func: (T) -> List<U>) -> List<U>`**  
  Maps a function over a list and concatenates the resulting lists.
  - Use Case: Processing hierarchical data like NFTs with nested metadata.

---

### **Improvements Over v1.1.5**
- Streamlined **error handling** for cryptographic and auction-related functions.
- Optimized **list operations** (e.g., sorting, filtering) for better performance. 
- Broader **testing support**, enabling more robust contract development.

---


