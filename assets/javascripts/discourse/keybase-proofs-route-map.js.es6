export default function() {
  this.route("new-proof", {
    path: "/keybase-proofs/new-proof/:username/:kb_username/:sig_hash",
  });
}
