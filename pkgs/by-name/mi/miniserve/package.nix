{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  curl,
}:

rustPlatform.buildRustPackage rec {
  pname = "miniserve";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "svenstaro";
    repo = "miniserve";
    rev = "v${version}";
    hash = "sha256-jrQnmIYap5eHVWPqoRsXVroB0VWLKxesi3rB/WylR0U=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-SosRbtk5gBcOVropy+HVFFmLLexu29GjchC6zFweiYw=";

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = [
    curl
  ];

  checkFlags = [
    "--skip=bind_ipv4_ipv6::case_2"
    "--skip=qrcode_hidden_in_tty_when_disabled"
    "--skip=qrcode_shown_in_tty_when_enabled"
    "--skip=show_root_readme_contents"
    "--skip=validate_printed_urls"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/miniserve --print-manpage >miniserve.1
    installManPage miniserve.1

    installShellCompletion --cmd miniserve \
      --bash <($out/bin/miniserve --print-completions bash) \
      --fish <($out/bin/miniserve --print-completions fish) \
      --zsh <($out/bin/miniserve --print-completions zsh)
  '';

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "CLI tool to serve files and directories over HTTP";
    homepage = "https://github.com/svenstaro/miniserve";
    changelog = "https://github.com/svenstaro/miniserve/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ figsoda ];
    mainProgram = "miniserve";
  };
}
