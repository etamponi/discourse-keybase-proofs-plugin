export default Discourse.Route.extend({
  beforeModel(transition) {
    if (!Discourse.User.current()) {
      $.cookie("destination_url", window.location.href);
      return this.replaceWith("login");
    }
    this.controllerFor("new-proof").send("openModal", transition.to.queryParams);
  },
});
