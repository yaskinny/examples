build {
  sources = [
    "source.amazon-ebs.app",
  ]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/main.yaml"
  }
}
