export default {
  shouldRender(_, ctx) {
    return ctx.siteSettings.keybase_proofs_enabled;
  }
};
