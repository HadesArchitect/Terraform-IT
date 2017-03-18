output "AWS Voting IP" {
  value = "${aws_eip.voting_ip.public_ip}"
}
output "DO Voting IP" {
  value = "${digitalocean_droplet.voting.ipv4_address}"
}
output "AWS Result IP" {
  value = "${aws_eip.result_ip.public_ip}"
}
output "DO Result IP" {
  value = "${digitalocean_droplet.result.ipv4_address}"
}
