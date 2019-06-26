import { defaultHomepage } from "discourse/lib/utilities";

export default Discourse.Route.extend({
  beforeModel(transition) {
    if (!Discourse.User.current()) {
      $.cookie("destination_url", window.location.href);
      return this.replaceWith("login");
    }
    this.replaceWith(`/${defaultHomepage()}`).then(e => {
      Ember.run.next(() => {
        this.controllerFor("new-proof").send("openModal", transition.to.params);
      });
    });
  },
});
