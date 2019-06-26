import { withPluginApi } from "discourse/lib/plugin-api";

function initializeKeybaseProof(api) {
  
  // see app/assets/javascripts/discourse/lib/plugin-api
  // for the functions available via the api object
  
}

export default {
  name: "keybase-proofs",

  initialize() {
    withPluginApi("0.8", initializeKeybaseProof);
  }
};
