let
  # hokey-pokey webservice
  hokey-pokey = builtins.fetchTarball {
    url = "https://github.com/input-output-hk/hokey-pokey/archive/a092b18.tar.gz";
    # nix-prefetch-url --unpack https://github.com/input-output-hk/hokey-pokey/archive/a092b18.tar.gz
    sha256 = "0n9gwhis5d290vwljwxqmbbvh9npvs0s5wnqrcnx6i355rh5v20p";
  };
in

{ config, pkgs, ... }:
{
    imports = [ (hokey-pokey + "/module.nix") ];

    services.hokey-pokey.enable = true;

    security.acme.email = "moritz.angermann@iohk.io";
    security.acme.acceptTerms = true;

    services.nginx = {
        enable = true;
        virtualHosts = {
            "hokey-pokey.loony-tools.dev.iohkdev.io" = {
                enableACME = true;
                default = true;
                locations."/".proxyPass = "http://127.0.0.1:8080";
                basicAuthFile = ../secrets/hokey-pokey-auth.htpasswd;
                # proxyWebsockets = true;
            };
            "cache.loony-tools.dev.iohkdev.io" = {
                enableACME = true;
                locations."/".extraConfig = ''
                    proxy_pass http://localhost:${toString config.services.nix-serve.port};
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                '';
            };
        };
    };
}