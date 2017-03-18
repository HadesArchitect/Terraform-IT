provider "digitalocean" {
  token = "DO_TOKEN"
}
resource "digitalocean_ssh_key" "default" {
  name = "Terraform"
  public_key = "${file("PATH_TO_KEY/id_rsa.pub")}"
}
