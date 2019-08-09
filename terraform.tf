variable "do_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}


provider "digitalocean" {
  token = "${var.do_token}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}


data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "droplet" {
  image  = "docker-18-04"
  name   = "droplet"
  region = "fra1"
  size   = "s-1vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
}

resource "cloudflare_record" "droplet" {
  domain = "sikademo.com"
  name   = "droplet"
  value  = "${digitalocean_droplet.droplet.ipv4_address}"
  type   = "A"
  proxied = false
}


resource "cloudflare_record" "droplet_wildcard" {
  domain = "sikademo.com"
  name   = "*.droplet"
  value  = "droplet.sikademo.com"
  type   = "CNAME"
  proxied = false
}
