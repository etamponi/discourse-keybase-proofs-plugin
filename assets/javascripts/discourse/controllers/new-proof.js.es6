import { renderAvatar } from "discourse/helpers/user-avatar";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import showModal from "discourse/lib/show-modal";
import ModalFunctionality from "discourse/mixins/modal-functionality";

export default Ember.Controller.extend(ModalFunctionality, {
  kbPicUrl: "",
  kbUsername: "",
  sigHash: "",
  kbUA: "",

  get current() {
    return Discourse.User.current() || {};
  },

  get currentUsername() {
    return this.current.username;
  },

  get renderCurrentUserAvatar() {
    return renderAvatar(this.current, {
      imageSize: 60,
    });
  },

  get discourseDomain() {
    return location.hostname;
  },

  actions: {
    authorize() {
      console.log("OK, let's authorize...");
      ajax(`/keybase-proofs/proofs`, {
        type: "POST",
        data: {
          kb_username: this.kbUsername,
          sig_hash: this.sigHash,
        },
      })
      .then(() => {
        window.location.href = `https://keybase.io/_/proof_creation_success?domain=${location.hostname}&kb_username=${this.kbUsername}&username=${this.currentUsername}&sig_hash=${this.sigHash}&kb_ua=${this.kbUA}`;
      })
      .catch((e) => {
        this.send("closeModal");
        popupAjaxError(e);
      });
    },

    cancel() {
      console.log("OK, let's cancel...");
      this.send("closeModal");
    },

    openModal(query) {
      this.set("kbUsername", query.kb_username);
      this.set("sigHash", query.sig_hash);
      this.set("kbUA", query.kb_ua);

      ajax("/keybase-proofs/pic-url", {
        type: "GET",
        data: { kb_username: this.kbUsername },
      })
      .then((json) => {
        this.set("kbPicUrl", json.pic_url);
        showModal("new-proof");
      });
    },
  },
});
