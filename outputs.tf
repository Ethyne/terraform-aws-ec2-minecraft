output "public_ip" {
  description = "Outputs the public IP which users can connect to"
  value = aws_instance.minecraft.public_ip  
}
