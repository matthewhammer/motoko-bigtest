/* TEMP file

 Demonstrates a minimal BigMap service via the Motoko CRUD package.

 to do -- Replace with the real BigMap service, when available.
*/

import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Prim "mo:prim";

import Database "mo:crud/Database";

actor {
  public type Key = [Nat8];
  public type Val = [Nat8];

  var nextKey : ?[Nat8] = null;

  func keyEqual(x : Key, y : Key) : Bool {
    switch (keyCompare(x, y)) {
    case (#equal) true;
    case _ false;
    }
  };

  // to do -- add a generic version to base package
  func keyCompare(x : Key, y : Key) : Order.Order {
    switch (Nat.compare(x.size(), y.size())) {
      case (#less) #less;
      case (#greater) #greater;
      case (#equal) {
        for (i in x.keys()) {
          if (x[i] < y[i]) return #less
          else if (x[i] > y[i]) return #greater
          else { }
        };
        return #equal
      };
    }
  };

  func keyHash(x : Key) : Word32 {
    let blowup : Nat8 -> Word32 = func (x) {
      Prim.natToWord32(Prim.nat8ToNat(x))
    };
    // to do -- use all bits in the final hash, not just the first ones
    switch (x.size()) {
      case 0 0;
      case 1 blowup(x[1]);
      case 2 { blowup(x[0]) << 0 +
                 blowup(x[1]) << 8 };
      case 3 { blowup(x[0]) << 0 +
                 blowup(x[1]) << 8 +
                 blowup(x[2]) << 16 };
      case _ {
             blowup(x[0]) << 24 +
               blowup(x[1]) << 16 +
               blowup(x[2]) << 8 +
               blowup(x[3])
           }
    }
  };

  var db = Database.Database<Key, Val>(
    func (_, _) : Key {
      switch nextKey {
        case null { assert false; loop { } };
        case (?x) x
      }},
    keyEqual,
    #hash(keyHash),
  );

  public func put(k:Key, v:Val) : async () {
    // to do -- for now, we communicate the key via mutation (ugly).
    nextKey := ?k;
    let _ = db.create(v);
  };

  public func get(k:Key) : async ?Val {
    switch (db.read(k)) {
      case (#ok(v)) ?v;
      case (#err(_)) null;
    }
  };

}
