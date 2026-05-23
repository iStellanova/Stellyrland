{
  self,
  inputs,
  ...
}: {
  _module.args = {
    nixosIdentity = self.lib.mkIdentity inputs.stellyrdata false;
    darwinIdentity = self.lib.mkIdentity inputs.stellyrdata true;
  };
}
