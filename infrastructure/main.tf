locals {
  zone_id = "be74919a1ccc6f1a63f1177777f3e604"
}

resource "cloudflare_zone" "zone" {
  zone = "filipstaffa.net"

  plan = "free"
}

resource "cloudflare_record" "cname_root" {
  zone_id = local.zone_id
  name    = "filipstaffa.net"
  type    = "CNAME"
  ttl     = "1"
  proxied = "true"
  value   = "filipstaffa.netlify.app"
}


resource "cloudflare_record" "cname_www" {
  zone_id = local.zone_id
  name    = "www.filipstaffa.net"
  type    = "CNAME"
  ttl     = "1"
  proxied = "true"
  value   = "filipstaffa.netlify.app"
}


resource "cloudflare_record" "dnslink_root" {
  zone_id = local.zone_id
  name    = "_dnslink"
  type    = "CNAME"
  ttl     = "60"
  proxied = "false"
  value   = "_dnslink.young-limit-4303.on.fleek.co"
}


resource "cloudflare_record" "dnslink_www" {
  zone_id = local.zone_id
  name    = "_dnslink.www"
  type    = "CNAME"
  ttl     = "60"
  proxied = "false"
  value   = "_dnslink.young-limit-4303.on.fleek.co"
}


resource "cloudflare_record" "mx" {
  zone_id  = local.zone_id
  name     = "filipstaffa.net"
  type     = "MX"
  ttl      = "1"
  proxied  = "false"
  priority = "10"
  value    = "mail.protonmail.ch"
}


resource "cloudflare_record" "txt_dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc.filipstaffa.net"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=DMARC1;p=reject;sp=none;pct=100;adkim=s;aspf=s;rua=mailto:easy484059@easydmarc.com,mailto:e80e9a1258f5771@rep.dmarcanalyzer.com;ruf=mailto:ruf@rep.easydmarc.com,mailto:e80e9a1258f5771@for.dmarcanalyzer.com;fo=1"
}


resource "cloudflare_record" "txt_protonmail_verification" {
  zone_id = local.zone_id
  name    = "filipstaffa.net"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "protonmail-verification=269d311bbc963f0a398a211d1ea45ccced71cc38"
}


resource "cloudflare_record" "txt_spf" {
  zone_id = local.zone_id
  name    = "filipstaffa.net"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=spf1 include:_spf.protonmail.ch mx ~all"
}


resource "cloudflare_record" "txt_dkim" {
  zone_id = local.zone_id
  name    = "protonmail._domainkey.filipstaffa.net"
  type    = "TXT"
  ttl     = "1"
  proxied = "false"
  value   = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeBs+tWlpsH0mkGEhxBw6tVGC6NGJLkVJrSI/OnrchAdyl+rsAsOxuOAguFQvO88busK0zu3Vwjf1ymabP4UQ8G13QT4oHNFxT1U3xRejjt3Fe8fLYvytPC1241EGkSRtJVs40mlHo2clCQse9nG7dnQooR+wG1RVOVr7xQBC+eQIDAQAB"
}

resource "cloudflare_zone_settings_override" "zone" {
  zone_id = "be74919a1ccc6f1a63f1177777f3e604"
  settings {
    brotli        = "on"
    rocket_loader = "on"

    always_use_https = "on"
    min_tls_version  = "1.2"
    ssl              = "strict"
    tls_1_3          = "on"
    http3            = "on"
    ipv6             = "on"

    security_header {
      enabled            = true
      include_subdomains = true
      max_age            = 31536000
      nosniff            = true
      preload            = true
    }
  }
}
