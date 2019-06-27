export default Discourse.Route.extend({
  beforeModel(transition) {
    if (!this.currentUser) {
      $.cookie("destination_url", window.location.href);
      this.replaceWith("login");
      return;
    }
    this.controllerFor("new-proof").send("openModal", transition.to.queryParams);
  },
});
