/* global BROWSER_RUNTIME */

let lib;
if (typeof BROWSER_RUNTIME != "undefined" && BROWSER_RUNTIME) {
  lib = require("@emurgo/cardano-serialization-lib-browser");
} else {
  lib = require("@emurgo/cardano-serialization-lib-nodejs");
}
lib = require("@mlabs-haskell/csl-gc-wrapper")(lib);

exports.freshPrivateKey = () => {
  return lib.PrivateKey.generate_ed25519();
};

exports._publicKeyFromBech32 = maybe => bech32 => {
  try {
    return maybe.just(lib.PublicKey.from_bech32(bech32));
  } catch (_) {
    return maybe.nothing;
  }
};

exports._publicKeyFromHex = maybe => hex => {
  try {
    return maybe.just(lib.PublicKey.from_hex(hex));
  } catch (_) {
    return maybe.nothing;
  }
};

exports._ed25519SignatureFromBech32 = maybe => bech32 => {
  try {
    return maybe.just(lib.Ed25519Signature.from_bech32(bech32));
  } catch (_) {
    return maybe.nothing;
  }
};

exports._ed25519SignatureFromHex = maybe => hex => {
  try {
    return maybe.just(lib.Ed25519Signature.from_hex(hex));
  } catch (_) {
    return maybe.nothing;
  }
};

exports._privateKeyFromBytes = maybe => bytes => {
  try {
    return maybe.just(lib.PrivateKey.from_normal_bytes(bytes));
  } catch (_) {
    return maybe.nothing;
  }
};

exports.privateKeyToBech32 = privateKey => privateKey.to_bech32();

exports._privateKeyFromBech32 = maybe => bech32 => {
  try {
    return maybe.just(lib.PrivateKey.from_bech32(bech32));
  } catch (_) {
    return maybe.nothing;
  }
};
