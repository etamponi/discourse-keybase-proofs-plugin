import { ajax } from "discourse/lib/ajax";
import {
  default as computed,
 } from "ember-addons/ember-computed-decorators";

export default Ember.Component.extend({
  signatures: [],
  username: null,

  init() {
    this._super(...arguments);
    ajax(`/keybase-proofs/proofs`, {
      type: "GET",
      data: { username: this.username },
    })
    .then((json) => {
      this.set("signatures", json.signatures);
    });

    this.revoke = this.revoke.bind(this);
  },

  revoke(signature) {
    const [...signatures] = this.get("signatures");
    ajax("/keybase-proofs/proofs", {
      type: "DELETE",
      data: { kb_username: signature.kb_username },
    })
    .then((json) => {
      signatures.splice(this.signatures.indexOf(signature), 1);
      this.set("signatures", signatures);
      console.log("revoked", json);
    });
  },

});
