import {
  default as computed,
 } from "ember-addons/ember-computed-decorators";

export default Ember.Component.extend({
  username: null,
  signature: null,
  revoke: null,

  @computed("signature")
  keybaseUrl() {
    const {kb_username, sig_hash} = this.signature;
    return `https://keybase.io/${kb_username}/sigs/${sig_hash}`;
  },

  @computed("signature", "username")
  keybaseStatusUrl() {
    const {kb_username, sig_hash} = this.signature;
    return `https://keybase.io/${kb_username}/proof_badge/${sig_hash}?domain=${location.hostname}&username=${this.username}`;
  },

  @computed("username")
  visitingOwnProfile() {
    return Discourse.User.current() && Discourse.User.current().username === this.username;
  },

  actions: {
    revoke() {
      this.get("revoke")(this.signature);
    }
  },

});
