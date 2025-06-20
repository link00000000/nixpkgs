{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  karmor,
}:

buildGoModule rec {
  pname = "karmor";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "kubearmor";
    repo = "kubearmor-client";
    rev = "v${version}";
    hash = "sha256-+Zk1tPZAk3rQ1ZfdNAPEvtjm0mdsWRELbRctlulvFnE=";
  };

  vendorHash = "sha256-4F/q6vYOGtLef+rrJXKhLwjM71NMNI4es4dKe1pohZU=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.BuildDate=1970-01-01"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.GitSummary=${version}"
  ];

  # integration tests require network access
  doCheck = false;

  postInstall = ''
    mv $out/bin/{kubearmor-client,karmor}
    installShellCompletion --cmd karmor \
      --bash <($out/bin/karmor completion bash) \
      --fish <($out/bin/karmor completion fish) \
      --zsh  <($out/bin/karmor completion zsh)
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = karmor;
      command = "karmor version || true";
    };
  };

  meta = {
    description = "Client tool to help manage KubeArmor";
    mainProgram = "karmor";
    homepage = "https://kubearmor.io";
    changelog = "https://github.com/kubearmor/kubearmor-client/releases/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      urandom
      kashw2
    ];
  };
}
